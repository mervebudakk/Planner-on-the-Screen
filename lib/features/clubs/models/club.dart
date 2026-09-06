/// 🌿 Calenda — Odak Kulübü Modeli
class Club {
  final String id;
  final String name;
  final String description;
  final String iconName; // 'matcha_cup', 'book_reading', 'star_cozy', 'rabbit_focus'
  final String inviteCode; // Örn: 'CLD-782'
  final int dailyTargetMinutes; // Kulübün günlük hedef odak süresi
  final int maxMembers; // Varsayılan 15
  final int memberCount;
  final String createdBy;
  final DateTime createdAt;

  const Club({
    required this.id,
    required this.name,
    this.description = '',
    this.iconName = 'matcha_cup',
    required this.inviteCode,
    this.dailyTargetMinutes = 60,
    this.maxMembers = 15,
    this.memberCount = 1,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isFull => memberCount >= maxMembers;

  Club copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? inviteCode,
    int? dailyTargetMinutes,
    int? maxMembers,
    int? memberCount,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      inviteCode: inviteCode ?? this.inviteCode,
      dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
      maxMembers: maxMembers ?? this.maxMembers,
      memberCount: memberCount ?? this.memberCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'İsimsiz Kulüp',
      description: json['description'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'matcha_cup',
      inviteCode: json['invite_code'] as String? ?? '',
      dailyTargetMinutes: json['daily_target_minutes'] as int? ?? 60,
      maxMembers: json['max_members'] as int? ?? 15,
      memberCount: json['member_count'] as int? ?? (json['members_count'] as int? ?? 1),
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'invite_code': inviteCode,
      'daily_target_minutes': dailyTargetMinutes,
      'max_members': maxMembers,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
