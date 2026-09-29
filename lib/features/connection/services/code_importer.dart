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
    if (protocol != null) {
      return _parseProtocolLink(input, protocol);
    }

    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return _parseSubscription(input);
    }

    // Быть может, это base64-подписка без схемы.
    if (_looksLikeBase64(input)) {
      return _parseSubscription(input, decoded: true);
    }

    return const ImportPreview(
      kind: ImportKind.unknown,
      title: 'Неизвестный формат',
      sourceLabel: '',
      entries: [],
      error: 'Формат пока не поддерживается',
    );
  }

  static Protocol? _protocolOf(String lower) {
    for (final entry in const [
      ('vless://', Protocol.xrayVless),
      ('vmess://', Protocol.vmess),
      ('trojan://', Protocol.trojan),
      ('hysteria2://', Protocol.hysteria2),
      ('ss://', Protocol.shadowsocks),
      ('wireguard://', Protocol.wireGuard),
      ('vpn://', Protocol.xrayVless),
    ]) {
      if (lower.startsWith(entry.$1)) return entry.$2;
    }
    return null;
  }

  static bool _looksLikeBase64(String input) {
    final cleaned = input.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length < 24 || cleaned.length % 4 != 0) return false;
    try {
      final decoded = utf8.decode(base64.decode(cleaned));
      return decoded.contains('://') || decoded.contains('proxies:');
    } catch (_) {
      return false;
    }
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
    final host = uri?.host.isNotEmpty == true ? uri!.host : 'сервер';
    final port = uri?.port;
    return ImportPreview(
      kind: ImportKind.protocolLink,
      title: protocol.displayName,
      sourceLabel: 'Ссылка протокола',
      entries: [
        PreviewEntry(
          id: 'link-${protocol.name}',
          title: host,
          subtitle:
              '${protocol.displayName}${port != null && port > 0 ? ' · $port' : ''}',
          protocol: protocol,
        ),
      ],
    );
  }

  static ImportPreview _parseSubscription(String input, {bool decoded = false}) {
    return ImportPreview(
      kind: ImportKind.subscription,
      title: decoded ? 'Подписка (base64)' : 'Подписка',
      sourceLabel: 'Обновляемый источник',
      entries: const [
        PreviewEntry(
          id: 'sub-1',
          title: 'Профиль 1',
          subtitle: 'AmneziaWG · 51820',
          protocol: Protocol.amneziaWG,
        ),
        PreviewEntry(
          id: 'sub-2',
          title: 'Профиль 2',
          subtitle: 'Hysteria 2 · 8443',
          protocol: Protocol.hysteria2,
        ),
        PreviewEntry(
          id: 'sub-3',
          title: 'Профиль 3',
          subtitle: 'Shadowsocks · требуется модуль',
          protocol: Protocol.shadowsocks,
          needsModule: true,
        ),
      ],
      hasRoutingRules: true,
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
