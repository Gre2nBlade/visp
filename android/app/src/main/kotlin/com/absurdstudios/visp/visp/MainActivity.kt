package com.absurdstudios.visp.visp

import android.content.Intent
import com.absurdstudios.visp.visp.engines.EngineChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var engineChannel: EngineChannel? = null
    private var permissionChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        engineChannel = EngineChannel(flutterEngine, this)
        // Отдельный канал для ответа Android на запрос VPN-разрешения.
        permissionChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EngineChannel.PERMISSION_CHANNEL
        )
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == EngineChannel.REQUEST_CODE) {
            val granted = resultCode == RESULT_OK
            permissionChannel?.invokeMethod(
                "result",
                mapOf("granted" to granted)
            )
        }
    }

    override fun onDestroy() {
        engineChannel?.dispose()
        engineChannel = null
        permissionChannel = null
        super.onDestroy()
    }
}
