import 'package:flutter/material.dart';

/// Alışkanlık & Rutin Veri Modeli
class RoutineModel {
  final String id;
  final String title;
  final int iconCodePoint;
  final int colorValue;
  final int accentValue;
  final bool isCompleted;
  final int streak;
  final String? lastCompletedDate;

  const RoutineModel({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    this.colorValue = 0xFFEFF5ED,
    this.accentValue = 0xFF4A7C59,
    this.isCompleted = false,
    this.streak = 1,
    this.lastCompletedDate,
  });

  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
  Color get accent => Color(accentValue);

  RoutineModel copyWith({
    String? id,
    String? title,
    int? iconCodePoint,
    int? colorValue,
    int? accentValue,
    bool? isCompleted,
    int? streak,
    String? lastCompletedDate,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      accentValue: accentValue ?? this.accentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      streak: streak ?? this.streak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon_code_point': iconCodePoint,
      'color_value': colorValue,
      'accent_value': accentValue,
      'is_completed': isCompleted,
      'streak': streak,
      'last_completed_date': lastCompletedDate,
    };
  }

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['id'] as String? ?? 'r_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? '',
      iconCodePoint: json['icon_code_point'] as int? ?? Icons.auto_awesome_rounded.codePoint,
      colorValue: json['color_value'] as int? ?? 0xFFEFF5ED,
      accentValue: json['accent_value'] as int? ?? 0xFF4A7C59,
      isCompleted: json['is_completed'] as bool? ?? false,
      streak: (json['streak'] as num?)?.toInt() ?? 1,
      lastCompletedDate: json['last_completed_date'] as String?,
    );
  }

  /// 5 temel sakin ve estetik varsayılan rutin
  static List<RoutineModel> get defaults => [
        RoutineModel(
          id: 'r1',
          title: 'Günde 2 Litre Su',
          iconCodePoint: Icons.water_drop_outlined.codePoint,
          colorValue: 0xFFDAEAF6,
          accentValue: 0xFF4A7C59,
          isCompleted: true,
          streak: 12,
        ),
        RoutineModel(
          id: 'r2',
          title: '20 Sayfa Kitap Okuma',
          iconCodePoint: Icons.menu_book_rounded.codePoint,
          colorValue: 0xFFFDEBF0,
          accentValue: 0xFFC47B89,
          isCompleted: false,
          streak: 5,
        ),
        RoutineModel(
          id: 'r3',
          title: 'Günlük Öncelikler & Planlama',
          iconCodePoint: Icons.edit_note_rounded.codePoint,
          colorValue: 0xFFEBF7EE,
          accentValue: 0xFF4A7C59,
          isCompleted: true,
          streak: 8,
        ),
        RoutineModel(
          id: 'r4',
          title: '15 Dk Yürüyüş / Temiz Hava',
          iconCodePoint: Icons.directions_walk_rounded.codePoint,
          colorValue: 0xFFFCF4DD,
          accentValue: 0xFFB59A57,
          isCompleted: false,
          streak: 3,
        ),
        RoutineModel(
          id: 'r5',
          title: 'Akşam Günlüğü & Farkındalık',
          iconCodePoint: Icons.nightlight_round.codePoint,
          colorValue: 0xFFE8DFF5,
          accentValue: 0xFF8E79AB,
          isCompleted: false,
          streak: 4,
        ),
      ];
}
