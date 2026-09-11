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
 * HaftalÄ±k PlanlayÄ±cÄ± Android Åeffaf GÃ¼nlÃ¼k Widget SaÄŸlayÄ±cÄ±sÄ±
 */
class AestheticPlannerWidget : AppWidgetProvider() {

    companion object {
        private const val TAG = "AestheticPlannerWidget"
        private val FALLBACK_COLORS = listOf("#DAEAF6", "#FCF4DD", "#B5EAD7", "#FFDAC1")

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
            val thisWidget = ComponentName(context, AestheticPlannerWidget::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
        super.onReceive(context, intent)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        MidnightAlarmScheduler.scheduleNextMidnight(context)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.aesthetic_planner_widget_layout)

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
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val todayEventsJson = widgetData.getString("today_events_json", null)
                val weeklyEventsJson = widgetData.getString("weekly_events_json", null)
                val themeConfigJson = widgetData.getString("theme_config_json", null)

                // ğŸ“… Dinamik GÃ¼n HesabÄ±
                val cal = Calendar.getInstance()
                val calDay = cal.get(Calendar.DAY_OF_WEEK)
                val currentDayOfWeek = if (calDay == Calendar.SUNDAY) 7 else calDay - 1

                var cellOpacity = 0.0
                var textColor = Color.WHITE

                if (themeConfigJson != null) {
                    val themeObj = JSONObject(themeConfigJson)
                    cellOpacity = themeObj.optDouble("backgroundOpacity", 0.0).coerceIn(0.0, 1.0)
                    val bgHex = themeObj.optString("backgroundColorHex", "#FFFFFF")
                    val bgColor = parseSafeColor(bgHex, "#FFFFFF")
                    val textColorHex = themeObj.optString("textColorHex", "#FFFFFF")
                    textColor = parseSafeColor(textColorHex, "#FFFFFF")

                    if (cellOpacity > 0.0) {
                        val alpha = (cellOpacity * 255).toInt().coerceIn(0, 255)
                        val r = Color.red(bgColor)
                        val g = Color.green(bgColor)
                        val b = Color.blue(bgColor)
                        views.setInt(R.id.widget_root, "setBackgroundColor", Color.argb(alpha, r, g, b))
                    } else {
                        views.setInt(R.id.widget_root, "setBackgroundColor", Color.TRANSPARENT)
                    }
                } else {
                    views.setInt(R.id.widget_root, "setBackgroundColor", Color.TRANSPARENT)
                }

                // Etkinlik Listesi: HaftalÄ±k tablodan dinamik gÃ¼n etkinliklerini veya bugÃ¼n listesini al
                val weeklyEventsObj = if (weeklyEventsJson != null) JSONObject(weeklyEventsJson) else JSONObject()
                val eventsArray = weeklyEventsObj.optJSONArray(currentDayOfWeek.toString())
                    ?: (if (todayEventsJson != null) JSONArray(todayEventsJson) else JSONArray())

                if (eventsArray.length() == 0) {
                    views.setViewVisibility(R.id.widget_empty_text, View.VISIBLE)
                    views.setTextColor(R.id.widget_empty_text, textColor)
                    views.setViewVisibility(R.id.widget_item_1, View.GONE)
                    views.setViewVisibility(R.id.widget_item_2, View.GONE)
                    views.setViewVisibility(R.id.widget_item_3, View.GONE)
                    views.setViewVisibility(R.id.widget_item_4, View.GONE)
                } else {
                    views.setViewVisibility(R.id.widget_empty_text, View.GONE)
                    renderEventItem(views, eventsArray, 0, R.id.widget_item_1, R.id.widget_item_1_title, R.id.widget_item_1_subtitle, R.id.widget_item_1_time, R.id.widget_item_1_bell, R.id.widget_item_1_bar, FALLBACK_COLORS[0], textColor)
                    renderEventItem(views, eventsArray, 1, R.id.widget_item_2, R.id.widget_item_2_title, R.id.widget_item_2_subtitle, R.id.widget_item_2_time, R.id.widget_item_2_bell, R.id.widget_item_2_bar, FALLBACK_COLORS[1], textColor)
                    renderEventItem(views, eventsArray, 2, R.id.widget_item_3, R.id.widget_item_3_title, R.id.widget_item_3_subtitle, R.id.widget_item_3_time, R.id.widget_item_3_bell, R.id.widget_item_3_bar, FALLBACK_COLORS[2], textColor)
                    renderEventItem(views, eventsArray, 3, R.id.widget_item_4, R.id.widget_item_4_title, R.id.widget_item_4_subtitle, R.id.widget_item_4_time, R.id.widget_item_4_bell, R.id.widget_item_4_bar, FALLBACK_COLORS[3], textColor)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Widget guncelleme hatasi", e)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        MidnightAlarmScheduler.scheduleNextMidnight(context)
    }

    private fun renderEventItem(
        views: RemoteViews,
        eventsArray: JSONArray,
        index: Int,
        itemViewId: Int,
        titleViewId: Int,
        subtitleViewId: Int,
        timeViewId: Int,
        bellViewId: Int,
        barViewId: Int,
        fallbackColor: String,
        textColor: Int
    ) {
        if (eventsArray.length() > index) {
            val event = eventsArray.getJSONObject(index)
            views.setViewVisibility(itemViewId, View.VISIBLE)
            views.setTextViewText(titleViewId, event.optString("title", "â€”"))
            views.setTextColor(titleViewId, textColor)

            val subtitle = event.optString("subtitle", "").trim()
            if (subtitle.isNotEmpty()) {
                views.setViewVisibility(subtitleViewId, View.VISIBLE)
                views.setTextViewText(subtitleViewId, subtitle)
                val r = Color.red(textColor)
                val g = Color.green(textColor)
                val b = Color.blue(textColor)
                views.setTextColor(subtitleViewId, Color.argb(200, r, g, b))
            } else {
                views.setViewVisibility(subtitleViewId, View.GONE)
            }

            val formattedTime = formatFullTime(event)
            if (formattedTime.isNotEmpty()) {
                views.setViewVisibility(timeViewId, View.VISIBLE)
                views.setTextViewText(timeViewId, formattedTime)
                val timeColor = Color.argb(190, Color.red(textColor), Color.green(textColor), Color.blue(textColor))
                views.setTextColor(timeViewId, timeColor)

                val isNotifEnabled = event.optBoolean("isNotificationEnabled", false)
                if (isNotifEnabled) {
                    views.setViewVisibility(bellViewId, View.VISIBLE)
                    views.setInt(bellViewId, "setColorFilter", timeColor)
                } else {
                    views.setViewVisibility(bellViewId, View.GONE)
                }
            } else {
                views.setViewVisibility(timeViewId, View.GONE)
                views.setViewVisibility(bellViewId, View.GONE)
            }

            val colorHex = event.optString("colorHex", fallbackColor)
            val parsedColor = parseSafeColor(colorHex, fallbackColor)
            views.setInt(barViewId, "setColorFilter", parsedColor)
        } else {
            views.setViewVisibility(itemViewId, View.GONE)
        }
    }

    private fun formatFullTime(json: JSONObject): String {
        val hasSpecificTime = json.optBoolean("hasSpecificTime", true)
        if (!hasSpecificTime) return ""
        val sHVal = json.optInt("startHour", 0)
        val sMVal = json.optInt("startMinute", 0)
        val endH = json.optInt("endHour", 0)
        val endM = json.optInt("endMinute", 0)
        if (sHVal == 0 && sMVal == 0 && endH == 0 && endM == 0 && !json.has("hasSpecificTime")) {
            return ""
        }
        val sH = sHVal.coerceIn(0, 23).toString().padStart(2, '0')
        val sM = sMVal.coerceIn(0, 59).toString().padStart(2, '0')
        if (endH == 0 && endM == 0) {
            return "$sH:$sM"
        }
        val eH = endH.coerceIn(0, 23).toString().padStart(2, '0')
        val eM = endM.coerceIn(0, 59).toString().padStart(2, '0')
        return "$sH:$sM - $eH:$eM"
    }
}