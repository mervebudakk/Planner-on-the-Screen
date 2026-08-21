/// Kullanıcı Profil Modeli
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isLoggedIn;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isLoggedIn = true,
    this.createdAt,
  });

  /// Boş / Giriş yapılmamış anonim profil
  factory UserProfile.guest() {
    return const UserProfile(
      id: '',
      name: 'Misafir Kullanıcı',
      email: '',
      isLoggedIn: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isLoggedIn': isLoggedIn,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];

    return UserProfile(
      id: _safeString(json['id'], maxLength: 80),
      name: _safeString(
        json['name'],
        fallback: 'Kullanıcı',
        maxLength: 80,
        allowEmpty: false,
      ),
      email: _safeString(json['email'], maxLength: 160),
      avatarUrl: _nullableString(json['avatarUrl'], maxLength: 500),
      isLoggedIn: json['isLoggedIn'] is bool
          ? json['isLoggedIn'] as bool
          : false,
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

  static String? _nullableString(Object? value, {required int maxLength}) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isLoggedIn,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
