/// ⏱️ Calenda — Birlikte Canlı Odaklanma Seansı Modeli
class ClubFocusSession {
  final String id;
  final String clubId;
  final String hostUserId;
  final String hostName;
  final String title;
  final String focusTag;
  final int durationMinutes;
  final String status; // 'waiting' (lobi), 'active' (başladı), 'completed', 'cancelled'
  final int participantCount;
  final List<String> participantIds;
  final List<String> participantNames;
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
    this.participantIds = const [],
    this.participantNames = const [],
    required this.startedAt,
    this.endedAt,
  });

  bool get isWaiting => status == 'waiting';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  /// Gelecek zaman ve saat dilimi (UTC kayması) tutarsızlıklarını önleyen efektif başlangıç zamanı
  DateTime get _effectiveStartedAt {
    final now = DateTime.now();
    DateTime effectiveStart = startedAt;
    if (effectiveStart.isAfter(now)) {
      final futureDiff = effectiveStart.difference(now);
      if (futureDiff.inHours >= 1) {
        effectiveStart = effectiveStart.subtract(Duration(hours: futureDiff.inHours));
      } else {
        effectiveStart = now;
      }
    }
    return effectiveStart;
  }

  /// Seans başladıktan sonra 5 dakika geçti mi? (Yeni katılımcı kilidi)
  bool get isLocked {
    if (isWaiting) return false;
    if (isActive) {
      final now = DateTime.now();
      final start = _effectiveStartedAt;
      final elapsedSec = now.isBefore(start) ? 0 : now.difference(start).inSeconds;
      return elapsedSec >= (5 * 60);
    }
    return true;
  }

  /// Yeni katılımcı katılabilir mi? (Lobi veya ilk 5 dakika içinde)
  bool get canJoin {
    if (isWaiting) return true;
    if (isActive) {
      final now = DateTime.now();
      final start = _effectiveStartedAt;
      final elapsedSec = now.isBefore(start) ? 0 : now.difference(start).inSeconds;
      return elapsedSec < (5 * 60);
    }
    return false;
  }

  /// Katılım için kalan süre (saniye cinsinden, ilk 5 dk)
  int get joinWindowRemainingSeconds {
    if (isWaiting) return 300;
    if (isActive) {
      final now = DateTime.now();
      final start = _effectiveStartedAt;
      final elapsedSec = now.isBefore(start) ? 0 : now.difference(start).inSeconds;
      return (300 - elapsedSec).clamp(0, 300);
    }
    return 0;
  }

  /// Seansın kalan süresi (saniye)
  int get remainingSeconds {
    if (isWaiting) return durationMinutes * 60;
    if (!isActive) return 0;
    final now = DateTime.now();
    final start = _effectiveStartedAt;
    final elapsed = now.isBefore(start) ? 0 : now.difference(start).inSeconds;
    final total = durationMinutes * 60;
    return (total - elapsed).clamp(0, total);
  }

  /// Tamamlanma yüzdesi (0.0 - 1.0)
  double get progressPercent {
    if (isWaiting) return 0.0;
    if (!isActive) return 1.0;
    final total = durationMinutes * 60;
    if (total <= 0) return 1.0;
    final remaining = remainingSeconds;
    return ((total - remaining) / total).clamp(0.0, 1.0);
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
    List<String>? participantIds,
    List<String>? participantNames,
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
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  factory ClubFocusSession.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      final dt = DateTime.tryParse(val.toString());
      if (dt == null) return DateTime.now();
      return dt.isUtc ? dt.toLocal() : dt;
    }

    final pIds = (json['participant_ids'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final pNames = (json['participant_names'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final hostId = json['host_user_id'] as String? ?? '';
    final hostName = json['host_name'] as String? ?? 'Kulüp Üyesi';

    if (hostId.isNotEmpty && !pIds.contains(hostId)) {
      pIds.insert(0, hostId);
      pNames.insert(0, hostName);
    }

    return ClubFocusSession(
      id: json['id'] as String? ?? '',
      clubId: json['club_id'] as String? ?? '',
      hostUserId: hostId,
      hostName: hostName,
      title: json['title'] as String? ?? 'Birlikte Odaklanma',
      focusTag: json['focus_tag'] as String? ?? 'Ders & Çalışma',
      durationMinutes: json['duration_minutes'] as int? ?? 25,
      status: json['status'] as String? ?? 'active',
      participantCount: json['participant_count'] as int? ?? pIds.length.clamp(1, 999),
      participantIds: pIds,
      participantNames: pNames,
      startedAt: parseDate(json['started_at']),
      endedAt: json['ended_at'] != null ? parseDate(json['ended_at']) : null,
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
      'participant_count': participantIds.isNotEmpty ? participantIds.length : participantCount,
      'participant_ids': participantIds,
      'participant_names': participantNames,
      'started_at': startedAt.toUtc().toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt!.toUtc().toIso8601String(),
    };
  }
}
