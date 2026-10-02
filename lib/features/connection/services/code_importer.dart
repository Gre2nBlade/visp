import 'dart:convert';

import '../models/connection_models.dart';

/// Что именно введено в поле подключения (раздел 2.4): приложение само
/// определяет формат и предлагает соответствующее действие.
enum ImportKind {
  /// Оффлайн-код, до 4 подключений, параметры внутри кода (раздел 2.1).
  vispOffline,

  /// Серверный управляемый код VISP-****-**** + visp.to/... (раздел 2.2).
  vispServer,

  /// Ссылка протокола: vless://, hysteria2://, ss://, trojan://, vmess://.
  protocolLink,

  /// Подписка: base64, Clash YAML, sing-box/Xray JSON.
  subscription,

  /// Telegram-прокси: tg://proxy, t.me/proxy, t.me/webproxy.
  telegramProxy,

  /// Секретный код активации роли разработчика (раздел 13.2).
  devActivation,

  unknown,
}

/// Одна запись предварительного просмотра импорта (раздел 2.7).
class PreviewEntry {
  final String id;
  final String title;
  final String subtitle;
  final Protocol? protocol;
  final ProxyType? proxyType;

  /// Движок отсутствует — профиль сохранится со статусом «Нужен модуль».
  final bool needsModule;

  /// Распарсенные параметры подключения (для vless/hysteria2/конфигов).
  final ProtocolConfig? config;

  /// Прокси-запись плагина «Прокси для Telegram».
  final bool isProxy;
  final bool selected;

  const PreviewEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    this.protocol,
    this.proxyType,
    this.needsModule = false,
    this.config,
    this.isProxy = false,
    this.selected = true,
  });

  PreviewEntry copyWith({
    String? id,
    String? title,
    String? subtitle,
    Protocol? protocol,
    ProxyType? proxyType,
    bool? needsModule,
    ProtocolConfig? config,
    bool? isProxy,
    bool? selected,
  }) {
    return PreviewEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      protocol: protocol ?? this.protocol,
      proxyType: proxyType ?? this.proxyType,
      needsModule: needsModule ?? this.needsModule,
      config: config ?? this.config,
      isProxy: isProxy ?? this.isProxy,
      selected: selected ?? this.selected,
    );
  }
}

/// Результат распознавания введённого кода.
class ImportPreview {
  final ImportKind kind;
  final String title;
  final String sourceLabel;
  final List<PreviewEntry> entries;

  /// Правила маршрутизации в составе кода (раздел 7.4).
  final bool hasRoutingRules;
  final String? error;

  const ImportPreview({
    required this.kind,
    required this.title,
    required this.sourceLabel,
    required this.entries,
    this.hasRoutingRules = false,
    this.error,
  });

  int get selectedCount => entries.where((e) => e.selected).length;
}

/// Распознавание и разбор кодов/ссылок/подписок.
///
/// Сетевая ошибка не выдаётся за неверный код, а неизвестный формат не
/// угадывается: возвращается понятное сообщение (раздел 2.7).
class CodeImporter {
  CodeImporter._();

  static final RegExp _vispServerCode = RegExp(r'^VISP-[A-Z0-9]{4}-[A-Z0-9]{4}$');
  static final RegExp _devCode = RegExp(r'^VISPDV-[A-Z0-9]{6,}$');

  static bool isValidDevCode(String input) => _devCode.hasMatch(input.trim());

  static ImportPreview parse(String rawInput) {
    final input = rawInput.trim();
    if (input.isEmpty) {
      return const ImportPreview(
        kind: ImportKind.unknown,
        title: '',
        sourceLabel: '',
        entries: [],
      );
    }

    if (isValidDevCode(input)) {
      return ImportPreview(
        kind: ImportKind.devActivation,
        title: 'Код активации роли разработчика',
        sourceLabel: 'Секретный код',
        entries: [],
      );
    }

    final lower = input.toLowerCase();
    final trimmed = input.trimLeft();
    if (lower.startsWith('visp://')) {
      return _parseVispOffline(input);
    }
    if (_vispServerCode.hasMatch(input)) {
      return _parseVispServer(input);
    }
    if (lower.startsWith('tg://proxy') ||
        lower.startsWith('https://t.me/proxy') ||
        lower.startsWith('https://t.me/webproxy') ||
        lower.startsWith('t.me/proxy') ||
        lower.startsWith('t.me/webproxy')) {
      return _parseTelegramProxy(input);
    }

    final protocol = _protocolOf(lower);
    // JSON-подобное содержимое проверяем до схем: sing-box/Xray начинаются с «{».
    if (trimmed.startsWith('{')) {
      return _parseSubscription(input);
    }

    // WireGuard/AmneziaWG добавляются конфигурационным файлом (раздел 2.4).
    if (_looksLikeWireGuardConf(input)) {
      return parseConfig(input);
    }

    // Ссылка на подписку — это адрес, а не содержимое. Разбирать её нечем
    // без загрузки, поэтому честно объясняем, что нужно.
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return ImportPreview(
        kind: ImportKind.unknown,
        title: 'Нужна подписка или её содержимое',
        sourceLabel: '',
        entries: const [],
        error: 'Это адрес подписки, а не её содержимое. Откройте ссылку и '
            'вставьте полученный список кодов, либо экспортируйте подписку в файл.',
      );
    }

    // Одна схема в начале — обычная ссылка протокола.
    if (protocol != null && !input.contains('\n')) {
      return _parseProtocolLink(input, protocol);
    }

    // Многострочный ввод: список ссылок или подписка целиком.
    if (input.contains('\n') || input.contains('\r')) {
      return _parseSubscription(input);
    }

    // Быть может, это base64-подписка без схемы.
    if (_looksLikeBase64(input)) {
      return _parseSubscription(input, decoded: true);
    }

    // Одиночная ссылка протокола, разбор которой не сработал выше.
    if (protocol != null) {
      return _parseProtocolLink(input, protocol);
    }

    return ImportPreview(
      kind: ImportKind.unknown,
      title: 'Неизвестный формат',
      sourceLabel: '',
      entries: [],
      error: _unknownFormatError(input),
    );
  }

  /// Подсказка вместо общего отказа: если введено похожее на протокол или на
  /// код слово, объясняем, что именно ожидалось (раздел 2.7 — не угадывать).
  static String _unknownFormatError(String input) {
    final lower = input.toLowerCase().trim();
    for (final hint in _protocolHints) {
      if (lower.contains(hint.$1)) {
        return hint.$2;
      }
    }
    if (lower.contains('wireguard') || lower.contains('amnezia')) {
      return 'AmneziaWG и WireGuard добавляются конфигурационным файлом '
          '(раздел [Interface]/[Peer]) или кодом VISP-****-****';
    }
    return 'Нужен код VISP-****-****, ссылка протокола (vless://, hysteria2://, '
        'olcrtc://), конфигурационный файл или подписка';
  }

  /// Подсказки для похожих, но неверных вводов.
  static const List<(String, String)> _protocolHints = [
    ('vless', 'Для VLESS нужен код вида vless://…@host:443?…#Название'),
    ('vmess', 'Для VMess нужен код вида vmess://… с base64 внутри'),
    ('vpn://', 'vpn:// не является единым стандартом. Нужен код конкретного '
        'протокола: vless://, hysteria2://, olcrtc://'),
    ('hysteria', 'Для Hysteria 2 нужен код вида hysteria2://host:8443/?auth=…'),
    ('ss://', 'Shadowsocks добавляется совместимым движком позже. '
        'Пока доступен код ss:// как подписка'),
    ('trojan', 'Для Trojan нужен код вида trojan://…@host:443#Название'),
  ];

  static Protocol? _protocolOf(String lower) {
    // Схемы перечислены явно и только те, где протокол известен из самой
    // ссылки. Общая схема vpn:// намеренно отсутствует: она не является
    // единым стандартом, и приравнивать её к VLESS значило бы угадывать
    // (раздел 2.2). Для неё есть отдельная подсказка в _protocolHints.
    for (final entry in const [
      ('vless://', Protocol.xrayVless),
      ('vmess://', Protocol.vmess),
      ('trojan://', Protocol.trojan),
      ('hysteria2://', Protocol.hysteria2),
      ('hy2://', Protocol.hysteria2),
      ('ss://', Protocol.shadowsocks),
      ('olcrtc://', Protocol.olcRtc),
      ('webrtc://', Protocol.olcRtc),
      ('wireguard://', Protocol.wireGuard),
      ('awg://', Protocol.amneziaWG),
      ('amneziawg://', Protocol.amneziaWG),
    ]) {
      if (lower.startsWith(entry.$1)) return entry.$2;
    }
    return null;
  }

  static bool _looksLikeBase64(String input) {
    // Проверяем через саму расшифровку, а не по длине: подписки часто
    // приходят без padding, и проверка «длина кратна 4» их отбрасывала.
    if (_tryDecodeBase64Body(input) == null) return false;
    final cleaned = input.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length < 16) return false;
    if (RegExp(r'^[a-zA-Z0-9+/=:\-_\s]+$').hasMatch(cleaned) == false) {
      return false;
    }
    try {
      final decoded = utf8.decode(base64.decode(_normalizeBase64(cleaned)));
      return decoded.contains('://') || decoded.contains('proxies:');
    } catch (_) {
      return false;
    }
  }

  /// Дополняет base64 до длины, кратной четырём, и допускает URL-безопасный алфавит.
  static String _normalizeBase64(String input) {
    var cleaned = input.replaceAll(RegExp(r'\s'), '');
    cleaned = cleaned.replaceAll('-', '+').replaceAll('_', '/');
    final padding = (4 - cleaned.length % 4) % 4;
    return cleaned + ('=' * padding);
  }

  /// Оффлайн-код: параметры подключения внутри кода, до 4 подключений.
  static ImportPreview _parseVispOffline(String input) {
    final payload = input.substring('visp://'.length);
    final lower = payload.toLowerCase();

    final candidates = <Protocol>[];
    if (lower.contains('awg') || lower.contains('amnezia')) candidates.add(Protocol.amneziaWG);
    if (lower.contains('hys') || lower.contains('hysteria')) candidates.add(Protocol.hysteria2);
    if (lower.contains('rtc')) candidates.add(Protocol.olcRtc);
    if (lower.contains('vless') || lower.contains('xray')) candidates.add(Protocol.xrayVless);
    if (candidates.isEmpty) {
      candidates.addAll([Protocol.amneziaWG, Protocol.hysteria2]);
    }

    // Жёсткий предел оффлайн-формата: не больше четырёх подключений.
    final selected = candidates.take(4).toList();

    final entries = <PreviewEntry>[];
    for (var i = 0; i < selected.length; i++) {
      final p = selected[i];
      entries.add(PreviewEntry(
        id: 'visp-${p.name}-$i',
        title: 'Маршрут ${p.displayName}',
        subtitle: '${p.displayName} · параметры в коде',
        protocol: p,
        needsModule: p == Protocol.olcRtc || p == Protocol.xrayVless,
      ));
    }

    return ImportPreview(
      kind: ImportKind.vispOffline,
      title: 'Оффлайн-код Visp',
      sourceLabel: 'visp:// · ${entries.length} из 4',
      entries: entries,
      hasRoutingRules: lower.contains('route') || lower.contains('split'),
    );
  }

  /// Серверный код: содержимое получает служба разрешения, лимита «4» нет.
  static ImportPreview _parseVispServer(String input) {
    return ImportPreview(
      kind: ImportKind.vispServer,
      title: 'Серверный код $input',
      sourceLabel: 'Управляемый код · служба разрешения',
      entries: [
        const PreviewEntry(
          id: 'visp-server-awg',
          title: 'Основной сервер',
          subtitle: 'AmneziaWG · 443',
          protocol: Protocol.amneziaWG,
        ),
        const PreviewEntry(
          id: 'visp-server-hys',
          title: 'Мобильный маршрут',
          subtitle: 'Hysteria 2 · 8443',
          protocol: Protocol.hysteria2,
        ),
        const PreviewEntry(
          id: 'visp-server-rtc',
          title: 'Маршрут для ограниченных сетей',
          subtitle: 'olcRTC · требуется модуль',
          protocol: Protocol.olcRtc,
          needsModule: true,
        ),
        const PreviewEntry(
          id: 'visp-server-proxy',
          title: 'Telegram MTProto',
          subtitle: 'tg://proxy · в плагин «Прокси»',
          isProxy: true,
          proxyType: ProxyType.mtproto,
        ),
      ],
      hasRoutingRules: true,
    );
  }

  static ImportPreview _parseProtocolLink(String input, Protocol protocol) {
    final uri = Uri.tryParse(input);
    final hasHost = uri?.host.isNotEmpty == true;

    // Схема без адреса — это не ссылка. Такое не должно превращаться в
    // профиль «сервер»: лучше честная подсказка с ожидаемым форматом.
    if (!hasHost) {
      return ImportPreview(
        kind: ImportKind.unknown,
        title: 'Неизвестный формат',
        sourceLabel: '',
        entries: [],
        error: 'В ссылке нет адреса. Ожидается '
            '${protocol.displayName}: протокол://…@host:порт',
      );
    }

    final host = uri!.host;
    final port = uri.port > 0 ? uri.port : _defaultPort(protocol);
    final name = _nameFromFragment(uri);

    switch (protocol) {
      case Protocol.xrayVless:
        return _parseVless(uri, host, port, name);
      case Protocol.hysteria2:
        return _parseHysteria2(uri, host, port, name);
      case Protocol.olcRtc:
        return _parseOlcRtc(uri, host, port, name);
      case Protocol.vmess:
        return _parseVmess(input, host, port, name);
      default:
        return _linkPreview(protocol, host, port,
            name: name,
            config: ProtocolConfig(address: host, port: port, raw: input));
    }
  }

  static int _defaultPort(Protocol protocol) {
    switch (protocol) {
      case Protocol.amneziaWG:
      case Protocol.wireGuard:
        return 51820;
      case Protocol.hysteria2:
        return 8443;
      case Protocol.olcRtc:
      case Protocol.xrayVless:
      case Protocol.trojan:
        return 443;
      default:
        return 8388;
    }
  }

  static ImportPreview _linkPreview(
    Protocol protocol,
    String host,
    int port, {
    ProtocolConfig? config,
    bool? needsModule,
    String? subtitle,
    String? name,
  }) {
    return ImportPreview(
      kind: ImportKind.protocolLink,
      title: protocol.displayName,
      sourceLabel: 'Ссылка протокола',
      entries: [
        PreviewEntry(
          id: 'link-${protocol.name}',
          // Ссылка может нести своё имя в конце после «#» (например
          // «#Amnezia»). Показываем его, а не адрес: так пользователь видит
          // то название, которое он сам и вводил.
          title: (name != null && name.isNotEmpty) ? name : host,
          subtitle: subtitle ?? '${protocol.displayName} · $host:$port',
          protocol: protocol,
          needsModule: needsModule ?? _engineNotBundled(protocol),
          config: config,
        ),
      ],
    );
  }

  /// Имя из ссылки: фрагмент после «#», декодированный.
  static String? _nameFromFragment(Uri uri) {
    if (uri.fragment.isEmpty) return null;
    final decoded = Uri.decodeFull(uri.fragment.replaceAll('+', '%20')).trim();
    return decoded.isEmpty ? null : decoded;
  }

  /// Движок не входит в стартовый набор и докачивается при первом подключении.
  static bool _engineNotBundled(Protocol protocol) =>
      protocol == Protocol.olcRtc ||
      protocol == Protocol.xrayVless ||
      protocol == Protocol.vmess ||
      protocol == Protocol.trojan ||
      protocol == Protocol.shadowsocks ||
      protocol == Protocol.wireGuard ||
      protocol == Protocol.openVpn;

  /// vless://uuid@host:port?encryption=none&security=reality&sni=example.com
  ///   &fp=chrome&pbk=publicKey&sid=shortId&flow=xtls-rprx-vision&type=tcp
  static ImportPreview _parseVless(
      Uri? uri, String host, int port, String? name) {
    final q = uri?.queryParameters ?? const <String, String>{};
    final isReality =
        q['security']?.toLowerCase() == 'reality' && (q['pbk']?.isNotEmpty ?? false);
    final config = ProtocolConfig(
      address: host,
      port: port,
      uuid: (uri?.userInfo.isNotEmpty == true) ? uri!.userInfo : null,
      encryption: q['encryption'],
      flow: q['flow'],
      network: q['type'] ?? q['headertype'],
      sni: q['sni'] ?? q['peer'],
      fingerprint: q['fp'],
      publicKey: q['pbk'],
      shortId: q['sid'],
      password: q['path'],
      extras: {
        if (q['alpn'] != null) 'alpn': q['alpn']!,
        if (q['sid'] != null) 'sid': q['sid']!,
      },
      raw: uri?.toString(),
    );
    return _linkPreview(
      Protocol.xrayVless,
      host,
      port,
      name: name,
      config: config,
      subtitle: 'XRay VLESS${isReality ? '/REALITY' : ''} · $host:$port',
    );
  }

  /// hysteria2://host:port/?auth=token&obfs=salamander&obfs-password=pw
  ///   &sni=example.com&insecure=1&pinSHA256=hash
  static ImportPreview _parseHysteria2(
      Uri? uri, String host, int port, String? name) {
    final q = uri?.queryParameters ?? const <String, String>{};
    final config = ProtocolConfig(
      address: host,
      port: port,
      auth: q['auth'],
      obfs: q['obfs'],
      obfsPassword: q['obfs-password'],
      sni: q['sni'],
      extras: {
        if (q['pinsha256'] != null) 'pinSHA256': q['pinsha256']!,
        if (q['insecure'] != null) 'insecure': q['insecure']!,
      },
      raw: uri?.toString(),
    );
    return _linkPreview(Protocol.hysteria2, host, port,
        name: name, config: config);
  }

  /// olcrtc://host:port/?transport=webrtc&token=... — транспорт, связанный
  /// с WebRTC; пригодность проверяется на практике (раздел 3).
  static ImportPreview _parseOlcRtc(
      Uri? uri, String host, int port, String? name) {
    final q = uri?.queryParameters ?? const <String, String>{};
    final config = ProtocolConfig(
      address: host,
      port: port,
      auth: q['token'] ?? q['auth'],
      sni: q['sni'],
      extras: {
        if (q['transport'] != null) 'transport': q['transport']!,
        if (q['ice'] != null) 'ice': q['ice']!,
      },
      raw: uri?.toString(),
    );
    return _linkPreview(Protocol.olcRtc, host, port, name: name, config: config);
  }

  /// vmess://base64(JSON) — базовый разбор без угадывания неподдерживаемых
  /// полей; движок XRay докачивается отдельно.
  static ImportPreview _parseVmess(
      String rawInput, String host, int port, String? name) {
    ProtocolConfig? config;
    try {
      final payload = rawInput
          .substring(rawInput.toLowerCase().indexOf('vmess://') + 'vmess://'.length)
          .trim();
      final json = utf8.decode(base64.decode(_base64Normalize(payload)));
      final map = jsonDecode(json) as Map<String, dynamic>;
      config = ProtocolConfig(
        address: (map['add'] as String?) ?? host,
        port: int.tryParse('${map['port']}') ?? port,
        uuid: map['id'] as String?,
        network: map['net'] as String?,
        encryption: map['scy'] as String?,
        sni: (map['sni'] as String?) ?? (map['host'] as String?),
        extras: {if (map['aid'] != null) 'aid': '${map['aid']}'},
        raw: json,
      );
    } catch (_) {
      config = ProtocolConfig(address: host, port: port, raw: rawInput);
    }
    return _linkPreview(Protocol.vmess, host, port,
        name: name, config: config);
  }

  /// Дополняет base64 до валидной длины (payload ссылки часто без padding).
  static String _base64Normalize(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
    final padding = (4 - cleaned.length % 4) % 4;
    return cleaned + '=' * padding;
  }

  /// Разбор WireGuard/AmneziaWG .conf (INI). AmneziaWG определяется по
  /// параметрам маскировки Jc/Jmin/Jmax/S1/S2/H1–H4 в секции [Interface].
  static ImportPreview parseConfig(String text) {
    final sections = _parseIniSections(text);
    final iface = sections['interface'] ?? const <String, String>{};
    final peer = sections['peer'] ?? const <String, String>{};

    const junkKeys = ['jc', 'jmin', 'jmax', 's1', 's2', 'h1', 'h2', 'h3', 'h4'];
    final isAmnezia = junkKeys.any((k) => iface.containsKey(k));
    final protocol = isAmnezia ? Protocol.amneziaWG : Protocol.wireGuard;

    final endpoint = peer['endpoint'] ?? '';
    final parts = endpoint.split(':');
    final host = parts.isNotEmpty ? parts.first : 'сервер';
    final port = (parts.length > 1 ? int.tryParse(parts.sublist(1).join()) : null) ??
        _defaultPort(protocol);

    final extras = <String, String>{};
    for (final k in junkKeys) {
      if (iface.containsKey(k)) extras[k.toUpperCase()] = iface[k]!;
    }

    final config = ProtocolConfig(
      address: host,
      port: port,
      publicKey: peer['publickey'],
      password: peer['presharedkey'],
      auth: iface['privatekey'],
      extras: extras,
      raw: text,
    );
    return ImportPreview(
      kind: ImportKind.protocolLink,
      title: 'Конфигурация ${protocol.displayName}',
      sourceLabel: 'Файл настроек · WireGuard/AmneziaWG',
      entries: [
        PreviewEntry(
          id: 'conf-${protocol.name}-${host.hashCode.abs()}',
          title: host,
          subtitle: '${protocol.displayName} · $host:$port',
          protocol: protocol,
          needsModule: !isAmnezia,
          config: config,
        ),
      ],
    );
  }

  /// Плоская INI-разбивка по секциям; ключи в нижнем регистре.
  static Map<String, Map<String, String>> _parseIniSections(String text) {
    final sections = <String, Map<String, String>>{};
    var current = 'global';
    for (final raw in text.split(RegExp(r'\r?\n'))) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#') || line.startsWith(';')) continue;
      final secMatch = RegExp(r'^\[(.+)\]$').firstMatch(line);
      if (secMatch != null) {
        current = secMatch.group(1)!.toLowerCase();
        continue;
      }
      final eq = line.indexOf('=');
      if (eq <= 0) continue;
      sections
          .putIfAbsent(current, () => <String, String>{})
        [line.substring(0, eq).trim().toLowerCase()] = line.substring(eq + 1).trim();
    }
    return sections;
  }

  /// true для WireGuard/AmneziaWG конфигурационного файла.
  static bool _looksLikeWireGuardConf(String input) {
    final lower = input.toLowerCase();
    return lower.contains('[interface]') && lower.contains('[peer]');
  }

  /// Подписка: разбирает всё, что внутри, а не придумывает профили.
  ///
  /// Поддерживаются три формы содержимого (раздел 2.5):
  ///  - base64 со списком ссылок построчно;
  ///  - список ссылок или base64-ссылок без обёртки;
  ///  - sing-box / Xray JSON с массивом outbound.
  static ImportPreview _parseSubscription(
    String input, {
    bool decoded = false,
  }) {
    // Декодирование выполняется здесь всегда: вызывающая сторона могла лишь
  // догадаться, что ввод — base64, и передать флаг decoded.
  final content = _tryDecodeBase64Body(input) ?? input;

    final entries = <PreviewEntry>[];
    var sawStructured = false;

    // 1. JSON-подобное содержимое: outbounds / proxies.
    final trimmed = content.trimLeft();
    if (trimmed.startsWith('{')) {
      try {
        final json = jsonDecode(trimmed) as Map<String, dynamic>;
        final list = (json['outbounds'] as List?) ?? (json['proxies'] as List?);
        if (list != null) {
          sawStructured = true;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              final entry = _entryFromJsonOutbound(item, entries.length);
              if (entry != null) entries.add(entry);
            }
          }
        }
      } catch (_) {
        // Не JSON: пробуем как список ссылок.
      }
    }

    // 2. Ссылки построчно — основная форма большинства подписок.
    if (entries.isEmpty) {
      var index = 0;
      for (final rawLine in content.split(RegExp(r'[\r\n]+'))) {
        var line = rawLine.trim();
        if (line.isEmpty) continue;
        // Подписка иногда отдаёт base64-ссылку внутри base64-обёртки.
        // Декодируем только если строка сама по себе не является ссылкой
        // протокола: иначе «vless://…» ошибочно уйдёт в декодирование.
        if (_protocolOf(line.toLowerCase()) == null) {
          final inner = _tryDecodeBase64Body(line);
          if (inner != null && inner.contains('://')) {
            line = inner.trim();
          }
        }
        final protocol = _protocolOf(line.toLowerCase());
        if (protocol == null) continue;

        final parsed = _parseProtocolLink(line, protocol);
        for (final e in parsed.entries) {
          entries.add(e.copyWith(id: 'sub-${index++}'));
        }
        if (entries.length >= 200) break; // Разумный предел на одну подписку.
      }
    }

    if (entries.isEmpty) {
      return ImportPreview(
        kind: ImportKind.unknown,
        title: 'Подписка без профилей',
        sourceLabel: '',
        entries: const [],
        error: sawStructured
            ? 'В содержимом нет поддерживаемых протоколов'
            : 'Не нашлось ни одной ссылки протокола. Поддерживаются vless://, '
                'vmess://, trojan://, ss://, hysteria2:// и конфигурации '
                'WireGuard/AmneziaWG.',
      );
    }

    return ImportPreview(
      kind: ImportKind.subscription,
      title: decoded ? 'Подписка (base64)' : 'Подписка',
      sourceLabel: 'Обновляемый источник · ${entries.length} профилей',
      entries: entries,
      hasRoutingRules: false,
    );
  }

  /// Возвращает декодированное тело, если вход действительно base64.
  static String? _tryDecodeBase64Body(String input) {
    final cleaned = input.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length < 16 || cleaned.length % 4 != 0) return null;
    if (!RegExp(r'^[A-Za-z0-9+/]+={0,2}$').hasMatch(cleaned)) return null;
    try {
      return utf8.decode(base64.decode(cleaned));
    } catch (_) {
      return null;
    }
  }

  /// Профиль из outbound в sing-box / Xray JSON.
  static PreviewEntry? _entryFromJsonOutbound(
    Map<String, dynamic> item,
    int index,
  ) {
    final protocolName = (item['protocol'] ?? item['type'])?.toString();
    if (protocolName == null) return null;

    final protocol = switch (protocolName.toLowerCase()) {
      'vless' => Protocol.xrayVless,
      'vmess' => Protocol.vmess,
      'trojan' => Protocol.trojan,
      'hysteria2' || 'hy2' => Protocol.hysteria2,
      'shadowsocks' || 'ss' => Protocol.shadowsocks,
      'wireguard' => Protocol.wireGuard,
      _ => null,
    };
    if (protocol == null) return null;

    // Адрес и порт лежат в разных местах в зависимости от формата.
    final settings = (item['settings'] as Map?)?.cast<String, dynamic>();
    final vnext = (settings?['vnext'] as List?)?.first;
    final server = vnext is Map ? vnext : null;
    final servers = (settings?['servers'] as List?)?.first;
    final serverNode = servers is Map ? servers : null;

    final address = ((item['address'] ?? server?['address'] ??
            serverNode?['address']) as String?);
    if (address == null || address.isEmpty) return null;

    final rawPort = item['port'] ?? server?['port'] ?? serverNode?['port'];
    final port = rawPort is int
        ? rawPort
        : int.tryParse('${rawPort ?? ''}') ?? _defaultPort(protocol);

    final tag = (item['tag'] ?? item['remarks'] ?? '$address:$port').toString();

    final users = (server?['users'] as List?) ?? const [];
    final uuid = users.isNotEmpty && users.first is Map
        ? (users.first as Map)['id']?.toString()
        : item['uuid'] as String?;

    return PreviewEntry(
      id: 'sub-json-$index',
      title: tag,
      subtitle: '${protocol.displayName} · $address:$port',
      protocol: protocol,
      needsModule: _engineNotBundled(protocol),
      config: ProtocolConfig(
        address: address,
        port: port,
        uuid: uuid,
        publicKey: serverNode?['password']?.toString(),
        sni: (server?['tls'] as Map?)?['serverName']?.toString(),
        flow: server?['flow']?.toString(),
        auth: item['password']?.toString(),
        raw: jsonEncode(item),
      ),
    );
  }

  static ImportPreview _parseTelegramProxy(String input) {
    final isWeb = input.toLowerCase().contains('webproxy');
    return ImportPreview(
      kind: ImportKind.telegramProxy,
      title: isWeb ? 'Telegram WEB proxy' : 'Telegram MTProto',
      sourceLabel: 'Плагин «Прокси для Telegram»',
      entries: [
        PreviewEntry(
          id: 'tg-proxy',
          title: isWeb ? 'WEB proxy' : 'MTProto proxy',
          subtitle: isWeb
              ? 't.me/webproxy?server=...&secret=...'
              : 'tg://proxy?server=...&secret=...',
          isProxy: true,
          proxyType: isWeb ? ProxyType.webProxy : ProxyType.mtproto,
        ),
      ],
    );
  }
}
