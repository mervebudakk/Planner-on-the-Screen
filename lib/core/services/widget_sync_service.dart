import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/schedule_event.dart';
import '../models/widget_theme_config.dart';
import '../utils/date_time_utils.dart';

/// Flutter ile Native Widget'lar (Android AppWidget ve iOS WidgetKit) arasındaki köprü
class WidgetSyncService {
  /// Widget verilerini günceller ve işletim sistemine widget'ı yenileme sinyali gönderir
  static Future<void> updateWidgetData({
    required List<ScheduleEvent> allEvents,
    required WidgetThemeConfig themeConfig,
  }) async {
    try {
      final todayDate = DateTimeUtils.today;
      final int today = todayDate.weekday;

      // Bugünün etkinliklerini filtrele ve sırala
      final todayEvents = DateTimeUtils.sortEventsChronologically(
        _eventsForDate(allEvents, todayDate).take(themeConfig.maxDailyItems).toList(),
      );

      // 7 günün her birinin etkinlik listesi
      final Map<String, List<Map<String, dynamic>>> weeklyMap = {};
      for (int d = 1; d <= 7; d++) {
        final dayEvents = DateTimeUtils.sortEventsChronologically(
          allEvents
              .where((event) =>
                  event.dateStr == null || event.dateStr!.isEmpty)
              .where((event) => event.dayOfWeek == d)
              .toList(),
        );
        weeklyMap[d.toString()] = dayEvents.map((e) => e.toJson()).toList();
      }

      // Widget'a gönderilecek verileri kaydet
      await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      await HomeWidget.saveWidgetData<String>(
        'today_events_json',
        jsonEncode(todayEvents.map((e) => e.toJson()).toList()),
      );
      await HomeWidget.saveWidgetData<String>(
        'weekly_events_json',
        jsonEncode(weeklyMap),
      );
      await HomeWidget.saveWidgetData<String>(
        'theme_config_json',
        jsonEncode(themeConfig.toJson()),
      );
      await HomeWidget.saveWidgetData<int>('current_day_of_week', today);

      // Native Widget'ları yenile
      await HomeWidget.updateWidget(
        name: AppConstants.androidWidgetName,
        iOSName: AppConstants.iosWidgetKind,
      );
    } catch (_) {
      // Widget platform desteği olmayan ortamlarda sessiz kal
    }
  }

  static List<ScheduleEvent> _eventsForDate(
    List<ScheduleEvent> events,
    DateTime date,
  ) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    return events.where((event) {
      if (event.dateStr != null && event.dateStr!.isNotEmpty) {
        return event.dateStr == dateStr;
      }
      return event.dayOfWeek == date.weekday;
    }).toList();
  }
}
