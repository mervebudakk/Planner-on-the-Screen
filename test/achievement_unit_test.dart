import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aesthetic_planner/core/models/achievement.dart';
import 'package:aesthetic_planner/core/models/desk_item.dart';
import 'package:aesthetic_planner/core/models/routine_model.dart';
import 'package:aesthetic_planner/core/models/schedule_event.dart';
import 'package:aesthetic_planner/core/services/achievement_service.dart';
import 'package:aesthetic_planner/core/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Achievement & The Cozy Desk Unit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
      AchievementService.instance.resetForTesting();
    });

    test('Default achievement catalog has exactly 18 items with valid categories', () {
      final catalog = Achievement.defaultCatalog;
      expect(catalog.length, 18);

      final ids = catalog.map((a) => a.id).toSet();
      expect(ids.length, 18, reason: 'All achievement IDs must be unique');

      for (final a in catalog) {
        expect(a.titleTr.isNotEmpty, true);
        expect(a.titleEn.isNotEmpty, true);
        expect(a.descriptionTr.isNotEmpty, true);
        expect(a.descriptionEn.isNotEmpty, true);
        expect(a.targetValue, greaterThan(0));
        expect(a.chainIndex, greaterThan(0));
        expect(a.chainTotal, greaterThanOrEqualTo(a.chainIndex));
      }
    });

    test('Default desk items catalog has valid canvas coordinates (0.0 to 1.0)', () {
      final items = DeskItem.defaultItems;
      expect(items.length, greaterThanOrEqualTo(14));

      for (final item in items) {
        expect(item.id.isNotEmpty, true);
        expect(item.achievementId.isNotEmpty, true);
        expect(item.nameTr.isNotEmpty, true);
        expect(item.nameEn.isNotEmpty, true);
        expect(item.normalizedX, inInclusiveRange(0.0, 1.0));
        expect(item.normalizedY, inInclusiveRange(0.0, 1.0));
        expect(item.size, greaterThan(20.0));
      }
    });

    test('Progress ratio calculates correctly and clamps to 1.0', () {
      final achv = Achievement.defaultCatalog.firstWhere((a) => a.id == 'focus_1h'); // target: 60
      expect(achv.progressRatio, 0.0);

      final halfProgress = achv.copyWith(currentProgress: 30);
      expect(halfProgress.progressRatio, 0.5);

      final fullProgress = achv.copyWith(currentProgress: 60);
      expect(fullProgress.progressRatio, 1.0);

      final overProgress = achv.copyWith(currentProgress: 120);
      expect(overProgress.progressRatio, 1.0);

      final unlockedProgress = achv.copyWith(isUnlocked: true, currentProgress: 10);
      expect(unlockedProgress.progressRatio, 1.0);
    });

    test('StorageService persists and retrieves unlocked achievements correctly', () async {
      final storage = StorageService.instance;
      expect(storage.getUnlockedAchievements().isEmpty, true);

      final testTime = DateTime.utc(2026, 9, 11, 14, 0, 0);
      await storage.unlockAchievement('first_focus', testTime);

      expect(storage.isAchievementUnlocked('first_focus'), true);
      expect(storage.isAchievementUnlocked('focus_1h'), false);

      final unlocked = storage.getUnlockedAchievements();
      expect(unlocked['first_focus'], testTime.toIso8601String());
    });

    test('AchievementService evaluates focus minutes and unlocks first_focus & focus_1h', () async {
      final service = AchievementService.instance;

      // 65 dakika odaklanıldığında: first_focus (>=1) ve focus_1h (>=60) açılmalı
      final newUnlocks = await service.evaluateProgress(allTimeFocusMinutes: 65);

      final unlockedIds = newUnlocks.map((a) => a.id).toList();
      expect(unlockedIds.contains('first_focus'), true);
      expect(unlockedIds.contains('focus_1h'), true);
      expect(unlockedIds.contains('focus_5h'), false);

      // Desk items güncellendi mi kontrolü
      final succulent = service.deskItems.firstWhere((i) => i.id == 'desk_succulent');
      expect(succulent.isUnlocked, true);

      final hourglass = service.deskItems.firstWhere((i) => i.id == 'desk_hourglass');
      expect(hourglass.isUnlocked, true);
    });

    test('AchievementService unlocks routine streaks when target is reached', () async {
      final service = AchievementService.instance;

      final routines = [
        const RoutineModel(
          id: 'r1',
          title: 'Kitap Okuma',
          iconCodePoint: 0xe000,
          colorValue: 0xFF2E6342,
          accentValue: 0xFF8CEFA5,
          streak: 4,
          isCompleted: true,
        ),
      ];

      final newUnlocks = await service.evaluateProgress(routines: routines);
      final unlockedIds = newUnlocks.map((a) => a.id).toList();
      expect(unlockedIds.contains('routine_3d'), true);
      expect(unlockedIds.contains('routine_7d'), false);
    });

    test('AchievementService unlocks plan_10 after 10 completed plans', () async {
      final storage = StorageService.instance;
      await storage.incrementCompletedPlanCount(12);

      final service = AchievementService.instance;
      final newUnlocks = await service.evaluateProgress();

      final unlockedIds = newUnlocks.map((a) => a.id).toList();
      expect(unlockedIds.contains('plan_10'), true);
      expect(unlockedIds.contains('plan_50'), false);
    });

    test('AchievementService unlocks perfectionist when all daily plans are finished', () async {
      final service = AchievementService.instance;

      const events = [
        ScheduleEvent(
          id: 'p1',
          title: 'Ders',
          subtitle: '',
          dayOfWeek: 5,
          startHour: 9,
          startMinute: 0,
          endHour: 10,
          endMinute: 0,
          colorHex: '#B5EAD7',
          isCompleted: true,
        ),
        ScheduleEvent(
          id: 'p2',
          title: 'Spor',
          subtitle: '',
          dayOfWeek: 5,
          startHour: 11,
          startMinute: 0,
          endHour: 12,
          endMinute: 0,
          colorHex: '#B5EAD7',
          isCompleted: true,
        ),
        ScheduleEvent(
          id: 'p3',
          title: 'Okuma',
          subtitle: '',
          dayOfWeek: 5,
          startHour: 14,
          startMinute: 0,
          endHour: 15,
          endMinute: 0,
          colorHex: '#B5EAD7',
          isCompleted: true,
        ),
      ];

      final newUnlocks = await service.evaluateProgress(todayEvents: events);
      final unlockedIds = newUnlocks.map((a) => a.id).toList();
      expect(unlockedIds.contains('perfectionist'), true);
    });
  });
}
