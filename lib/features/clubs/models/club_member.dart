/// 🌸 Calenda — Kulüp Üyesi Modeli
class ClubMember {
  final String id;
  final String clubId;
  final String userId;
  final String displayName;
  final String avatarAnimal;
  final String avatarAccessory;
  final String avatarBgColor;
  final String role; // 'owner', 'member'
  final int dailyGoalMinutes;
  final int todayFocusMinutes;
  final bool isFocusingNow;
  final String currentSessionTitle;
  final int streakDays;
  final DateTime joinedAt;

  const ClubMember({
    required this.id,
    required this.clubId,
    required this.userId,
    required this.displayName,
    this.avatarAnimal = '01_rabbit',
    this.avatarAccessory = 'none',
    this.avatarBgColor = '#FAF7F2',
    this.role = 'member',
    this.dailyGoalMinutes = 60,
    this.todayFocusMinutes = 0,
    this.isFocusingNow = false,
    this.currentSessionTitle = '',
    this.streakDays = 0,
    required this.joinedAt,
  });

  /// Günlük hedefe ulaşma oranı (0.0 - 1.0+)
  double get goalProgress {
    if (dailyGoalMinutes <= 0) return 0.0;
    return (todayFocusMinutes / dailyGoalMinutes).clamp(0.0, 1.5);
  }

  /// Hedef tamamlandı mı?
  bool get isGoalMet => todayFocusMinutes >= dailyGoalMinutes && dailyGoalMinutes > 0;

  bool get isOwner => role == 'owner';

  ClubMember copyWith({
    String? id,
    String? clubId,
    String? userId,
    String? displayName,
    String? avatarAnimal,
    String? avatarAccessory,
    String? avatarBgColor,
    String? role,
    int? dailyGoalMinutes,
    int? todayFocusMinutes,
    bool? isFocusingNow,
    String? currentSessionTitle,
    int? streakDays,
    DateTime? joinedAt,
  }) {
    return ClubMember(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarAnimal: avatarAnimal ?? this.avatarAnimal,
      avatarAccessory: avatarAccessory ?? this.avatarAccessory,
      avatarBgColor: avatarBgColor ?? this.avatarBgColor,
      role: role ?? this.role,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      todayFocusMinutes: todayFocusMinutes ?? this.todayFocusMinutes,
      isFocusingNow: isFocusingNow ?? this.isFocusingNow,
      currentSessionTitle: currentSessionTitle ?? this.currentSessionTitle,
      streakDays: streakDays ?? this.streakDays,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory ClubMember.fromJson(Map<String, dynamic> json) {
    return ClubMember(
      id: json['id'] as String? ?? '',
      clubId: json['club_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Üye',
      avatarAnimal: json['avatar_animal'] as String? ?? '01_rabbit',
      avatarAccessory: json['avatar_accessory'] as String? ?? 'none',
      avatarBgColor: json['avatar_bg_color'] as String? ?? '#FAF7F2',
      role: json['role'] as String? ?? 'member',
      dailyGoalMinutes: json['daily_goal_minutes'] as int? ?? 60,
      todayFocusMinutes: json['today_focus_minutes'] as int? ?? 0,
      isFocusingNow: json['is_focusing_now'] as bool? ?? false,
      currentSessionTitle: json['current_session_title'] as String? ?? '',
      streakDays: json['streak_days'] as int? ?? 0,
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_id': clubId,
      'user_id': userId,
      'display_name': displayName,
      'avatar_animal': avatarAnimal,
      'avatar_accessory': avatarAccessory,
      'avatar_bg_color': avatarBgColor,
      'role': role,
      'daily_goal_minutes': dailyGoalMinutes,
      'today_focus_minutes': todayFocusMinutes,
      'is_focusing_now': isFocusingNow,
      'current_session_title': currentSessionTitle,
      'streak_days': streakDays,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
