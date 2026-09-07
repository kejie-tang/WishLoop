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
        private const val PREFS = "wishloop_widget"

        fun save(context: Context, json: String) {
            require(json.length <= 128_000)
            require(JSONObject(json).optInt("version") == 1)
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

        fun preview(context: Context): RemoteViews = render(context, readSnapshot(context), 280)

        private fun readSnapshot(context: Context): JSONObject? {
            val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString("snapshot", null)
            return try { raw?.let(::JSONObject) } catch (_: org.json.JSONException) { null }
        }

        private fun update(context: Context, manager: AppWidgetManager, id: Int) {
            val snapshot = readSnapshot(context)
            val options = manager.getAppWidgetOptions(id)
            // Launcher min/max heights describe landscape/portrait respectively.
            // RemoteViews selects the correct layout when the device rotates.
            manager.updateAppWidget(id, RemoteViews(
                render(context, snapshot, options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 180)),
                render(context, snapshot, options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 260))
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
            val count = ((height - 125 * textScale) / (48 * textScale)).toInt().coerceIn(0, 3)
            val views = RemoteViews(context.packageName, R.layout.wishloop_widget)
            views.setInt(R.id.widget_root, "setBackgroundResource", if (dark) R.drawable.widget_background_dark else R.drawable.widget_background_light)
            views.setOnClickPendingIntent(R.id.widget_root, launch(context, "today"))
            views.setOnClickPendingIntent(R.id.widget_title, launch(context, "today"))
            views.setOnClickPendingIntent(R.id.widget_balance, launch(context, "wallet"))
            views.setOnClickPendingIntent(R.id.widget_goal, launch(context, "wishes"))
            views.setTextViewText(R.id.widget_title, snapshot?.optString("walletLabel") ?: context.getString(R.string.appName))
            views.setTextViewText(R.id.widget_balance, snapshot?.optString("balance") ?: "—")
            views.setTextViewText(R.id.widget_net, day?.optString("net") ?: "")
            views.setTextViewText(R.id.widget_wish, snapshot?.optString("wish") ?: context.getString(R.string.widget_open))
            views.setProgressBar(R.id.widget_progress, 1000, snapshot?.optInt("progress") ?: 0, false)
            views.setViewVisibility(R.id.widget_goal, if (height >= 155 * textScale) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.widget_hobbies, if (count > 0) View.VISIBLE else View.GONE)
            views.setTextColor(R.id.widget_title, secondary)
            views.setTextColor(R.id.widget_balance, foreground)
            views.setTextColor(R.id.widget_wish, secondary)
            val net = day?.optLong("netMinor") ?: 0L
            views.setTextColor(R.id.widget_net, if (net > 0) Color.parseColor(if (dark) "#FFB4AB" else "#A73A38") else if (net < 0) Color.parseColor(if (dark) "#A5D6AE" else "#367148") else secondary)
            val rows = day?.optJSONArray("hobbies")
            listOf(R.id.widget_hobby_0, R.id.widget_hobby_1, R.id.widget_hobby_2).forEachIndexed { index, viewId ->
                val row = rows?.optJSONObject(index)
                views.setViewVisibility(viewId, if (index < count && row != null) View.VISIBLE else View.GONE)
                views.setTextViewText(viewId, row?.optString("text") ?: "")
                views.setTextColor(viewId, foreground)
                views.setOnClickPendingIntent(viewId, launch(context, "today", row?.optString("id") ?: ""))
            }
            views.setViewVisibility(R.id.widget_empty, if (rows == null || rows.length() == 0) View.VISIBLE else View.GONE)
            views.setTextViewText(R.id.widget_empty, if (snapshot == null) context.getString(R.string.widget_open) else if (day == null) snapshot.optString("refresh", context.getString(R.string.widget_refresh)) else day.optString("empty"))
            views.setTextColor(R.id.widget_empty, secondary)
            return views
        }
    }

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { update(context, manager, it) }
    }

    override fun onAppWidgetOptionsChanged(context: Context, manager: AppWidgetManager, id: Int, options: Bundle) {
        update(context, manager, id)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action in listOf(Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED, Intent.ACTION_TIME_CHANGED, Intent.ACTION_TIMEZONE_CHANGED, Intent.ACTION_LOCALE_CHANGED, Intent.ACTION_DATE_CHANGED)) {
            updateAll(context)
        }
    }
}
