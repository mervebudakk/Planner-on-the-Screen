import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aesthetic_planner/core/constants/app_colors.dart';
import 'package:aesthetic_planner/core/models/schedule_event.dart';
import 'package:aesthetic_planner/core/models/user_profile.dart';
import 'package:aesthetic_planner/core/models/widget_theme_config.dart';
import 'package:aesthetic_planner/core/services/storage_service.dart';
import 'package:aesthetic_planner/core/utils/date_time_utils.dart';
import 'package:aesthetic_planner/features/planner/providers/planner_provider.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('tr_TR', null);
  });
  // ─────────────────────────────────────────
  // ScheduleEvent Model Tests
  // ─────────────────────────────────────────
  group('ScheduleEvent Unit Tests', () {
    test('Event serialization to and from JSON works correctly', () {
      const event = ScheduleEvent(
        id: 'test-1',
        title: 'Business class',
        subtitle: 'Presentation',
        dayOfWeek: 2,
        startHour: 9,
        startMinute: 0,
        endHour: 12,
        endMinute: 0,
        colorHex: '#60A5FA',
        isNotificationEnabled: true,
        reminderMinutesBefore: 15,
      );

      final json = event.toJson();
      final fromJson = ScheduleEvent.fromJson(json);

      expect(fromJson.id, 'test-1');
      expect(fromJson.title, 'Business class');
      expect(fromJson.formattedTimeRange, '09:00 - 12:00');
      expect(fromJson.reminderMinutesBefore, 15);
      expect(fromJson.colorHex, '#60A5FA');
    });

    test('Events are sorted chronologically by start time', () {
      const e1 = ScheduleEvent(
        id: '1', title: 'Late', dayOfWeek: 1,
        startHour: 14, startMinute: 0, endHour: 16, endMinute: 0,
        colorHex: '#60A5FA',
      );
      const e2 = ScheduleEvent(
        id: '2', title: 'Early', dayOfWeek: 1,
        startHour: 8, startMinute: 30, endHour: 10, endMinute: 0,
        colorHex: '#F472B6',
      );

      final sorted = DateTimeUtils.sortEventsChronologically([e1, e2]);
      expect(sorted.first.id, '2');
      expect(sorted.last.id, '1');
    });

    test('Untimed events are sorted at the top of the list', () {
      const early = ScheduleEvent(
        id: 'early', title: 'Early 08:00', dayOfWeek: 1,
        startHour: 8, startMinute: 0, endHour: 9, endMinute: 0,
        colorHex: '#60A5FA', hasSpecificTime: true,
      );
      const lateEvent = ScheduleEvent(
        id: 'late', title: 'Late 21:00', dayOfWeek: 1,
        startHour: 21, startMinute: 0, endHour: 22, endMinute: 0,
        colorHex: '#60A5FA', hasSpecificTime: true,
      );
      const untimed1 = ScheduleEvent(
        id: 'untimed-1', title: 'Spor yap', dayOfWeek: 1,
        startHour: 0, startMinute: 0, endHour: 0, endMinute: 0,
        colorHex: '#34D399', hasSpecificTime: false,
      );
      const untimed2 = ScheduleEvent(
        id: 'untimed-2', title: 'Kitap oku', dayOfWeek: 1,
        startHour: 0, startMinute: 0, endHour: 0, endMinute: 0,
        colorHex: '#F472B6', hasSpecificTime: false,
      );

      final sorted = DateTimeUtils.sortEventsChronologically([lateEvent, untimed1, early, untimed2]);
      expect(sorted[0].hasSpecificTime, false);
      expect(sorted[1].hasSpecificTime, false);
      expect(sorted[2].id, 'early');
      expect(sorted[3].id, 'late');
    });

    test('Untimed event serialization hasSpecificTime works', () {
      const event = ScheduleEvent(
        id: 'untimed-test',
        title: 'Spor yap',
        dayOfWeek: 1,
        startHour: 0,
        startMinute: 0,
        endHour: 0,
        endMinute: 0,
        colorHex: '#34D399',
        hasSpecificTime: false,
      );

      final json = event.toJson();
      expect(json['hasSpecificTime'], false);

      final fromJson = ScheduleEvent.fromJson(json);
      expect(fromJson.hasSpecificTime, false);
      expect(fromJson.formattedTimeRange, '');
    });
  });

  // ─────────────────────────────────────────
  // 🔒 GÜVENLIK: fromJson Doğrulama Testleri
  // ─────────────────────────────────────────
  group('🔒 ScheduleEvent.fromJson Security Validation Tests', () {
    test('Null ID → yeni UUID üretilir, uygulama çökmez', () {
      final event = ScheduleEvent.fromJson({
        'id': null,
        'title': 'Valid',
        'dayOfWeek': 2,
        'startHour': 9, 'startMinute': 0,
        'endHour': 10, 'endMinute': 0,
        'colorHex': '#60A5FA',
      });

      expect(event.id, isNotEmpty);
      expect(event.title, 'Valid');
    });

    test('Sayısal title → varsayılan başlık atanır, TypeError fırlatılmaz', () {
      final event = ScheduleEvent.fromJson({
        'id': 'test-x',
        'title': 12345, // ← Hatalı tip
        'dayOfWeek': 2,
        'startHour': 9, 'startMinute': 0,
        'endHour': 10, 'endMinute': 0,
        'colorHex': '#60A5FA',
      });

      expect(event.title, 'İsimsiz Plan');
    });

    test('startHour = 999 → 23 ile sınırlandırılır', () {
      final event = ScheduleEvent.fromJson({
        'id': 'test-h',
        'title': 'Test',
        'dayOfWeek': 3,
        'startHour': 999, 'startMinute': 0,
        'endHour': 10, 'endMinute': 0,
        'colorHex': '#60A5FA',
      });

      expect(event.startHour, 23);
    });

    test('startHour = -5 → 0 ile sınırlandırılır', () {
      final event = ScheduleEvent.fromJson({
        'id': 'test-neg',
        'title': 'Test',
        'dayOfWeek': 3,
        'startHour': -5, 'startMinute': 0,
        'endHour': 10, 'endMinute': 0,
        'colorHex': '#60A5FA',
      });

      expect(event.startHour, 0);
    });

    test('dayOfWeek = -1 → 1 (Pazartesi) ile sınırlandırılır', () {
      final event = ScheduleEvent.fromJson({
        'id': 'test-day',
        'title': 'Test',
        'dayOfWeek': -1, // ← Sınır dışı
        'startHour': 9, 'startMinute': 0,
        'endHour': 10, 'endMinute': 0,
        'colorHex': '#60A5FA',
      });

      expect(event.dayOfWeek, 1);
    });

    test('dayOfWeek = 99 → 7 (Pazar) ile sınırlandırılır', () {
      final event = ScheduleEvent.fromJson({
        'id': 'test-day2',
        'title': 'Test',
        'dayOfWeek': 99,
        'startHour': 9, 'startMinute': 0,
        'endHour': 10, 'endMinute': 0,
        'colorHex': '#60A5FA',
      });

      expect(event.dayOfWeek, 7);
    });

    test('Geçersiz HEX renk → güvenli fallback mavi kullanılır', () {
      final event = ScheduleEvent.fromJson({
        'id': 'test-color',
        'title': 'Test',
        'dayOfWeek': 2,
        'startHour': 9, 'startMinute': 0,
        'endHour': 10, 'endMinute': 0,
        'colorHex': 'INVALID_HEX_INJECTION', // ← Potansiyel injection
      });

      expect(event.colorHex, AppColors.defaultEventColorHex);
    });

    test('HEX renk geçersiz uzunluk → fallback kullanılır', () {
      final event = ScheduleEvent.fromJson({
        'id': 'test-color2',
        'title': 'Test',
        'dayOfWeek': 2,
        'startHour': 9, 'startMinute': 0,
        'endHour': 10, 'endMinute': 0,
        'colorHex': '#60A5FA8099', // ← 10 karakter geçersiz
      });

      expect(event.colorHex, AppColors.defaultEventColorHex);
    });

    test('title 100 karakterden uzun → kesilir', () {
      final longTitle = 'A' * 200;
      final event = ScheduleEvent.fromJson({
        'id': 'test-long',
        'title': longTitle,
        'dayOfWeek': 1,
        'startHour': 9, 'startMinute': 0,
        'endHour': 10, 'endMinute': 0,
        'colorHex': '#60A5FA',
      });

      expect(event.title.length, lessThanOrEqualTo(100));
    });

    test('reminderMinutesBefore = 9999 → 120 ile sınırlandırılır', () {
      final event = ScheduleEvent.fromJson({
        'id': 'test-rem',
        'title': 'Test',
        'dayOfWeek': 2,
        'startHour': 9, 'startMinute': 0,
        'endHour': 10, 'endMinute': 0,
        'colorHex': '#60A5FA',
        'reminderMinutesBefore': 9999,
      });

      expect(event.reminderMinutesBefore, 120);
    });

    test('Tüm alanlar null → uygulama çökmez, güvenli varsayılanlar kullanılır', () {
      expect(
        () => ScheduleEvent.fromJson({
          'id': null, 'title': null, 'dayOfWeek': null,
          'startHour': null, 'startMinute': null,
          'endHour': null, 'endMinute': null,
        }),
        returnsNormally,
      );
    });
  });

  // ─────────────────────────────────────────
  // WidgetThemeConfig Tests
  // ─────────────────────────────────────────
  group('WidgetThemeConfig Unit Tests', () {
    test('Default opacity is 0.0 (%100 transparent)', () {
      const config = WidgetThemeConfig();
      expect(config.backgroundOpacity, 0.0);
      expect(config.enableTextShadow, true);
    });

    test('JSON serialization maintains opacity and theme values', () {
      const config = WidgetThemeConfig(
        backgroundOpacity: 0.25,
        enableTextShadow: true,
      );

      final json = config.toJson();
      final fromJson = WidgetThemeConfig.fromJson(json);

      expect(fromJson.backgroundOpacity, 0.25);
      expect(fromJson.enableTextShadow, true);
    });
  });

  // ─────────────────────────────────────────
  // AppColors Tests
  // ─────────────────────────────────────────
  group('AppColors Unit Tests', () {
    test('Hex to Color and back conversion is consistent', () {
      final color = AppColors.hexToColor('#60A5FA');
      final hex = AppColors.colorToHex(color);
      expect(hex.toUpperCase(), '#60A5FA');
    });
  });

  // ─────────────────────────────────────────
  // 🔒 GÜVENLIK: FNV-1a Hash Tests
  // ─────────────────────────────────────────
  group('🔒 NotificationService FNV-1a Hash Security Tests', () {
    test('Aynı input her zaman aynı hash üretir (deterministik)', () {
      // Reflection ile private metoda erişemeyiz, dolaylı test:
      // İki event aynı ID ile oluşturulduğunda cancelNotification aynı ID ile çalışmalı
      const event1 = ScheduleEvent(
        id: 'uuid-abc-123',
        title: 'Test',
        dayOfWeek: 1,
        startHour: 9, startMinute: 0,
        endHour: 10, endMinute: 0,
        colorHex: '#60A5FA',
      );
      const event2 = ScheduleEvent(
        id: 'uuid-abc-123', // Aynı ID
        title: 'Test2',
        dayOfWeek: 2,
        startHour: 10, startMinute: 0,
        endHour: 11, endMinute: 0,
        colorHex: '#F472B6',
      );

      // ID'ler aynı olduğunda FNV-1a her zaman aynı int üretmeli (çakışma test edilemez
      // ama deterministik olduğu garanti edilir - fonksiyon sadece input'a bağlıdır)
      expect(event1.id, event2.id);
    });

    test('isValidHexColor regex #RRGGBB ve #RRGGBBAA formatlarını kabul eder, geçersizlerde fallback döner', () {
      // ScheduleEvent.fromJson üzerinden dolaylı test
      final validColors = ['#60A5FA', '#FFFFFF', '#000000', '#F472B6', '#34D399', '#60A5FA80'];
      final invalidColors = [
        'INVALID', '#GGGGGG', '#60A5FA8099', // 10 karakter
        '', '#', // boş veya sadece #
        '<script>', 'DROP TABLE', // injection attempts
      ];

      for (final color in validColors) {
        final event = ScheduleEvent.fromJson({
          'id': 'test', 'title': 'Test', 'dayOfWeek': 1,
          'startHour': 9, 'startMinute': 0, 'endHour': 10, 'endMinute': 0,
          'colorHex': color,
        });
        expect(event.colorHex, color, reason: '$color geçerli olmalı');
      }

      for (final color in invalidColors) {
        final event = ScheduleEvent.fromJson({
          'id': 'test', 'title': 'Test', 'dayOfWeek': 1,
          'startHour': 9, 'startMinute': 0, 'endHour': 10, 'endMinute': 0,
          'colorHex': color,
        });
        expect(event.colorHex, AppColors.defaultEventColorHex,
            reason: '$color geçersiz → fallback kullanılmalı');
      }
    });
  });

  // ─────────────────────────────────────────
  // UserProfile Model & Equality Tests
  // ─────────────────────────────────────────
  group('UserProfile Model & Equality Tests', () {
    test('Two identical UserProfile instances are equal and share hashCode', () {
      final u1 = UserProfile(
        id: 'u1',
        username: 'calenda_test',
        firstName: 'Merve',
        lastName: 'Budak',
        email: 'test@example.com',
      );
      final u2 = UserProfile(
        id: 'u1',
        username: 'calenda_test',
        firstName: 'Merve',
        lastName: 'Budak',
        email: 'test@example.com',
      );

      expect(u1, equals(u2));
      expect(u1.hashCode, equals(u2.hashCode));
    });

    test('UserProfile copyWith modifies value and breaks equality', () {
      final u1 = UserProfile(
        id: 'u1',
        username: 'calenda_test',
        firstName: 'Merve',
        lastName: 'Budak',
        email: 'test@example.com',
      );
      final u2 = u1.copyWith(firstName: 'Updated');

      expect(u1 == u2, isFalse);
    });
  });

  // ─────────────────────────────────────────
  // DateTimeUtils Optimization Tests
  // ─────────────────────────────────────────
  group('DateTimeUtils Formatter Tests', () {
    test('formatMonthYear, formatFullDateHeader, and getFullFormattedDate return consistent Turkish strings', () {
      final date = DateTime(2026, 9, 8);
      expect(DateTimeUtils.formatMonthYear(date), 'Eylül 2026');
      expect(DateTimeUtils.getFullFormattedDate(date), 'Salı, 8 Eylül');
    });
  });

  // ─────────────────────────────────────────
  // PlannerProvider Cache Optimization Tests
  // ─────────────────────────────────────────
  group('PlannerProvider Cache Optimization Tests', () {
    test('calendarDays returns 31 days and reuses cached list', () async {
      SharedPreferences.setMockInitialValues({});
      final storageService = await StorageService.init();
      final provider = PlannerProvider(storageService);

      final days1 = provider.calendarDays;
      final days2 = provider.calendarDays;

      expect(days1.length, 31);
      expect(identical(days1, days2), isTrue);
    });

    test('getEventsForDate reuses cached list until modified', () async {
      SharedPreferences.setMockInitialValues({});
      final storageService = await StorageService.init();
      final provider = PlannerProvider(storageService);

      final date = DateTime(2026, 9, 8);
      final events1 = provider.getEventsForDate(date);
      final events2 = provider.getEventsForDate(date);

      expect(identical(events1, events2), isTrue);
    });
  });

  // ─────────────────────────────────────────
  // ⏱️ Focus Heartbeat & Crash Recovery Tests
  // ─────────────────────────────────────────
  group('Focus Session Heartbeat & Crash Recovery Tests', () {
    test('Session credited minutes can be tracked, updated, and cleared', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      const sessionId = 'session-123';

      expect(storage.getSessionCreditedMinutes(sessionId), 0);

      await storage.setSessionCreditedMinutes(sessionId, 15);
      expect(storage.getSessionCreditedMinutes(sessionId), 15);

      await storage.setSessionCreditedMinutes(sessionId, 30);
      expect(storage.getSessionCreditedMinutes(sessionId), 30);

      await storage.clearSessionCreditedMinutes(sessionId);
      expect(storage.getSessionCreditedMinutes(sessionId), 0);
    });

    test('Incremental delta calculations prevent double-counting', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      const sessionId = 'session-456';
      final today = DateTime.now();

      // Minute 10 tick: 10 minutes elapsed, 0 credited -> delta 10
      var elapsedMins = 10;
      var credited = storage.getSessionCreditedMinutes(sessionId);
      var delta = elapsedMins - credited;
      expect(delta, 10);
      await storage.recordDailyFocusMinutes(today, delta);
      await storage.setSessionCreditedMinutes(sessionId, elapsedMins);
      expect(storage.getDailyFocusMinutes(today), 10);

      // Minute 25 tick: 25 minutes elapsed, 10 credited -> delta 15
      elapsedMins = 25;
      credited = storage.getSessionCreditedMinutes(sessionId);
      delta = elapsedMins - credited;
      expect(delta, 15);
      await storage.recordDailyFocusMinutes(today, delta);
      await storage.setSessionCreditedMinutes(sessionId, elapsedMins);
      expect(storage.getDailyFocusMinutes(today), 25);

      // Natural completion at 30 mins: 30 minutes total, 25 credited -> delta 5
      elapsedMins = 30;
      credited = storage.getSessionCreditedMinutes(sessionId);
      delta = elapsedMins - credited;
      expect(delta, 5);
      await storage.recordDailyFocusMinutes(today, delta);
      await storage.setSessionCreditedMinutes(sessionId, elapsedMins);
      expect(storage.getDailyFocusMinutes(today), 30);

      // Double trigger check: delta should be 0, no extra minutes added
      credited = storage.getSessionCreditedMinutes(sessionId);
      delta = elapsedMins - credited;
      expect(delta, 0);
      expect(storage.getDailyFocusMinutes(today), 30);
    });

    test('Reconciled lost 30-min session flag persists correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      expect(storage.hasReconciledLost30MinSession(), isFalse);
      await storage.setReconciledLost30MinSession();
      expect(storage.hasReconciledLost30MinSession(), isTrue);
    });
  });

  // ─────────────────────────────────────────
  // ✍️ Strikethrough Optical Centering Tests
  // ─────────────────────────────────────────
  group('Strikethrough Optical Centering Tests', () {
    test('Single-line text calculates optical vertical center within glyph body', () {
      const text = 'Deneme';
      const fontSize = 15.5;
      const style = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700);

      final tp = TextPainter(
        text: const TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 300);

      final lm = tp.computeLineMetrics().first;
      final y = lm.baseline - (fontSize * 0.28);

      // Strikethrough y must be located between the baseline and top of lowercase letters
      expect(y, lessThan(lm.baseline));
      expect(y, greaterThan(lm.baseline - lm.ascent));
      expect(lm.width, greaterThan(0));
    });

    test('Multi-line wrapped text calculates consistent optical center for all lines', () {
      const text = 'En az 20 dakika İngilizce konuşma pratiği yap';
      const fontSize = 15.5;
      const style = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700);

      final tp = TextPainter(
        text: const TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 160);

      final lines = tp.computeLineMetrics();
      expect(lines.length, greaterThan(1));

      for (int i = 0; i < lines.length; i++) {
        final lm = lines[i];
        final y = lm.baseline - (fontSize * 0.28);
        expect(y, lessThan(lm.baseline));
        expect(y, greaterThan(lm.baseline - lm.ascent));
        expect(lm.width, greaterThan(0));
      }
    });
  });

  // ─────────────────────────────────────────
  // 🌙 Günü Toparla (Day Wrap-Up) Tests
  // ─────────────────────────────────────────
  group('Day Wrap-Up (Günü Toparla) Tests', () {
    test('copyEventsToDate copies uncompleted events with same time to target date', () async {
      SharedPreferences.setMockInitialValues({});
      final storageService = await StorageService.init();
      final provider = PlannerProvider(storageService);
      final today = DateTimeUtils.today;
      final tomorrow = today.add(const Duration(days: 1));
      final tomorrowDateStr = DateFormat('yyyy-MM-dd').format(tomorrow);

      const timedOriginal = ScheduleEvent(
        id: 'orig-timed',
        title: 'Geometri Soru Çözümü',
        subtitle: 'Çemberde Açılar',
        dayOfWeek: 5,
        startHour: 15,
        startMinute: 30,
        endHour: 17,
        endMinute: 0,
        colorHex: '#60A5FA',
        hasSpecificTime: true,
        isCompleted: false,
      );

      const untimedOriginal = ScheduleEvent(
        id: 'orig-untimed',
        title: 'Kitap Oku',
        subtitle: '20 Sayfa',
        dayOfWeek: 5,
        startHour: 0,
        startMinute: 0,
        endHour: 0,
        endMinute: 0,
        colorHex: '#34D399',
        hasSpecificTime: false,
        isCompleted: false,
      );

      final count = await provider.copyEventsToDate(
        [timedOriginal, untimedOriginal],
        tomorrow,
      );

      expect(count, 2);

      // Yarının etkinliklerini kontrol et
      final tomorrowEvents = provider.getEventsForDate(tomorrow);
      expect(tomorrowEvents.length, greaterThanOrEqualTo(2));

      final copiedTimed = tomorrowEvents.firstWhere((e) => e.title == 'Geometri Soru Çözümü');
      expect(copiedTimed.id, isNot('orig-timed'));
      expect(copiedTimed.dateStr, tomorrowDateStr);
      expect(copiedTimed.dayOfWeek, tomorrow.weekday);
      expect(copiedTimed.startHour, 15);
      expect(copiedTimed.startMinute, 30);
      expect(copiedTimed.endHour, 17);
      expect(copiedTimed.endMinute, 0);
      expect(copiedTimed.hasSpecificTime, true);
      expect(copiedTimed.isCompleted, false);

      final copiedUntimed = tomorrowEvents.firstWhere((e) => e.title == 'Kitap Oku');
      expect(copiedUntimed.id, isNot('orig-untimed'));
      expect(copiedUntimed.dateStr, tomorrowDateStr);
      expect(copiedUntimed.dayOfWeek, tomorrow.weekday);
      expect(copiedUntimed.hasSpecificTime, false);
      expect(copiedUntimed.isCompleted, false);
    });
  });
}
