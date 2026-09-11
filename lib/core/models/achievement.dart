import 'package:flutter/material.dart';

/// Başarı kategorileri
enum AchievementCategory {
  focus,
  routine,
  planning,
  loyalty,
  club,
  special,
}

/// Calenda Başarı Modeli
class Achievement {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
  final AchievementCategory category;
  final int targetValue;
  final int chainIndex;
  final int chainTotal;
  final IconData icon;
  final String? deskItemId;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;

  const Achievement({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.category,
    required this.targetValue,
    required this.chainIndex,
    required this.chainTotal,
    required this.icon,
    this.deskItemId,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  /// 0.0 - 1.0 aralığında ilerleme oranı
  double get progressRatio {
    if (isUnlocked) return 1.0;
    if (targetValue <= 0) return 0.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  /// Kategori ismi yerelleştirilmiş
  String getCategoryTitle(String languageCode) {
    final isEn = languageCode == 'en';
    switch (category) {
      case AchievementCategory.focus:
        return isEn ? 'Focus' : 'Odak';
      case AchievementCategory.routine:
        return isEn ? 'Routines' : 'Rutinler';
      case AchievementCategory.planning:
        return isEn ? 'Planning' : 'Planlama';
      case AchievementCategory.loyalty:
        return isEn ? 'Journey' : 'Yolculuk';
      case AchievementCategory.club:
        return isEn ? 'Clubs' : 'Kulüpler';
      case AchievementCategory.special:
        return isEn ? 'Special' : 'Özel';
    }
  }

  String getTitle(String languageCode) => languageCode == 'en' ? titleEn : titleTr;
  String getDescription(String languageCode) => languageCode == 'en' ? descriptionEn : descriptionTr;

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id,
      titleTr: titleTr,
      titleEn: titleEn,
      descriptionTr: descriptionTr,
      descriptionEn: descriptionEn,
      category: category,
      targetValue: targetValue,
      chainIndex: chainIndex,
      chainTotal: chainTotal,
      icon: icon,
      deskItemId: deskItemId,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json, Achievement base) {
    return base.copyWith(
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.tryParse(json['unlockedAt'] as String) : null,
      currentProgress: json['currentProgress'] as int? ?? 0,
    );
  }

  /// Tüm 18 Başarı Tanımı (Varsayılan Katalog)
  static List<Achievement> get defaultCatalog => [
    // ── 1. ODAK SÜRESİ ZİNCİRİ (6 Adet) ──
    const Achievement(
      id: 'first_focus',
      titleTr: 'İlk Odak',
      titleEn: 'First Focus',
      descriptionTr: 'İlk odak seansını başarıyla tamamladın.',
      descriptionEn: 'Completed your first focus session.',
      category: AchievementCategory.focus,
      targetValue: 1,
      chainIndex: 1,
      chainTotal: 6,
      icon: Icons.eco_rounded,
      deskItemId: 'desk_succulent',
    ),
    const Achievement(
      id: 'focus_1h',
      titleTr: 'Saatin Sahibi',
      titleEn: 'Timekeeper',
      descriptionTr: 'Toplam 1 saat (60 dk) odak süresine ulaştın.',
      descriptionEn: 'Accumulated 1 hour of total focus time.',
      category: AchievementCategory.focus,
      targetValue: 60,
      chainIndex: 2,
      chainTotal: 6,
      icon: Icons.hourglass_top_rounded,
      deskItemId: 'desk_hourglass',
    ),
    const Achievement(
      id: 'focus_5h',
      titleTr: 'Kararlı Öğrenci',
      titleEn: 'Steady Learner',
      descriptionTr: 'Toplam 5 saat odaklanarak ritmini güçlendirdin.',
      descriptionEn: 'Reached 5 hours of total focus time.',
      category: AchievementCategory.focus,
      targetValue: 300,
      chainIndex: 3,
      chainTotal: 6,
      icon: Icons.local_cafe_rounded,
      deskItemId: 'desk_matcha_cup',
    ),
    const Achievement(
      id: 'focus_25h',
      titleTr: 'Derin Çalışma',
      titleEn: 'Deep Work',
      descriptionTr: 'Toplam 25 saat odak süresiyle derin odak ustası oldun.',
      descriptionEn: 'Achieved 25 hours of focused study.',
      category: AchievementCategory.focus,
      targetValue: 1500,
      chainIndex: 4,
      chainTotal: 6,
      icon: Icons.wb_incandescent_rounded,
      deskItemId: 'desk_candle',
    ),
    const Achievement(
      id: 'focus_50h',
      titleTr: 'Zirve Arayışı',
      titleEn: 'Summit Seeker',
      descriptionTr: 'Toplam 50 saat odaklandın; çalışma masan canlanıyor.',
      descriptionEn: '50 hours of dedication on your study desk.',
      category: AchievementCategory.focus,
      targetValue: 3000,
      chainIndex: 5,
      chainTotal: 6,
      icon: Icons.menu_book_rounded,
      deskItemId: 'desk_lamp',
    ),
    const Achievement(
      id: 'focus_100h',
      titleTr: 'Ustalık Yolu',
      titleEn: 'Mastery Path',
      descriptionTr: '100 saatlik efsanevi odak süresiyle zirveye ulaştın.',
      descriptionEn: 'Master of deep work with 100 hours focused.',
      category: AchievementCategory.focus,
      targetValue: 6000,
      chainIndex: 6,
      chainTotal: 6,
      icon: Icons.nightlight_round,
      deskItemId: 'desk_moon_lamp',
    ),

    // ── 2. RUTİN & ALIŞKANLIK ZİNCİRİ (3 Adet) ──
    const Achievement(
      id: 'routine_3d',
      titleTr: 'Alışkanlık Tohumu',
      titleEn: 'Habit Seed',
      descriptionTr: '3 gün kesintisiz rutin serisi yakaladın.',
      descriptionEn: 'Maintained a 3-day routine streak.',
      category: AchievementCategory.routine,
      targetValue: 3,
      chainIndex: 1,
      chainTotal: 3,
      icon: Icons.grass_rounded,
      deskItemId: 'desk_potted_plant',
    ),
    const Achievement(
      id: 'routine_7d',
      titleTr: 'Haftalık Ritim',
      titleEn: 'Weekly Rhythm',
      descriptionTr: '7 gün boyunca rutinlerini eksiksiz sürdürdün.',
      descriptionEn: 'Flawless 7-day routine streak.',
      category: AchievementCategory.routine,
      targetValue: 7,
      chainIndex: 2,
      chainTotal: 3,
      icon: Icons.auto_awesome_rounded,
      deskItemId: 'desk_stationery_set',
    ),
    const Achievement(
      id: 'routine_30d',
      titleTr: 'Aylık Güç',
      titleEn: 'Monthly Power',
      descriptionTr: '30 günlük kesintisiz rutin ustalığı sergiledin.',
      descriptionEn: 'Unstoppable 30-day routine mastery.',
      category: AchievementCategory.routine,
      targetValue: 30,
      chainIndex: 3,
      chainTotal: 3,
      icon: Icons.spa_rounded,
      deskItemId: 'desk_tea_set',
    ),

    // ── 3. PLANLAMA ZİNCİRİ (3 Adet) ──
    const Achievement(
      id: 'plan_10',
      titleTr: 'Planın Var',
      titleEn: 'Plan in Motion',
      descriptionTr: 'Toplam 10 planı başarıyla tamamladın.',
      descriptionEn: 'Completed 10 scheduled plans.',
      category: AchievementCategory.planning,
      targetValue: 10,
      chainIndex: 1,
      chainTotal: 3,
      icon: Icons.checklist_rounded,
      deskItemId: 'desk_notepad',
    ),
    const Achievement(
      id: 'plan_50',
      titleTr: 'Organize Zihin',
      titleEn: 'Organized Mind',
      descriptionTr: '50 planı tamamlayarak ajandanı ustaca kullandın.',
      descriptionEn: 'Completed 50 plans with consistent organization.',
      category: AchievementCategory.planning,
      targetValue: 50,
      chainIndex: 2,
      chainTotal: 3,
      icon: Icons.collections_bookmark_rounded,
      deskItemId: 'desk_book_stack',
    ),
    const Achievement(
      id: 'plan_100',
      titleTr: 'Ustanın Defteri',
      titleEn: 'Master Journal',
      descriptionTr: '100 planı tamamlayarak zamanının efendisi oldun.',
      descriptionEn: 'Conquered 100 plans like a true master.',
      category: AchievementCategory.planning,
      targetValue: 100,
      chainIndex: 3,
      chainTotal: 3,
      icon: Icons.book_rounded,
      deskItemId: 'desk_journal',
    ),

    // ── 4. SADAKAT ZİNCİRİ (2 Adet) ──
    const Achievement(
      id: 'first_week',
      titleTr: 'İlk Hafta',
      titleEn: 'First Week',
      descriptionTr: 'Calenda ile 7 günlük yolculuğu geride bıraktın.',
      descriptionEn: 'Spent a full week organizing with Calenda.',
      category: AchievementCategory.loyalty,
      targetValue: 7,
      chainIndex: 1,
      chainTotal: 2,
      icon: Icons.calendar_month_rounded,
      deskItemId: 'desk_wall_calendar',
    ),
    const Achievement(
      id: 'first_month',
      titleTr: 'Bir Aydır Buradasın',
      titleEn: 'One Month Strong',
      descriptionTr: 'Calenda ile 30 günü tamamladın; odan seninle büyüyor.',
      descriptionEn: 'A month of dedication and aesthetic planning.',
      category: AchievementCategory.loyalty,
      targetValue: 30,
      chainIndex: 2,
      chainTotal: 2,
      icon: Icons.favorite_rounded,
      deskItemId: 'desk_photo_frame',
    ),

    // ── 5. SOSYAL & KULÜP ZİNCİRİ (2 Adet) ──
    const Achievement(
      id: 'club_join',
      titleTr: 'Takım Oyuncusu',
      titleEn: 'Team Player',
      descriptionTr: 'İlk çalışma kulübüne katıldın.',
      descriptionEn: 'Joined your very first study club.',
      category: AchievementCategory.club,
      targetValue: 1,
      chainIndex: 1,
      chainTotal: 2,
      icon: Icons.groups_rounded,
      deskItemId: 'desk_friendship_badge',
    ),
    const Achievement(
      id: 'club_session',
      titleTr: 'Birlikte Daha Güçlü',
      titleEn: 'Stronger Together',
      descriptionTr: 'Kulüp arkadaşlarınla canlı odak seansını tamamladın.',
      descriptionEn: 'Finished a live group focus session with your club.',
      category: AchievementCategory.club,
      targetValue: 1,
      chainIndex: 2,
      chainTotal: 2,
      icon: Icons.military_tech_rounded,
      deskItemId: 'desk_trophy',
    ),

    // ── 6. ÖZEL ANLAR ZİNCİRİ (2 Adet) ──
    const Achievement(
      id: 'night_owl',
      titleTr: 'Gece Baykuşu',
      titleEn: 'Night Owl',
      descriptionTr: 'Günü Toparla ile gece saatlerinde planlarını yarına devrettin.',
      descriptionEn: 'Used Day Wrap-Up late at night to prepare for tomorrow.',
      category: AchievementCategory.special,
      targetValue: 1,
      chainIndex: 1,
      chainTotal: 2,
      icon: Icons.bedtime_rounded,
      deskItemId: 'desk_star_globe',
    ),
    const Achievement(
      id: 'perfectionist',
      titleTr: 'Mükemmeliyetçi',
      titleEn: 'Perfectionist',
      descriptionTr: 'Günün tüm planlarını eksiksiz tamamladın.',
      descriptionEn: 'Finished every single scheduled plan in a day.',
      category: AchievementCategory.special,
      targetValue: 1,
      chainIndex: 2,
      chainTotal: 2,
      icon: Icons.verified_rounded,
      deskItemId: 'desk_gold_seal',
    ),
  ];
}
