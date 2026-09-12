import 'room_furniture.dart';
import 'room_level.dart';

/// 🏠 Calenda Odam Durumu (Seçili Mobilyalar, Kat, Tema ve XP)
class RoomState {
  final String themeColor;
  final Map<RoomCategory, String> activeItems;
  final int activeFloor; // 0 = 1. Kat (Zemin), 1 = 2. Kat (Loft)
  final int xp;

  const RoomState({
    required this.themeColor,
    required this.activeItems,
    this.activeFloor = 0,
    this.xp = 0,
  });

  RoomLevelTier get currentTier => RoomLevel.getTier(xp);
  RoomLevelTier? get nextTier => RoomLevel.getNextTier(xp);
  double get progressRatio => RoomLevel.getProgressRatio(xp);
  bool get isFloor2Unlocked => currentTier.unlocksFloor2;

  String getActiveItem(RoomCategory category) {
    return activeItems[category] ?? defaultActiveItems[category] ?? '${category.name}_lv1';
  }

  static Map<RoomCategory, String> get defaultActiveItems => {
    RoomCategory.bed: 'bed_lv1',
    RoomCategory.desk: 'desk_lv1',
    RoomCategory.rug: 'rug_lv1',
    RoomCategory.window: 'window_lv1',
    RoomCategory.decor: 'decor_lv1',
    RoomCategory.wallDecor: 'wall_lv1',
  };

  RoomState copyWith({
    String? themeColor,
    Map<RoomCategory, String>? activeItems,
    int? activeFloor,
    int? xp,
  }) {
    return RoomState(
      themeColor: themeColor ?? this.themeColor,
      activeItems: activeItems ?? this.activeItems,
      activeFloor: activeFloor ?? this.activeFloor,
      xp: xp ?? this.xp,
    );
  }
}
