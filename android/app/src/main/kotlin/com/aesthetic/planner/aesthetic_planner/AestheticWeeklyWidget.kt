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
 * ğŸŒ¿ 7 GÃ¼nlÃ¼k Dinamik Matris ve Alt GÃ¼nlÃ¼k AkÄ±ÅŸ HaftalÄ±k Widget SaÄŸlayÄ±cÄ±sÄ±
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
                val weeklyEventsJson = widgetData.getString("weekly_events_json", null)
                val themeConfigJson = widgetData.getString("theme_config_json", null)

                // ğŸ“… 1. GÃœNCEL GÃœN VE HAFTA NUMARALARININ DÄ°NAMÄ°K TESPÄ°TÄ°
                val cal = Calendar.getInstance()
                cal.firstDayOfWeek = Calendar.MONDAY
                val calDay = cal.get(Calendar.DAY_OF_WEEK) // 1=Sun, 2=Mon...
                val currentDayOfWeek = if (calDay == Calendar.SUNDAY) 7 else calDay - 1

                // Dinamik 7 gÃ¼nÃ¼n ayÄ±n kaÃ§Ä± olduÄŸu hesabÄ±
                val dayNumbersList = mutableListOf<String>()
                val weekCal = Calendar.getInstance().apply {
                    firstDayOfWeek = Calendar.MONDAY
                    add(Calendar.DAY_OF_MONTH, -(currentDayOfWeek - 1))
                }
                for (i in 0 until 7) {
                    dayNumbersList.add(weekCal.get(Calendar.DAY_OF_MONTH).toString())
                    weekCal.add(Calendar.DAY_OF_MONTH, 1)
                }

                // ğŸ¨ Tema Renkleri
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
                        views.setInt(R.id.widget_weekly_root, "setBackgroundColor", Color.argb(alpha, r, g, b))
                    } else {
                        views.setInt(R.id.widget_weekly_root, "setBackgroundColor", Color.TRANSPARENT)
                    }
                }

                // â”€â”€ 1. 7 GÃœNLÃœK ÃœST MATRÄ°S â”€â”€
                val weeklyEventsObj = if (weeklyEventsJson != null) JSONObject(weeklyEventsJson) else JSONObject()

                for (d in 1..7) {
                    val colId = context.resources.getIdentifier("widget_day_col_$d", "id", context.packageName)
                    val nameId = context.resources.getIdentifier("widget_day_name_$d", "id", context.packageName)
                    val numId = context.resources.getIdentifier("widget_day_num_$d", "id", context.packageName)

                    if (d - 1 < dayNumbersList.size) {
                        views.setTextViewText(numId, dayNumbersList[d - 1])
                    }
                    views.setTextColor(nameId, textColor)
                    views.setTextColor(numId, textColor)

                    // SeÃ§ili / BugÃ¼nkÃ¼ gÃ¼nÃ¼n arka planÄ± (Dinamik)
                    if (d == currentDayOfWeek) {
                        views.setInt(colId, "setBackgroundResource", R.drawable.widget_day_selected_bg)
                    } else {
                        views.setInt(colId, "setBackgroundColor", Color.TRANSPARENT)
                    }

                    // O gÃ¼ne ait mini etkinlik hÃ¼creleri (1..4)
                    val dayEventsArray = weeklyEventsObj.optJSONArray(d.toString()) ?: JSONArray()
                    for (e in 1..4) {
                        val cellId = context.resources.getIdentifier("widget_d${d}_e$e", "id", context.packageName)
                        val bgId = context.resources.getIdentifier("widget_d${d}_e${e}_bg", "id", context.packageName)
                        val titleId = context.resources.getIdentifier("widget_d${d}_e${e}_title", "id", context.packageName)
                        val timeId = context.resources.getIdentifier("widget_d${d}_e${e}_time", "id", context.packageName)

                        if (e - 1 < dayEventsArray.length()) {
                            val eventObj = dayEventsArray.getJSONObject(e - 1)
                            val title = eventObj.optString("title", "â€”")
                            val miniTime = formatMiniTime(eventObj)
                            val colorHex = eventObj.optString("colorHex", FALLBACK_COLORS[(d + e - 2) % FALLBACK_COLORS.size])
                            val rawColor = parseSafeColor(colorHex, FALLBACK_COLORS[0])

                            // 1ï¸âƒ£ Apple & Google Calendar Modeli:
                            // YumuÅŸak aÃ§Ä±k pastel arka plan
                            val r = Color.red(rawColor)
                            val g = Color.green(rawColor)
                            val b = Color.blue(rawColor)
                            val pastelR = (r + 255 * 3) / 4
                            val pastelG = (g + 255 * 3) / 4
                            val pastelB = (b + 255 * 3) / 4
                            val softPastelBg = Color.rgb(pastelR, pastelG, pastelB)

                            views.setInt(bgId, "setColorFilter", softPastelBg)

                            // Koyu ve net siyah/lacivert fontlar
                            val darkTitleColor = Color.parseColor("#0F172A")
                            val darkTimeColor = Color.parseColor("#334155")

                            views.setTextViewText(titleId, title)
                            views.setTextColor(titleId, darkTitleColor)

                            views.setTextViewText(timeId, miniTime)
                            views.setTextColor(timeId, darkTimeColor)

                            views.setViewVisibility(cellId, View.VISIBLE)
                        } else {
                            views.setViewVisibility(cellId, View.GONE)
                        }
                    }
                }

                // â”€â”€ 2. ALT KISIM: DÄ°NAMÄ°K GÃœNÃœN DETAYLI PLANLARI â”€â”€
                // Gece yarÄ±sÄ± gÃ¼n deÄŸiÅŸtiÄŸinde haftalÄ±k plandan o gÃ¼nÃ¼n etkinliklerini otomatik yÃ¼kle
                val currentDayEvents = weeklyEventsObj.optJSONArray(currentDayOfWeek.toString())
                    ?: (if (todayEventsJson != null) JSONArray(todayEventsJson) else JSONArray())

                if (currentDayEvents.length() == 0) {
                    views.setViewVisibility(R.id.widget_weekly_empty_text, View.VISIBLE)
                    views.setTextColor(R.id.widget_weekly_empty_text, textColor)
                    views.setViewVisibility(R.id.widget_weekly_item_1, View.GONE)
                    views.setViewVisibility(R.id.widget_weekly_item_2, View.GONE)
                    views.setViewVisibility(R.id.widget_weekly_item_3, View.GONE)
                    views.setViewVisibility(R.id.widget_weekly_item_4, View.GONE)
                } else {
                    views.setViewVisibility(R.id.widget_weekly_empty_text, View.GONE)
                    renderBottomEventRow(views, currentDayEvents, 0, R.id.widget_weekly_item_1, R.id.widget_weekly_item_1_title, R.id.widget_weekly_item_1_subtitle, R.id.widget_weekly_item_1_time, R.id.widget_weekly_item_1_bell, R.id.widget_weekly_item_1_bar, FALLBACK_COLORS[0], textColor)
                    renderBottomEventRow(views, currentDayEvents, 1, R.id.widget_weekly_item_2, R.id.widget_weekly_item_2_title, R.id.widget_weekly_item_2_subtitle, R.id.widget_weekly_item_2_time, R.id.widget_weekly_item_2_bell, R.id.widget_weekly_item_2_bar, FALLBACK_COLORS[1], textColor)
                    renderBottomEventRow(views, currentDayEvents, 2, R.id.widget_weekly_item_3, R.id.widget_weekly_item_3_title, R.id.widget_weekly_item_3_subtitle, R.id.widget_weekly_item_3_time, R.id.widget_weekly_item_3_bell, R.id.widget_weekly_item_3_bar, FALLBACK_COLORS[2], textColor)
                    renderBottomEventRow(views, currentDayEvents, 3, R.id.widget_weekly_item_4, R.id.widget_weekly_item_4_title, R.id.widget_weekly_item_4_subtitle, R.id.widget_weekly_item_4_time, R.id.widget_weekly_item_4_bell, R.id.widget_weekly_item_4_bar, FALLBACK_COLORS[3], textColor)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Haftalik widget guncelleme hatasi", e)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        // Bir sonraki gece yarÄ±sÄ± tetiklemesini garanti et
        MidnightAlarmScheduler.scheduleNextMidnight(context)
    }

    private fun renderBottomEventRow(
        views: RemoteViews,
        eventsArray: JSONArray,
        index: Int,
        rowId: Int,
        titleId: Int,
        subtitleId: Int,
        timeId: Int,
        bellId: Int,
        barId: Int,
        fallbackColor: String,
        textColor: Int
    ) {
        if (eventsArray.length() > index) {
            val event = eventsArray.getJSONObject(index)
            views.setViewVisibility(rowId, View.VISIBLE)
            views.setTextViewText(titleId, event.optString("title", "â€”"))
            views.setTextColor(titleId, textColor)

            val subtitle = event.optString("subtitle", "").trim()
            if (subtitle.isNotEmpty()) {
                views.setViewVisibility(subtitleId, View.VISIBLE)
                views.setTextViewText(subtitleId, subtitle)
                val r = Color.red(textColor)
                val g = Color.green(textColor)
                val b = Color.blue(textColor)
                views.setTextColor(subtitleId, Color.argb(200, r, g, b))
            } else {
                views.setViewVisibility(subtitleId, View.GONE)
            }

            views.setTextViewText(timeId, formatFullTime(event))
            val timeColor = Color.argb(190, Color.red(textColor), Color.green(textColor), Color.blue(textColor))
            views.setTextColor(timeId, timeColor)

            val isNotifEnabled = event.optBoolean("isNotificationEnabled", false)
            if (isNotifEnabled) {
                views.setViewVisibility(bellId, View.VISIBLE)
                views.setInt(bellId, "setColorFilter", timeColor)
            } else {
                views.setViewVisibility(bellId, View.GONE)
            }

            val colorHex = event.optString("colorHex", fallbackColor)
            val parsedColor = parseSafeColor(colorHex, fallbackColor)
            views.setInt(barId, "setColorFilter", parsedColor)
        } else {
            views.setViewVisibility(rowId, View.GONE)
        }
    }

    private fun formatMiniTime(json: JSONObject): String {
        val sH = json.optInt("startHour", 9).coerceIn(0, 23).toString().padStart(2, '0')
        val sM = json.optInt("startMinute", 0).coerceIn(0, 59).toString().padStart(2, '0')
        val endH = json.optInt("endHour", 0)
        val endM = json.optInt("endMinute", 0)
        if (endH == 0 && endM == 0) {
            return "$sH:$sM"
        }
        val eH = endH.coerceIn(0, 23).toString().padStart(2, '0')
        val eM = endM.coerceIn(0, 59).toString().padStart(2, '0')
        return "$sH:$sM-$eH:$eM"
    }

    private fun formatFullTime(json: JSONObject): String {
        val sH = json.optInt("startHour", 9).coerceIn(0, 23).toString().padStart(2, '0')
        val sM = json.optInt("startMinute", 0).coerceIn(0, 59).toString().padStart(2, '0')
        val endH = json.optInt("endHour", 0)
        val endM = json.optInt("endMinute", 0)
        if (endH == 0 && endM == 0) {
            return "$sH:$sM"
        }
        val eH = endH.coerceIn(0, 23).toString().padStart(2, '0')
        val eM = endM.coerceIn(0, 59).toString().padStart(2, '0')
        return "$sH:$sM - $eH:$eM"
    }
}