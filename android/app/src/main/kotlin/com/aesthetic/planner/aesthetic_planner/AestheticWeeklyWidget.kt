package com.aesthetic.planner.aesthetic_planner

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

/**
 * 2 Katmanlı Hibrit Haftalık Widget (Üstte 7 Günlük Matris, Altta Günün Planları)
 */
class AestheticWeeklyWidget : AppWidgetProvider() {

    companion object {
        private const val TAG = "AestheticWeeklyWidget"
        private val FALLBACK_COLORS = listOf("#DAEAF6", "#FCF4DD", "#B5EAD7", "#DAEAF6", "#FFDAC1", "#FCF4DD", "#E8DFF5")

        fun parseSafeColor(hexString: String, fallbackHex: String = "#DAEAF6"): Int {
            return try {
                Color.parseColor(hexString)
            } catch (e: Exception) {
                Color.parseColor(fallbackHex)
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val isHomeWidgetUpdate = action == "es.antonborri.home_widget.action.UPDATE"
        val isSystemUpdate = action == AppWidgetManager.ACTION_APPWIDGET_UPDATE ||
                action == AppWidgetManager.ACTION_APPWIDGET_OPTIONS_CHANGED ||
                action == AppWidgetManager.ACTION_APPWIDGET_ENABLED

        if (isHomeWidgetUpdate || isSystemUpdate) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, AestheticWeeklyWidget::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.aesthetic_weekly_widget_layout)

            val intent = Intent(context, MainActivity::class.java).apply {
                this.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_weekly_root, pendingIntent)

            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val todayEventsJson = widgetData.getString("today_events_json", null)
                val themeConfigJson = widgetData.getString("theme_config_json", null)
                val weekLabel = widgetData.getString("week_label", "Haftalık Program")

                var cellOpacity = 0.0
                var textColor = Color.WHITE

                if (themeConfigJson != null) {
                    val themeObj = JSONObject(themeConfigJson)
                    cellOpacity = themeObj.optDouble("backgroundOpacity", 0.0).coerceIn(0.0, 1.0)
                    val textColorHex = themeObj.optString("textColorHex", "#FFFFFF")
                    textColor = parseSafeColor(textColorHex, "#FFFFFF")
                }

                views.setTextViewText(R.id.widget_weekly_title, weekLabel)
                views.setTextColor(R.id.widget_weekly_title, textColor)

                // 2. Alt Günlük Akış
                val eventsArray = if (todayEventsJson != null) JSONArray(todayEventsJson) else JSONArray()
                if (eventsArray.length() == 0) {
                    views.setViewVisibility(R.id.widget_weekly_empty_text, View.VISIBLE)
                    views.setTextColor(R.id.widget_weekly_empty_text, textColor)
                    views.setViewVisibility(R.id.widget_weekly_item_1, View.GONE)
                    views.setViewVisibility(R.id.widget_weekly_item_2, View.GONE)
                    views.setViewVisibility(R.id.widget_weekly_item_3, View.GONE)
                } else {
                    views.setViewVisibility(R.id.widget_weekly_empty_text, View.GONE)
                    renderEventRow(views, eventsArray, 0, R.id.widget_weekly_item_1, R.id.widget_weekly_item_1_title, R.id.widget_weekly_item_1_time, R.id.widget_weekly_item_1_bar, FALLBACK_COLORS[0], cellOpacity, textColor)
                    renderEventRow(views, eventsArray, 1, R.id.widget_weekly_item_2, R.id.widget_weekly_item_2_title, R.id.widget_weekly_item_2_time, R.id.widget_weekly_item_2_bar, FALLBACK_COLORS[1], cellOpacity, textColor)
                    renderEventRow(views, eventsArray, 2, R.id.widget_weekly_item_3, R.id.widget_weekly_item_3_title, R.id.widget_weekly_item_3_time, R.id.widget_weekly_item_3_bar, FALLBACK_COLORS[2], cellOpacity, textColor)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Haftalık hibrit widget güncelleme hatası", e)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun renderEventRow(
        views: RemoteViews,
        eventsArray: JSONArray,
        index: Int,
        rowId: Int,
        titleId: Int,
        timeId: Int,
        barId: Int,
        fallbackColor: String,
        cellOpacity: Double,
        textColor: Int
    ) {
        if (eventsArray.length() > index) {
            val event = eventsArray.getJSONObject(index)
            views.setViewVisibility(rowId, View.VISIBLE)
            views.setTextViewText(titleId, event.optString("title", "—"))
            views.setTextColor(titleId, textColor)
            views.setTextViewText(timeId, formatTime(event))
            views.setTextColor(timeId, textColor)

            val colorHex = event.optString("colorHex", fallbackColor)
            val parsedColor = parseSafeColor(colorHex, fallbackColor)
            views.setInt(barId, "setBackgroundColor", parsedColor)

            if (cellOpacity > 0.0) {
                val alpha = (cellOpacity * 0.80 * 255).toInt().coerceIn(0, 255)
                val r = Color.red(parsedColor)
                val g = Color.green(parsedColor)
                val b = Color.blue(parsedColor)
                views.setInt(rowId, "setBackgroundColor", Color.argb(alpha, r, g, b))
            } else {
                views.setInt(rowId, "setBackgroundColor", Color.TRANSPARENT)
            }
        } else {
            views.setViewVisibility(rowId, View.GONE)
        }
    }

    private fun formatTime(json: JSONObject): String {
        val sH = json.optInt("startHour", 9).coerceIn(0, 23).toString().padStart(2, '0')
        val sM = json.optInt("startMinute", 0).coerceIn(0, 59).toString().padStart(2, '0')
        val eH = json.optInt("endHour", 10).coerceIn(0, 23).toString().padStart(2, '0')
        val eM = json.optInt("endMinute", 0).coerceIn(0, 59).toString().padStart(2, '0')
        return "$sH:$sM - $eH:$eM"
    }
}
