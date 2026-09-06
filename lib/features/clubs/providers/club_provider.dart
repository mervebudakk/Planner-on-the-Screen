import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/error_logger.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/club.dart';
import '../models/club_focus_session.dart';
import '../models/club_member.dart';
import '../services/club_service.dart';

/// 🌿 Calenda — Kulüpler ve Canlı Odaklanma Provider'ı
class ClubProvider extends ChangeNotifier {
  final ClubService _service = ClubService.instance;

  List<Club> _myClubs = [];
  Club? _selectedClub;
  List<ClubMember> _members = [];
  ClubFocusSession? _activeSession;
  bool _isLoading = false;
  String? _errorMessage;
  RealtimeChannel? _activeChannel;
  Timer? _sessionTicker;

  List<Club> get myClubs => _myClubs;
  Club? get selectedClub => _selectedClub;
  List<ClubMember> get members => _members;
  ClubFocusSession? get activeSession => _activeSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _sessionTicker?.cancel();
    _activeChannel?.unsubscribe();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // 📥 KULLANICI KULÜPLERİNİ YÜKLE
  // ─────────────────────────────────────────────────────────────
  Future<void> loadUserClubs(UserProfile user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allClubs = await _service.fetchUserClubs(user.id);
      // Tek kulüp kuralı: Birden fazla kulüp varsa yalnızca en sonuncusunu tut
      if (allClubs.length > 1) {
        _myClubs = [allClubs.first];
        await _service.persistLocalClubs(_myClubs);
      } else {
        _myClubs = allClubs;
      }
      if (_myClubs.isNotEmpty) {
        await selectClub(_myClubs.first.id);
      } else {
        _selectedClub = null;
        _members = [];
        _activeSession = null;
      }
    } catch (e, st) {
      ErrorLogger.log('ClubProvider.loadUserClubs', e, st);
      _errorMessage = 'Kulüpler yüklenirken bir sorun oluştu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🎯 KULÜP SEÇİMİ VE DETAY YÜKLEME
  // ─────────────────────────────────────────────────────────────
  Future<void> selectClub(String clubId) async {
    _selectedClub = _myClubs.firstWhere(
      (c) => c.id == clubId,
      orElse: () => _myClubs.isNotEmpty ? _myClubs.first : _selectedClub!,
    );
    notifyListeners();

    await _loadClubDetails(clubId);
    _subscribeToClubRealtime(clubId);
  }

  Future<void> _loadClubDetails(String clubId) async {
    try {
      _members = await _service.fetchClubMembers(clubId);
      _activeSession = await _service.getActiveSession(clubId);
      _startSessionTicker();
      notifyListeners();
    } catch (e, st) {
      ErrorLogger.log('ClubProvider._loadClubDetails', e, st);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ⚡ SUPABASE REALTIME BİLDİRİM VE SEANS DİNLEYİCİSİ
  // ─────────────────────────────────────────────────────────────
  void _subscribeToClubRealtime(String clubId) {
    _activeChannel?.unsubscribe();

    final sb = SupabaseService.instance.client;
    if (sb == null) return;

    try {
      _activeChannel = sb.channel('club_sessions_$clubId');

      _activeChannel?.onBroadcast(
        event: 'new_session',
        callback: (payload) {
          final hostName = payload['host_name'] as String? ?? 'Kulüp Üyesi';
          final duration = payload['duration'] as int? ?? 25;
          final title = payload['title'] as String? ?? 'Odaklanma Seansı';
          final tag = payload['tag'] as String? ?? 'Ders';

          // 🔔 DİĞER KULÜP ÜYELERİNE ANLIK BİLDİRİM GÖSTER!
          NotificationService().showImmediateNotification(
            title: '🌿 Canlı Odaklanma Seansı Başladı',
            body: '@$hostName $duration dakikalık "$title" ($tag) seansı başlattı. Katılmak ister misin?',
            payload: 'club_join:$clubId',
          );

          // Aktif seansı güncelle
          _loadClubDetails(clubId);
        },
      );

      _activeChannel?.subscribe();
    } catch (e, st) {
      ErrorLogger.log('ClubProvider._subscribeToClubRealtime', e, st);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ⏰ CANLI GERİ SAYIM TICKER'I
  // ─────────────────────────────────────────────────────────────
  void _startSessionTicker() {
    _sessionTicker?.cancel();
    if (_activeSession == null || !_activeSession!.isActive) return;

    _sessionTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_activeSession != null && _activeSession!.remainingSeconds <= 0) {
        _activeSession = _activeSession!.copyWith(status: 'completed');
        _sessionTicker?.cancel();
        notifyListeners();
      } else {
        notifyListeners();
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  // 🏛️ YENİ KULÜP OLUŞTUR (Tek Kulüp Kuralı)
  // ─────────────────────────────────────────────────────────────
  Future<Club?> createClub({
    required String name,
    String description = '',
    String iconName = 'matcha_cup',
    int dailyTargetMinutes = 60,
    required UserProfile userProfile,
  }) async {
    if (_myClubs.isNotEmpty) {
      _errorMessage = 'Zaten bir kulübe üyesiniz. Yeni kulüp oluşturmak için mevcut kulübünüzden ayrılmalısınız.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final club = await _service.createClub(
        name: name,
        description: description,
        iconName: iconName,
        dailyTargetMinutes: dailyTargetMinutes,
        userProfile: userProfile,
      );

      _myClubs = [club];
      _selectedClub = club;
      await _loadClubDetails(club.id);
      _subscribeToClubRealtime(club.id);
      return club;
    } catch (e, st) {
      ErrorLogger.log('ClubProvider.createClub', e, st);
      _errorMessage = _formatFriendlyError(e);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🤝 DAVET KODUYLA KULÜBE KATIL (Tek Kulüp Kuralı)
  // ─────────────────────────────────────────────────────────────
  Future<Club?> joinClubByCode({
    required String inviteCode,
    required UserProfile userProfile,
  }) async {
    if (_myClubs.isNotEmpty) {
      _errorMessage = 'Zaten bir kulübe üyesiniz. Yeni bir kulübe katılmak için mevcut kulübünüzden ayrılmalısınız.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final club = await _service.joinClubByInviteCode(
        inviteCode: inviteCode,
        userProfile: userProfile,
      );

      _myClubs = [club];
      _selectedClub = club;
      await _loadClubDetails(club.id);
      _subscribeToClubRealtime(club.id);
      return club;
    } catch (e, st) {
      ErrorLogger.log('ClubProvider.joinClubByCode', e, st);
      _errorMessage = _formatFriendlyError(e);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🚪 KULÜPTEN AYRILMA
  // ─────────────────────────────────────────────────────────────
  Future<bool> leaveClub({
    required String clubId,
    required UserProfile userProfile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.leaveClub(clubId: clubId, userId: userProfile.id);
      _myClubs.removeWhere((c) => c.id == clubId);
      _selectedClub = null;
      _members = [];
      _activeSession = null;
      _activeChannel?.unsubscribe();
      _activeChannel = null;
      return true;
    } catch (e, st) {
      ErrorLogger.log('ClubProvider.leaveClub', e, st);
      _errorMessage = 'Kulüpten ayrılırken bir sorun oluştu.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ⏱️ BİRLİKTE ODAKLANMA SEANSI BAŞLAT
  // ─────────────────────────────────────────────────────────────
  Future<ClubFocusSession?> startFocusSession({
    required String title,
    required int durationMinutes,
    String focusTag = 'Ders & Çalışma',
    required UserProfile userProfile,
  }) async {
    if (_selectedClub == null) return null;

    try {
      final session = await _service.startFocusSession(
        clubId: _selectedClub!.id,
        user: userProfile,
        title: title,
        durationMinutes: durationMinutes,
        focusTag: focusTag,
      );

      _activeSession = session;
      _startSessionTicker();
      notifyListeners();
      return session;
    } catch (e, st) {
      ErrorLogger.log('ClubProvider.startFocusSession', e, st);
      _errorMessage = _formatFriendlyError(e);
      notifyListeners();
      return null;
    }
  }

  String _formatFriendlyError(dynamic e) {
    final raw = e.toString();
    if (raw.contains('PGRST205') ||
        raw.contains('schema cache') ||
        raw.contains('does not exist')) {
      return 'Supabase üzerinde kulüp tabloları henüz oluşturulmamış.\nLütfen SQL şemasını Supabase SQL Editor üzerinden çalıştırın.';
    }
    if (raw.contains('maksimum kapasite')) {
      return 'Bu kulüp maksimum 15 kişilik üye kapasitesine ulaştı.';
    }
    if (raw.contains('bulunamadı')) {
      return 'Girdiğiniz davet koduna ait bir kulüp bulunamadı.';
    }
    if (raw.contains('SocketException') ||
        raw.contains('Failed host lookup') ||
        raw.contains('Network')) {
      return 'İnternet bağlantısı kurulamadı. Lütfen bağlantınızı kontrol edin.';
    }
    return raw.replaceAll('Exception: ', '').trim();
  }

  // ─────────────────────────────────────────────────────────────
  // 📈 ODAK SÜRESİNİ TÜM KULÜPLERE SENKRONİZE ET
  // ─────────────────────────────────────────────────────────────
  Future<void> recordFocusCompleted({
    required int minutes,
    required UserProfile userProfile,
  }) async {
    if (minutes <= 0 || _myClubs.isEmpty) return;

    for (final club in _myClubs) {
      try {
        await _service.recordFocusMinutes(
          clubId: club.id,
          userId: userProfile.id.isNotEmpty ? userProfile.id : 'local_owner',
          minutes: minutes,
        );
      } catch (e, st) {
        ErrorLogger.log('ClubProvider.recordFocusCompleted', e, st);
      }
    }

    if (_selectedClub != null) {
      await _loadClubDetails(_selectedClub!.id);
    }
  }
}
