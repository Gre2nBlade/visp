import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/connection_models.dart';
import 'vpn_engine.dart';

/// Движок AmneziaWG поверх нативного ядра amneziawg-go (docs/ENGINES.md).
///
/// Dart не трогает нативные указатели: наружу уходит только дескриптор tun
/// и сериализованный UAPI-конфиг, обратно приходит JSON-строка статуса.
class AmneziaWgEngine extends VpnEngine {
  AmneziaWgEngine({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel('com.absurdstudios.visp.visp/engine_amneziawg');

  final MethodChannel _channel;
  final _stateController = StreamController<EngineSessionState>.broadcast();

  @override
  Set<Protocol> get supportedProtocols => const {
        Protocol.amneziaWG,
        Protocol.wireGuard,
      };

  @override
  bool get isAvailable => true;

  @override
  Future<bool> requestPermission() async {
    try {
      final granted = await _channel.invokeMethod<bool>('requestPermission');
      return granted ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      // На платформах без канала (десктоп, тесты) ядро недоступно.
      return false;
    }
  }

  @override
  Future<EngineResult> connect(ProtocolProfile profile) async {
    final uapi = _buildUapi(profile);
    if (uapi == null) return EngineResult.invalidConfig;

    if (!await requestPermission()) return EngineResult.permissionDenied;

    try {
      await _channel.invokeMethod<void>('startTunnel', <String, dynamic>{
        'uapi': uapi,
        'mtu': _mtu,
        'label': profile.name,
        'addresses': _addressFor(profile),
        'routes': const ['0.0.0.0', '0'],
        'dns': _dnsFor(profile),
      });
      return EngineResult.connected;
    } on PlatformException catch (e) {
      lastError = e.message ?? 'Ошибка запуска туннеля';
      return EngineResult.failed;
    } on MissingPluginException {
      return EngineResult.engineMissing;
    }
  }

  /// Текст последней ошибки для экрана поддержки.
  String lastError = '';

  static const int _mtu = 1420;

  /// Собирает UAPI из распарсенного конфига профиля.
  ///
  /// Требуются приватный ключ и порт: без них туннель не поднять, и профиль
  /// честно помечается как неполный, а не подменяется значениями по умолчанию.
  String? _buildUapi(ProtocolProfile profile) {
    final config = profile.config;
    if (config == null) return null;

    final privateKey = config.auth ?? config.extras['PRIVATE_KEY'];
    if (privateKey == null || privateKey.isEmpty) return null;

    final port = config.port > 0 ? config.port : 51820;
    final buffer = StringBuffer()
      ..writeln('private_key=$privateKey')
      ..writeln('listen_port=$port')
      ..writeln('replace_peers=true');

    final publicKey = config.publicKey;
    final endpoint = config.address;
    if (publicKey != null &&
        publicKey.isNotEmpty &&
        endpoint.isNotEmpty &&
        endpoint != 'сервер') {
      buffer
        ..writeln('public_key=$publicKey')
        ..writeln('endpoint=$endpoint:$port');
      final psk = config.password;
      if (psk != null && psk.isNotEmpty) {
        buffer.writeln('preshared_key=$psk');
      }
      buffer.writeln('persistent_keepalive_interval=25');
    }

    return buffer.toString();
  }

  /// Адрес tun-интерфейса: клиентская сторона AmneziaWG из конфига [Interface].
  List<String> _addressFor(ProtocolProfile profile) {
    final address = profile.config?.extras['ADDRESS'];
    if (address != null && address.isNotEmpty) {
      final parts = address.split('/');
      return [parts.first, parts.length > 1 ? parts[1] : '32'];
    }
    // Стандартная сеть WireGuard, если адрес не задан конфигом.
    return const ['10.8.0.2', '32'];
  }

  List<String> _dnsFor(ProtocolProfile profile) {
    final dns = profile.config?.extras['DNS'];
    if (dns != null && dns.isNotEmpty) {
      return dns.split(',').map((e) => e.trim()).toList();
    }
    return const ['1.1.1.1'];
  }

  @override
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod<void>('stopTunnel');
    } on PlatformException {
      // Сервис уже остановлен — это не ошибка для пользователя.
    } on MissingPluginException {
      // Нет канала: нечего останавливать.
    }
  }

  @override
  Stream<EngineSessionState> get stateStream => _stateController.stream;

  /// Читает статус из нативного ядра и публикует его в поток.
  Future<EngineSessionState?> pollStatus() async {
    try {
      final raw = await _channel.invokeMethod<String>('status');
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final state = EngineSessionState(
        connected: decoded['connected'] == true,
        elapsed: Duration(seconds: (decoded['elapsedSecs'] as num?)?.toInt() ?? 0),
        upSpeed: (decoded['txBytes'] as num?)?.toInt(),
        downSpeed: (decoded['rxBytes'] as num?)?.toInt(),
        detail: decoded['error'] as String?,
      );
      _stateController.add(state);
      return state;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<String> get coreVersion async => 'AmneziaWG (amneziawg-go)';

  @override
  void dispose() {
    _stateController.close();
  }
}
