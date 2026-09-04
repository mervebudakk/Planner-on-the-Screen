package com.aesthetic.planner.aesthetic_planner

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import java.util.Calendar

/**
 * â° Widget'larÄ±n gece yarÄ±sÄ± (00:00:01) otomatik olarak bir sonraki gÃ¼ne geÃ§mesini saÄŸlayan alarm zamanlayÄ±cÄ±sÄ±.
 */
object MidnightAlarmScheduler {
    private const val TAG = "MidnightScheduler"
    const val REQUEST_CODE_MIDNIGHT = 2001
    const val ACTION_MIDNIGHT_UPDATE = "com.aesthetic.planner.aesthetic_planner.ACTION_MIDNIGHT_UPDATE"

    fun scheduleNextMidnight(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return

        val intent = Intent(context, WidgetUpdateReceiver::class.java).apply {
            action = ACTION_MIDNIGHT_UPDATE
        }

        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val pendingIntent = PendingIntent.getBroadcast(context, REQUEST_CODE_MIDNIGHT, intent, flags)

        val targetMidnightMillis = calculateNextMidnightMillis()

        Log.d(TAG, "Bir sonraki gece yarisi guncellemesi zamanlandi: $targetMidnightMillis")

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        targetMidnightMillis,
                        pendingIntent
                    )
                } else {
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        targetMidnightMillis,
                        pendingIntent
                    )
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    targetMidnightMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    targetMidnightMillis,
                    pendingIntent
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Gece yarisi alarmi kurulurken hata olustu", e)
        }
    }

    private fun calculateNextMidnightMillis(): Long {
        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 1) // 1 saniye gecmesi gun sinir hatasini onler
            set(Calendar.MILLISECOND, 0)
        }
        return calendar.timeInMillis
    }
}