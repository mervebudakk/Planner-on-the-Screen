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

  static const List<String> weekDaysEnglish = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
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

  static const List<String> weekDaysShortEnglish = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> monthsTurkish = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const List<String> monthsEnglish = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Ayın adını seçili dile göre döner (Örn: "Ağustos" / "August")
  static String getMonthName(DateTime date, {String? locale}) {
    if (date.month < 1 || date.month > 12) return '';
    final isEn = locale != null && locale.startsWith('en');
    return isEn ? monthsEnglish[date.month - 1] : monthsTurkish[date.month - 1];
  }

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
  static String getFullDayName(int dayOfWeek, {String? locale}) {
    if (dayOfWeek < 1 || dayOfWeek > 7) return '';
    final isEn = locale != null && locale.startsWith('en');
    return isEn ? weekDaysEnglish[dayOfWeek - 1] : weekDaysTurkish[dayOfWeek - 1];
  }

  /// Günün kısa adını döner
  static String getShortDayName(int dayOfWeek, {String? locale}) {
    if (dayOfWeek < 1 || dayOfWeek > 7) return '';
    final isEn = locale != null && locale.startsWith('en');
    return isEn ? weekDaysShortEnglish[dayOfWeek - 1] : weekDaysShortTurkish[dayOfWeek - 1];
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

  /// Hafta başlığı metnini döner (Örn: "Bu Hafta (18 - 24 Ağustos)", "This Week (18 - 24 August)")
  static String getWeekLabel(int weekOffset, {String? locale}) {
    final days = getDaysOfWeek(weekOffset);
    final start = days.first;
    final end = days.last;
    final isEn = locale != null && locale.startsWith('en');

    String prefix;
    if (weekOffset == 0) {
      prefix = isEn ? 'This Week' : 'Bu Hafta';
    } else if (weekOffset == 1) {
      prefix = isEn ? 'Next Week' : 'Gelecek Hafta';
    } else if (weekOffset == -1) {
      prefix = isEn ? 'Last Week' : 'Geçen Hafta';
    } else if (weekOffset > 1) {
      prefix = isEn ? '$weekOffset Weeks Later' : '$weekOffset Hafta Sonra';
    } else {
      prefix = isEn ? '${weekOffset.abs()} Weeks Ago' : '${weekOffset.abs()} Hafta Önce';
    }

    final locCode = isEn ? 'en_US' : 'tr_TR';
    final monthFormat = DateFormat('MMMM', locCode);
    final shortMonthFormat = DateFormat('MMM', locCode);

    if (start.month == end.month) {
      final monthName = monthFormat.format(start);
      return '$prefix (${start.day} - ${end.day} $monthName)';
    } else {
      final startMonth = shortMonthFormat.format(start);
      final endMonth = shortMonthFormat.format(end);
      return '$prefix (${start.day} $startMonth - ${end.day} $endMonth)';
    }
  }

  /// Ay ve yıl metni döner (Örn: "Ağustos 2026" / "August 2026")
  static String formatMonthYear(DateTime date, {String? locale}) {
    final locCode = (locale != null && locale.startsWith('en')) ? 'en_US' : 'tr_TR';
    return DateFormat('MMMM yyyy', locCode).format(date);
  }

  /// Başlık için detaylı gün ve tarih metni ("Perşembe, 20 Ağustos • Bugün")
  static String formatFullDateHeader(DateTime date, {String? locale}) {
    final isEn = locale != null && locale.startsWith('en');
    final locCode = isEn ? 'en_US' : 'tr_TR';
    final dateStr = DateFormat('EEEE, d MMMM', locCode).format(date);
    if (isToday(date)) {
      final todayLabel = isEn ? 'Today' : 'Bugün';
      return '$dateStr • $todayLabel';
    }
    return dateStr;
  }

  /// Tam tarih formatı (Örn: "Cumartesi, 22 Ağustos")
  static String getFullFormattedDate(DateTime date, {String? locale}) {
    final locCode = (locale != null && locale.startsWith('en')) ? 'en_US' : 'tr_TR';
    return DateFormat('EEEE, d MMMM', locCode).format(date);
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
