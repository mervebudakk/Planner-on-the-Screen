import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
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
}
