/// Calenda Kullanıcı Profil Modeli
class UserProfile {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime? birthDate;
  final String avatarAnimal;      // Örn: '01_rabbit', '02_fox', '03_deer', vb.
  final String avatarAccessory;   // Örn: 'strawberry_beret', 'star_glasses', 'flower_crown', 'none'
  final String avatarBgColor;     // Örn: '#FAF7F2', '#FDEBF0', '#EBF5EE'
  final int weeklyGoalDays;       // 0 ise serbest/hedefsiz mod, 1-7 ise haftalık hedef
  final int dailyFocusMinutes;    // 0 ise serbest mod, 25/45/60 vb.
  final String coreFocusArea;     // 'Dersler & Sınavlar', 'Sakin Ajanda & Rutinler' vb.
  final bool marketingEmailOptIn;
  final bool isLoggedIn;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    required this.email,
    this.birthDate,
    this.avatarAnimal = '01_rabbit',
    this.avatarAccessory = 'none',
    this.avatarBgColor = '#FAF7F2',
    this.weeklyGoalDays = 0,
    this.dailyFocusMinutes = 0,
    this.coreFocusArea = 'Sakin & Huzurlu Haftalık Ajanda',
    this.marketingEmailOptIn = false,
    this.isLoggedIn = true,
    this.createdAt,
  });

  /// Görünen ad (Ad Soyad veya Kullanıcı Adı)
  String get displayName {
    final full = '$firstName $lastName'.trim();
    if (full.isNotEmpty) return full;
    if (username.isNotEmpty) return username.startsWith('@') ? username : '@$username';
    return 'Misafir Kullanıcı';
  }

  /// Eski name getter'ı ile geriye dönük tam uyumluluk
  String get name => displayName;

  /// Boş / Giriş yapılmamış anonim profil
  factory UserProfile.guest() {
    return const UserProfile(
      id: '',
      username: 'misafir',
      firstName: 'Misafir',
      lastName: 'Kullanıcı',
      email: '',
      isLoggedIn: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'birthDate': birthDate?.toIso8601String(),
      'avatarAnimal': avatarAnimal,
      'avatarAccessory': avatarAccessory,
      'avatarBgColor': avatarBgColor,
      'weeklyGoalDays': weeklyGoalDays,
      'dailyFocusMinutes': dailyFocusMinutes,
      'coreFocusArea': coreFocusArea,
      'marketingEmailOptIn': marketingEmailOptIn,
      'isLoggedIn': isLoggedIn,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    final birthDate = json['birthDate'];

    return UserProfile(
      id: _safeString(json['id'], maxLength: 80),
      username: _safeString(json['username'], maxLength: 60),
      firstName: _safeString(json['firstName'] ?? json['name'], fallback: '', maxLength: 80),
      lastName: _safeString(json['lastName'], maxLength: 80),
      email: _safeString(json['email'], maxLength: 160),
      birthDate: birthDate is String ? DateTime.tryParse(birthDate) : null,
      avatarAnimal: _safeString(json['avatarAnimal'], fallback: '01_rabbit', maxLength: 50),
      avatarAccessory: _safeString(json['avatarAccessory'], fallback: 'none', maxLength: 50),
      avatarBgColor: _safeString(json['avatarBgColor'], fallback: '#FAF7F2', maxLength: 30),
      weeklyGoalDays: json['weeklyGoalDays'] is int ? json['weeklyGoalDays'] as int : 0,
      dailyFocusMinutes: json['dailyFocusMinutes'] is int ? json['dailyFocusMinutes'] as int : 0,
      coreFocusArea: _safeString(json['coreFocusArea'], fallback: 'Sakin & Huzurlu Haftalık Ajanda', maxLength: 100),
      marketingEmailOptIn: json['marketingEmailOptIn'] is bool ? json['marketingEmailOptIn'] as bool : false,
      isLoggedIn: json['isLoggedIn'] is bool ? json['isLoggedIn'] as bool : false,
      createdAt: createdAt is String ? DateTime.tryParse(createdAt) : null,
    );
  }

  static String _safeString(
    Object? value, {
    String fallback = '',
    required int maxLength,
    bool allowEmpty = true,
  }) {
    if (value is! String) return fallback;
    final trimmed = value.trim();
    if (!allowEmpty && trimmed.isEmpty) return fallback;
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? birthDate,
    String? avatarAnimal,
    String? avatarAccessory,
    String? avatarBgColor,
    int? weeklyGoalDays,
    int? dailyFocusMinutes,
    String? coreFocusArea,
    bool? marketingEmailOptIn,
    bool? isLoggedIn,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      avatarAnimal: avatarAnimal ?? this.avatarAnimal,
      avatarAccessory: avatarAccessory ?? this.avatarAccessory,
      avatarBgColor: avatarBgColor ?? this.avatarBgColor,
      weeklyGoalDays: weeklyGoalDays ?? this.weeklyGoalDays,
      dailyFocusMinutes: dailyFocusMinutes ?? this.dailyFocusMinutes,
      coreFocusArea: coreFocusArea ?? this.coreFocusArea,
      marketingEmailOptIn: marketingEmailOptIn ?? this.marketingEmailOptIn,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
