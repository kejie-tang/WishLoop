package io.github.friesi23.mhabit

import android.app.Activity
import android.content.Intent
import java.io.File
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val ANIMATION_SCALE_CHANNEL = "global.app.animation/scale_stream"
    }

    private var animationScaleHandler: AnimationScaleStreamHandler? = null
    private var backupResult: MethodChannel.Result? = null
    private var backupSource: File? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        animationScaleHandler?.dispose()
        val handler = AnimationScaleStreamHandler(contentResolver)
        animationScaleHandler = handler

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger, ANIMATION_SCALE_CHANNEL
        ).setStreamHandler(handler)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "io.github.friesi23.mhabit/wishloop_backup").setMethodCallHandler { call, result ->
            if (call.method != "saveBackup") {
                result.notImplemented()
            } else if (backupResult != null) {
                result.error("BUSY", "A document picker is already open", null)
            } else {
                try {
                    val source = File(requireNotNull(call.argument<String>("path"))).canonicalFile
                    require(source.isFile && source.path.startsWith(File(applicationInfo.dataDir).canonicalPath + "/"))
                    val name = File(call.argument<String>("name") ?: "WishLoop.json").name
                    backupSource = source
                    backupResult = result
                    startActivityForResult(Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "application/json"
                        putExtra(Intent.EXTRA_TITLE, name)
                    }, 6201)
                } catch (error: Exception) {
                    backupResult = null
                    backupSource = null
                    result.error("EXPORT_FAILED", error.message, null)
                }
            }
        }
    }

    @Deprecated("Activity result callback retained for FlutterActivity compatibility")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 6201) return
        val result = backupResult ?: return
        val source = backupSource
        backupResult = null
        backupSource = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null || source == null) {
            result.success(false)
            return
        }
        Thread {
            try {
                source.inputStream().use { input ->
                    requireNotNull(contentResolver.openOutputStream(uri, "wt")).use { output ->
                        input.copyTo(output)
                        output.flush()
                    }
                }
                runOnUiThread { result.success(true) }
            } catch (error: Exception) {
                runOnUiThread { result.error("EXPORT_FAILED", error.message, null) }
            }
        }.start()
    }

    override fun onDestroy() {
        animationScaleHandler?.dispose()
        animationScaleHandler = null
        super.onDestroy()
    }
}
