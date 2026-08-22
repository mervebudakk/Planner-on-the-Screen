import 'package:intl/intl.dart';
import '../models/schedule_event.dart';

/// Tarih, saat, hafta hesaplamaları ve formatlama yardımcıları
class DateTimeUtils {
  static const List<String> weekDaysTurkish = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  static const List<String> weekDaysShortTurkish = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  /// Bugünün haftanın kaçıncı günü olduğu (1 = Pazartesi, 7 = Pazar)
  static int get currentDayOfWeek => DateTime.now().weekday;

  /// Bugünün tarihi (Saat kısmı sıfırlanmış)
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Verilen tarihin bugün olup olmadığını döner
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// İki tarihin aynı gün olup olmadığını kontrol eder
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Günün tam adını döner
  static String getFullDayName(int dayOfWeek) {
    if (dayOfWeek < 1 || dayOfWeek > 7) return '';
    return weekDaysTurkish[dayOfWeek - 1];
  }

  /// Günün kısa adını döner
  static String getShortDayName(int dayOfWeek) {
    if (dayOfWeek < 1 || dayOfWeek > 7) return '';
    return weekDaysShortTurkish[dayOfWeek - 1];
  }

  /// Belirli bir hafta offsetine göre (0 = Bu Hafta, 1 = Gelecek Hafta, -1 = Geçen Hafta)
  /// haftanın Pazartesi gününü döndürür.
  static DateTime getMondayOfWeek(int weekOffset) {
    final now = DateTime.now();
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    final targetMonday = currentMonday.add(Duration(days: weekOffset * 7));
    return DateTime(targetMonday.year, targetMonday.month, targetMonday.day);
  }

  /// Belirli bir hafta offsetine ait 7 günün tam DateTime listesini döndürür (Pzt -> Paz)
  static List<DateTime> getDaysOfWeek(int weekOffset) {
    final monday = getMondayOfWeek(weekOffset);
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Hafta başlığı metnini döner (Örn: "Bu Hafta (18 - 24 Ağustos)", "Gelecek Hafta (25 - 31 Ağustos)")
  static String getWeekLabel(int weekOffset) {
    final days = getDaysOfWeek(weekOffset);
    final start = days.first;
    final end = days.last;

    String prefix;
    if (weekOffset == 0) {
      prefix = 'Bu Hafta';
    } else if (weekOffset == 1) {
      prefix = 'Gelecek Hafta';
    } else if (weekOffset == -1) {
      prefix = 'Geçen Hafta';
    } else if (weekOffset > 1) {
      prefix = '$weekOffset Hafta Sonra';
    } else {
      prefix = '${weekOffset.abs()} Hafta Önce';
    }

    if (start.month == end.month) {
      final monthName = DateFormat('MMMM', 'tr_TR').format(start);
      return '$prefix (${start.day} - ${end.day} $monthName)';
    } else {
      final startMonth = DateFormat('MMM', 'tr_TR').format(start);
      final endMonth = DateFormat('MMM', 'tr_TR').format(end);
      return '$prefix (${start.day} $startMonth - ${end.day} $endMonth)';
    }
  }

  /// Ay ve yıl metni döner (Örn: "Ağustos 2026")
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'tr_TR').format(date);
  }

  /// Başlık için detaylı gün ve tarih metni ("Perşembe, 20 Ağustos • Bugün")
  static String formatFullDateHeader(DateTime date) {
    final dateStr = DateFormat('EEEE, d MMMM', 'tr_TR').format(date);
    if (isToday(date)) {
      return '$dateStr • Bugün';
    }
    return dateStr;
  }

  /// Tam tarih formatı (Örn: "Cumartesi, 22 Ağustos")
  static String getFullFormattedDate(DateTime date) {
    return DateFormat('EEEE, d MMMM', 'tr_TR').format(date);
  }

  /// Etkinlikleri başlangıç saatine göre kronolojik sıralar
  static List<ScheduleEvent> sortEventsChronologically(List<ScheduleEvent> events) {
    final list = List<ScheduleEvent>.from(events);
    list.sort((a, b) {
      if (a.startHour != b.startHour) {
        return a.startHour.compareTo(b.startHour);
      }
      return a.startMinute.compareTo(b.startMinute);
    });
    return list;
  }
}
