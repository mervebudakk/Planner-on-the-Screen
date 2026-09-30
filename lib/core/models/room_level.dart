import 'package:flutter/foundation.dart';

/// 🏅 Calenda Odam Seviye Kademesi (XP & Seviye Tanımı)
@immutable
class RoomLevelTier {
  final int level;
  final String titleTr;
  final String titleEn;
  final int xpRequired;
  final String subtitleTr;
  final String subtitleEn;
  final bool unlocksFloor2;
  final String glbAssetPath;

  const RoomLevelTier({
    required this.level,
    required this.titleTr,
    required this.titleEn,
    required this.xpRequired,
    required this.subtitleTr,
    required this.subtitleEn,
    this.unlocksFloor2 = false,
    this.glbAssetPath = 'assets/models/room_level_1.glb',
  });

  String getTitle(String lang) => lang == 'en' ? titleEn : titleTr;
  String getSubtitle(String lang) => lang == 'en' ? subtitleEn : subtitleTr;
}

/// 🌟 Oda Seviyesi & İlerleme Hesaplayıcı
class RoomLevel {
  static const List<RoomLevelTier> tiers = [
    RoomLevelTier(
      level: 1,
      titleTr: 'Huzurlu Köşe',
      titleEn: 'Cozy Nook',
      xpRequired: 0,
      subtitleTr: '1. Kat · Başlangıç Odası',
      subtitleEn: '1st Floor · Starter Room',
      unlocksFloor2: false,
      glbAssetPath: 'assets/models/room_level_1.glb',
    ),
    RoomLevelTier(
      level: 2,
      titleTr: 'Çalışma Loftu',
      titleEn: 'Study Loft',
      xpRequired: 300,
      subtitleTr: '2. Kat Kütüphanesi Açıldı!',
      subtitleEn: '2nd Floor Library Unlocked!',
      unlocksFloor2: true,
      glbAssetPath: 'assets/models/room_level_2.glb',
    ),
    RoomLevelTier(
      level: 3,
      titleTr: 'Sevimli Yuva',
      titleEn: 'Sweet Studio',
      xpRequired: 800,
      subtitleTr: 'Modern Kreatif Alan',
      subtitleEn: 'Creative Studio Sanctuary',
      unlocksFloor2: true,
      glbAssetPath: 'assets/models/room_level_3.glb',
    ),
    RoomLevelTier(
      level: 4,
      titleTr: 'Rüya Atölyesi',
      titleEn: 'Dream Atelier',
      xpRequired: 1800,
      subtitleTr: 'Gelişmiş Çalışma & Dinlenme',
      subtitleEn: 'Master Study & Lounge',
      unlocksFloor2: true,
      glbAssetPath: 'assets/models/room_level_1.glb',
    ),
    RoomLevelTier(
      level: 5,
      titleTr: 'İlham Malikanesi',
      titleEn: 'Inspiration Penthouse',
      xpRequired: 3500,
      subtitleTr: 'En Üst Seviye Cozy Ev',
      subtitleEn: 'Ultimate Cozy Haven',
      unlocksFloor2: true,
      glbAssetPath: 'assets/models/room_level_2.glb',
    ),
  ];

  /// Mevcut XP'ye karşılık gelen seviye kademesi
  static RoomLevelTier getTier(int xp) {
    RoomLevelTier current = tiers.first;
    for (final tier in tiers) {
      if (xp >= tier.xpRequired) {
        current = tier;
      } else {
        break;
      }
    }
    return current;
  }

  /// Bir sonraki seviye kademesi (Maksimum seviyedeyse null döner)
  static RoomLevelTier? getNextTier(int xp) {
    for (final tier in tiers) {
      if (xp < tier.xpRequired) {
        return tier;
      }
    }
    return null;
  }

  /// Sonraki seviyeye kalan ilerleme oranı (0.0 .. 1.0)
  static double getProgressRatio(int xp) {
    final current = getTier(xp);
    final next = getNextTier(xp);
    if (next == null) return 1.0;
    final range = next.xpRequired - current.xpRequired;
    if (range <= 0) return 1.0;
    return ((xp - current.xpRequired) / range).clamp(0.0, 1.0);
  }
}
