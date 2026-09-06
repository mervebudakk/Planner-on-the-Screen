import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';

/// Haftalık plandaki her bir ders veya görevi temsil eden değişmez (immutable) model
class ScheduleEvent {
  final String id;
  final String title;
  final String subtitle;
  final int dayOfWeek; // 1: Pazartesi ... 7: Pazar
  final String? dateStr; // İsteğe bağlı belirli bir tarih (Örn: '2026-08-27'). Null ise haftalık tekrarlar.
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String colorHex;
  final bool isNotificationEnabled;
  final int reminderMinutesBefore;
  final DateTime? updatedAt;

  const ScheduleEvent({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.dayOfWeek,
    this.dateStr,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.colorHex,
    this.isNotificationEnabled = true,
    this.reminderMinutesBefore = 15,
    this.updatedAt,
  });

  /// Event rengini Color nesnesi olarak döndürür
  Color get color => AppColors.hexToColor(colorHex);

  /// Bitiş saati tanımlı mı?
  bool get hasEndTime => !(endHour == 0 && endMinute == 0);

  /// Tek seferlik / Alarm modu mu?
  bool get hasNoEndTime => endHour == 0 && endMinute == 0;

  /// Başlangıç ve bitiş saatini '09:00 - 12:00' veya '09:00' formatında string olarak döndürür
  String get formattedTimeRange {
    final startH = startHour.toString().padLeft(2, '0');
    final startM = startMinute.toString().padLeft(2, '0');
    final endH = endHour.toString().padLeft(2, '0');
    final endM = endMinute.toString().padLeft(2, '0');

    if (hasNoEndTime) {
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
      'dateStr': dateStr,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'colorHex': colorHex,
      'isNotificationEnabled': isNotificationEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// JSON'dan ScheduleEvent oluşturur.
  ///
  /// 🔒 GÜVENLİK: Tüm alanlar için tip güvenli dönüşüm, değer aralığı sınırlaması
  /// ve güvenli fallback uygulanmıştır. Bozuk veya kötü niyetle değiştirilmiş JSON
  /// uygulamayı çökertmez; bunun yerine geçerli varsayılan değerler kullanılır.
  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    final id = _safeString(json['id'], maxLength: 80);
    final title = _safeString(
      json['title'],
      fallback: 'İsimsiz Plan',
      maxLength: 100,
      allowEmpty: false,
    );
    final subtitle = _safeString(json['subtitle'], maxLength: 200);
    final dayOfWeek = _safeInt(json['dayOfWeek'], fallback: 1, min: 1, max: 7);

    final parsedDateStr = _safeString(json['dateStr'], maxLength: 10);
    final dateStr = _isValidDateString(parsedDateStr) ? parsedDateStr : null;

    final startHour =
        _safeInt(json['startHour'], fallback: 9, min: 0, max: 23);
    final startMinute =
        _safeInt(json['startMinute'], fallback: 0, min: 0, max: 59);
    final endHour = _safeInt(json['endHour'], fallback: 10, min: 0, max: 23);
    final endMinute =
        _safeInt(json['endMinute'], fallback: 0, min: 0, max: 59);

    final rawColor = json['colorHex'];
    final colorHex =
        AppColors.normalizeHexColor(rawColor is String ? rawColor : null);
    final rawNotificationEnabled = json['isNotificationEnabled'];
    final isNotificationEnabled =
        rawNotificationEnabled is bool ? rawNotificationEnabled : true;
    final reminderMinutesBefore = _safeInt(
      json['reminderMinutesBefore'],
      fallback: 15,
      min: 0,
      max: 120,
    );

    final rawUpdatedAt = json['updatedAt'] ?? json['updated_at'];
    final updatedAt = rawUpdatedAt is String ? DateTime.tryParse(rawUpdatedAt) : null;

    return ScheduleEvent(
      id: id.isEmpty ? const Uuid().v4() : id,
      title: title,
      subtitle: subtitle,
      dayOfWeek: dayOfWeek,
      dateStr: dateStr,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      colorHex: colorHex,
      isNotificationEnabled: isNotificationEnabled,
      reminderMinutesBefore: reminderMinutesBefore,
      updatedAt: updatedAt,
    );
  }

  static String _safeString(
    Object? value, {
    String fallback = '',
    int maxLength = 200,
    bool allowEmpty = true,
  }) {
    if (value is! String) return fallback;
    final trimmed = value.trim();
    if (!allowEmpty && trimmed.isEmpty) return fallback;
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  static int _safeInt(
    Object? value, {
    required int fallback,
    required int min,
    required int max,
  }) {
    if (value is int) return value.clamp(min, max).toInt();
    return fallback;
  }

  static bool _isValidDateString(String dateStr) {
    if (dateStr.isEmpty) return false;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) return false;

    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return false;

    final normalized =
        '${parsed.year.toString().padLeft(4, '0')}-'
        '${parsed.month.toString().padLeft(2, '0')}-'
        '${parsed.day.toString().padLeft(2, '0')}';
    return normalized == dateStr;
  }

  ScheduleEvent copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? dayOfWeek,
    String? dateStr,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    String? colorHex,
    bool? isNotificationEnabled,
    int? reminderMinutesBefore,
    DateTime? updatedAt,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dateStr: dateStr ?? this.dateStr,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      colorHex: colorHex ?? this.colorHex,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
