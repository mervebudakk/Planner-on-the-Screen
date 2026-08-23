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
 * 🌿 7 Günlük Dinamik Matris ve Alt Günlük Akış Haftalık Widget Sağlayıcısı
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
                val weeklyEventsJson = widgetData.getString("weekly_events_json", null)
                val themeConfigJson = widgetData.getString("theme_config_json", null)
                val weekDayNumbersJson = widgetData.getString("week_day_numbers_json", null)

                // 📅 Güncel günün tespiti (1 = Pazartesi, 7 = Pazar)
                var currentDayOfWeek = widgetData.getInt("current_day_of_week", -1)
                if (currentDayOfWeek == -1) {
                    val cal = Calendar.getInstance()
                    val calDay = cal.get(Calendar.DAY_OF_WEEK) // 1=Sun, 2=Mon...
                    currentDayOfWeek = if (calDay == Calendar.SUNDAY) 7 else calDay - 1
                }

                // 🎨 Tema Renkleri
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

                // ── 1. 7 GÜNLÜK ÜST MATRİS ──
                val dayNumbersList = mutableListOf<String>()
                if (weekDayNumbersJson != null) {
                    val arr = JSONArray(weekDayNumbersJson)
                    for (i in 0 until arr.length()) {
                        dayNumbersList.add(arr.optString(i))
                    }
                }

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

                    // Seçili / Bugünkü günün arka planı
                    if (d == currentDayOfWeek) {
                        views.setInt(colId, "setBackgroundResource", R.drawable.widget_day_selected_bg)
                    } else {
                        views.setInt(colId, "setBackgroundColor", Color.TRANSPARENT)
                    }

                    // O güne ait mini etkinlik hücreleri (1..4)
                    val dayEventsArray = weeklyEventsObj.optJSONArray(d.toString()) ?: JSONArray()
                    for (e in 1..4) {
                        val cellId = context.resources.getIdentifier("widget_d${d}_e$e", "id", context.packageName)
                        val bgId = context.resources.getIdentifier("widget_d${d}_e${e}_bg", "id", context.packageName)
                        val borderId = context.resources.getIdentifier("widget_d${d}_e${e}_border", "id", context.packageName)
                        val timeId = context.resources.getIdentifier("widget_d${d}_e${e}_time", "id", context.packageName)
                        val titleId = context.resources.getIdentifier("widget_d${d}_e${e}_title", "id", context.packageName)

                        if (e - 1 < dayEventsArray.length()) {
                            val eventObj = dayEventsArray.getJSONObject(e - 1)
                            views.setViewVisibility(cellId, View.VISIBLE)

                            val eventColorHex = eventObj.optString("colorHex", FALLBACK_COLORS[(d - 1) % FALLBACK_COLORS.size])
                            val eventColor = parseSafeColor(eventColorHex, "#DAEAF6")
                            val r = Color.red(eventColor)
                            val g = Color.green(eventColor)
                            val b = Color.blue(eventColor)
                            
                            // 🌿 1. Seçenek (Apple & Google Calendar Modeli):
                            // Yumuşak açık pastel yapışkan not dolgusu + Canlı renkli kenarlık
                            val bgR = (r * 0.35 + 255 * 0.65).toInt().coerceIn(0, 255)
                            val bgG = (g * 0.35 + 255 * 0.65).toInt().coerceIn(0, 255)
                            val bgB = (b * 0.35 + 255 * 0.65).toInt().coerceIn(0, 255)
                            val fillColor = Color.argb(238, bgR, bgG, bgB)
                            views.setInt(bgId, "setColorFilter", fillColor)

                            val borderColor = Color.argb(230, (r * 0.85).toInt(), (g * 0.85).toInt(), (b * 0.85).toInt())
                            views.setInt(borderId, "setColorFilter", borderColor)

                            // 📝 Koyu, net ve jilet gibi okunaklı tipografi
                            views.setTextColor(titleId, Color.argb(255, 15, 23, 42))  // #0F172A
                            views.setTextColor(timeId, Color.argb(255, 51, 65, 85))    // #334155

                            views.setTextViewText(timeId, formatMiniTime(eventObj))
                            views.setTextViewText(titleId, eventObj.optString("title", "—"))
                        } else {
                            views.setViewVisibility(cellId, View.GONE)
                        }
                    }
                }

                // ── 2. ALT KISIM: BUGÜNÜN DETAYLI PLANLARI ──
                val todayArray = if (todayEventsJson != null) JSONArray(todayEventsJson) else JSONArray()
                if (todayArray.length() == 0) {
                    views.setViewVisibility(R.id.widget_weekly_empty_text, View.VISIBLE)
                    views.setTextColor(R.id.widget_weekly_empty_text, textColor)
                    views.setViewVisibility(R.id.widget_weekly_item_1, View.GONE)
                    views.setViewVisibility(R.id.widget_weekly_item_2, View.GONE)
                    views.setViewVisibility(R.id.widget_weekly_item_3, View.GONE)
                    views.setViewVisibility(R.id.widget_weekly_item_4, View.GONE)
                } else {
                    views.setViewVisibility(R.id.widget_weekly_empty_text, View.GONE)
                    renderBottomEventRow(views, todayArray, 0, R.id.widget_weekly_item_1, R.id.widget_weekly_item_1_title, R.id.widget_weekly_item_1_subtitle, R.id.widget_weekly_item_1_time, R.id.widget_weekly_item_1_bell, R.id.widget_weekly_item_1_bar, FALLBACK_COLORS[0], textColor)
                    renderBottomEventRow(views, todayArray, 1, R.id.widget_weekly_item_2, R.id.widget_weekly_item_2_title, R.id.widget_weekly_item_2_subtitle, R.id.widget_weekly_item_2_time, R.id.widget_weekly_item_2_bell, R.id.widget_weekly_item_2_bar, FALLBACK_COLORS[1], textColor)
                    renderBottomEventRow(views, todayArray, 2, R.id.widget_weekly_item_3, R.id.widget_weekly_item_3_title, R.id.widget_weekly_item_3_subtitle, R.id.widget_weekly_item_3_time, R.id.widget_weekly_item_3_bell, R.id.widget_weekly_item_3_bar, FALLBACK_COLORS[2], textColor)
                    renderBottomEventRow(views, todayArray, 3, R.id.widget_weekly_item_4, R.id.widget_weekly_item_4_title, R.id.widget_weekly_item_4_subtitle, R.id.widget_weekly_item_4_time, R.id.widget_weekly_item_4_bell, R.id.widget_weekly_item_4_bar, FALLBACK_COLORS[3], textColor)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Haftalık widget güncelleme hatası", e)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
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
            views.setTextViewText(titleId, event.optString("title", "—"))
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
            // 🌿 Canlı ve parlak çubuk rengi
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
