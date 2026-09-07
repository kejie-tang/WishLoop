package io.github.friesi23.mhabit

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.os.Bundle
import android.text.SpannableString
import android.text.Spanned
import android.text.style.AbsoluteSizeSpan
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** The private cache is display-only. All check-ins and ledger writes stay in Dart/SQLite. */
class WishLoopWidgetProvider : AppWidgetProvider() {
    companion object {
        const val CHANNEL = "io.github.friesi23.mhabit/wishloop_widget"
        const val TARGET = "wishloop_widget_target"
        const val HOBBY = "wishloop_widget_hobby"
        private const val COMPLETE = "io.github.friesi23.mhabit.WIDGET_COMPLETE"
        private const val DAY = "wishloop_widget_day"
        private const val AMOUNT = "wishloop_widget_amount"
        private const val PREFS = "wishloop_widget"

        fun saveArguments(context: Context, arguments: Any?) {
            val values = requireNotNull(arguments as? Map<*, *>)
            val json = requireNotNull(values["snapshot"] as? String)
            val generation = requireNotNull(values["generation"] as? Number).toLong()
            require(json.length <= 128_000)
            require(JSONObject(json).optInt("version") == 2)
            if (!WidgetSnapshotOrder.accept(generation)) return
            save(context, json)
        }

        private fun save(context: Context, json: String) {
            require(json.length <= 128_000)
            require(JSONObject(json).optInt("version") == 2)
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString("snapshot", json).apply()
            updateAll(context)
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            manager.getAppWidgetIds(ComponentName(context, WishLoopWidgetProvider::class.java)).forEach {
                update(context, manager, it)
            }
        }

        private fun launch(context: Context, target: String, hobby: String = ""): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                // A distinct action separates PendingIntents without a URI that
                // Flutter would also interpret as an automatic deep link.
                action = "${context.packageName}.widget.$target.$hobby"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra(TARGET, target)
                putExtra(HOBBY, hobby)
            }
            return PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }

        fun preview(context: Context): RemoteViews = render(context, readSnapshot(context), 170)

        fun readSnapshot(context: Context): JSONObject? {
            val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString("snapshot", null)
            return try { raw?.let(::JSONObject) } catch (_: org.json.JSONException) { null }
        }

        private fun complete(context: Context, day: String, row: JSONObject): PendingIntent {
            val id = row.optString("id")
            val amount = row.optLong("amountMinor")
            val intent = Intent(context, WishLoopWidgetProvider::class.java).apply {
                action = COMPLETE
                data = android.net.Uri.parse("wishloop-widget://complete/$day/$id/$amount")
                flags = Intent.FLAG_RECEIVER_FOREGROUND
                putExtra(HOBBY, id); putExtra(DAY, day); putExtra(AMOUNT, amount)
            }
            return PendingIntent.getBroadcast(context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }

        private fun update(context: Context, manager: AppWidgetManager, id: Int) {
            val snapshot = readSnapshot(context)
            val options = manager.getAppWidgetOptions(id)
            // Launcher min/max heights describe landscape/portrait respectively.
            // RemoteViews selects the correct layout when the device rotates.
            manager.updateAppWidget(id, RemoteViews(
                render(context, snapshot, options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)),
                render(context, snapshot, options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 170))
            ))
        }

        private fun render(context: Context, snapshot: JSONObject?, height: Int): RemoteViews {
            val systemDark = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
            val dark = when (snapshot?.optString("theme")) { "dark" -> true; "light" -> false; else -> systemDark }
            val foreground = Color.parseColor(if (dark) "#FFEADA" else "#35271D")
            val secondary = Color.parseColor(if (dark) "#D6BFAE" else "#766354")
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.ROOT).format(Date())
            val day = snapshot?.optJSONObject("days")?.optJSONObject(today)
            val textScale = context.resources.configuration.fontScale.coerceAtLeast(1f)

            val views = RemoteViews(context.packageName, R.layout.wishloop_widget)
            views.setInt(R.id.widget_root, "setBackgroundResource", if (dark) R.drawable.widget_background_dark else R.drawable.widget_background_light)
            views.setOnClickPendingIntent(R.id.widget_root, launch(context, "today"))
            views.setOnClickPendingIntent(R.id.widget_balance, launch(context, "wallet"))
            views.setOnClickPendingIntent(R.id.widget_goal, launch(context, "wishes"))
            views.setContentDescription(R.id.widget_balance, snapshot?.optString("walletLabel") ?: context.getString(R.string.appName))
            views.setTextViewText(R.id.widget_balance, snapshot?.optString("balance") ?: "—")
            views.setTextViewText(R.id.widget_net, day?.optString("net") ?: "")
            views.setTextViewText(R.id.widget_wish, snapshot?.optString("wish") ?: context.getString(R.string.widget_open))
            views.setProgressBar(R.id.widget_progress, 1000, snapshot?.optInt("progress") ?: 0, false)
            views.setViewVisibility(R.id.widget_goal, if (height >= 130 * textScale) View.VISIBLE else View.GONE)
            views.setTextColor(R.id.widget_balance, foreground)
            views.setTextColor(R.id.widget_wish, secondary)
            val net = day?.optLong("netMinor") ?: 0L
            views.setTextColor(R.id.widget_net, if (net > 0) Color.parseColor(if (dark) "#FFB4AB" else "#A73A38") else if (net < 0) Color.parseColor(if (dark) "#A5D6AE" else "#367148") else secondary)
            val rows = day?.optJSONArray("hobbies")
            listOf(R.id.widget_hobby_0, R.id.widget_hobby_1, R.id.widget_hobby_2, R.id.widget_hobby_3).forEachIndexed { index, viewId ->
                val row = rows?.optJSONObject(index)
                views.setViewVisibility(viewId, if (row != null) View.VISIBLE else View.GONE)
                val emoji = row?.optString("emoji", "🌱") ?: ""
                val amount = row?.optString("amount") ?: ""
                val text = SpannableString("$emoji\n$amount")
                if (emoji.isNotEmpty()) text.setSpan(AbsoluteSizeSpan(26, true), 0, emoji.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
                views.setTextViewText(viewId, text)
                views.setContentDescription(viewId, row?.optString("label") ?: "")
                views.setTextColor(viewId, foreground)
                val busy = row != null && WishLoopWidgetJob.pending(context, row.optString("id"))
                views.setFloat(viewId, "setAlpha", if (busy) .4f else 1f)
                // Keep the tile consuming taps while busy; the queue deduplicates
                // them, and a second tap must not fall through to the root Activity.
                views.setOnClickPendingIntent(viewId, if (row != null) complete(context, today, row) else null)
            }
            views.setViewVisibility(R.id.widget_status, if (WishLoopWidgetJob.failed(context)) View.VISIBLE else View.GONE)
            views.setTextColor(R.id.widget_status, secondary)
            views.setTextViewText(R.id.widget_status, snapshot?.optString("retry") ?: context.getString(R.string.widget_retry))
            views.setViewVisibility(R.id.widget_empty, if (rows == null || rows.length() == 0) View.VISIBLE else View.GONE)
            views.setTextViewText(R.id.widget_empty, if (snapshot == null) context.getString(R.string.widget_open) else if (day == null) snapshot.optString("refresh", context.getString(R.string.widget_refresh)) else day.optString("empty"))
            views.setTextColor(R.id.widget_empty, secondary)
            return views
        }
    }

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { update(context, manager, it) }
        if (ids.isNotEmpty()) WishLoopWidgetJob.enqueue(context)
    }

    override fun onAppWidgetOptionsChanged(context: Context, manager: AppWidgetManager, id: Int, options: Bundle) {
        update(context, manager, id)
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == COMPLETE) {
            val day = intent.getStringExtra(DAY) ?: return
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.ROOT).format(Date())
            val id = intent.getStringExtra(HOBBY) ?: return
            val rows = readSnapshot(context)?.optJSONObject("days")?.optJSONObject(today)?.optJSONArray("hobbies")
            val visible = rows != null && (0 until rows.length()).any {
                val row = rows.getJSONObject(it)
                row.optString("id") == id && row.optLong("amountMinor") == intent.getLongExtra(AMOUNT, Long.MIN_VALUE)
            }
            if (day == today && visible) WishLoopWidgetJob.enqueue(context, day, id, intent.getLongExtra(AMOUNT, 0))
            else WishLoopWidgetJob.enqueue(context)
            return
        }
        super.onReceive(context, intent)
        if (intent.action in listOf(Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED, Intent.ACTION_TIME_CHANGED, Intent.ACTION_TIMEZONE_CHANGED, Intent.ACTION_LOCALE_CHANGED, Intent.ACTION_DATE_CHANGED)) {
            updateAll(context)
            if (AppWidgetManager.getInstance(context).getAppWidgetIds(ComponentName(context, WishLoopWidgetProvider::class.java)).isNotEmpty()) {
                WishLoopWidgetJob.enqueue(context)
            }
        }
    }
}
