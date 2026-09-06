import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/error_logger.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/club.dart';
import '../models/club_focus_session.dart';
import '../models/club_member.dart';

/// 🌿 Calenda — Kulüp ve Canlı Odaklanma Servisi (Cloud + Local Fallback)
class ClubService {
  static final ClubService instance = ClubService._internal();
  factory ClubService() => instance;
  ClubService._internal();

  static const String _localClubsKey = 'calenda_local_clubs_v1';
  static const String _localMembersKey = 'calenda_local_club_members_v1';
  static const String _localSessionsKey = 'calenda_local_club_sessions_v1';

  SupabaseClient? get _supabase => SupabaseService.instance.client;

  // ─────────────────────────────────────────────────────────────
  // 🔑 DAVET KODU ÜRETİCİSİ (Örn: CLD-482)
  // ─────────────────────────────────────────────────────────────
  String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final suffix = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    return 'CLD-$suffix';
  }

  // ─────────────────────────────────────────────────────────────
  // 🏛️ KULÜP OLUŞTURMA
  // ─────────────────────────────────────────────────────────────
  Future<Club> createClub({
    required String name,
    String description = '',
    String iconName = 'matcha_cup',
    int dailyTargetMinutes = 60,
    required UserProfile userProfile,
  }) async {
    final clubId = const Uuid().v4();
    final inviteCode = generateInviteCode();
    final now = DateTime.now();

    final newClub = Club(
      id: clubId,
      name: name.trim(),
      description: description.trim(),
      iconName: iconName,
      inviteCode: inviteCode,
      dailyTargetMinutes: dailyTargetMinutes,
      maxMembers: 15,
      memberCount: 1,
      createdBy: userProfile.id.isNotEmpty ? userProfile.id : 'local_owner',
      createdAt: now,
    );

    final ownerMember = ClubMember(
      id: const Uuid().v4(),
      clubId: clubId,
      userId: userProfile.id.isNotEmpty ? userProfile.id : 'local_owner',
      displayName: userProfile.displayName,
      avatarAnimal: userProfile.avatarAnimal,
      avatarAccessory: userProfile.avatarAccessory,
      avatarBgColor: userProfile.avatarBgColor,
      role: 'owner',
      dailyGoalMinutes: dailyTargetMinutes,
      todayFocusMinutes: 0,
      joinedAt: now,
    );

    // 1. Bulut Senkronizasyonu (Supabase)
    final sb = _supabase;
    if (sb != null && userProfile.id.isNotEmpty) {
      try {
        await sb.from('clubs').insert({
          'id': newClub.id,
          'name': newClub.name,
          'description': newClub.description,
          'icon_name': newClub.iconName,
          'invite_code': newClub.inviteCode,
          'daily_target_minutes': newClub.dailyTargetMinutes,
          'max_members': 15,
          'created_by': userProfile.id,
          'created_at': now.toIso8601String(),
        }).timeout(const Duration(seconds: 8));

        await sb.from('club_members').insert({
          'id': ownerMember.id,
          'club_id': clubId,
          'user_id': userProfile.id,
          'display_name': ownerMember.displayName,
          'avatar_animal': ownerMember.avatarAnimal,
          'avatar_accessory': ownerMember.avatarAccessory,
          'avatar_bg_color': ownerMember.avatarBgColor,
          'role': 'owner',
          'daily_goal_minutes': ownerMember.dailyGoalMinutes,
          'joined_at': now.toIso8601String(),
        }).timeout(const Duration(seconds: 8));
      } catch (e, st) {
        ErrorLogger.log('ClubService.createClub.supabase', e, st);
      }
    }

    // 2. Yerel Önbellek Kaydı
    await _saveLocalClub(newClub);
    await _saveLocalMember(ownerMember);

    return newClub;
  }

  // ─────────────────────────────────────────────────────────────
  // 🤝 DAVET KODUYLA KULÜBE KATILMA (Maksimum 15 Kişi)
  // ─────────────────────────────────────────────────────────────
  Future<Club> joinClubByInviteCode({
    required String inviteCode,
    required UserProfile userProfile,
  }) async {
    final cleanCode = inviteCode.trim().toUpperCase().replaceAll(' ', '');
    if (cleanCode.isEmpty) {
      throw Exception('Lütfen geçerli bir davet kodu girin.');
    }

    final normalizedSearch = cleanCode.replaceAll('-', '');

    // 1. Bulut Senkronizasyonu (Supabase)
    final sb = _supabase;
    if (sb != null && userProfile.id.isNotEmpty) {
      try {
        // Buluttan kulübü ara
        final res = await sb
            .from('clubs')
            .select()
            .eq('invite_code', cleanCode)
            .maybeSingle()
            .timeout(const Duration(seconds: 8));

        if (res != null) {
          final foundClub = Club.fromJson(res);

          // Üye sayısını kontrol et (Maksimum 15 Kişi Kuralı)
          final membersRes = await sb
              .from('club_members')
              .select('id, user_id')
              .eq('club_id', foundClub.id)
              .timeout(const Duration(seconds: 8));

          final membersList = membersRes as List<dynamic>;
          final isAlreadyMember = membersList.any(
            (m) => m['user_id'] == userProfile.id,
          );

          if (isAlreadyMember) {
            await _saveLocalClub(foundClub);
            return foundClub;
          }

          if (membersList.length >= foundClub.maxMembers) {
            throw Exception(
              'Bu kulüp maksimum kapasitesine (${foundClub.maxMembers} üye) ulaşmıştır.',
            );
          }

          // Üyeyi kulübe ekle
          final newMember = ClubMember(
            id: const Uuid().v4(),
            clubId: foundClub.id,
            userId: userProfile.id,
            displayName: userProfile.displayName,
            avatarAnimal: userProfile.avatarAnimal,
            avatarAccessory: userProfile.avatarAccessory,
            avatarBgColor: userProfile.avatarBgColor,
            role: 'member',
            dailyGoalMinutes: foundClub.dailyTargetMinutes,
            todayFocusMinutes: 0,
            joinedAt: DateTime.now(),
          );

          await sb.from('club_members').insert({
            'id': newMember.id,
            'club_id': foundClub.id,
            'user_id': userProfile.id,
            'display_name': newMember.displayName,
            'avatar_animal': newMember.avatarAnimal,
            'avatar_accessory': newMember.avatarAccessory,
            'avatar_bg_color': newMember.avatarBgColor,
            'role': 'member',
            'daily_goal_minutes': newMember.dailyGoalMinutes,
            'joined_at': DateTime.now().toIso8601String(),
          }).timeout(const Duration(seconds: 8));

          final updatedClub = foundClub.copyWith(
            memberCount: membersList.length + 1,
          );
          await _saveLocalClub(updatedClub);
          await _saveLocalMember(newMember);
          return updatedClub;
        }
      } catch (e, st) {
        ErrorLogger.log('ClubService.joinClubByInviteCode.supabase', e, st);
        // Maksimum kapasite gibi iş kurallarını yukarı ilet
        if (e.toString().contains('maksimum kapasite')) {
          rethrow;
        }
        // Sunucu tablosu henüz yoksa veya bağlantı kurulamadıysa yerel arama için devam et
      }
    }

    // 2. Yerel Mod Kontrolü (Yerelde oluşturulmuş / kayıtlı kulüpler)
    final localClubs = await fetchLocalClubs();
    final match = localClubs.cast<Club?>().firstWhere(
      (c) =>
          c != null &&
          (c.inviteCode.toUpperCase().replaceAll('-', '') == normalizedSearch ||
              c.inviteCode.toUpperCase() == cleanCode),
      orElse: () => null,
    );

    if (match != null) {
      final members = await fetchLocalMembers(match.id);
      final isAlreadyMember = members.any(
        (m) =>
            m.userId == userProfile.id ||
            m.displayName == userProfile.displayName,
      );

      if (!isAlreadyMember) {
        if (members.length >= match.maxMembers) {
          throw Exception(
            'Bu kulüp maksimum kapasitesine (${match.maxMembers} üye) ulaşmıştır.',
          );
        }

        final newMember = ClubMember(
          id: const Uuid().v4(),
          clubId: match.id,
          userId: userProfile.id.isNotEmpty ? userProfile.id : 'local_member',
          displayName: userProfile.displayName,
          avatarAnimal: userProfile.avatarAnimal,
          avatarAccessory: userProfile.avatarAccessory,
          avatarBgColor: userProfile.avatarBgColor,
          role: 'member',
          dailyGoalMinutes: match.dailyTargetMinutes,
          todayFocusMinutes: 0,
          joinedAt: DateTime.now(),
        );

        await _saveLocalMember(newMember);
        final updatedClub = match.copyWith(memberCount: members.length + 1);
        await _saveLocalClub(updatedClub);
        return updatedClub;
      }

      return match;
    }

    throw Exception('Bu davet koduna ($cleanCode) ait bir kulüp bulunamadı.');
  }

  // ─────────────────────────────────────────────────────────────
  // 📜 KULLANICININ KULÜPLERİNİ GETİRME
  // ─────────────────────────────────────────────────────────────
  Future<List<Club>> fetchUserClubs(String userId) async {
    final sb = _supabase;
    if (sb != null && userId.isNotEmpty) {
      try {
        final res = await sb
            .from('club_members')
            .select('club_id, clubs(*)')
            .eq('user_id', userId)
            .timeout(const Duration(seconds: 8));

        final List<Club> clubs = [];
        for (final row in res as List<dynamic>) {
          if (row['clubs'] != null) {
            final clubJson = Map<String, dynamic>.from(row['clubs'] as Map);
            // Üye sayısını al
            final countRes = await sb
                .from('club_members')
                .select('id')
                .eq('club_id', clubJson['id'])
                .timeout(const Duration(seconds: 5));
            clubJson['member_count'] = (countRes as List).length;
            clubs.add(Club.fromJson(clubJson));
          }
        }
        await _persistLocalClubs(clubs);
        return clubs;
      } catch (e, st) {
        ErrorLogger.log('ClubService.fetchUserClubs', e, st);
      }
    }
    return fetchLocalClubs();
  }

  // ─────────────────────────────────────────────────────────────
  // 👥 KULÜP ÜYELERİNİ & GÜNLÜK HEDEFLERİNİ GETİRME
  // ─────────────────────────────────────────────────────────────
  Future<List<ClubMember>> fetchClubMembers(String clubId) async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final sb = _supabase;

    if (sb != null) {
      try {
        final res = await sb
            .from('club_members')
            .select()
            .eq('club_id', clubId)
            .timeout(const Duration(seconds: 8));

        // Bugünkü odak istatistiklerini çek
        final progressRes = await sb
            .from('club_daily_progress')
            .select()
            .eq('club_id', clubId)
            .eq('date', todayStr)
            .timeout(const Duration(seconds: 8));

        final progressMap = <String, int>{};
        for (final p in (progressRes as List<dynamic>)) {
          progressMap[p['user_id'] as String] = (p['total_focus_minutes'] as int?) ?? 0;
        }

        final members = (res as List<dynamic>).map((json) {
          final member = ClubMember.fromJson(json as Map<String, dynamic>);
          final todayMins = progressMap[member.userId] ?? 0;
          return member.copyWith(todayFocusMinutes: todayMins);
        }).toList();

        await _persistLocalMembers(clubId, members);
        return members;
      } catch (e, st) {
        ErrorLogger.log('ClubService.fetchClubMembers', e, st);
      }
    }

    return fetchLocalMembers(clubId);
  }

  // ─────────────────────────────────────────────────────────────
  // ⏱️ BİRLİKTE ODAKLANMA SEANSI BAŞLATMA
  // ─────────────────────────────────────────────────────────────
  Future<ClubFocusSession> startFocusSession({
    required String clubId,
    required UserProfile user,
    required String title,
    required int durationMinutes,
    String focusTag = 'Ders & Çalışma',
  }) async {
    final sessionId = const Uuid().v4();
    final now = DateTime.now();

    final session = ClubFocusSession(
      id: sessionId,
      clubId: clubId,
      hostUserId: user.id.isNotEmpty ? user.id : 'local_host',
      hostName: user.displayName,
      title: title.isNotEmpty ? title : 'Birlikte Odaklanma',
      focusTag: focusTag,
      durationMinutes: durationMinutes,
      status: 'active',
      participantCount: 1,
      startedAt: now,
    );

    final sb = _supabase;
    if (sb != null) {
      try {
        await sb
            .from('club_focus_sessions')
            .insert(session.toJson())
            .timeout(const Duration(seconds: 8));

        // Katılımcıyı ekle
        await sb.from('session_participants').insert({
          'id': const Uuid().v4(),
          'session_id': sessionId,
          'user_id': user.id,
          'display_name': user.displayName,
          'joined_at': now.toIso8601String(),
        }).timeout(const Duration(seconds: 8));

        // Supabase Realtime Broadcast ile odaya duyur
        final channel = sb.channel('club_sessions_$clubId');
        await channel.sendBroadcastMessage(
          event: 'new_session',
          payload: {
            'session_id': sessionId,
            'host_name': user.displayName,
            'duration': durationMinutes,
            'title': session.title,
            'tag': session.focusTag,
          },
        );
      } catch (e, st) {
        ErrorLogger.log('ClubService.startFocusSession', e, st);
      }
    }

    // Yerel bildirim göster (Simülasyon / Foreground)
    await NotificationService().showImmediateNotification(
      title: '🌿 Odaklanma Seansı Başladı',
      body: '${user.displayName} $durationMinutes dakikalık "$title" seansı başlattı.',
      payload: 'club_session:$sessionId',
    );

    await _saveLocalSession(session);
    return session;
  }

  // ─────────────────────────────────────────────────────────────
  // 📈 GÜNLÜK ODAK SÜRESİNİ KULÜBE KAYDETME
  // ─────────────────────────────────────────────────────────────
  Future<void> recordFocusMinutes({
    required String clubId,
    required String userId,
    required int minutes,
  }) async {
    if (minutes <= 0) return;
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final sb = _supabase;

    if (sb != null && userId.isNotEmpty) {
      try {
        // Mevcut süreyi al ve artır
        final existing = await sb
            .from('club_daily_progress')
            .select('total_focus_minutes')
            .eq('club_id', clubId)
            .eq('user_id', userId)
            .eq('date', todayStr)
            .maybeSingle()
            .timeout(const Duration(seconds: 8));

        final currentMins = existing != null
            ? (existing['total_focus_minutes'] as int? ?? 0)
            : 0;
        final newTotal = currentMins + minutes;

        await sb.from('club_daily_progress').upsert({
          'club_id': clubId,
          'user_id': userId,
          'date': todayStr,
          'total_focus_minutes': newTotal,
          'goal_met': newTotal >= 60,
          'updated_at': DateTime.now().toIso8601String(),
        }).timeout(const Duration(seconds: 8));
      } catch (e, st) {
        ErrorLogger.log('ClubService.recordFocusMinutes', e, st);
      }
    }

    // Yerel ilerlemeyi güncelle
    await _updateLocalProgress(clubId, userId, minutes);
  }

  // ─────────────────────────────────────────────────────────────
  // 🔍 AKTİF SEANSI GETİRME
  // ─────────────────────────────────────────────────────────────
  Future<ClubFocusSession?> getActiveSession(String clubId) async {
    final sb = _supabase;
    if (sb != null) {
      try {
        final res = await sb
            .from('club_focus_sessions')
            .select()
            .eq('club_id', clubId)
            .eq('status', 'active')
            .order('started_at', ascending: false)
            .limit(1)
            .maybeSingle()
            .timeout(const Duration(seconds: 8));

        if (res != null) {
          final session = ClubFocusSession.fromJson(res);
          // Süresi dolmuş mu kontrol et
          if (session.remainingSeconds > 0) {
            return session;
          }
        }
      } catch (e, st) {
        ErrorLogger.log('ClubService.getActiveSession', e, st);
      }
    }
    return _getLocalActiveSession(clubId);
  }

  // ─────────────────────────────────────────────────────────────
  // 💾 YEREL ÖNBELLEK YÖNETİMİ (OFFLINE FALLBACK)
  // ─────────────────────────────────────────────────────────────
  Future<List<Club>> fetchLocalClubs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localClubsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Club.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalClub(Club club) async {
    final clubs = await fetchLocalClubs();
    final index = clubs.indexWhere((c) => c.id == club.id);
    if (index >= 0) {
      clubs[index] = club;
    } else {
      clubs.add(club);
    }
    await _persistLocalClubs(clubs);
  }

  Future<void> _persistLocalClubs(List<Club> clubs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(clubs.map((c) => c.toJson()).toList());
    await prefs.setString(_localClubsKey, raw);
  }

  Future<List<ClubMember>> fetchLocalMembers(String clubId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('${_localMembersKey}_$clubId');
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => ClubMember.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalMember(ClubMember member) async {
    final members = await fetchLocalMembers(member.clubId);
    final index = members.indexWhere((m) => m.userId == member.userId);
    if (index >= 0) {
      members[index] = member;
    } else {
      members.add(member);
    }
    await _persistLocalMembers(member.clubId, members);
  }

  Future<void> _persistLocalMembers(String clubId, List<ClubMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(members.map((m) => m.toJson()).toList());
    await prefs.setString('${_localMembersKey}_$clubId', raw);
  }

  Future<void> _saveLocalSession(ClubFocusSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_localSessionsKey}_${session.clubId}', jsonEncode(session.toJson()));
  }

  Future<ClubFocusSession?> _getLocalActiveSession(String clubId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('${_localSessionsKey}_$clubId');
      if (raw == null) return null;
      final session = ClubFocusSession.fromJson(jsonDecode(raw));
      if (session.remainingSeconds > 0 && session.isActive) {
        return session;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateLocalProgress(String clubId, String userId, int minutes) async {
    final members = await fetchLocalMembers(clubId);
    final index = members.indexWhere((m) => m.userId == userId);
    if (index >= 0) {
      final m = members[index];
      members[index] = m.copyWith(todayFocusMinutes: m.todayFocusMinutes + minutes);
      await _persistLocalMembers(clubId, members);
    }
  }
}
