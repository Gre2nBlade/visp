import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_vless/flutter_vless.dart';

import '../models/connection_models.dart';
import 'vpn_engine.dart';

/// Реальный движок на ядре Xray через flutter_vless (раздел 3).
///
/// Поднимает VLESS/REALITY и Hysteria 2. AmneziaWG и olcRTC этим ядром не
/// поддерживаются — для них остаётся [UnavailableEngine] и честный статус
/// «Нужен модуль», пока не будет собрано собственное ядро.
class XrayEngine extends VpnEngine {
  XrayEngine() {
    _controller = FlutterVless(onStatusChanged: _onStatus);
  }

  late final FlutterVless _controller;
  final _stateController = StreamController<EngineSessionState>.broadcast();
  bool _initialized = false;
  bool _connected = false;

  @override
  Set<Protocol> get supportedProtocols => const {
        Protocol.xrayVless,
        Protocol.hysteria2,
        Protocol.vmess,
        Protocol.trojan,
        Protocol.shadowsocks,
      };

  @override
  bool get isAvailable => true;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _controller.initializeVless(
      notificationIconResourceName: 'ic_launcher',
    );
    _initialized = true;
  }

  void _onStatus(VlessStatus status) {
    _connected = status.connectionState == VlessConnectionState.connected;
    _stateController.add(EngineSessionState(
      connected: _connected,
      elapsed: Duration(seconds: status.duration),
      upSpeed: status.uploadSpeed,
      downSpeed: status.downloadSpeed,
      detail: status.state,
    ));
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    return _controller.requestPermission();
  }

  @override
  Future<EngineResult> connect(ProtocolProfile profile) async {
    final config = profile.config;
    final raw = config?.raw;
    if (raw == null || raw.isEmpty) return EngineResult.invalidConfig;

    await _ensureInitialized();
    if (!await requestPermission()) return EngineResult.permissionDenied;

    try {
      // flutter_vless сам разбирает ссылку и генерирует Xray JSON.
      final url = FlutterVless.parseFromURL(raw);
      final xrayConfig = url.getFullConfiguration();
      await _controller.startVless(
        remark: profile.name,
        config: xrayConfig,
        blockedApps: null,
        bypassSubnets: null,
      );
      return EngineResult.connected;
    } on ArgumentError {
      return EngineResult.invalidConfig;
    } catch (e) {
      debugPrint('XrayEngine connect failed: $e');
      return EngineResult.failed;
    }
  }

  @override
  Future<void> disconnect() async {
    await _ensureInitialized();
    await _controller.stopVless();
    _connected = false;
  }

  @override
  Stream<EngineSessionState> get stateStream => _stateController.stream;

  @override
  Future<String> get coreVersion async {
    await _ensureInitialized();
    try {
      return await _controller.getCoreVersion();
    } catch (_) {
      return 'Xray (версия недоступна)';
    }
  }

  @override
  void dispose() {
    _stateController.close();
  }

  /// Служебный доступ для экранов диагностики.
  FlutterVless get controller => _controller;

  /// Кодирование JSON-конфига для отладочного вывода.
  String prettyConfig(String config) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(config));
    } catch (_) {
      return config;
    }
  }
}
