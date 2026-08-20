import '../models/schedule_event.dart';

/// Tarih ve saat hesaplamaları için yardımcı fonksiyonlar
class DateTimeUtils {
  static const List<String> dayNamesTr = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  static const List<String> shortDayNamesEn = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> shortDayNamesTr = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  /// Haftanın bugünkü gün indeksini (1 = Pazartesi, 7 = Pazar) döndürür
  static int get currentDayOfWeek => DateTime.now().weekday;

  /// Belirtilen günün kısa adını döndürür (1 -> 'Mon')
  static String getShortDayName(int dayOfWeek, {bool isTurkish = false}) {
    final index = (dayOfWeek - 1).clamp(0, 6);
    return isTurkish ? shortDayNamesTr[index] : shortDayNamesEn[index];
  }

  /// Belirtilen günün tam adını döndürür (1 -> 'Pazartesi')
  static String getFullDayName(int dayOfWeek) {
    final index = (dayOfWeek - 1).clamp(0, 6);
    return dayNamesTr[index];
  }

  /// Mevcut haftanın günlerinin ay içindeki gün sayılarını döndürür (Örn: Mon 17, Tue 18 ...)
  static Map<int, int> getCurrentWeekDayNumbers() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final result = <int, int>{};

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      result[i + 1] = day.day;
    }
    return result;
  }

  /// Etkinlik listesini başlangıç saatine göre kronolojik sıralar
  static List<ScheduleEvent> sortEventsChronologically(List<ScheduleEvent> events) {
    final sorted = List<ScheduleEvent>.from(events);
    sorted.sort((a, b) {
      if (a.startHour != b.startHour) {
        return a.startHour.compareTo(b.startHour);
      }
      return a.startMinute.compareTo(b.startMinute);
    });
    return sorted;
  }

  /// Saat ve dakikayı formatlar (örn: 09:05)
  static String formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
