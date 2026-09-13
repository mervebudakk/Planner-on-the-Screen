import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/routine_model.dart';
import '../models/schedule_event.dart';
import '../models/user_profile.dart';
import '../models/widget_theme_config.dart';
import 'error_logger.dart';

/// SharedPreferences tabanlı güvenli yerel depolama servisi
class StorageService {
  final SharedPreferences _prefs;
  static StorageService? _instance;
  static StorageService get instance =>
      _instance ?? (throw StateError('StorageService not initialized'));

  static const int _maxPayloadBytes = 2 * 1024 * 1024; // 2MB
  static const int _maxCustomColors = 20;
  static const int _retentionDays = 15; // 15 gün saklama kuralı (geçmiş hafta verileri için)

  StorageService(this._prefs) {
    _instance = this;
  }

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);
    _instance = service;
    return service;
  }

  /// Eski/doygun renk kodlarını yeni Venngage soft pastel renk skalasına dönüştürür
  static String mapLegacyColorToPastel(String hex) {
    final clean = hex.toUpperCase().trim();
    switch (clean) {
      case '#86EFAC':
        return '#B5EAD7'; // Venngage Soft Mint
      case '#FED7AA':
        return '#FFDAC1'; // Venngage Peach Blossom
      case '#93C5FD':
        return '#DAEAF6'; // Venngage Pastel Sky Blue
      case '#C4B5FD':
        return '#E8DFF5'; // Venngage Lavender Mist
      case '#FDE047':
        return '#FCF4DD'; // Venngage Cream Buttercup
      case '#F9A8D4':
        return '#FFC8DD'; // Venngage Cotton Candy Rose
      case '#E2E8F0':
        return '#DDEDEA'; // Venngage Sage Dew
      case '#60A5FA':
        return '#A2D2FF'; // Venngage Pastel Cerulean
      case '#A7F3D0':
        return '#B5EAD7'; // Venngage Soft Mint
      case '#FBCFE8':
        return '#FCE1E4'; // Venngage Soft Blush Pink
      default:
        return hex;
    }
  }

  /// Varsayılan mock verilerin başlıkları (Gerektiğinde geriye dönük temizlik için)
  static const Set<String> _mockEventTitles = {
    'Psikoloji 101',
    'Kütüphanede Çalışma',
    'Öğle Molası & Kahve',
    'Pazarlama Dersi',
    'Sabah Yürüyüşü',
    'İş Yönetimi Dersi',
    'Tasarım Çalışması',
    'Haftalık Alışveriş',
    'İstatistik & Veri',
    'Ekip Toplantısı',
    'Ekonomi Dersi',
    'Danışman Görüşmesi',
    'Ödev & Proje Teslimi',
    'Arkadaşlarla Akşam Yemeği',
    'Spor & Tenis',
    'Haftalık Planlama & Dinlenme',
  };

  /// Tüm kayıtlı etkinlikleri getirir (1 haftadan eski olanlar otomatik temizlenir)
  List<ScheduleEvent> getEvents() {
    final rawJson = _prefs.getString(AppConstants.storageKeyEvents);
    if (rawJson == null || rawJson.isEmpty) {
      return <ScheduleEvent>[];
    }

    if (rawJson.length > _maxPayloadBytes) {
      ErrorLogger.security(
        'StorageService: Payload boyutu limiti aşıldı (${rawJson.length} bytes). Boş liste döndürülüyor.',
      );
      return <ScheduleEvent>[];
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List) {
        ErrorLogger.security('StorageService: Beklenmeyen JSON tipi.');
        return <ScheduleEvent>[];
      }

      final events = <ScheduleEvent>[];

      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          final event = ScheduleEvent.fromJson(Map<String, dynamic>.from(item));
          events.add(event);
        } on Object catch (e) {
          ErrorLogger.log('StorageService.getEvents', e, null, 'Bozuk etkinlik atlandı');
        }
      }

      // 🧹 Eski cihazlardaki varsayılan mock etkinlikleri bir defaya mahsus tamamen temizle
      final isPurged = _prefs.getBool('mock_seed_data_purged_v1') ?? false;
      if (!isPurged) {
        events.removeWhere((e) => _mockEventTitles.contains(e.title.trim()));
        saveEvents(events);
        _prefs.setBool('mock_seed_data_purged_v1', true);
      }

      // 1 haftadan (7 gün) eski geçmiş verileri filtrele
      final filteredEvents = _filterExpiredEvents(events);
      if (filteredEvents.length != events.length) {
        saveEvents(filteredEvents); // Temizlenmiş listeyi kaydet
      }

      return filteredEvents;
    } on FormatException catch (e, st) {
      ErrorLogger.log('StorageService.getEvents', e, st, 'JSON parse hatası');
      return <ScheduleEvent>[];
    } on Object catch (e, st) {
      ErrorLogger.log('StorageService.getEvents', e, st);
      return <ScheduleEvent>[];
    }
  }

  /// Etkinlik listesini kaydeder (15 günden eski veriler ayıklanarak)
  Future<bool> saveEvents(List<ScheduleEvent> events) async {
    final validEvents = _filterExpiredEvents(events);
    final jsonList = validEvents.map((e) => e.toJson()).toList();
    return _prefs.setString(AppConstants.storageKeyEvents, jsonEncode(jsonList));
  }

  /// 15 günden eski tarihli etkinlikleri temizler (Retention Policy)
  List<ScheduleEvent> _filterExpiredEvents(List<ScheduleEvent> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thresholdDate = today.subtract(const Duration(days: _retentionDays));

    return events.where((event) {
      if (event.dateStr == null || event.dateStr!.isEmpty) {
        return true; // Haftalık tekrarlayan dersleri tut
      }
      try {
        final eventDate = DateFormat('yyyy-MM-dd').parse(event.dateStr!);
        return !eventDate.isBefore(thresholdDate);
      } catch (_) {
        return true;
      }
    }).toList();
  }

  /// Widget tema ayarlarını getirir
  WidgetThemeConfig getWidgetTheme() {
    final rawJson = _prefs.getString(AppConstants.storageKeyWidgetTheme);
    if (rawJson == null || rawJson.isEmpty) {
      return const WidgetThemeConfig();
    }

    if (rawJson.length > _maxPayloadBytes) {
      ErrorLogger.security('StorageService: Widget theme payload limiti aşıldı.');
      return const WidgetThemeConfig();
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) return const WidgetThemeConfig();
      return WidgetThemeConfig.fromJson(Map<String, dynamic>.from(decoded));
    } on Object catch (e, st) {
      ErrorLogger.log('StorageService.getWidgetTheme', e, st);
      return const WidgetThemeConfig();
    }
  }

  /// Widget tema ayarlarını kaydeder
  Future<bool> saveWidgetTheme(WidgetThemeConfig config) async {
    return _prefs.setString(
      AppConstants.storageKeyWidgetTheme,
      jsonEncode(config.toJson()),
    );
  }

  /// Tema Modunu getirir (Daima Açık Tema)
  ThemeMode getThemeMode() {
    return ThemeMode.light;
  }

  /// Tema Modunu kaydeder (Daima Açık Tema)
  Future<bool> saveThemeMode(ThemeMode mode) async {
    return _prefs.setString(AppConstants.storageKeyThemeMode, 'light');
  }

  /// Kullanıcının oluşturduğu özel renkleri getirir
  List<String> getCustomColors() {
    final rawColors =
        _prefs.getStringList(AppConstants.storageKeyCustomColors) ?? [];
    final normalizedColors = <String>[];

    for (final color in rawColors) {
      final normalized = AppColors.normalizeHexColor(color, fallback: '');
      if (normalized.isNotEmpty && !normalizedColors.contains(normalized)) {
        normalizedColors.add(normalized);
      }
      if (normalizedColors.length >= _maxCustomColors) break;
    }

    return normalizedColors;
  }

  /// Yeni bir özel renk kaydeder
  Future<bool> saveCustomColor(String hexColor) async {
    final normalized = AppColors.normalizeHexColor(hexColor, fallback: '');
    if (normalized.isEmpty) return false;

    final current = getCustomColors();
    if (!current.contains(normalized)) {
      if (current.length >= _maxCustomColors) {
        current.removeAt(0);
      }
      current.add(normalized);
      return _prefs.setStringList(AppConstants.storageKeyCustomColors, current);
    }
    return true;
  }

  /// Kullanıcının oluşturduğu özel rengi siler
  Future<bool> removeCustomColor(String hexColor) async {
    final normalized = AppColors.normalizeHexColor(hexColor, fallback: '');
    if (normalized.isEmpty) return false;

    final current = getCustomColors();
    current.removeWhere((c) => c.toUpperCase() == normalized.toUpperCase());
    return _prefs.setStringList(AppConstants.storageKeyCustomColors, current);
  }

  // ─── KULLANICI PROFİLİ VE GİRİŞ DURUMU ───
  static const String _keyUserProfile = 'user_profile_data_v1';
  static const String _keyOnboardingCompleted = 'onboarding_completed_v1';

  /// Karşılama (Onboarding) ekranının daha önce tamamlanıp tamamlanmadığını kontrol eder
  bool isOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// Karşılama ekranının tamamlandığını kaydeder (Sonraki girişlerde doğrudan Ana Ekran açılır)
  Future<bool> setOnboardingCompleted([bool completed = true]) async {
    return _prefs.setBool(_keyOnboardingCompleted, completed);
  }

  /// Kullanıcı profilini getirir
  UserProfile getUserProfile() {
    final rawJson = _prefs.getString(_keyUserProfile);
    if (rawJson == null || rawJson.isEmpty) {
      return UserProfile.guest();
    }
    if (rawJson.length > _maxPayloadBytes) {
      ErrorLogger.security('StorageService: User profile payload limiti aşıldı.');
      return UserProfile.guest();
    }
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) return UserProfile.guest();
      return UserProfile.fromJson(Map<String, dynamic>.from(decoded));
    } on Object catch (e, st) {
      ErrorLogger.log('StorageService.getUserProfile', e, st);
      return UserProfile.guest();
    }
  }

  /// Kullanıcı profilini kaydeder
  Future<bool> saveUserProfile(UserProfile profile) async {
    return _prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
  }

  /// Kullanıcı oturumunu kapatır
  Future<bool> clearUserProfile() async {
    return _prefs.remove(_keyUserProfile);
  }

  /// 🚪 Oturum kapatıldığında (Logout) tüm kullanıcıya özel yerel verileri güvenle temizler
  Future<void> clearUserData() async {
    await _prefs.remove(AppConstants.storageKeyEvents);
    await _prefs.remove(_keyRoutines);
    await _prefs.remove(_keyRoutinesLastDate);
    await _prefs.remove(_keyUserProfile);
    await _prefs.remove(_keyOnboardingProgress);
    await _prefs.remove(_keyOnboardingCompleted);
    await _prefs.remove(AppConstants.storageKeyCustomColors);
    await _prefs.remove(AppConstants.storageKeyCustomWallpaper);

    // Günlük odaklanma dakikası kayıtlarını temizle
    final keys = _prefs.getKeys().where((k) => k.startsWith('focus_mins_')).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }

  /// Etkinlikleri tamamen temizler
  Future<bool> clearEvents() async {
    return _prefs.remove(AppConstants.storageKeyEvents);
  }

  /// Rutinleri tamamen temizler
  Future<bool> clearRoutines() async {
    await _prefs.remove(_keyRoutines);
    return _prefs.remove(_keyRoutinesLastDate);
  }

  /// Kullanıcının seçtiği yerel duvar kâğıdı yolunu getirir
  String? getCustomWallpaperPath() {
    return _prefs.getString(AppConstants.storageKeyCustomWallpaper);
  }

  /// Kullanıcının seçtiği yerel duvar kâğıdı yolunu kaydeder (null ise temizler)
  Future<void> saveCustomWallpaperPath(String? path) async {
    if (path == null || path.isEmpty) {
      await _prefs.remove(AppConstants.storageKeyCustomWallpaper);
    } else {
      await _prefs.setString(AppConstants.storageKeyCustomWallpaper, path);
    }
  }

  /// İlk karşılama (Onboarding) ekranının görülüp görülmediğini döndürür
  bool hasSeenWelcome() {
    return _prefs.getBool(AppConstants.storageKeyWelcomeSeen) ?? false;
  }

  /// Karşılama ekranının tamamlandığını kaydeder
  Future<void> setWelcomeSeen() async {
    await _prefs.setBool(AppConstants.storageKeyWelcomeSeen, true);
  }

  // ─── ODAKLANMA DAKİKALARI VE HAFTALIK RİTİM ───
  static String _focusKeyForDate(DateTime date) {
    return 'focus_mins_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
  }

  /// ⏱️ Belirli bir gün için odaklanma dakikalarını ekleyerek kaydeder
  Future<void> recordDailyFocusMinutes(DateTime date, int minutes) async {
    final key = _focusKeyForDate(date);
    final current = _prefs.getInt(key) ?? 0;
    await _prefs.setInt(key, current + minutes);
    await addFocusMinutesToAllTime(minutes);
  }

  /// ⏱️ Belirli bir günün toplam odaklanma dakikasını getirir
  int getDailyFocusMinutes(DateTime date) {
    final key = _focusKeyForDate(date);
    return _prefs.getInt(key) ?? 0;
  }

  /// ⏱️ Belirli bir günün toplam odaklanma dakikasını doğrudan ayarlar (Bulut senkronizasyonu için)
  Future<void> setDailyFocusMinutes(DateTime date, int minutes) async {
    final key = _focusKeyForDate(date);
    await _prefs.setInt(key, minutes);
  }

  /// ⏱️ Mevcut haftanın (Pazartesi'den Pazar'a) her bir gününün odak dakikasını döner
  Map<int, int> getWeeklyFocusMinutes(DateTime weekDate) {
    final monday = DateTime(weekDate.year, weekDate.month, weekDate.day)
        .subtract(Duration(days: weekDate.weekday - 1));
    final result = <int, int>{};
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      result[i] = getDailyFocusMinutes(day);
    }
    return result;
  }

  // ─── RUTİNLER & ALIŞKANLIKLAR ───
  static const String _keyRoutines = 'user_routines_data_v1';
  static const String _keyRoutinesLastDate = 'user_routines_last_date_v1';

  /// Kayıtlı rutinleri ham JSON listesi olarak döner
  List<Map<String, dynamic>> getRoutinesRaw() {
    final raw = _prefs.getString(_keyRoutines);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e, st) {
      ErrorLogger.log('StorageService.getRoutinesRaw', e, st);
    }
    return [];
  }

  /// Rutinleri kaydeder
  Future<bool> saveRoutinesRaw(List<Map<String, dynamic>> routines) async {
    return _prefs.setString(_keyRoutines, jsonEncode(routines));
  }

  /// Günlük sıfırlama tarihi kontrolü (Gece yarısı geçildiğinde tamamlanmaları sıfırlamak için)
  String? getRoutinesLastDate() {
    return _prefs.getString(_keyRoutinesLastDate);
  }

  Future<bool> setRoutinesLastDate(String dateStr) async {
    return _prefs.setString(_keyRoutinesLastDate, dateStr);
  }

  /// Kayıtlı rutinleri RoutineModel listesi olarak döner.
  /// Gün değişmişse:
  /// - Bugün tamamlananlar isCompleted = true kalır.
  /// - Dün tamamlananların isCompleted bayrağı sıfırlanır (bugün için hazır), streak'i korunur.
  /// - Dün tamamlanmayanların (veya daha eski) streak'i 0'a sıfırlanır ve isCompleted = false olur.
  List<RoutineModel> getRoutines() {
    final list = getRoutinesRaw();
    if (list.isEmpty) {
      return RoutineModel.defaults;
    }
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

    final routines = list.map((m) => RoutineModel.fromJson(m)).toList();
    bool needsSave = false;

    final updated = routines.map((r) {
      // 1. Bugün zaten tamamlanmışsa
      if (r.lastCompletedDate == todayStr) {
        if (!r.isCompleted) {
          needsSave = true;
          return r.copyWith(isCompleted: true);
        }
        return r;
      }

      // 2. Dün tamamlanmışsa: Bugün yeni gün, isCompleted = false, seri korunur
      if (r.lastCompletedDate == yesterdayStr) {
        if (r.isCompleted) {
          needsSave = true;
          return r.copyWith(isCompleted: false);
        }
        return r;
      }

      // 3. Dün tamamlanmamışsa (dünden daha eski veya hiç yapılmamış):
      // Seri yandı / bozuldu! Streak 0'a düşer ve isCompleted false olur.
      if (r.streak > 0 || r.isCompleted) {
        needsSave = true;
        return r.copyWith(isCompleted: false, streak: 0);
      }

      return r;
    }).toList();

    if (needsSave) {
      saveRoutines(updated);
    }
    setRoutinesLastDate(todayStr);

    return updated;
  }

  Future<bool> saveRoutines(List<RoutineModel> routines) async {
    final jsonList = routines.map((r) => r.toJson()).toList();
    return saveRoutinesRaw(jsonList);
  }

  /// Kullanıcının tüm yerel verilerini ve ayarlarını sıfırlar
  Future<void> clearAllData() async {
    await _prefs.clear();
  }

  // ─────────────────────────────────────────────────────────────
  // 💾 ONBOARDING İLERLEME YEDEKLEMESİ (Fix #11)
  // ─────────────────────────────────────────────────────────────
  static const String _keyOnboardingProgress = 'calenda_onboarding_progress_v1';

  Future<void> saveOnboardingProgress(Map<String, dynamic> data) async {
    await _prefs.setString(_keyOnboardingProgress, jsonEncode(data));
  }

  Map<String, dynamic>? getOnboardingProgress() {
    final raw = _prefs.getString(_keyOnboardingProgress);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearOnboardingProgress() async {
    await _prefs.remove(_keyOnboardingProgress);
  }

  // ─────────────────────────────────────────────────────────────
  // ⏱️ AKTİF ODAK SEANSI YEDEKLEMESİ (Arka plan & çökme koruması)
  // ─────────────────────────────────────────────────────────────
  static const String _keyActiveFocusSession = 'calenda_active_focus_session_v1';

  Future<void> saveActiveFocusSession(Map<String, dynamic> data) async {
    await _prefs.setString(_keyActiveFocusSession, jsonEncode(data));
  }

  Map<String, dynamic>? getActiveFocusSession() {
    final raw = _prefs.getString(_keyActiveFocusSession);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearActiveFocusSession() async {
    await _prefs.remove(_keyActiveFocusSession);
  }

  // ─────────────────────────────────────────────────────────────
  // 💓 KESİNTİSİZ ODAK KALBİ & KREDİ TAKİBİ (Heartbeat & Crash Recovery)
  // ─────────────────────────────────────────────────────────────
  static String _keySessionCredited(String sessionId) => 'focus_credited_mins_$sessionId';
  static const String _keyReconciledLost30MinSession = 'calenda_reconciled_lost_30m_session_v1';

  int getSessionCreditedMinutes(String sessionId) {
    return _prefs.getInt(_keySessionCredited(sessionId)) ?? 0;
  }

  Future<void> setSessionCreditedMinutes(String sessionId, int minutes) async {
    await _prefs.setInt(_keySessionCredited(sessionId), minutes);
  }

  Future<void> clearSessionCreditedMinutes(String sessionId) async {
    await _prefs.remove(_keySessionCredited(sessionId));
  }

  bool hasReconciledLost30MinSession() {
    return _prefs.getBool(_keyReconciledLost30MinSession) ?? false;
  }

  Future<void> setReconciledLost30MinSession() async {
    await _prefs.setBool(_keyReconciledLost30MinSession, true);
  }

  // ─────────────────────────────────────────────────────────────
  // 🌐 DİL TERCİHİ (Türkçe & İngilizce Desteği)
  // ─────────────────────────────────────────────────────────────
  static const String _keySelectedLanguage = 'calenda_selected_language';

  String? getSelectedLanguage() {
    return _prefs.getString(_keySelectedLanguage);
  }

  Future<void> setSelectedLanguage(String languageCode) async {
    await _prefs.setString(_keySelectedLanguage, languageCode);
  }

  // ─────────────────────────────────────────────────────────────
  // 🏆 THE COZY DESK & BAŞARI SİSTEMİ (Gamification Storage)
  // ─────────────────────────────────────────────────────────────
  static const String _keyUnlockedAchievements = 'calenda_unlocked_achievements_v2';
  static const String _keyTotalCompletedPlans = 'calenda_total_completed_plans_v1';
  static const String _keyAllTimeFocusMinutes = 'calenda_all_time_focus_minutes_v1';
  static const String _keyFirstAppOpenDate = 'calenda_first_app_open_date_v1';
  static const String _keyRoomThemeColor = 'calenda_room_theme_color_v1';
  static const String _keyActiveRoomItems = 'calenda_active_room_items_v1';
  static const String _keyRoomXP = 'calenda_room_xp_v1';
  static const String _keyActiveRoomFloor = 'calenda_active_room_floor_v1';
  static const String _keyUnlockedDioramaItems = 'calenda_unlocked_diorama_items_v1';

  /// Satın alınıp odaya yerleştirilen 3D diorama eşya id'leri
  Set<String> getUnlockedDioramaItems() {
    final list = _prefs.getStringList(_keyUnlockedDioramaItems);
    return list != null ? list.toSet() : <String>{};
  }

  Future<void> unlockDioramaItem(String itemId) async {
    final current = getUnlockedDioramaItems();
    current.add(itemId);
    await _prefs.setStringList(_keyUnlockedDioramaItems, current.toList());
  }

  /// Odanın seçili renk teması ('pink', 'purple', 'blue', 'green')
  String getRoomThemeColor() {
    return _prefs.getString(_keyRoomThemeColor) ?? 'pink';
  }

  Future<void> setRoomThemeColor(String color) async {
    await _prefs.setString(_keyRoomThemeColor, color);
  }

  /// Aktif mobilya eşleşmelerini döner (örn: {'bed': 'bed_lv1', 'desk': 'desk_lv1'})
  Map<String, String> getActiveRoomItems() {
    final raw = _prefs.getString(_keyActiveRoomItems);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (e, st) {
      ErrorLogger.log('StorageService.getActiveRoomItems', e, st);
    }
    return {};
  }

  Future<void> setActiveRoomItem(String category, String itemId) async {
    final map = getActiveRoomItems();
    map[category] = itemId;
    await _prefs.setString(_keyActiveRoomItems, jsonEncode(map));
  }

  /// Odanın toplam deneyim puanı (XP)
  int getRoomXP() {
    return _prefs.getInt(_keyRoomXP) ?? 0;
  }

  Future<void> addRoomXP(int delta) async {
    final current = getRoomXP();
    await _prefs.setInt(_keyRoomXP, (current + delta).clamp(0, 9999999));
  }

  Future<void> setRoomXP(int value) async {
    await _prefs.setInt(_keyRoomXP, value.clamp(0, 9999999));
  }

  /// Aktif kat (0: 1. Kat / Cozy Room, 1: 2. Kat / Loft Kütüphane)
  int getActiveRoomFloor() {
    return _prefs.getInt(_keyActiveRoomFloor) ?? 0;
  }

  Future<void> setActiveRoomFloor(int floor) async {
    await _prefs.setInt(_keyActiveRoomFloor, floor);
  }

  /// Açılan başarıları `Map<achievementId, isoTimestamp>` olarak döner
  Map<String, String> getUnlockedAchievements() {
    final raw = _prefs.getString(_keyUnlockedAchievements);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (e, st) {
      ErrorLogger.log('StorageService.getUnlockedAchievements', e, st);
    }
    return {};
  }

  /// Yeni bir başarı kilidi açar ve kaydeder
  Future<void> unlockAchievement(String id, [DateTime? unlockedAt]) async {
    final map = getUnlockedAchievements();
    final date = unlockedAt ?? DateTime.now().toUtc();
    map[id] = date.toIso8601String();
    await _prefs.setString(_keyUnlockedAchievements, jsonEncode(map));
  }

  /// Başarının açık olup olmadığını kontrol eder
  bool isAchievementUnlocked(String id) {
    return getUnlockedAchievements().containsKey(id);
  }

  /// Kümülatif tamamlanan toplam plan sayısı
  int getTotalCompletedPlans() {
    return _prefs.getInt(_keyTotalCompletedPlans) ?? 0;
  }

  Future<void> incrementCompletedPlanCount([int delta = 1]) async {
    final current = getTotalCompletedPlans();
    await _prefs.setInt(_keyTotalCompletedPlans, (current + delta).clamp(0, 9999999));
  }

  /// Kümülatif toplam odak dakikası (Tüm zamanlar)
  int getAllTimeFocusMinutes() {
    // 1. Doğrudan sayaç
    final direct = _prefs.getInt(_keyAllTimeFocusMinutes);
    if (direct != null && direct > 0) return direct;

    // 2. İlk defa hesaplanıyorsa, tüm kayıtlı focus_mins_ anahtarlarını topla
    int sum = 0;
    final keys = _prefs.getKeys().where((k) => k.startsWith('focus_mins_'));
    for (final k in keys) {
      sum += _prefs.getInt(k) ?? 0;
    }
    _prefs.setInt(_keyAllTimeFocusMinutes, sum);
    return sum;
  }

  Future<void> addFocusMinutesToAllTime(int minutes) async {
    final current = getAllTimeFocusMinutes();
    await _prefs.setInt(_keyAllTimeFocusMinutes, current + minutes);
  }

  /// İlk uygulama açılış veya kayıt tarihi
  DateTime getFirstAppOpenDate() {
    final raw = _prefs.getString(_keyFirstAppOpenDate);
    if (raw != null) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    final now = DateTime.now().toUtc();
    _prefs.setString(_keyFirstAppOpenDate, now.toIso8601String());
    return now;
  }
}

