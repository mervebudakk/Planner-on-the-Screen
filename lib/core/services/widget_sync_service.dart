import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/schedule_event.dart';
import '../models/widget_theme_config.dart';
import '../utils/date_time_utils.dart';
import 'storage_service.dart';

/// Flutter ile Native Widget'lar (Android AppWidget ve iOS WidgetKit) arasındaki köprü
class WidgetSyncService {
  /// Widget verilerini günceller ve işletim sistemine widget'ları yenileme sinyali gönderir
  static Future<void> updateWidgetData({
    required List<ScheduleEvent> allEvents,
    required WidgetThemeConfig themeConfig,
  }) async {
    try {
      final todayDate = DateTimeUtils.today;
      final int today = todayDate.weekday;

      // İçinde bulunulan haftanın (Pzt -> Paz) 7 günü ve haftalık başlığı
      final currentWeekDays = DateTimeUtils.getDaysOfWeek(0);
      final weekLabel = DateTimeUtils.getWeekLabel(0);

      // Bugünün etkinliklerini filtrele ve sırala (Günlük Widget için)
      final todayEvents = DateTimeUtils.sortEventsChronologically(
        _eventsForDate(allEvents, todayDate),
      ).take(themeConfig.maxDailyItems).toList();

      // Haftanın 7 gününün (1-7) her birinin etkinlik listesi (Haftalık Widget için)
      final Map<String, List<Map<String, dynamic>>> weeklyMap = {};
      for (int d = 1; d <= 7; d++) {
        final dayDate = currentWeekDays[d - 1];
        final dayEvents = DateTimeUtils.sortEventsChronologically(
          _eventsForDate(allEvents, dayDate),
        );
        weeklyMap[d.toString()] = dayEvents.map((e) => e.toJson()).toList();
      }

      // Aktif dil bilgisi ve yerelleştirilmiş widget başlıkları
      final lang = StorageService.instance.getSelectedLanguage() ?? 'tr';
      final isEn = lang == 'en';
      final effectiveTitle = (themeConfig.titleText == 'Bugünün Planı' && isEn)
          ? "Today's Schedule"
          : themeConfig.titleText;
      final effectiveWeeklyTitle = (themeConfig.weeklyTitleText == 'Haftalık Planım' && isEn)
          ? 'My Weekly Plan'
          : themeConfig.weeklyTitleText;

      final effectiveTheme = themeConfig.copyWith(
        titleText: effectiveTitle,
        weeklyTitleText: effectiveWeeklyTitle,
      );

      // Widget'a gönderilecek verileri kaydet
      await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      await HomeWidget.saveWidgetData<String>('app_language', lang);
      await HomeWidget.saveWidgetData<String>(
        'today_events_json',
        jsonEncode(todayEvents.map((e) => e.toJson()).toList()),
      );
      await HomeWidget.saveWidgetData<String>(
        'weekly_events_json',
        jsonEncode(weeklyMap),
      );
      await HomeWidget.saveWidgetData<String>(
        'week_label',
        weekLabel,
      );
      await HomeWidget.saveWidgetData<String>(
        'theme_config_json',
        jsonEncode(effectiveTheme.toJson()),
      );
      final dayNumbers = currentWeekDays.map((d) => d.day).toList();
      await HomeWidget.saveWidgetData<String>(
        'week_day_numbers_json',
        jsonEncode(dayNumbers),
      );
      await HomeWidget.saveWidgetData<int>('current_day_of_week', today);

      // Native Widget'ları yenile (Hem Günlük hem Haftalık)
      await HomeWidget.updateWidget(
        name: AppConstants.androidWidgetName,
        iOSName: AppConstants.iosWidgetKind,
      );
      await HomeWidget.updateWidget(
        name: AppConstants.androidWeeklyWidgetName,
        iOSName: AppConstants.iosWeeklyWidgetKind,
      );
    } catch (_) {
      // Widget platform desteği olmayan ortamlarda sessiz kal
    }
  }

  /// 📲 Uygulama içinden tek tıkla işletim sistemine widget sabitleme (Pin Widget) isteği gönderir.
  /// [isWeekly] true ise Haftalık Widget, false ise Günlük Widget'ı ekler.
  static Future<bool> requestPinWidget({bool isWeekly = false}) async {
    try {
      await HomeWidget.requestPinWidget(
        androidName: isWeekly
            ? AppConstants.androidWeeklyWidgetName
            : AppConstants.androidWidgetName,
      );
      return true;
    } catch (_) {
      return false;
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
