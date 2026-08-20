import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';

/// Haftalık plandaki her bir ders veya görevi temsil eden değişmez (immutable) model
class ScheduleEvent {
  final String id;
  final String title;
  final String subtitle;
  final int dayOfWeek; // 1: Pazartesi ... 7: Pazar
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String colorHex;
  final bool isNotificationEnabled;
  final int reminderMinutesBefore;

  const ScheduleEvent({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.dayOfWeek,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.colorHex,
    this.isNotificationEnabled = true,
    this.reminderMinutesBefore = 15,
  });

  /// Event rengini Color nesnesi olarak döndürür
  Color get color => AppColors.hexToColor(colorHex);

  /// Başlangıç ve bitiş saatini '09:00 - 12:00' formatında string olarak döndürür
  String get formattedTimeRange {
    final startH = startHour.toString().padLeft(2, '0');
    final startM = startMinute.toString().padLeft(2, '0');
    final endH = endHour.toString().padLeft(2, '0');
    final endM = endMinute.toString().padLeft(2, '0');

    if (endHour == 0 && endMinute == 0) {
      return '$startH:$startM';
    }
    return '$startH:$startM - $endH:$endM';
  }

  /// JSON dönüşümü (Local persistence ve widget bridge için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'dayOfWeek': dayOfWeek,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'colorHex': colorHex,
      'isNotificationEnabled': isNotificationEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  /// JSON'dan ScheduleEvent oluşturur.
  ///
  /// 🔒 GÜVENLİK: Tüm alanlar için tip güvenli dönüşüm, değer aralığı sınırlaması
  /// ve güvenli fallback uygulanmıştır. Bozuk veya kötü niyetle değiştirilmiş JSON
  /// uygulamayı çökertmez; bunun yerine geçerli varsayılan değerler kullanılır.
  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    // ID: null ise yeni UUID üret (asla throw etme)
    final rawId = json['id'];
    final id = (rawId is String && rawId.isNotEmpty) ? rawId : const Uuid().v4();

    // Başlık: string değilse veya boşsa varsayılan ata
    final rawTitle = json['title'];
    final title = (rawTitle is String && rawTitle.trim().isNotEmpty)
        ? rawTitle.trim().substring(0, rawTitle.trim().length.clamp(0, 100))
        : 'İsimsiz Plan';

    // Alt Başlık: en fazla 200 karakter
    final rawSubtitle = json['subtitle'];
    final subtitle = rawSubtitle is String
        ? rawSubtitle.trim().substring(0, rawSubtitle.trim().length.clamp(0, 200))
        : '';

    // Gün: 1-7 arası zorunlu (Pazartesi-Pazar)
    final rawDay = json['dayOfWeek'];
    final dayOfWeek = (rawDay is int) ? rawDay.clamp(1, 7) : 1;

    // Saatler: 0-23 arası, Dakikalar: 0-59 arası
    final startHour = (json['startHour'] is int)
        ? (json['startHour'] as int).clamp(0, 23)
        : 9;
    final startMinute = (json['startMinute'] is int)
        ? (json['startMinute'] as int).clamp(0, 59)
        : 0;
    final endHour = (json['endHour'] is int)
        ? (json['endHour'] as int).clamp(0, 23)
        : 10;
    final endMinute = (json['endMinute'] is int)
        ? (json['endMinute'] as int).clamp(0, 59)
        : 0;

    // Renk: geçerli HEX formatı kontrolü (#RRGGBB), aksi hâlde güvenli mavi
    final rawColor = json['colorHex'];
    final colorHex = (rawColor is String && _isValidHexColor(rawColor))
        ? rawColor
        : '#60A5FA';

    // Bildirim ayarları
    final isNotificationEnabled = json['isNotificationEnabled'] is bool
        ? json['isNotificationEnabled'] as bool
        : true;
    final rawReminder = json['reminderMinutesBefore'];
    final reminderMinutesBefore = (rawReminder is int)
        ? rawReminder.clamp(0, 120)
        : 15;

    return ScheduleEvent(
      id: id,
      title: title,
      subtitle: subtitle,
      dayOfWeek: dayOfWeek,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      colorHex: colorHex,
      isNotificationEnabled: isNotificationEnabled,
      reminderMinutesBefore: reminderMinutesBefore,
    );
  }

  /// 🔒 GÜVENLİK: Hex renk string'ini doğrular. Yalnızca '#RRGGBB' formatını kabul eder.
  static bool _isValidHexColor(String hex) {
    return RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex);
  }

  ScheduleEvent copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? dayOfWeek,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    String? colorHex,
    bool? isNotificationEnabled,
    int? reminderMinutesBefore,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      colorHex: colorHex ?? this.colorHex,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }
}
