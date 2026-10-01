import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../constants/supabase_constants.dart';
import '../models/schedule_event.dart';
import '../models/user_profile.dart';
import '../models/widget_theme_config.dart';
import 'error_logger.dart';

/// ⚡ Calenda — Supabase Bulut Veritabanı ve Kimlik Doğrulama Servisi
///
/// Çevrimdışı öncelikli (Offline-First) mimari:
/// Uygulama her zaman SharedPreferences ile anında çalışır,
/// internet ve Supabase bağlantısı olduğunda veriler arka planda senkronize edilir.
class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  factory SupabaseService() => instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Supabase İstemcisine güvenli erişim (Kurulu değilse null döner)
  SupabaseClient? get client {
    if (!_isInitialized || !SupabaseConstants.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mevcut oturum açmış kullanıcı
  User? get currentUser => client?.auth.currentUser;

  /// Oturum açık mı?
  bool get isAuthenticated => currentUser != null;

  /// Kullanıcı ID'si
  String? get currentUserId => currentUser?.id;

  /// Kimlik durumu akışı
  Stream<AuthState>? get authStateChanges => client?.auth.onAuthStateChange;

  /// 🚀 Supabase'i Başlatır (main.dart içinden çağrılır)
  static Future<void> init() async {
    if (!SupabaseConstants.isConfigured) {
      debugPrint('ℹ️ SupabaseConstants henüz yapılandırılmadı. Uygulama yerel modda çalışıyor.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConstants.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: SupabaseConstants.supabaseAnonKey,
        debug: kDebugMode,
      );
      instance._isInitialized = true;
      debugPrint('✅ Supabase başarıyla başlatıldı.');
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.init', e, st);
      instance._isInitialized = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🔐 KİMLİK DOĞRULAMA (AUTH) METOTLARI
  // ─────────────────────────────────────────────────────────────

  /// Google ID Token ile Supabase'e giriş yapar
  Future<AuthResponse?> signInWithGoogleIdToken({
    required String idToken,
    String? accessToken,
  }) async {
    final sb = client;
    if (sb == null) return null;

    try {
      final response = await sb.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      return response;
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.signInWithGoogleIdToken', e, st);
      rethrow;
    }
  }

  /// Apple ID Token ile Supabase'e giriş yapar
  Future<AuthResponse?> signInWithAppleIdToken({
    required String idToken,
    required String rawNonce,
  }) async {
    final sb = client;
    if (sb == null) return null;

    try {
      final response = await sb.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      return response;
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.signInWithAppleIdToken', e, st);
      rethrow;
    }
  }

  /// Apple Sign-In için ham nonce üretir
  String generateRawNonce() {
    final sb = client;
    if (sb != null) {
      return sb.auth.generateRawNonce();
    }
    return const Uuid().v4();
  }

  /// E-posta ve şifre ile Supabase'e giriş yapar
  Future<AuthResponse?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final sb = client;
    if (sb == null) return null;

    try {
      final response = await sb.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.signInWithPassword', e, st);
      rethrow;
    }
  }

  /// E-posta ve şifre ile yeni hesap oluşturur
  Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final sb = client;
    if (sb == null) return null;

    try {
      final response = await sb.auth.signUp(
        email: email.trim(),
        password: password,
        data: data,
      );
      return response;
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.signUpWithEmail', e, st);
      rethrow;
    }
  }

  /// Supabase oturumunu kapatır
  Future<void> signOut() async {
    final sb = client;
    if (sb == null) return;
    try {
      await sb.auth.signOut(scope: SignOutScope.global);
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.signOut', e, st);
    }
  }

  /// Kullanıcının Supabase bulutundaki tüm verilerini siler ve oturumu kapatır
  Future<bool> deleteUserAccountAndData() async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null) return false;

    try {
      // İlişkili tablolardaki verileri hata toleranslı olarak sil (biri hata verse de diğerleri silinir)
      final tables = [
        'schedule_events',
        'routines',
        'focus_sessions',
        'widget_configs',
        'session_participants',
        'club_daily_progress',
        'club_members',
        'profiles',
      ];

      for (final table in tables) {
        try {
          final column = table == 'profiles' ? 'id' : 'user_id';
          await sb
              .from(table)
              .delete()
              .eq(column, uid)
              .timeout(const Duration(seconds: 6));
        } catch (_) {
          // Bireysel tablo hataları genel silme akışını engellemez
        }
      }

      await sb.auth.signOut().timeout(const Duration(seconds: 5));
      return true;
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.deleteUserAccountAndData', e, st);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 👤 PROFİL (PROFILES) METOTLARI
  // ─────────────────────────────────────────────────────────────

  /// UUID format kontrolü
  static bool isValidUuid(String str) {
    return RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(str);
  }

  /// Kullanıcı profilini Supabase veritabanına kaydeder / günceller (Upsert)
  Future<void> syncUserProfile(UserProfile profile) async {
    final sb = client;
    if (sb == null) return;

    // Öncelik: Profilin kendi ID'si geçerli bir UUID ise doğrudan onu kullan.
    // Stale/eski oturumların üzerine yazmayı önlemek için profile.id daima önceliklidir!
    final bool isProfileIdValid = profile.id.isNotEmpty &&
        !profile.id.startsWith('usr_') &&
        profile.id != 'guest';

    final String? uid = isProfileIdValid ? profile.id : currentUserId;
    if (uid == null || uid.isEmpty) return;

    // Kullanıcı adı boş ise veritabanına kaydetme (tamamlanmamış onboarding adımı)
    final cleanUsername = profile.username.trim().replaceAll('@', '');
    if (cleanUsername.isEmpty) {
      debugPrint('ℹ️ Supabase: Kullanıcı adı boş olduğu için profil henüz buluta senkronize edilmedi.');
      return;
    }

    try {
      await sb.from('profiles').upsert({
        'id': uid,
        'username': cleanUsername,
        'first_name': profile.firstName.trim(),
        'last_name': profile.lastName.trim(),
        'email': profile.email.trim(),
        'birth_date': profile.birthDate?.toIso8601String(),
        'avatar_animal': profile.avatarAnimal,
        'avatar_accessory': profile.avatarAccessory,
        'avatar_bg_color': profile.avatarBgColor,
        'weekly_goal_days': profile.weeklyGoalDays,
        'daily_focus_minutes': profile.dailyFocusMinutes,
        'core_focus_area': profile.coreFocusArea,
        'marketing_email_opt_in': profile.marketingEmailOptIn,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('✅ Supabase profili senkronize edildi: $uid (@$cleanUsername)');
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.syncUserProfile', e, st);
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('duplicate key') || errStr.contains('23505') || errStr.contains('unique')) {
        throw Exception('Bu kullanıcı adı (@$cleanUsername) veya e-posta zaten başka bir hesap tarafından kullanılıyor.');
      }
      rethrow;
    }
  }

  /// Kullanıcı adının benzersiz (müsait) olup olmadığını kontrol eder
  Future<bool> isUsernameAvailable(String username, {String? excludeUserId}) async {
    final sb = client;
    if (sb == null) return true;

    final clean = username.trim().toLowerCase().replaceAll('@', '');
    if (clean.length < 3 || clean.length > 20) return false;

    // Yasaklı / Rezerve edilmiş kullanıcı adları
    const reserved = {
      'admin', 'administrator', 'calenda', 'support', 'help',
      'calenda_user', 'apple_user', 'misafir', 'guest', 'root', 'system'
    };
    if (reserved.contains(clean)) return false;

    try {
      // 1. Önce RPC fonksiyonunu dene (varsa RLS bypass ile en güvenli kontrol)
      try {
        final rpcRes = await sb.rpc('check_username_available', params: {
          'check_username': clean,
          'exclude_user_id': excludeUserId,
        });
        if (rpcRes is bool) return rpcRes;
      } catch (_) {
        // RPC henüz oluşturulmamışsa normal PostgREST sorgusuyla devam et
      }

      // 2. Doğrudan PostgREST sorgusu
      var query = sb.from('profiles').select('id, username').ilike('username', clean);
      if (excludeUserId != null && excludeUserId.isNotEmpty) {
        query = query.neq('id', excludeUserId);
      }
      final List<dynamic> rows = await query.limit(1);
      return rows.isEmpty;
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.isUsernameAvailable', e, st);
      // Ağ hatası durumunda sahte "true" dönüp çakışma yaratma!
      return false;
    }
  }

  /// Supabase'den kullanıcı profilini çeker
  Future<UserProfile?> fetchUserProfile(String userId) async {
    final sb = client;
    if (sb == null || userId.isEmpty) return null;

    // Eğer userId bir UUID değilse Postgres 22P02 hatası vermemesi için sorgulama yapma
    if (!isValidUuid(userId)) {
      debugPrint('ℹ️ Supabase: userId geçerli bir UUID değil: $userId');
      return null;
    }

    try {
      final data = await sb
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;

      return UserProfile(
        id: data['id'] as String? ?? userId,
        username: data['username'] as String? ?? '',
        firstName: data['first_name'] as String? ?? '',
        lastName: data['last_name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        birthDate: data['birth_date'] != null ? DateTime.tryParse(data['birth_date'] as String) : null,
        avatarAnimal: data['avatar_animal'] as String? ?? '01_rabbit',
        avatarAccessory: data['avatar_accessory'] as String? ?? 'none',
        avatarBgColor: data['avatar_bg_color'] as String? ?? '#FAF7F2',
        weeklyGoalDays: (data['weekly_goal_days'] as num?)?.toInt() ?? 0,
        dailyFocusMinutes: (data['daily_focus_minutes'] as num?)?.toInt() ?? 0,
        coreFocusArea: data['core_focus_area'] as String? ?? 'Kişisel Planlama & Notlar',
        marketingEmailOptIn: data['marketing_email_opt_in'] as bool? ?? false,
        isLoggedIn: true,
        createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at'] as String) : null,
      );
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.fetchUserProfile', e, st);
      return null;
    }
  }

  /// E-posta adresine göre profil çeker (farklı provider ile aynı e-posta linki için)
  Future<UserProfile?> fetchUserProfileByEmail(String email) async {
    final sb = client;
    final cleanEmail = email.trim().toLowerCase();
    if (sb == null || cleanEmail.isEmpty) return null;

    try {
      final data = await sb
          .from('profiles')
          .select()
          .ilike('email', cleanEmail)
          .maybeSingle();

      if (data == null) return null;

      return UserProfile(
        id: data['id'] as String? ?? '',
        username: data['username'] as String? ?? '',
        firstName: data['first_name'] as String? ?? '',
        lastName: data['last_name'] as String? ?? '',
        email: data['email'] as String? ?? cleanEmail,
        birthDate: data['birth_date'] != null ? DateTime.tryParse(data['birth_date'] as String) : null,
        avatarAnimal: data['avatar_animal'] as String? ?? '01_rabbit',
        avatarAccessory: data['avatar_accessory'] as String? ?? 'none',
        avatarBgColor: data['avatar_bg_color'] as String? ?? '#FAF7F2',
        weeklyGoalDays: (data['weekly_goal_days'] as num?)?.toInt() ?? 0,
        dailyFocusMinutes: (data['daily_focus_minutes'] as num?)?.toInt() ?? 0,
        coreFocusArea: data['core_focus_area'] as String? ?? 'Kişisel Planlama & Notlar',
        marketingEmailOptIn: data['marketing_email_opt_in'] as bool? ?? false,
        isLoggedIn: true,
        createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at'] as String) : null,
      );
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.fetchUserProfileByEmail', e, st);
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 📅 ETKİNLİKLER (SCHEDULE_EVENTS) METOTLARI
  // ─────────────────────────────────────────────────────────────

  /// Kullanıcının tüm etkinliklerini Supabase'den çeker
  Future<List<ScheduleEvent>> fetchEvents() async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null) return [];

    try {
      final List<dynamic> rows = await sb
          .from('schedule_events')
          .select()
          .eq('user_id', uid)
          .order('day_of_week', ascending: true)
          .order('start_hour', ascending: true)
          .order('start_minute', ascending: true);

      return rows.map((row) {
        final rawHasSpecificTime = row['has_specific_time'];
        final startH = (row['start_hour'] as num?)?.toInt() ?? 0;
        final startM = (row['start_minute'] as num?)?.toInt() ?? 0;
        final endH = (row['end_hour'] as num?)?.toInt() ?? 0;
        final endM = (row['end_minute'] as num?)?.toInt() ?? 0;
        final bool hasSpecificTime = rawHasSpecificTime is bool
            ? rawHasSpecificTime
            : (startH == 0 && startM == 0 && endH == 0 && endM == 0 ? false : true);

        return ScheduleEvent(
          id: row['id'] as String,
          title: row['title'] as String? ?? '',
          subtitle: row['subtitle'] as String? ?? '',
          dayOfWeek: (row['day_of_week'] as num?)?.toInt() ?? 1,
          dateStr: row['date_str'] as String?,
          startHour: startH,
          startMinute: startM,
          endHour: endH,
          endMinute: endM,
          colorHex: row['color_hex'] as String? ?? '#DAEAF6',
          isNotificationEnabled: row['is_notification_enabled'] as bool? ?? true,
          reminderMinutesBefore: (row['reminder_minutes_before'] as num?)?.toInt() ?? 15,
          updatedAt: row['updated_at'] != null ? DateTime.tryParse(row['updated_at'] as String) : null,
          isCompleted: row['is_completed'] as bool? ?? false,
          hasSpecificTime: hasSpecificTime,
        );
      }).toList();
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.fetchEvents', e, st);
      return [];
    }
  }

  /// Tek bir etkinliği ekler veya günceller (Upsert)
  Future<void> upsertEvent(ScheduleEvent event) async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null) return;

    try {
      await sb.from('schedule_events').upsert({
        'id': event.id,
        'user_id': uid,
        'title': event.title,
        'subtitle': event.subtitle,
        'day_of_week': event.dayOfWeek,
        'date_str': event.dateStr,
        'start_hour': event.startHour,
        'start_minute': event.startMinute,
        'end_hour': event.endHour,
        'end_minute': event.endMinute,
        'color_hex': event.colorHex,
        'is_notification_enabled': event.isNotificationEnabled,
        'reminder_minutes_before': event.reminderMinutesBefore,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.upsertEvent', e, st);
    }
  }

  /// Etkinliği siler
  Future<void> deleteEvent(String eventId) async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null) return;

    try {
      await sb
          .from('schedule_events')
          .delete()
          .eq('id', eventId)
          .eq('user_id', uid);
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.deleteEvent', e, st);
    }
  }

  /// Yerel etkinliklerin tamamını Supabase'e senkronize eder
  Future<void> syncAllEvents(List<ScheduleEvent> events) async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null || events.isEmpty) return;

    try {
      final payload = events.map((e) => {
        'id': e.id,
        'user_id': uid,
        'title': e.title,
        'subtitle': e.subtitle,
        'day_of_week': e.dayOfWeek,
        'date_str': e.dateStr,
        'start_hour': e.startHour,
        'start_minute': e.startMinute,
        'end_hour': e.endHour,
        'end_minute': e.endMinute,
        'color_hex': e.colorHex,
        'is_notification_enabled': e.isNotificationEnabled,
        'reminder_minutes_before': e.reminderMinutesBefore,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).toList();

      await sb.from('schedule_events').upsert(payload);
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.syncAllEvents', e, st);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🌿 RUTİNLER (ROUTINES) METOTLARI
  // ─────────────────────────────────────────────────────────────

  /// Rutinleri Supabase'e kaydeder / günceller
  Future<void> syncRoutine({
    required String id,
    required String title,
    required String time,
    required String category,
    required int iconCodePoint,
    required String colorHex,
    required String accentHex,
    required bool isCompleted,
    required int streak,
  }) async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null) return;

    try {
      await sb.from('routines').upsert({
        'id': id,
        'user_id': uid,
        'title': title,
        'time_str': time,
        'category': category,
        'icon_code_point': iconCodePoint,
        'color_hex': colorHex,
        'accent_hex': accentHex,
        'is_completed': isCompleted,
        'streak': streak,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.syncRoutine', e, st);
    }
  }

  /// Rutini siler
  Future<void> deleteRoutine(String routineId) async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null) return;

    try {
      await sb
          .from('routines')
          .delete()
          .eq('id', routineId)
          .eq('user_id', uid)
          .timeout(const Duration(seconds: 8));
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.deleteRoutine', e, st);
    }
  }

  /// Buluttaki rutinleri çeker
  Future<List<Map<String, dynamic>>> fetchRoutines() async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null) return [];

    try {
      final res = await sb
          .from('routines')
          .select()
          .eq('user_id', uid)
          .timeout(const Duration(seconds: 8));
      return (res as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.fetchRoutines', e, st);
      return [];
    }
  }

  /// Yerel rutinlerin tamamını Supabase'e senkronize eder
  Future<void> syncAllRoutines(List<Map<String, dynamic>> routines) async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null || routines.isEmpty) return;

    try {
      final payload = routines.map((r) => {
        'id': r['id'],
        'user_id': uid,
        'title': r['title'] ?? '',
        'time_str': r['time_str'] ?? '',
        'category': r['category'] ?? 'Genel',
        'icon_code_point': r['icon_code_point'] ?? 0,
        'color_hex': (r['color_value'] ?? r['color_hex'] ?? 0).toString(),
        'accent_hex': (r['accent_value'] ?? r['accent_hex'] ?? 0).toString(),
        'is_completed': r['is_completed'] ?? false,
        'streak': r['streak'] ?? 1,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).toList();

      await sb.from('routines').upsert(payload).timeout(const Duration(seconds: 8));
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.syncAllRoutines', e, st);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ⏱️ ODAK SEANSLARI (FOCUS_SESSIONS) METOTLARI
  // ─────────────────────────────────────────────────────────────

  /// Tamamlanan odak seansını kaydeder
  Future<void> logFocusSession({
    required int durationMinutes,
    required String mode,
    required String focusTag,
    DateTime? completedAt,
  }) async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null) return;

    try {
      await sb.from('focus_sessions').insert({
        'user_id': uid,
        'duration_minutes': durationMinutes,
        'mode': mode,
        'focus_tag': focusTag,
        'completed_at': (completedAt ?? DateTime.now()).toUtc().toIso8601String(),
      });
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.logFocusSession', e, st);
    }
  }

  /// ⏱️ Kullanıcının Supabase bulutundaki geçmiş odaklanma seanslarını çeker
  Future<List<Map<String, dynamic>>> fetchFocusSessions({
    String? userId,
    DateTime? since,
  }) async {
    final sb = client;
    final uid = userId ?? currentUserId;
    if (sb == null || uid == null) return [];

    try {
      var query = sb.from('focus_sessions').select().eq('user_id', uid);
      if (since != null) {
        query = query.gte('completed_at', since.toUtc().toIso8601String());
      }
      final List<dynamic> rows = await query.order('completed_at', ascending: true);
      return rows.map((r) => Map<String, dynamic>.from(r as Map)).toList();
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.fetchFocusSessions', e, st);
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🎨 WIDGET VE TEMA AYARLARI
  // ─────────────────────────────────────────────────────────────

  /// Widget görünüm tercihlerini buluta kaydeder
  Future<void> syncWidgetConfig({
    required WidgetThemeConfig config,
    required List<String> customColors,
  }) async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null) return;

    try {
      await sb.from('widget_configs').upsert({
        'user_id': uid,
        'opacity': config.backgroundOpacity,
        'bg_color_hex': config.backgroundColorHex,
        'accent_color_hex': config.textColorHex,
        'custom_colors': customColors,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.syncWidgetConfig', e, st);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 💬 KULLANICI GERİ BİLDİRİMLERİ (FEEDBACK)
  // ─────────────────────────────────────────────────────────────

  /// Kullanıcının ilettiği geri bildirimi Supabase veritabanına kaydeder.
  /// Geliştirici bu bildirimleri Supabase Dashboard -> Table Editor -> user_feedbacks tablosunda görebilir.
  Future<bool> submitFeedback({
    required String content,
    String? username,
    String? userEmail,
  }) async {
    final sb = client;
    if (sb == null) return false;

    try {
      final uid = currentUserId;
      await sb.from('user_feedbacks').insert({
        'user_id': uid,
        'username': username,
        'email': userEmail,
        'content': content.trim(),
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      return true;
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.submitFeedback', e, st);
      return false;
    }
  }
}
