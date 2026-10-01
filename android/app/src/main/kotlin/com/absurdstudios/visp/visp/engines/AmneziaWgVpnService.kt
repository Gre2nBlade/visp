package com.absurdstudios.visp.visp.engines

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log

/**
 * VpnService для AmneziaWG.
 *
 * Граница доверия (docs/ENGINES.md):
 *  - этот класс владеет ТОЛЬКО Android API: разрешением, дескриптором tun и уведомлением;
 *  - криптографией и туннелем занимается Go-ядро, полученное по дескриптору;
 *  - наружу уходят только целое число (fd) и сериализованная строка конфигурации.
 *
 * Секреты (private_key, preshared_key) не пишутся в лог и не покидают Kotlin.
 */
class AmneziaWgVpnService : VpnService() {

    private var bridge: amneziawg.Bridge? = null
    private var tunInterface: ParcelFileDescriptor? = null

    override fun onCreate() {
        super.onCreate()
        bridge = amneziawg.Bridge()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_CONNECT -> startFromIntent(intent)
            ACTION_DISCONNECT -> stopTunnel()
        }
        // Система может перезапустить сервис; состояние туннеля не восстанавливаем.
        return START_NOT_STICKY
    }

    private fun startFromIntent(intent: Intent) {
        val uapi = intent.getStringExtra(EXTRA_UAPI)
        if (uapi.isNullOrBlank()) {
            Log.w(TAG, "connect without uapi")
            stopTunnel()
            return
        }

        val mtu = intent.getIntExtra(EXTRA_MTU, DEFAULT_MTU)
        val addresses = intent.getStringArrayExtra(EXTRA_ADDRESSES) ?: emptyArray()
        val routes = intent.getStringArrayExtra(EXTRA_ROUTES) ?: emptyArray()
        val dnsServers = intent.getStringArrayExtra(EXTRA_DNS) ?: emptyArray()
        val includePackages = intent.getStringArrayExtra(EXTRA_INCLUDE_PACKAGES) ?: emptyArray()
        val excludePackages = intent.getStringArrayExtra(EXTRA_EXCLUDE_PACKAGES) ?: emptyArray()

        val builder = Builder()
            .setSession(intent.getStringExtra(EXTRA_LABEL) ?: "Visp")
            .setMtu(mtu)

        if (addresses.isNotEmpty()) {
            builder.addAddress(addresses[0], addresses.getOrNull(1)?.toIntOrNull() ?: 32)
        }
        if (dnsServers.isNotEmpty()) {
            dnsServers.firstOrNull()?.let { builder.addDnsServer(it) }
        }
        if (routes.isNotEmpty()) {
            builder.addRoute(routes[0], routes.getOrNull(1)?.toIntOrNull() ?: 0)
        } else {
            builder.addRoute("0.0.0.0", 0)
        }
        if (includePackages.isNotEmpty()) {
            builder.addDisallowedApplication(packageName)
            includePackages.forEach(builder::addAllowedApplication)
        }
        excludePackages.forEach(builder::addDisallowedApplication)

        val descriptor = try {
            builder.establish()
        } catch (e: Exception) {
            Log.e(TAG, "establish failed: ${e.message}")
            null
        }

        if (descriptor == null) {
            Log.w(TAG, "no tun descriptor")
            stopTunnel()
            return
        }

        tunInterface = descriptor

        // Дескриптор tun уходит в Go как целое число; указатели через JNI не
        // передаются. gomobile отображает Go int в long, поэтому приводим явно.
        val fd = descriptor.detachFd().toLong()
        val result = runCatching { bridge?.connect(fd, uapi) }
        if (result.isFailure) {
            Log.e(TAG, "core rejected config: ${result.exceptionOrNull()?.message}")
            stopTunnel()
        }
    }

    private fun stopTunnel() {
        runCatching { bridge?.disconnect() }
        runCatching { tunInterface?.close() }
        tunInterface = null
        stopForegroundSafely()
        stopSelf()
    }

    private fun stopForegroundSafely() {
        runCatching { if (BuildVersion.isAtLeastQ()) stopForeground(STOP_FOREGROUND_REMOVE) }
    }

    override fun onDestroy() {
        stopTunnel()
        runCatching { bridge?.free() }
        bridge = null
        super.onDestroy()
    }

    override fun onRevoke() {
        // Пользователь или система отозвали VPN: туннель обязан упасть.
        Log.w(TAG, "tun revoked")
        stopTunnel()
        super.onRevoke()
    }

    private object BuildVersion {
        fun isAtLeastQ(): Boolean =
            android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q
    }

    companion object {
        private const val TAG = "VispAWG"
        const val DEFAULT_MTU = 1420

        const val ACTION_CONNECT = "com.absurdstudios.visp.visp.CONNECT_AWG"
        const val ACTION_DISCONNECT = "com.absurdstudios.visp.visp.DISCONNECT_AWG"

        const val EXTRA_UAPI = "uapi"
        const val EXTRA_MTU = "mtu"
        const val EXTRA_ADDRESSES = "addresses"
        const val EXTRA_ROUTES = "routes"
        const val EXTRA_DNS = "dns"
        const val EXTRA_LABEL = "label"
        const val EXTRA_INCLUDE_PACKAGES = "includePackages"
        const val EXTRA_EXCLUDE_PACKAGES = "excludePackages"
    }
}
