import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// Supabase oturumunu kapatır
  Future<void> signOut() async {
    final sb = client;
    if (sb == null) return;
    try {
      await sb.auth.signOut();
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.signOut', e, st);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 👤 PROFİL (PROFILES) METOTLARI
  // ─────────────────────────────────────────────────────────────

  /// Kullanıcı profilini Supabase veritabanına kaydeder / günceller (Upsert)
  Future<void> syncUserProfile(UserProfile profile) async {
    final sb = client;
    final uid = currentUserId;
    if (sb == null || uid == null) return;

    try {
      await sb.from('profiles').upsert({
        'id': uid,
        'username': profile.username,
        'first_name': profile.firstName,
        'last_name': profile.lastName,
        'email': profile.email,
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
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.syncUserProfile', e, st);
    }
  }

  /// Supabase'den kullanıcı profilini çeker
  Future<UserProfile?> fetchUserProfile(String userId) async {
    final sb = client;
    if (sb == null) return null;

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
        coreFocusArea: data['core_focus_area'] as String? ?? 'Sakin & Huzurlu Haftalık Ajanda',
        marketingEmailOptIn: data['marketing_email_opt_in'] as bool? ?? false,
        isLoggedIn: true,
        createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at'] as String) : null,
      );
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.fetchUserProfile', e, st);
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
        return ScheduleEvent(
          id: row['id'] as String,
          title: row['title'] as String? ?? '',
          subtitle: row['subtitle'] as String? ?? '',
          dayOfWeek: (row['day_of_week'] as num?)?.toInt() ?? 1,
          dateStr: row['date_str'] as String?,
          startHour: (row['start_hour'] as num?)?.toInt() ?? 9,
          startMinute: (row['start_minute'] as num?)?.toInt() ?? 0,
          endHour: (row['end_hour'] as num?)?.toInt() ?? 10,
          endMinute: (row['end_minute'] as num?)?.toInt() ?? 0,
          colorHex: row['color_hex'] as String? ?? '#DAEAF6',
          isNotificationEnabled: row['is_notification_enabled'] as bool? ?? true,
          reminderMinutesBefore: (row['reminder_minutes_before'] as num?)?.toInt() ?? 15,
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

  // ─────────────────────────────────────────────────────────────
  // ⏱️ ODAK SEANSLARI (FOCUS_SESSIONS) METOTLARI
  // ─────────────────────────────────────────────────────────────

  /// Tamamlanan odak seansını kaydeder
  Future<void> logFocusSession({
    required int durationMinutes,
    required String mode,
    required String focusTag,
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
        'completed_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.logFocusSession', e, st);
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
        'opacity': config.opacity,
        'bg_color_hex': config.backgroundColorHex,
        'accent_color_hex': config.accentColorHex,
        'custom_colors': customColors,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, st) {
      ErrorLogger.log('SupabaseService.syncWidgetConfig', e, st);
    }
  }
}
