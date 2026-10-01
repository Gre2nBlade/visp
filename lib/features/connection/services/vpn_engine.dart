import '../models/connection_models.dart';

/// Результат попытки подключения движка.
enum EngineResult {
  connected,
  permissionDenied,
  invalidConfig,
  engineMissing,
  failed,
}

/// Состояние сессии от реального движка.
class EngineSessionState {
  final bool connected;
  final Duration? elapsed;
  final int? upSpeed; // bytes/s
  final int? downSpeed; // bytes/s
  final int? pingMs;
  final String? detail;

  const EngineSessionState({
    required this.connected,
    this.elapsed,
    this.upSpeed,
    this.downSpeed,
    this.pingMs,
    this.detail,
  });
}

/// Контракт VPN-движка (раздел 3.4).
///
/// UI работает только с этим интерфейсом, поэтому нативный движок
/// (gomobile, VPN service) заменяет mock-реализацию без правок экранов.
abstract class VpnEngine {
  /// Протоколы, которые умеет поднимать этот движок.
  Set<Protocol> get supportedProtocols;

  /// Движок готов к работе на этой платформе (ядро в комплекте).
  bool get isAvailable;

  /// Запросить разрешение ОС на туннель (VPN permission на Android).
  Future<bool> requestPermission();

  /// Поднять туннель по профилю. Возвращает результат попытки.
  Future<EngineResult> connect(ProtocolProfile profile);

  /// Остановить туннель.
  Future<void> disconnect();

  /// Поток состояний сессии для отладочного блока и статуса.
  Stream<EngineSessionState> get stateStream;

  /// Версия ядра для каталога (раздел 3: «последняя проверенная версия»).
  Future<String> get coreVersion;

  /// Освободить ресурсы.
  void dispose();
}

/// Заглушка-протокол: движка для протокола нет в комплекте, ядро требуется
/// собирать отдельно (AmneziaWG, olcRTC). UI показывает честный статус.
class UnavailableEngine extends VpnEngine {
  UnavailableEngine(this._missingProtocols);

  final Set<Protocol> _missingProtocols;

  @override
  Set<Protocol> get supportedProtocols => _missingProtocols;

  @override
  bool get isAvailable => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<EngineResult> connect(ProtocolProfile profile) async =>
      EngineResult.engineMissing;

  @override
  Future<void> disconnect() async {}

  @override
  Stream<EngineSessionState> get stateStream => const Stream.empty();

  @override
  Future<String> get coreVersion async => 'нет ядра';

  @override
  void dispose() {}
}
