package com.aesthetic.planner.aesthetic_planner

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * ğŸ“¡ Gece yarÄ±sÄ± alarmÄ± ve sistem olaylarÄ±nda (saat deÄŸiÅŸimi, yeniden baÅŸlatma vb.)
 * widget'larÄ±n otomatik gÃ¼ncellenmesini tetikleyen Receiver.
 */
class WidgetUpdateReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "WidgetUpdateReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        Log.d(TAG, "Sistem yayini alindi: $action")

        when (action) {
            MidnightAlarmScheduler.ACTION_MIDNIGHT_UPDATE,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_DATE_CHANGED,
            "android.intent.action.TIME_SET",
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                // 1. Her iki widget saÄŸlayÄ±cÄ±sÄ±nÄ± anÄ±nda gÃ¼ncelle
                refreshAllWidgets(context)

                // 2. Bir sonraki gece yarÄ±sÄ± iÃ§in alarmÄ± kur
                MidnightAlarmScheduler.scheduleNextMidnight(context)
            }
        }
    }

    private fun refreshAllWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)

        // A. HaftalÄ±k Widget'Ä± Yenile
        val weeklyComponent = ComponentName(context, AestheticWeeklyWidget::class.java)
        val weeklyIds = appWidgetManager.getAppWidgetIds(weeklyComponent)
        if (weeklyIds != null && weeklyIds.isNotEmpty()) {
            val weeklyProvider = AestheticWeeklyWidget()
            weeklyProvider.onUpdate(context, appWidgetManager, weeklyIds)
        }

        // B. GÃ¼nlÃ¼k Widget'Ä± Yenile
        val dailyComponent = ComponentName(context, AestheticPlannerWidget::class.java)
        val dailyIds = appWidgetManager.getAppWidgetIds(dailyComponent)
        if (dailyIds != null && dailyIds.isNotEmpty()) {
            val dailyProvider = AestheticPlannerWidget()
            dailyProvider.onUpdate(context, appWidgetManager, dailyIds)
        }
    }
}