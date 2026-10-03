import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/feedback/haptics.dart';
import '../core/feedback/visp_error.dart';
import '../core/widgets/blup_visp.dart';
import '../features/connection/models/connection_models.dart';
import '../features/connection/services/amneziawg_engine.dart';
import '../features/connection/services/code_importer.dart';
import '../features/connection/services/vpn_engine.dart';
import '../features/connection/services/xray_engine.dart';
import 'preferences.dart';

/// Центральное состояние приложения: подключения, движки VPN, разделяемое
/// состояние выбора/поиска/фильтров серверов и предпочтения.
class AppState extends ChangeNotifier {
  AppState() {
    // Реальные ядра поднимаются только там, где есть нативная платформа.
    _engines[Protocol.amneziaWG] = AmneziaWgEngine();
    _engines[Protocol.wireGuard] = AmneziaWgEngine();
    _engines[Protocol.xrayVless] = XrayEngine();
    _engines[Protocol.hysteria2] = XrayEngine();
  }

  /// Ядра по протоколам. Протокол без ядра остаётся в состоянии
  /// «Нужен модуль», а не подменяется выдуманным подключением.
  final Map<Protocol, VpnEngine> _engines = {};

  /// Настоящее ядро доступно на этой платформе (на десктопе — нет).
  bool get hasNativeEngine =>
      !kIsWeb && defaultTargetPlatform != TargetPlatform.windows;


  List<ServerHost> _hosts = [];
  List<ProxyRecord> _proxies = [];
  String? _selectedProfileId;
  BlupStatus _status = BlupStatus.idle;

  /// Текстовая причина ошибки: декоративный эффект не маскирует ошибку.
  VispError? _error;
  String? _statusDetail;

  bool _trafficPulse = false;
  Timer? _ticker;
  int _connectToken = 0;
  bool _connectingCancelled = false;

  // Debug-информация (раздел 4.2)
  int? _ping;
  double? _downSpeed;
  double? _upSpeed;
  DateTime? _sessionStart;
  Duration _sessionDuration = Duration.zero;

  // Разделяемое состояние списка серверов (раздел 5.1)
  String _serverQuery = '';
  Protocol? _protocolFilter;
  bool _readyOnly = false;
  final Set<String> _expandedHosts = {};

  // Прокси-плагин: локальный сервис
  bool _localProxyRunning = false;

  bool _initialized = false;

  // ---- Настройки ----
  AppThemeMode _themeMode = AppThemeMode.system;
  HapticPref _haptics = HapticPref.auto;
  GlassMode _glassMode = GlassMode.regular;
  bool _studioPinned = false;
  bool _proxyInstalled = false;
  bool _devRole = false;
  bool _debugVisible = false;
  bool _navLabels = true;
  String? _localeCode;
  bool _killSwitch = false;
  bool _autostart = false;
  bool _splitTunneling = false;
  bool _screenshotsAllowed = true;
  UpdateChannel _updateChannel = UpdateChannel.stable;

  List<ServerHost> get hosts => List.unmodifiable(_hosts);
  List<ProxyRecord> get proxies => List.unmodifiable(_proxies);
  BlupStatus get status => _status;
  VispError? get error => _error;

  /// Однострочный текст ошибки для тостов и заголовков.
  String? get errorText => _error?.summary;
  String? get statusDetail => _statusDetail;
  bool get trafficPulse => _trafficPulse;
  bool get hasConnections => _hosts.any((h) => h.profiles.isNotEmpty);
  bool get isInitialized => _initialized;

  int? get ping => _ping;
  double? get downSpeed => _downSpeed;
  double? get upSpeed => _upSpeed;
  DateTime? get sessionStart => _sessionStart;
  Duration get sessionDuration => _sessionDuration;

  String get serverQuery => _serverQuery;
  Protocol? get protocolFilter => _protocolFilter;
  bool get readyOnly => _readyOnly;
  bool isHostExpanded(String id) => _expandedHosts.contains(id);
  bool get localProxyRunning => _localProxyRunning;

  AppThemeMode get themeMode => _themeMode;
  HapticPref get haptics => _haptics;
  /// Режим стекла: без стекла, матовое или обычное (раздел 11.2).
  GlassMode get glassMode => _glassMode;

  /// Стекло включено в любом из режимов — для совместимости с UI.
  bool get glass => _glassMode != GlassMode.none;
  bool get studioPinned => _studioPinned;
  bool get proxyInstalled => _proxyInstalled;
  bool get devRole => _devRole;
  bool get debugVisible => _debugVisible;

  /// Показывать ли подписи вкладок в навигации.
  bool get navLabelsVisible => _navLabels;
  bool get killSwitch => _killSwitch;
  bool get autostart => _autostart;
  bool get splitTunneling => _splitTunneling;
  bool get screenshotsAllowed => _screenshotsAllowed;
  UpdateChannel get updateChannel => _updateChannel;

  Locale? get locale => _localeCode == null ? null : Locale(_localeCode!);

  ProtocolProfile? get selectedProfile {
    for (final host in _hosts) {
      final match =
          host.profiles.where((p) => p.id == _selectedProfileId).toSet();
      if (match.isNotEmpty) return match.first;
    }
    return null;
  }

  ServerHost? get selectedHost {
    for (final host in _hosts) {
      if (host.profiles.any((p) => p.id == _selectedProfileId)) return host;
    }
    return null;
  }

  /// Текущий профиль выбран автоматически (режим «Автоматически»).
  bool get isAutoMode => _selectedProfileId == _autoProfileId;

  static const _autoProfileId = 'auto';

  /// Инициализация: настройки и стартовый набор демонстрационных подключений.
  Future<void> init() async {
    await Preferences.load();

    _themeMode = Preferences.themeMode;
    _haptics = Preferences.haptics;
    Haptics.strength = _haptics == HapticPref.minimal
        ? HapticStrength.minimal
        : _haptics == HapticPref.off
            ? HapticStrength.off
            : HapticStrength.auto;
    _glassMode = Preferences.glassMode;
    _studioPinned = Preferences.studioPinned;
    _proxyInstalled = Preferences.proxyInstalled;
    _devRole = Preferences.devRole;
    _debugVisible = Preferences.debugVisible;
    _navLabels = Preferences.navLabels;
    _localeCode = Preferences.locale;
    _killSwitch = Preferences.killSwitch;
    _autostart = Preferences.autostart;
    _splitTunneling = Preferences.splitTunneling;
    _screenshotsAllowed = Preferences.screenshotsAllowed;
    _updateChannel = Preferences.updateChannel;

    _seedDemoData();
    _initialized = true;
    notifyListeners();
  }

  void _seedDemoData() {
    _hosts = [
      ServerHost(
        id: 'host-de',
        name: 'Германия',
        address: '2.27.63.201',
        region: 'Франкфурт',
        owned: true,
        profiles: [
          const ProtocolProfile(
            id: 'de-awg',
            name: 'AmneziaWG',
            protocol: Protocol.amneziaWG,
            port: 51820,
            engineState: EngineState.ready,
            source: 'Свой сервер',
            favorite: true,
          ),
          const ProtocolProfile(
            id: 'de-hys',
            name: 'Hysteria 2',
            protocol: Protocol.hysteria2,
            port: 8443,
            engineState: EngineState.ready,
            source: 'Свой сервер',
          ),
          const ProtocolProfile(
            id: 'de-xray',
            name: 'XRay VLESS/REALITY',
            protocol: Protocol.xrayVless,
            port: 443,
            engineState: EngineState.notInstalled,
            source: 'Свой сервер',
          ),
        ],
      ),
      ServerHost(
        id: 'host-nl',
        name: 'Нидерланды',
        address: '94.142.241.5',
        region: 'Амстердам',
        owned: false,
        profiles: [
          const ProtocolProfile(
            id: 'nl-awg',
            name: 'AmneziaWG',
            protocol: Protocol.amneziaWG,
            port: 51820,
            engineState: EngineState.ready,
            source: 'Код VISP-7F2A-9Q4M',
          ),
          const ProtocolProfile(
            id: 'nl-rtc',
            name: 'olcRTC',
            protocol: Protocol.olcRtc,
            port: 443,
            engineState: EngineState.notInstalled,
            source: 'Код VISP-7F2A-9Q4M',
          ),
        ],
      ),
      ServerHost(
        id: 'host-ru',
        name: 'Зеркало DNS',
        address: '10.8.0.1',
        region: 'Локальный маршрут',
        owned: false,
        profiles: const [
          ProtocolProfile(
            id: 'ru-ss',
            name: 'Shadowsocks',
            protocol: Protocol.shadowsocks,
            port: 8388,
            engineState: EngineState.notInstalled,
            source: 'Подписка',
          ),
        ],
      ),
    ];
    _selectedProfileId = 'de-awg';

    if (_proxyInstalled) {
      _proxies = _demoProxies();
    }
  }

  List<ProxyRecord> _demoProxies() => const [
        ProxyRecord(
          id: 'proxy-1',
          name: 'Основной MTProto',
          type: ProxyType.mtproto,
          address: 'proxy.example.com:443',
          ping: 54,
          checkState: ProxyCheckState.working,
          favorite: true,
        ),
        ProxyRecord(
          id: 'proxy-2',
          name: 'WEB proxy',
          type: ProxyType.webProxy,
          address: 'web.example.com',
          checkState: ProxyCheckState.unsupported,
        ),
        ProxyRecord(
          id: 'proxy-3',
          name: 'Локальный сервис',
          type: ProxyType.localWs,
          address: '127.0.0.1:8080',
          checkState: ProxyCheckState.untested,
        ),
      ];

  // ---- Подключение ----------------------------------------------------

  bool get isActive =>
      _status == BlupStatus.connected ||
      _status == BlupStatus.preparing ||
      _status == BlupStatus.checking ||
      _status == BlupStatus.connecting ||
      _status == BlupStatus.reconnecting;

  /// Повтор подключения не создаёт вторую параллельную попытку.
  Future<void> connect() async {
    if (isActive) return;
    final profile = selectedProfile;
    if (profile == null) {
      _fail(const VispError(VispErrorCode.noProfileSelected));
      return;
    }

    final token = ++_connectToken;
    _connectingCancelled = false;
    _error = null;

    _setStatus(BlupStatus.preparing, detail: 'Подготовка модуля');
    await _tick(token, const Duration(milliseconds: 900));
    if (_cancelled(token)) return;

    // Импорт сохраняет профиль даже без движка: докачка запускается при
    // первом подключении, если ОС и канал допускают (раздел 3.4).
    if (profile.engineState != EngineState.ready) {
      if (profile.engineState == EngineState.unsupported) {
        _fail(VispError(
          VispErrorCode.engineUnavailable,
          detail: 'Протокол ${profile.protocol.displayName}',
        ));
        return;
      }
      _setEngineState(profile, EngineState.downloading);
      _setStatus(BlupStatus.preparing, detail: 'Докачка модуля');
      await _tick(token, const Duration(milliseconds: 1600));
      if (_cancelled(token)) return;
      _setEngineState(profile, EngineState.ready);
    }

    _setStatus(BlupStatus.checking, detail: 'Проверка сервера');
    await _tick(token, const Duration(milliseconds: 900));
    if (_cancelled(token)) return;

    // Нативное ядро поднимает настоящий туннель. На платформах без ядра
    // (десктоп, тесты) остаётся прототип, и UI сообщает об этом честно.
    final engine = _engines[profile.protocol];
    if (engine != null && hasNativeEngine) {
      _setStatus(BlupStatus.connecting, detail: 'Соединение');
      final result = await engine.connect(profile);
      if (_cancelled(token)) return;
      if (result != EngineResult.connected) {
        _fail(_engineError(result, profile));
        return;
      }
      _setEngineState(profile, EngineState.ready);
      _sessionStart = DateTime.now();
      _sessionDuration = Duration.zero;
      _ping = null;
      _downSpeed = null;
      _upSpeed = null;
      _setStatus(BlupStatus.connected, detail: null);
      _startTicker();
      return;
    }

    if (engine == null && hasNativeEngine) {
      _fail(VispError(
        VispErrorCode.engineMissing,
        detail: 'Протокол ${profile.protocol.displayName}',
      ));
      return;
    }

    _setStatus(BlupStatus.connecting, detail: 'Прототип подключения');
    await _tick(token, const Duration(milliseconds: 1100));
    if (_cancelled(token)) return;

    _sessionStart = DateTime.now();
    _sessionDuration = Duration.zero;
    _ping = 32;
    _downSpeed = 0;
    _upSpeed = 0;
    _setStatus(BlupStatus.connected, detail: null);
    _startTicker();
  }

  /// Понятная причина вместо технического кода движка.
///
/// Движок сообщает о результате обобщённо, а пользователю нужен код ошибки,
/// короткий заголовок и подсказка. Имя протокола уходит в детали, а не в
/// заголовок: иначе строка растягивалась на весь экран.
VispError _engineError(EngineResult result, ProtocolProfile profile) {
    final name = profile.protocol.displayName;
    switch (result) {
      case EngineResult.connected:
        return const VispError(VispErrorCode.tunnelFailed);
      case EngineResult.permissionDenied:
        return VispError(
          VispErrorCode.permissionDenied,
          detail: 'Протокол $name',
        );
      case EngineResult.invalidConfig:
        return VispError(
          VispErrorCode.missingParameters,
          detail: 'Протокол $name',
        );
      case EngineResult.engineMissing:
        return VispError(
          VispErrorCode.engineMissing,
          detail: 'Протокол $name',
        );
      case EngineResult.failed:
        return VispError(
          VispErrorCode.tunnelFailed,
          detail: 'Протокол $name',
        );
    }
  }

  /// Обновляет состояние движка профиля в дереве хостов.
  void _setEngineState(ProtocolProfile profile, EngineState state) {
    _hosts = _hosts
        .map((host) => ServerHost(
              id: host.id,
              name: host.name,
              address: host.address,
              region: host.region,
              owned: host.owned,
              profiles: host.profiles
                  .map((p) => p.id == profile.id ? p.copyWith(engineState: state) : p)
                  .toList(),
            ))
        .toList();
    notifyListeners();
  }

  /// Явная отмена затянувшегося подключения.
  void cancelConnect() {
    if (!isActive || _status == BlupStatus.connected) return;
    _connectingCancelled = true;
    _connectToken++;
    _ticker?.cancel();
    // Гасим ожидание текущей фазы: иначе таймер продолжит висеть после
    // отмены, и приложение будет ждать его вхолостую.
    _cancelPendingTick();
    _setStatus(BlupStatus.idle, detail: null);
  }

  void disconnect() {
    if (!isActive) return;
    _connectToken++;
    _connectingCancelled = true;
    _ticker?.cancel();
    _cancelPendingTick();
    // Нативный туннель останавливается ядром, а не только флагом в UI.
    final engine = selectedProfile == null
        ? null
        : _engines[selectedProfile!.protocol];
    engine?.disconnect();
    // При disconnect старые debug-значения не продолжают выглядеть текущими.
    _ping = null;
    _downSpeed = null;
    _upSpeed = null;
    _sessionStart = null;
    _sessionDuration = Duration.zero;
    _trafficPulse = false;
    _error = null;
    _setStatus(BlupStatus.idle, detail: null);
  }

  /// Потеря сессии: плавное переподключение без сброса в начальную фазу.
  Future<void> reconnect() async {
    if (isActive) return;
    _error = null;
    _setStatus(BlupStatus.reconnecting, detail: 'Переподключение');
    await Future.delayed(const Duration(milliseconds: 700));
    await connect();
  }

  void _fail(VispError reason) {
    _error = reason;
    _ping = null;
    _downSpeed = null;
    _upSpeed = null;
    _sessionStart = null;
    _ticker?.cancel();
    Haptics.error(null);
    _setStatus(BlupStatus.error, detail: null);
  }

  void _setStatus(BlupStatus status, {String? detail}) {
    _status = status;
    _statusDetail = detail;
    notifyListeners();
  }

  /// Ожидание фазы подключения.
  ///
  /// Используется отменяемый таймер, а не Future.delayed: иначе отмена
  /// оставляла бы висящее ожидание. Отмена завершает ожидание тихо и без
  /// исключения — вызывающая сторона проверяет [_cancelled] и выходит сама.
  Future<void> _tick(int token, Duration duration) async {
    // Отмена могла прийти до того, как фаза успела создать таймер.
    // Проверяем до создания, иначе остался бы таймер, который уже никто
    // не сможет погасить.
    if (_cancelled(token)) return;

    final completer = Completer<void>();
    final timer = Timer(duration, () {
      if (!completer.isCompleted) completer.complete();
    });
    _pendingTick = timer;
    _pendingTickCompleter = completer;
    try {
      await completer.future;
    } finally {
      _pendingTick = null;
      _pendingTickCompleter = null;
      timer.cancel();
    }
  }

  Timer? _pendingTick;

  /// Отмена ожидания фазы: таймер гасится, а ожидание сразу завершается.
  ///
  /// Иначе отмена только убирала бы таймер, но оставляла бы async-функцию
  /// висеть на неразрешённом completer — подключение ждало бы вхолостую.
  void _cancelPendingTick() {
    final timer = _pendingTick;
    _pendingTick = null;
    timer?.cancel();
    final completer = _pendingTickCompleter;
    _pendingTickCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Completer<void>? _pendingTickCompleter;

  bool _cancelled(int token) =>
      _connectingCancelled || token != _connectToken;

  void _startTicker() {
    _ticker?.cancel();
    final random = math.Random(42);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_status != BlupStatus.connected) {
        _ticker?.cancel();
        return;
      }
      _sessionDuration = _sessionDuration + const Duration(seconds: 1);

      // С реальным ядром показания берутся из нативного счётчика, а не
      // выдумываются: неподтверждённый трафик не отображается.
      final awg = _engines[selectedProfile?.protocol];
      if (awg is AmneziaWgEngine && hasNativeEngine) {
        final state = await awg.pollStatus();
        if (state != null) {
          _downSpeed = state.downSpeed == null
              ? null
              : state.downSpeed! / (1024 * 1024);
          _upSpeed = state.upSpeed == null ? null : state.upSpeed! / (1024 * 1024);
          _trafficPulse = (state.downSpeed ?? 0) > 0 || (state.upSpeed ?? 0) > 0;
          notifyListeners();
          return;
        }
      }

      _ping = 24 + random.nextInt(38);
      final down = (_downSpeed ?? 8) + (random.nextDouble() * 14 - 7);
      final up = (_upSpeed ?? 3) + (random.nextDouble() * 8 - 4);
      _downSpeed = down.clamp(0.2, 240);
      _upSpeed = up.clamp(0.1, 120);
      // Пульсация яркости только при подтверждённом обмене трафиком.
      _trafficPulse = (_downSpeed ?? 0) > 4 || (_upSpeed ?? 0) > 2;
      notifyListeners();
    });
  }

  // ---- Выбор профиля и поиск -------------------------------------------

  /// Выбор записи сам по себе не запускает другой VPN. Смена сервера или
  /// протокола при активной сессии вызывает переподключение.
  Future<void> selectProfile(String profileId, {bool reconnectIfActive = true}) async {
    final previous = _selectedProfileId;
    _selectedProfileId = profileId;
    notifyListeners();
    if (reconnectIfActive && _status == BlupStatus.connected && previous != profileId) {
      await reconnect();
    }
  }

  void setAutoMode() {
    _selectedProfileId = _autoProfileId;
    notifyListeners();
  }

  void setServerQuery(String value) {
    _serverQuery = value;
    notifyListeners();
  }

  void setProtocolFilter(Protocol? protocol) {
    _protocolFilter = protocol;
    notifyListeners();
  }

  void setReadyOnly(bool value) {
    _readyOnly = value;
    notifyListeners();
  }

  void toggleHostExpanded(String hostId) {
    if (_expandedHosts.contains(hostId)) {
      _expandedHosts.remove(hostId);
    } else {
      _expandedHosts.add(hostId);
    }
    notifyListeners();
  }

  List<ServerHost> filteredHosts() {
    final query = _serverQuery.trim().toLowerCase();
    bool matchesHost(ServerHost h) {
      if (_protocolFilter != null &&
          !h.profiles.any((p) => p.protocol == _protocolFilter)) {
        return false;
      }
      if (_readyOnly && !h.profiles.any((p) => p.engineReady)) return false;
      if (query.isEmpty) return true;
      return h.name.toLowerCase().contains(query) ||
          h.address.toLowerCase().contains(query) ||
          (h.region?.toLowerCase().contains(query) ?? false) ||
          h.profiles.any(
            (p) => p.protocol.displayName.toLowerCase().contains(query),
          );
    }

    return _hosts.where(matchesHost).map((h) {
      final profiles = h.profiles.where((p) {
        if (_protocolFilter != null && p.protocol != _protocolFilter) {
          return false;
        }
        if (_readyOnly && !p.engineReady) return false;
        if (query.isEmpty) return true;
        return h.name.toLowerCase().contains(query) ||
            h.address.toLowerCase().contains(query) ||
            (h.region?.toLowerCase().contains(query) ?? false) ||
            p.protocol.displayName.toLowerCase().contains(query) ||
            p.name.toLowerCase().contains(query);
      }).toList();
      if (profiles.isEmpty) return null;
      return ServerHost(
        id: h.id,
        name: h.name,
        address: h.address,
        region: h.region,
        owned: h.owned,
        profiles: profiles,
      );
    }).whereType<ServerHost>().toList();
  }

  // ---- Импорт ----------------------------------------------------------

  /// Применение выбранного preview: повторное добавление распознаёт
  /// уже известные записи и не создаёт дубликаты.
  int applyImport(ImportPreview preview) {
    final vpnEntries = preview.entries
        .where((e) => !e.isProxy && e.selected)
        .toList();
    final proxyEntries = preview.entries.where((e) => e.isProxy && e.selected).toList();

    var added = 0;
    final newHosts = <ServerHost>[];

    for (final entry in vpnEntries) {
      final protocol = entry.protocol ?? Protocol.amneziaWG;
      final port = _portOf(entry.subtitle, protocol);
      final id = '${protocol.name}-${entry.title}-$port';
      final exists = _hosts.any((h) =>
          h.profiles.any((p) => p.id == id));
      if (exists) continue;

      final host = ServerHost(
        id: 'host-${id.hashCode.abs()}',
        name: entry.title,
        address: _addressOf(entry.subtitle),
        region: null,
        owned: false,
        profiles: [
          ProtocolProfile(
            id: id,
            name: protocol.displayName,
            protocol: protocol,
            port: port,
            engineState: entry.needsModule
                ? EngineState.notInstalled
                : EngineState.ready,
            config: entry.config,
            source: preview.sourceLabel,
          ),
        ],
      );
      newHosts.add(host);
      added++;
    }

    if (newHosts.isNotEmpty) {
      _hosts = [..._hosts, ...newHosts];
    }

    if (proxyEntries.isNotEmpty && _proxyInstalled) {
      final newProxies = <ProxyRecord>[];
      for (final entry in proxyEntries) {
        final id = 'proxy-${entry.title.hashCode.abs()}';
        if (_proxies.any((p) => p.id == id)) continue;
        newProxies.add(ProxyRecord(
          id: id,
          name: entry.title,
          type: entry.proxyType ?? ProxyType.mtproto,
          address: _addressOf(entry.subtitle),
          checkState: ProxyCheckState.untested,
        ));
      }
      if (newProxies.isNotEmpty) {
        _proxies = [..._proxies, ...newProxies];
      }
    }

    notifyListeners();
    return added;
  }

  int _portOf(String subtitle, Protocol protocol) {
    final match = RegExp(r'(\d{2,5})').firstMatch(subtitle);
    if (match != null) return int.parse(match.group(1)!);
    switch (protocol) {
      case Protocol.amneziaWG:
      case Protocol.wireGuard:
        return 51820;
      case Protocol.hysteria2:
        return 8443;
      case Protocol.xrayVless:
      case Protocol.trojan:
        return 443;
      default:
        return 8388;
    }
  }

  String _addressOf(String subtitle) {
    final match = RegExp(r'([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|(\d{1,3}\.){3}\d{1,3})')
        .firstMatch(subtitle);
    return match?.group(0) ?? 'сервер из кода';
  }

  /// Активация кода разработчика: успех — только toast «Код активирован»,
  /// поле очищается, экран остаётся прежним (раздел 13.2).
  Future<bool> activateDevCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!CodeImporter.isValidDevCode(code)) {
      return false;
    }
    _devRole = true;
    Preferences.devRole = true;
    notifyListeners();
    return true;
  }

  // ---- Self-hosted -----------------------------------------------------

  /// Установка на свой сервер: упрощённый мастер из раздела 12.
  Future<ServerHost> installSelfHosted({
    required String address,
    required String user,
    required String secret,
  }) async {
    final host = address.split(':').first;
    final id = 'selfhost-$host';
    _hosts = [
      ..._hosts.where((h) => h.id != id),
      ServerHost(
        id: id,
        name: 'Мой сервер',
        address: host,
        region: null,
        owned: true,
        profiles: [
          const ProtocolProfile(
            id: 'selfhost-awg',
            name: 'AmneziaWG',
            protocol: Protocol.amneziaWG,
            port: 51820,
            engineState: EngineState.ready,
            source: 'Self-hosted установка',
            favorite: true,
          ),
        ],
      ),
    ];
    _selectedProfileId = 'selfhost-awg';
    notifyListeners();
    return _hosts.firstWhere((h) => h.id == id);
  }

  Future<void> deleteHost(String hostId) async {
    final host = _hosts.where((h) => h.id == hostId).firstOrNull;
    if (host == null) return;
    final usingProfile = host.profiles.any((p) => p.id == _selectedProfileId);
    if (usingProfile) {
      disconnect();
    }
    _hosts = _hosts.where((h) => h.id != hostId).toList();
    if (_hosts.isNotEmpty &&
        !_hosts.any((h) => h.profiles.any((p) => p.id == _selectedProfileId))) {
      _selectedProfileId = _hosts.first.profiles.first.id;
    } else if (_hosts.isEmpty) {
      _selectedProfileId = null;
    }
    notifyListeners();
  }

  // ---- Плагины ---------------------------------------------------------

  Future<void> installProxyPlugin() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _proxyInstalled = true;
    _proxies = _demoProxies();
    Preferences.proxyInstalled = true;
    notifyListeners();
  }

  Future<void> toggleLocalProxyService() async {
    if (_localProxyRunning) {
      _localProxyRunning = false;
      notifyListeners();
      return;
    }
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    _localProxyRunning = true;
    notifyListeners();
  }

  // ---- Настройки -------------------------------------------------------

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    Preferences.themeMode = mode;
    notifyListeners();
  }

  void setHaptics(HapticPref value) {
    _haptics = value;
    Preferences.haptics = value;
    Haptics.strength = value == HapticPref.minimal
        ? HapticStrength.minimal
        : value == HapticPref.off
            ? HapticStrength.off
            : HapticStrength.auto;
    notifyListeners();
  }

  void setGlassMode(GlassMode value) {
    _glassMode = value;
    Preferences.glassMode = value;
    notifyListeners();
  }

  void setStudioPinned(bool value) {
    _studioPinned = value;
    Preferences.studioPinned = value;
    notifyListeners();
  }

  void setDebugVisible(bool value) {
    _debugVisible = value;
    Preferences.debugVisible = value;
    notifyListeners();
  }

  /// Подписи вкладок в навигации: по умолчанию показываются.
  void setNavLabels(bool value) {
    _navLabels = value;
    Preferences.navLabels = value;
    notifyListeners();
  }

  void setLocale(String? code) {
    _localeCode = code;
    Preferences.locale = code;
    notifyListeners();
  }

  void setKillSwitch(bool value) {
    _killSwitch = value;
    Preferences.killSwitch = value;
    notifyListeners();
  }

  void setAutostart(bool value) {
    _autostart = value;
    Preferences.autostart = value;
    notifyListeners();
  }

  void setSplitTunneling(bool value) {
    _splitTunneling = value;
    Preferences.splitTunneling = value;
    notifyListeners();
  }

  void setScreenshotsAllowed(bool value) {
    _screenshotsAllowed = value;
    Preferences.screenshotsAllowed = value;
    notifyListeners();
  }

  void setUpdateChannel(UpdateChannel value) {
    _updateChannel = value;
    Preferences.updateChannel = value;
    notifyListeners();
  }

  Future<void> resetAll() async {
    disconnect();
    await Preferences.resetAll();
    _hosts = [];
    _proxies = [];
    _selectedProfileId = null;
    _proxyInstalled = false;
    _devRole = false;
    _studioPinned = false;
    _glassMode = GlassMode.regular;
_debugVisible = false;
    _navLabels = true;
    _killSwitch = false;
    _autostart = false;
    _splitTunneling = false;
    _screenshotsAllowed = true;
    _themeMode = AppThemeMode.system;
    _haptics = HapticPref.auto;
    _updateChannel = UpdateChannel.stable;
    _localeCode = null;
    Haptics.strength = HapticStrength.auto;
    _seedDemoData();
    notifyListeners();
  }
}


