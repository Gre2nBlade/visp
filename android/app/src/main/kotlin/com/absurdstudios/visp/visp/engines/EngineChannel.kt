package com.absurdstudios.visp.visp.engines

import android.content.Intent
import android.net.VpnService
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Канал между Dart и нативным движком AmneziaWG.
 *
 * Контракт намеренно узкий: примитивы и строки, без объектов и указателей.
 * Dart никогда не касается Go напрямую — только через этот канал.
 */
class EngineChannel(
    private val engine: FlutterEngine,
    private val host: android.app.Activity
) : MethodChannel.MethodCallHandler {

    private val channel: MethodChannel

    init {
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasEngine" -> result.success(true)
            "requestPermission" -> requestPermission(call, result)
            "startTunnel" -> startTunnel(call, result)
            "stopTunnel" -> stopTunnel(result)
            else -> result.notImplemented()
        }
    }

    private fun requestPermission(call: MethodCall, result: MethodChannel.Result) {
        val consent = VpnService.prepare(host)
        if (consent == null) {
            // Разрешение уже выдано ранее.
            result.success(true)
            return
        }
        // Ответ придёт в onActivityResult главной Activity.
        host.startActivityForResult(consent, REQUEST_CODE)
        result.success(false)
    }

    private fun startTunnel(call: MethodCall, result: MethodChannel.Result) {
        val uapi = call.argument<String>("uapi")
        if (uapi.isNullOrBlank()) {
            result.error("no_config", "Пустая конфигурация", null)
            return
        }

        val intent = Intent(host, AmneziaWgVpnService::class.java).apply {
            action = AmneziaWgVpnService.ACTION_CONNECT
            putExtra(AmneziaWgVpnService.EXTRA_UAPI, uapi)
            putExtra(
                AmneziaWgVpnService.EXTRA_MTU,
                call.argument<Int>("mtu") ?: AmneziaWgVpnService.DEFAULT_MTU
            )
            // putExtra для массивов не принимает null: кладём только заданные ключи.
            call.argument<List<String>>("addresses")?.let {
                putExtra(AmneziaWgVpnService.EXTRA_ADDRESSES, it.toTypedArray())
            }
            call.argument<List<String>>("routes")?.let {
                putExtra(AmneziaWgVpnService.EXTRA_ROUTES, it.toTypedArray())
            }
            call.argument<List<String>>("dns")?.let {
                putExtra(AmneziaWgVpnService.EXTRA_DNS, it.toTypedArray())
            }
            call.argument<List<String>>("excludePackages")?.let {
                putExtra(AmneziaWgVpnService.EXTRA_EXCLUDE_PACKAGES, it.toTypedArray())
            }
            call.argument<String>("label")?.let {
                putExtra(AmneziaWgVpnService.EXTRA_LABEL, it)
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                host.startForegroundService(intent)
            } catch (e: Exception) {
                result.error("start_failed", e.message, null)
                return
            }
        } else {
            host.startService(intent)
        }
        result.success(true)
    }

    private fun stopTunnel(result: MethodChannel.Result) {
        val intent = Intent(host, AmneziaWgVpnService::class.java).apply {
            action = AmneziaWgVpnService.ACTION_DISCONNECT
        }
        host.startService(intent)
        result.success(true)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    companion object {
        const val CHANNEL = "com.absurdstudios.visp.visp/engine_amneziawg"
        const val PERMISSION_CHANNEL = "com.absurdstudios.visp.visp/engine_permission"
        const val REQUEST_CODE = 4211
    }
}
