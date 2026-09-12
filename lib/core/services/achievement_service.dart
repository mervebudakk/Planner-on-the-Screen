import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../models/desk_item.dart';
import '../models/room_furniture.dart';
import '../models/room_state.dart';
import '../models/routine_model.dart';
import '../models/schedule_event.dart';
import 'error_logger.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

/// 🏆 Calenda Gamification & Cozy Room Yönetim Servisi
class AchievementService extends ChangeNotifier {
  static final AchievementService _instance = AchievementService._internal();
  static AchievementService get instance => _instance;

  AchievementService._internal() {
    _init();
  }

  List<Achievement> _achievements = [];
  List<DeskItem> _deskItems = [];
  String _roomThemeColor = 'pink';
  RoomState _roomState = RoomState(
    themeColor: 'pink',
    activeItems: RoomState.defaultActiveItems,
  );
  bool _isInitialized = false;

  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<DeskItem> get deskItems => List.unmodifiable(_deskItems);
  String get roomThemeColor => _roomThemeColor;
  RoomState get roomState => _roomState;

  Future<void> setRoomThemeColor(String color) async {
    if (_roomThemeColor == color) return;
    _roomThemeColor = color;
    _roomState = _roomState.copyWith(themeColor: color);
    notifyListeners();
    try {
      await StorageService.instance.setRoomThemeColor(color);
    } catch (e, st) {
      ErrorLogger.log('AchievementService.setRoomThemeColor', e, st);
    }
  }

  Future<void> setActiveRoomItem(RoomCategory category, String itemId) async {
    final updatedItems = Map<RoomCategory, String>.from(_roomState.activeItems);
    updatedItems[category] = itemId;
    _roomState = _roomState.copyWith(activeItems: updatedItems);
    notifyListeners();
    try {
      await StorageService.instance.setActiveRoomItem(category.name, itemId);
    } catch (e, st) {
      ErrorLogger.log('AchievementService.setActiveRoomItem', e, st);
    }
  }

  Future<void> setActiveRoomFloor(int floor) async {
    if (_roomState.activeFloor == floor) return;
    _roomState = _roomState.copyWith(activeFloor: floor);
    notifyListeners();
    try {
      await StorageService.instance.setActiveRoomFloor(floor);
    } catch (e, st) {
      ErrorLogger.log('AchievementService.setActiveRoomFloor', e, st);
    }
  }

  Future<void> addRoomXP(int amount) async {
    if (amount <= 0) return;
    final newXp = _roomState.xp + amount;
    _roomState = _roomState.copyWith(xp: newXp);
    notifyListeners();
    try {
      await StorageService.instance.addRoomXP(amount);
    } catch (e, st) {
      ErrorLogger.log('AchievementService.addRoomXP', e, st);
    }
  }

  int get focusXP => StorageService.instance.getAllTimeFocusMinutes();

  bool isFurnitureUnlocked(RoomFurnitureItem item) {
    if (item.requiredXP <= 0) return true;
    return focusXP >= item.requiredXP;
  }

  bool get isFloor2Unlocked {
    final floor1Items = RoomFurnitureItem.catalog.where((i) => i.level <= 2);
    return floor1Items.every((item) => isFurnitureUnlocked(item));
  }

  int get floor1UnlockedCount {
    return RoomFurnitureItem.catalog
        .where((i) => i.level <= 2 && isFurnitureUnlocked(i))
        .length;
  }

  int get floor1TotalCount {
    return RoomFurnitureItem.catalog.where((i) => i.level <= 2).length;
  }

  List<RoomFurnitureItem> getFurnitureCatalogForCategory(RoomCategory category) {
    return RoomFurnitureItem.catalog
        .where((item) => item.category == category)
        .map((item) => item.copyWith(isUnlocked: isFurnitureUnlocked(item)))
        .toList();
  }

  int get unlockedCount => _achievements.where((a) => a.isUnlocked).length;
  int get totalCount => _achievements.length;
  double get totalProgressRatio => totalCount > 0 ? unlockedCount / totalCount : 0.0;

  void _init() {
    if (_isInitialized) return;
    try {
      final storage = StorageService.instance;
      _roomThemeColor = storage.getRoomThemeColor();
      final savedActiveMap = storage.getActiveRoomItems();
      final activeItems = Map<RoomCategory, String>.from(RoomState.defaultActiveItems);
      for (final category in RoomCategory.values) {
        if (savedActiveMap.containsKey(category.name)) {
          activeItems[category] = savedActiveMap[category.name]!;
        }
      }
      final xp = storage.getRoomXP();
      final activeFloor = storage.getActiveRoomFloor();
      _roomState = RoomState(
        themeColor: _roomThemeColor,
        activeItems: activeItems,
        activeFloor: activeFloor,
        xp: xp,
      );

      final unlockedMap = storage.getUnlockedAchievements();

      _achievements = Achievement.defaultCatalog.map((base) {
        final timestampStr = unlockedMap[base.id];
        if (timestampStr != null) {
          final unlockedDate = DateTime.tryParse(timestampStr) ?? DateTime.now().toUtc();
          return base.copyWith(
            isUnlocked: true,
            unlockedAt: unlockedDate,
            currentProgress: base.targetValue,
          );
        }
        return base;
      }).toList();

      _syncDeskItems();
      _isInitialized = true;
    } catch (e, st) {
      ErrorLogger.log('AchievementService._init', e, st);
    }
  }

  @visibleForTesting
  void resetForTesting() {
    _isInitialized = false;
    _init();
  }

  void _syncDeskItems() {
    final unlockedIds = _achievements.where((a) => a.isUnlocked).map((a) => a.id).toSet();
    _deskItems = DeskItem.defaultItems.map((item) {
      final isUnlocked = unlockedIds.contains(item.achievementId);
      return item.copyWith(isUnlocked: isUnlocked);
    }).toList();
  }

  /// Tüm başarıları baştan değerlendirir ve yeni açılan başarıları döner
  Future<List<Achievement>> evaluateProgress({
    int? allTimeFocusMinutes,
    List<RoutineModel>? routines,
    List<ScheduleEvent>? todayEvents,
    bool isNightOwlAction = false,
    bool isClubJoined = false,
    bool isClubSessionFinished = false,
  }) async {
    final storage = StorageService.instance;
    final List<Achievement> newlyUnlocked = [];

    // 1. İstatistikleri topla
    final totalFocus = allTimeFocusMinutes ?? storage.getAllTimeFocusMinutes();
    final totalPlans = storage.getTotalCompletedPlans();

    int maxRoutineStreak = 0;
    if (routines != null) {
      for (final r in routines) {
        if (r.streak > maxRoutineStreak) {
          maxRoutineStreak = r.streak;
        }
      }
    } else {
      final raw = storage.getRoutinesRaw();
      if (raw.isNotEmpty) {
        final savedRoutines = storage.getRoutines();
        for (final r in savedRoutines) {
          if (r.streak > maxRoutineStreak) {
            maxRoutineStreak = r.streak;
          }
        }
      }
    }

    final firstDate = storage.getFirstAppOpenDate();
    final daysSinceFirstOpen = DateTime.now().toUtc().difference(firstDate).inDays + 1;

    // Günün tüm planları bitti mi kontrolü
    bool isPerfectionistEligible = false;
    if (todayEvents != null && todayEvents.isNotEmpty) {
      final completedToday = todayEvents.where((e) => e.isCompleted).length;
      if (completedToday >= 3 && completedToday == todayEvents.length) {
        isPerfectionistEligible = true;
      }
    }

    // 2. Her bir başarıyı kontrol et
    final List<Achievement> updated = [];
    final now = DateTime.now().toUtc();

    for (final achv in _achievements) {
      if (achv.isUnlocked) {
        updated.add(achv);
        continue;
      }

      int progress = 0;
      bool shouldUnlock = false;

      switch (achv.id) {
        // ── Odak Zinciri ──
        case 'first_focus':
          progress = totalFocus >= 1 ? 1 : 0;
          shouldUnlock = totalFocus >= 1;
          break;
        case 'focus_1h':
          progress = totalFocus.clamp(0, 60);
          shouldUnlock = totalFocus >= 60;
          break;
        case 'focus_5h':
          progress = totalFocus.clamp(0, 300);
          shouldUnlock = totalFocus >= 300;
          break;
        case 'focus_25h':
          progress = totalFocus.clamp(0, 1500);
          shouldUnlock = totalFocus >= 1500;
          break;
        case 'focus_50h':
          progress = totalFocus.clamp(0, 3000);
          shouldUnlock = totalFocus >= 3000;
          break;
        case 'focus_100h':
          progress = totalFocus.clamp(0, 6000);
          shouldUnlock = totalFocus >= 6000;
          break;

        // ── Rutin Zinciri ──
        case 'routine_3d':
          progress = maxRoutineStreak.clamp(0, 3);
          shouldUnlock = maxRoutineStreak >= 3;
          break;
        case 'routine_7d':
          progress = maxRoutineStreak.clamp(0, 7);
          shouldUnlock = maxRoutineStreak >= 7;
          break;
        case 'routine_30d':
          progress = maxRoutineStreak.clamp(0, 30);
          shouldUnlock = maxRoutineStreak >= 30;
          break;

        // ── Planlama Zinciri ──
        case 'plan_10':
          progress = totalPlans.clamp(0, 10);
          shouldUnlock = totalPlans >= 10;
          break;
        case 'plan_50':
          progress = totalPlans.clamp(0, 50);
          shouldUnlock = totalPlans >= 50;
          break;
        case 'plan_100':
          progress = totalPlans.clamp(0, 100);
          shouldUnlock = totalPlans >= 100;
          break;

        // ── Sadakat Zinciri ──
        case 'first_week':
          progress = daysSinceFirstOpen.clamp(0, 7);
          shouldUnlock = daysSinceFirstOpen >= 7;
          break;
        case 'first_month':
          progress = daysSinceFirstOpen.clamp(0, 30);
          shouldUnlock = daysSinceFirstOpen >= 30;
          break;

        // ── Kulüp & Sosyal ──
        case 'club_join':
          progress = isClubJoined ? 1 : 0;
          shouldUnlock = isClubJoined;
          break;
        case 'club_session':
          progress = isClubSessionFinished ? 1 : 0;
          shouldUnlock = isClubSessionFinished;
          break;

        // ── Özel ──
        case 'night_owl':
          progress = isNightOwlAction ? 1 : 0;
          shouldUnlock = isNightOwlAction;
          break;
        case 'perfectionist':
          progress = isPerfectionistEligible ? 1 : 0;
          shouldUnlock = isPerfectionistEligible;
          break;
      }

      if (shouldUnlock) {
        final unlockedAchv = achv.copyWith(
          isUnlocked: true,
          unlockedAt: now,
          currentProgress: achv.targetValue,
        );
        updated.add(unlockedAchv);
        newlyUnlocked.add(unlockedAchv);
        await storage.unlockAchievement(achv.id, now);
      } else {
        updated.add(achv.copyWith(currentProgress: progress));
      }
    }

    _achievements = updated;
    _syncDeskItems();
    notifyListeners();

    // 3. Başarı başına 100 Room XP kazandır ve bulut senkronizasyonu yap
    if (newlyUnlocked.isNotEmpty) {
      await addRoomXP(newlyUnlocked.length * 100);
      unawaited(_syncToCloud(newlyUnlocked));
    }

    return newlyUnlocked;
  }

  Future<void> _syncToCloud(List<Achievement> items) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null || userId.isEmpty || userId == 'guest') return;
      final client = SupabaseService.instance.client;
      if (client == null) return;

      for (final item in items) {
        await client.from('user_achievements').upsert({
          'user_id': userId,
          'achievement_id': item.id,
          'unlocked_at': item.unlockedAt?.toIso8601String() ?? DateTime.now().toUtc().toIso8601String(),
        });
      }
    } catch (e, st) {
      ErrorLogger.log('AchievementService._syncToCloud', e, st);
    }
  }
}
