package com.aesthetic.planner.aesthetic_planner

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

/**
 * Aesthetic Planner Android Şeffaf Ana Ekran ve Kilit Ekranı Widget Sağlayıcısı
 *
 * 🔒 GÜVENLİK: Bu AppWidgetProvider aşağıdaki güvenlik önlemlerini içerir:
 *  - onReceive() içinde yalnızca beklenen sistem broadcast action'ları kabul edilir.
 *  - PendingIntent FLAG_IMMUTABLE ile explicit intent olarak tanımlanmıştır.
 *  - colorHex değerleri regex ile doğrulanır; geçersiz renk crash'e yol açmaz.
 *  - Widget bridge'den gelen JSON alanları optString/optInt ile null-safe okunur.
 */
class AestheticPlannerWidget : AppWidgetProvider() {

    companion object {
        private const val TAG = "AestheticPlannerWidget"

        /** 🔒 GÜVENLİK: Geçerli HEX renk formatı — yalnızca #RRGGBB kabul edilir */
        private val HEX_COLOR_REGEX = Regex("^#[0-9A-Fa-f]{6}$")

        /** 🔒 GÜVENLİK: Güvenli fallback renkleri — kullanıcı verisi geçersiz olursa bunlar kullanılır */
        private val FALLBACK_COLORS = listOf("#60A5FA", "#F472B6", "#FBBF24")

        /**
         * 🔒 GÜVENLİK: Hex renk string'ini doğrular ve int'e çevirir.
         * Geçersiz formatlarda IllegalArgumentException fırlatmak yerine fallback rengi döner.
         */
        fun parseSafeColor(hexString: String, fallbackHex: String = "#60A5FA"): Int {
            val safeHex = if (HEX_COLOR_REGEX.matches(hexString)) hexString else fallbackHex
            return try {
                Color.parseColor(safeHex)
            } catch (e: Exception) {
                Log.w(TAG, "Renk parse hatası: $hexString — fallback kullanılıyor", e)
                Color.parseColor(fallbackHex)
            }
        }
    }

    /**
     * 🔒 GÜVENLİK: onReceive override'ı — yalnızca beklenen sistem broadcast
     * action'larını işler. Tanımlanmayan action'lar sessizce atılır.
     * Bu, kötü niyetli uygulamaların özel broadcast göndererek widget state'ini
     * bozmasını veya crash tetiklemesini engeller.
     */
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: run {
            Log.w(TAG, "🔒 Null action ile broadcast geldi — atılıyor")
            return
        }

        // Yalnızca beklenen sistem action'larını kabul et
        val allowedActions = setOf(
            AppWidgetManager.ACTION_APPWIDGET_UPDATE,
            AppWidgetManager.ACTION_APPWIDGET_DELETED,
            AppWidgetManager.ACTION_APPWIDGET_DISABLED,
            AppWidgetManager.ACTION_APPWIDGET_ENABLED,
            AppWidgetManager.ACTION_APPWIDGET_OPTIONS_CHANGED,
        )

        if (action !in allowedActions) {
            Log.w(TAG, "🔒 Beklenmeyen broadcast action atıldı: $action")
            return
        }

        super.onReceive(context, intent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.aesthetic_planner_widget_layout)

            // 🔒 GÜVENLİK: PendingIntent — explicit intent + FLAG_IMMUTABLE
            // FLAG_IMMUTABLE ile intent içeriği sonradan değiştirilemez (Intent Hijacking önlemi)
            val intent = Intent(context, MainActivity::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId, // Her widget için benzersiz requestCode
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val todayEventsJson = widgetData.getString("today_events_json", null)
                val themeConfigJson = widgetData.getString("theme_config_json", null)

                if (themeConfigJson != null) {
                    val themeObj = JSONObject(themeConfigJson)
                    val opacity = themeObj.optDouble("backgroundOpacity", 0.0)
                    val alpha = (opacity * 255).toInt().coerceIn(0, 255)
                    val bgColor = Color.argb(alpha, 0, 0, 0)
                    views.setInt(R.id.widget_root, "setBackgroundColor", bgColor)
                }

                if (todayEventsJson != null) {
                    val eventsArray = JSONArray(todayEventsJson)
                    renderEventItem(views, eventsArray, 0, R.id.widget_item_1, R.id.widget_item_1_title, R.id.widget_item_1_time, R.id.widget_item_1_bar, FALLBACK_COLORS[0])
                    renderEventItem(views, eventsArray, 1, R.id.widget_item_2, R.id.widget_item_2_title, R.id.widget_item_2_time, R.id.widget_item_2_bar, FALLBACK_COLORS[1])
                    renderEventItem(views, eventsArray, 2, R.id.widget_item_3, R.id.widget_item_3_title, R.id.widget_item_3_time, R.id.widget_item_3_bar, FALLBACK_COLORS[2])
                }
            } catch (e: Exception) {
                // 🔒 Sessiz yutma yerine log al
                Log.e(TAG, "Widget güncelleme hatası", e)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    /**
     * Tek bir etkinlik satırını widget'a render eder.
     * 🔒 GÜVENLİK: Renk string'i regex ile doğrulanır; geçersiz renk crash'e yol açmaz.
     */
    private fun renderEventItem(
        views: RemoteViews,
        eventsArray: JSONArray,
        index: Int,
        itemViewId: Int,
        titleViewId: Int,
        timeViewId: Int,
        barViewId: Int,
        fallbackColor: String,
    ) {
        if (eventsArray.length() > index) {
            val event = eventsArray.getJSONObject(index)
            views.setViewVisibility(itemViewId, View.VISIBLE)
            views.setTextViewText(titleViewId, event.optString("title", "—"))
            views.setTextViewText(timeViewId, formatTime(event))
            val colorHex = event.optString("colorHex", fallbackColor)
            views.setInt(barViewId, "setBackgroundColor", parseSafeColor(colorHex, fallbackColor))
        } else {
            views.setViewVisibility(itemViewId, View.GONE)
        }
    }

    /** Saat ve dakikayı "HH:MM - HH:MM" formatında döndürür */
    private fun formatTime(json: JSONObject): String {
        val sH = json.optInt("startHour", 9).coerceIn(0, 23).toString().padStart(2, '0')
        val sM = json.optInt("startMinute", 0).coerceIn(0, 59).toString().padStart(2, '0')
        val eH = json.optInt("endHour", 10).coerceIn(0, 23).toString().padStart(2, '0')
        val eM = json.optInt("endMinute", 0).coerceIn(0, 59).toString().padStart(2, '0')
        return "$sH:$sM - $eH:$eM"
    }
}
