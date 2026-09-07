package io.github.friesi23.mhabit

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

/** Short, user-triggered local work. No Activity, foreground service or network. */
class WishLoopWidgetJob : JobService() {
    companion object {
        private const val JOB = 6202
        private const val PREFS = "wishloop_widget_actions"
        private const val CHANNEL = "io.github.friesi23.mhabit/wishloop_widget_background"
        private var active: WishLoopWidgetJob? = null
        private var lastTap = 0L
        private fun prefs(context: Context) = context.getSharedPreferences(PREFS, MODE_PRIVATE)
        private fun read(context: Context): MutableList<JSONObject> {
            val array = JSONArray(prefs(context).getString("queue", "[]"))
            return (0 until array.length()).map { array.getJSONObject(it) }.toMutableList()
        }
        private fun write(context: Context, queue: List<JSONObject>) {
            check(prefs(context).edit().putString("queue", JSONArray(queue).toString()).commit())
        }
        fun pending(context: Context, id: String): Boolean = read(context).any { it.optString("hobbyId") == id }
        fun failed(context: Context): Boolean = prefs(context).getBoolean("failed", false)

        fun enqueue(context: Context, day: String = "", hobby: String = "", amount: Long = 0) {
            val now = android.os.SystemClock.elapsedRealtime()
            // Ignore a double-tap after a just-completed tile has been replaced.
            if (hobby.isNotEmpty() && now - lastTap < 650) return
            if (hobby.isNotEmpty()) lastTap = now
            val queue = read(context)
            if (queue.none { it.optString("hobbyId") == hobby && it.optString("day") == day }) {
                queue.add(JSONObject().put("id", UUID.randomUUID().toString())
                    .put("hobbyId", hobby).put("day", day).put("amountMinor", amount)
                    .put("created", System.currentTimeMillis()).put("claimed", false))
                write(context, queue.take(8))
            }
            prefs(context).edit().putBoolean("failed", false).apply()
            WishLoopWidgetProvider.updateAll(context)
            if (active == null) schedule(context)
        }

        private fun schedule(context: Context) {
            val scheduler = context.getSystemService(JobScheduler::class.java)
            fun builder() = JobInfo.Builder(JOB, ComponentName(context, WishLoopWidgetJob::class.java))
            val fast = if (Build.VERSION.SDK_INT >= 31) builder().setExpedited(true).build()
                else builder().setOverrideDeadline(0).build()
            if (scheduler.schedule(fast) != JobScheduler.RESULT_SUCCESS &&
                scheduler.schedule(builder().setOverrideDeadline(0).build()) != JobScheduler.RESULT_SUCCESS) {
                write(context, emptyList())
                prefs(context).edit().putBoolean("failed", true).apply()
                WishLoopWidgetProvider.updateAll(context)
            }
        }
    }

    private var engine: FlutterEngine? = null
    private var channel: MethodChannel? = null
    private var params: JobParameters? = null
    private val handler = Handler(Looper.getMainLooper())
    private val deadline = Runnable { fail("Background widget operation timed out") }

    override fun onStartJob(parameters: JobParameters): Boolean {
        active = this
        refreshed = false
        params = parameters
        // Claimed requests are never replayed after interruption. A transaction
        // may already have committed and subsequently been undone in the app.
        val queue = read(this)
        val fresh = queue.filter { !it.optBoolean("claimed") &&
            System.currentTimeMillis() - it.optLong("created") in 0..15_000 }
        if (queue.size != fresh.size) prefs(this).edit().putBoolean("failed", true).apply()
        write(this, fresh)
        handler.postDelayed(deadline, 25_000)
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(applicationContext)
        loader.ensureInitializationCompleteAsync(applicationContext, null, handler) {
            if (params !== parameters) return@ensureInitializationCompleteAsync
            try {
                val flutter = FlutterEngine(applicationContext)
                engine = flutter
                channel = MethodChannel(flutter.dartExecutor.binaryMessenger, CHANNEL).also { bridge ->
                    bridge.setMethodCallHandler { call, result ->
                        if (params !== parameters) {
                            result.error("WIDGET_STOPPED", "The widget job has ended", null)
                            return@setMethodCallHandler
                        }
                        when (call.method) {
                            "ready" -> { result.success(null); next() }
                            "failed" -> { result.success(null); fail("Flutter widget initialization failed") }
                            "beginSnapshot" -> result.success(WidgetSnapshotOrder.next())
                            "updateSnapshot" -> {
                                try { WishLoopWidgetProvider.saveArguments(this, call.arguments); result.success(null) }
                                catch (e: Exception) { result.error("WIDGET_SNAPSHOT", e.message, null) }
                            }
                            else -> result.notImplemented()
                        }
                    }
                }
                flutter.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint(
                    loader.findAppBundlePath(),
                    "package:mhabit/platform/wishloop_widget_background.dart", "wishLoopWidgetBackground"))
            } catch (e: Exception) { fail("Cannot start widget engine", e) }
        }
        return true
    }

    private var refreshed = false
    private fun next() {
        val operation = params ?: return
        val queue = read(this)
        val request = queue.firstOrNull()
        if (request == null && refreshed) { finish(); return }
        if (request != null) {
            if (System.currentTimeMillis() - request.optLong("created") !in 0..15_000) {
                queue.removeAt(0); write(this, queue)
                prefs(this).edit().putBoolean("failed", true).apply()
                next(); return
            }
            request.put("claimed", true)
            write(this, queue) // Persist before invoking Dart; no automatic replay.
        }
        refreshed = true
        val arguments = mutableMapOf<String, Any>("hobbyId" to "", "day" to "", "amountMinor" to 0L,
            "theme" to (WishLoopWidgetProvider.readSnapshot(this)?.optString("theme") ?: "system"))
        if (request != null) {
            arguments["hobbyId"] = request.optString("hobbyId")
            arguments["day"] = request.optString("day")
            arguments["amountMinor"] = request.optLong("amountMinor")
        }
        channel?.invokeMethod("complete", arguments, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (params !== operation) return
                if (request != null) write(this@WishLoopWidgetJob,
                    read(this@WishLoopWidgetJob).filter { it.optString("id") != request.optString("id") })
                WishLoopWidgetProvider.updateAll(this@WishLoopWidgetJob)
                MainActivity.widgetUpdated()
                next()
            }
            override fun error(code: String, message: String?, details: Any?) {
                if (params === operation) fail("$code: $message")
            }
            override fun notImplemented() {
                if (params === operation) fail("Widget entry point is unavailable")
            }
        })
    }

    private fun fail(message: String, error: Exception? = null) {
        if (params == null) return
        Log.e("WishLoopWidget", message, error)
        write(this, emptyList())
        prefs(this).edit().putBoolean("failed", true).apply()
        WishLoopWidgetProvider.updateAll(this)
        MainActivity.widgetUpdated()
        finish()
    }

    private fun finish() {
        val parameters = params ?: return
        params = null
        if (active === this) active = null
        handler.removeCallbacks(deadline)
        releaseEngine()
        jobFinished(parameters, false)
    }

    private fun releaseEngine() {
        val oldEngine = engine ?: return
        val oldChannel = channel
        engine = null; channel = null
        var released = false
        fun destroy() { if (!released) { released = true; oldEngine.destroy() } }
        oldChannel?.invokeMethod("close", null, object : MethodChannel.Result {
            override fun success(result: Any?) { destroy() }
            override fun error(code: String, message: String?, details: Any?) { destroy() }
            override fun notImplemented() { destroy() }
        })
        handler.postDelayed({ destroy() }, 5_000)
    }

    override fun onStopJob(parameters: JobParameters): Boolean {
        if (params !== parameters) return false
        params = null
        if (active === this) active = null
        handler.removeCallbacks(deadline)
        write(this, emptyList())
        prefs(this).edit().putBoolean("failed", true).apply()
        WishLoopWidgetProvider.updateAll(this)
        releaseEngine()
        return false // An interrupted monetary action requires an explicit retry.
    }
}

/** Orders snapshots from the UI engine and headless engine in one process. */
internal object WidgetSnapshotOrder {
    private var issued = 0L
    private var applied = 0L
    @Synchronized fun next(): Long = ++issued
    @Synchronized fun accept(generation: Long): Boolean {
        if (generation < applied) return false
        applied = generation
        return true
    }
}
