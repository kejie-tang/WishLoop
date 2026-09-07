package io.github.friesi23.mhabit

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import android.os.Bundle
import android.content.Intent
import java.io.File
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private var widgetEvents: MethodChannel? = null
        fun widgetUpdated() { widgetEvents?.invokeMethod("changed", null) }
        private const val ANIMATION_SCALE_CHANNEL = "global.app.animation/scale_stream"
    }

    private var animationScaleHandler: AnimationScaleStreamHandler? = null
    private var backupResult: MethodChannel.Result? = null
    private var backupSource: File? = null
    private var widgetChannel: MethodChannel? = null
    private var widgetReady = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        animationScaleHandler?.dispose()
        val handler = AnimationScaleStreamHandler(contentResolver)
        animationScaleHandler = handler

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger, ANIMATION_SCALE_CHANNEL
        ).setStreamHandler(handler)

        widgetChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WishLoopWidgetProvider.CHANNEL).also { channel ->
            widgetEvents = channel
            channel.setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "beginSnapshot" -> result.success(WidgetSnapshotOrder.next())
                        "updateSnapshot" -> { WishLoopWidgetProvider.saveArguments(this, call.arguments); result.success(null) }
                        "consumeLaunch" -> { widgetReady = true; result.success(consumeWidgetLaunch()) }
                        "pinWidget" -> {
                            val manager = AppWidgetManager.getInstance(this)
                            result.success(Build.VERSION.SDK_INT >= 26 && manager.isRequestPinAppWidgetSupported && manager.requestPinAppWidget(ComponentName(this, WishLoopWidgetProvider::class.java), Bundle().apply {
                                putParcelable(AppWidgetManager.EXTRA_APPWIDGET_PREVIEW, WishLoopWidgetProvider.preview(this@MainActivity))
                            }, null))
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("WIDGET_FAILED", error.message, null)
                }
            }
        }

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

    private fun consumeWidgetLaunch(): Map<String, String>? {
        val target = intent.getStringExtra(WishLoopWidgetProvider.TARGET) ?: return null
        val hobby = intent.getStringExtra(WishLoopWidgetProvider.HOBBY) ?: ""
        intent.removeExtra(WishLoopWidgetProvider.TARGET)
        intent.removeExtra(WishLoopWidgetProvider.HOBBY)
        if (target !in listOf("today", "wallet", "wishes")) return null
        return mapOf("target" to target, "hobbyId" to hobby)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (widgetReady) consumeWidgetLaunch()?.let { widgetChannel?.invokeMethod("open", it) }
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
        if (widgetEvents === widgetChannel) widgetEvents = null
        animationScaleHandler?.dispose()
        animationScaleHandler = null
        super.onDestroy()
    }
}
