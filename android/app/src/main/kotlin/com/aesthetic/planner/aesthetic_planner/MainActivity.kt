package com.aesthetic.planner.aesthetic_planner

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MidnightAlarmScheduler.scheduleNextMidnight(this)
    }

    override fun onResume() {
        super.onResume()
        MidnightAlarmScheduler.scheduleNextMidnight(this)
    }
}
