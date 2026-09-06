/// ⏱️ Calenda — Birlikte Canlı Odaklanma Seansı Modeli
class ClubFocusSession {
  final String id;
  final String clubId;
  final String hostUserId;
  final String hostName;
  final String title;
  final String focusTag;
  final int durationMinutes;
  final String status; // 'active', 'completed', 'cancelled'
  final int participantCount;
  final DateTime startedAt;
  final DateTime? endedAt;

  const ClubFocusSession({
    required this.id,
    required this.clubId,
    required this.hostUserId,
    required this.hostName,
    required this.title,
    this.focusTag = 'Ders & Çalışma',
    this.durationMinutes = 25,
    this.status = 'active',
    this.participantCount = 1,
    required this.startedAt,
    this.endedAt,
  });

  bool get isActive => status == 'active';

  /// Seansın kalan süresi (saniye)
  int get remainingSeconds {
    if (!isActive) return 0;
    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    final total = durationMinutes * 60;
    return (total - elapsed).clamp(0, total);
  }

  /// Tamamlanma yüzdesi (0.0 - 1.0)
  double get progressPercent {
    if (!isActive) return 1.0;
    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    final total = durationMinutes * 60;
    if (total <= 0) return 1.0;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  ClubFocusSession copyWith({
    String? id,
    String? clubId,
    String? hostUserId,
    String? hostName,
    String? title,
    String? focusTag,
    int? durationMinutes,
    String? status,
    int? participantCount,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return ClubFocusSession(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      hostUserId: hostUserId ?? this.hostUserId,
      hostName: hostName ?? this.hostName,
      title: title ?? this.title,
      focusTag: focusTag ?? this.focusTag,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      participantCount: participantCount ?? this.participantCount,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  factory ClubFocusSession.fromJson(Map<String, dynamic> json) {
    return ClubFocusSession(
      id: json['id'] as String? ?? '',
      clubId: json['club_id'] as String? ?? '',
      hostUserId: json['host_user_id'] as String? ?? '',
      hostName: json['host_name'] as String? ?? 'Kulüp Üyesi',
      title: json['title'] as String? ?? 'Odaklanma Seansı',
      focusTag: json['focus_tag'] as String? ?? 'Ders & Çalışma',
      durationMinutes: json['duration_minutes'] as int? ?? 25,
      status: json['status'] as String? ?? 'active',
      participantCount: json['participant_count'] as int? ?? 1,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_id': clubId,
      'host_user_id': hostUserId,
      'host_name': hostName,
      'title': title,
      'focus_tag': focusTag,
      'duration_minutes': durationMinutes,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt!.toIso8601String(),
    };
  }
}
