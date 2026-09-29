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

/// Отдельный профиль протокола под хостом. Один VPN-профиль считается одним
/// подключением; правила маршрутизации — сопутствующие настройки.
class ProtocolProfile {
  final String id;
  final String name;
  final Protocol protocol;
  final int port;

  /// Движок находится на устройстве. Профиль без движка не выдаётся
  /// за рабочий: статус «Нужен модуль».
  final bool engineReady;

  /// Источник записи: «Свой сервер», код, подписка.
  final String source;

  final bool favorite;

  const ProtocolProfile({
    required this.id,
    required this.name,
    required this.protocol,
    required this.port,
    required this.engineReady,
    required this.source,
    this.favorite = false,
  });

  ProtocolProfile copyWith({
    String? id,
    String? name,
    Protocol? protocol,
    int? port,
    bool? engineReady,
    String? source,
    bool? favorite,
  }) {
    return ProtocolProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      protocol: protocol ?? this.protocol,
      port: port ?? this.port,
      engineReady: engineReady ?? this.engineReady,
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
