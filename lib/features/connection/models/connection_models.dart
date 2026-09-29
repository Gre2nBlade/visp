/// Протоколы Visp. Стартовый набор из четырёх способов подключения (раздел 3)
/// и варианты, которые добавляются по мере совместимых движков.
enum Protocol {
  amneziaWG(
    'AmneziaWG',
    'Основной быстрый вариант с маскировкой признаков WireGuard. '
        'Подходит как стартовый выбор, если работает в данной сети.',
  ),
  hysteria2(
    'Hysteria 2',
    'Дополнительный вариант для мобильных сетей и каналов с потерями. '
        'Ограничения UDP способны сделать его недоступным.',
  ),
  olcRtc(
    'olcRTC',
    'Специальный вариант для ограниченных сетей, использующий транспорт, '
        'связанный с WebRTC. Пригодность проверяется на практике.',
  ),
  xrayVless(
    'XRay VLESS/REALITY',
    'Альтернативный способ подключения для сетей, где другие варианты '
        'ограничены. XRay — движок, VLESS/REALITY — способ подключения.',
  ),
  wireGuard(
    'WireGuard',
    'Обычный WireGuard без маскировки признаков.',
  ),
  openVpn(
    'OpenVPN',
    'Классический туннель, добавляется конфигурационным файлом.',
  ),
  shadowsocks(
    'Shadowsocks',
    'Шифрованный SOCKS-прокси. Совместимые движки добавляются отдельно.',
  ),
  vmess(
    'VMess',
    'Транспорт XRay/совместимых движков.',
  ),
  trojan(
    'Trojan',
    'Совместимый движок добавляется отдельно от наличия XRay.',
  );

  final String displayName;
  final String description;

  const Protocol(this.displayName, this.description);
}

/// Состояние движка протокола на устройстве (раздел 3.4).
///
/// Три разных вещи не смешиваются: движок есть на устройстве, протокол
/// скачивается, протокол поддерживается каталогом. Импорт сохраняет профиль
/// даже без движка: докачка запускается при первом подключении.
enum EngineState {
  /// Движка нет. Профиль всё равно сохраняется (раздел 3.4).
  notInstalled('Нужен модуль', 'Движок докачивается при первом подключении'),

  /// Идёт загрузка движка.
  downloading('Скачивается', 'Движок загружается'),

  /// Движок на устройстве, подключение возможно.
  ready('Готов', 'Движок установлен'),

  /// Есть новая проверенная совместимая версия (каталог).
  needsUpdate('Обновление', 'Рекомендуется обновить движок'),

  /// Движок недоступен на этой платформе/канале.
  unsupported('Недоступно', 'Движок не поддерживается');

  final String displayName;
  final String hint;

  const EngineState(this.displayName, this.hint);
}

/// Распарсенные параметры подключения протокола.
///
/// Хранит только то, что есть в ссылке/конфиге; поля без значения — null.
/// Сырой источник сохраняется в [raw] для отображения и отладки.
class ProtocolConfig {
  final String address;
  final int port;
  final String? sni;
  final String? fingerprint;
  final String? flow;
  final String? publicKey;
  final String? shortId;
  final String? uuid;
  final String? encryption;
  final String? auth;
  final String? obfs;
  final String? obfsPassword;
  final String? network;
  final String? password;
  final Map<String, String> extras;
  final String? raw;

  const ProtocolConfig({
    required this.address,
    required this.port,
    this.sni,
    this.fingerprint,
    this.flow,
    this.publicKey,
    this.shortId,
    this.uuid,
    this.encryption,
    this.auth,
    this.obfs,
    this.obfsPassword,
    this.network,
    this.password,
    this.extras = const {},
    this.raw,
  });

  /// Подпись «протокол | IP-адрес» для строки сессии (раздел 8.3.1).
  String get endpoint => '$address:$port';
}

/// Отдельный профиль протокола под хостом. Один VPN-профиль считается одним
/// подключением; правила маршрутизации — сопутствующие настройки.
class ProtocolProfile {
  final String id;
  final String name;
  final Protocol protocol;
  final int port;

  /// Состояние движка на устройстве (раздел 3.4). Профиль без движка не
  /// выдаётся за рабочий: соответствующий чип показывается в списке.
  final EngineState engineState;

  /// Распарсенные параметры подключения (могут быть у пустой заглушки).
  final ProtocolConfig? config;

  /// Источник записи: «Свой сервер», код, подписка.
  final String source;

  final bool favorite;

  const ProtocolProfile({
    required this.id,
    required this.name,
    required this.protocol,
    required this.port,
    required this.engineState,
    this.config,
    required this.source,
    this.favorite = false,
  });

  /// Совместимый с UI способ спросить «движок готов к подключению».
  bool get engineReady => engineState == EngineState.ready;

  ProtocolProfile copyWith({
    String? id,
    String? name,
    Protocol? protocol,
    int? port,
    EngineState? engineState,
    ProtocolConfig? config,
    String? source,
    bool? favorite,
  }) {
    return ProtocolProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      protocol: protocol ?? this.protocol,
      port: port ?? this.port,
      engineState: engineState ?? this.engineState,
      config: config ?? this.config,
      source: source ?? this.source,
      favorite: favorite ?? this.favorite,
    );
  }

  String get subtitle => '${protocol.displayName} · $port';
}

/// Сервер-хост: обязательная раскрываемая группа, под которой каждый
/// протокол занимает отдельную строку.
class ServerHost {
  final String id;
  final String name;
  final String address;
  final String? region;

  /// Подтверждённое владение: определяет доступность «Поделиться»
  /// и автоустановки (разделы 2.5, 5.2).
  final bool owned;
  final List<ProtocolProfile> profiles;

  const ServerHost({
    required this.id,
    required this.name,
    required this.address,
    this.region,
    required this.owned,
    required this.profiles,
  });

  int get profileCount => profiles.length;
}

/// Тип Telegram-прокси (раздел 9).
enum ProxyType {
  mtproto('MTProto', 'tg://proxy, t.me/proxy'),
  webProxy('WEB proxy', 't.me/webproxy?server=...&secret=...'),
  localWs('Локальный TG WS Proxy', 'Локальный сервис на устройстве');

  final String displayName;
  final String hint;
  const ProxyType(this.displayName, this.hint);
}

/// Состояние проверки прокси (раздел 9.4).
enum ProxyCheckState {
  untested('Не проверен'),
  checking('Проверяется'),
  working('Работает'),
  laggy('Лаги'),
  dead('Не отвечает'),
  unsupported('Проверка не поддерживается'),
  stale('Данные устарели');

  final String displayName;
  const ProxyCheckState(this.displayName);
}

/// Запись прокси плагина «Прокси для Telegram».
class ProxyRecord {
  final String id;
  final String name;
  final ProxyType type;
  final String address;
  final int? ping;
  final ProxyCheckState checkState;
  final bool favorite;

  const ProxyRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    this.ping,
    required this.checkState,
    this.favorite = false,
  });
}
