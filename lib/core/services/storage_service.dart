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

  static const int _maxPayloadBytes = 2 * 1024 * 1024; // 2MB
  static const int _maxCustomColors = 20;
  static const int _retentionDays = 15; // 15 gün saklama kuralı (geçmiş hafta verileri için)

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
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
  /// Gün değişmişse, dünün tamamlanma bayraklarını sıfırlar, serileri korur.
  List<RoutineModel> getRoutines() {
    final list = getRoutinesRaw();
    if (list.isEmpty) {
      return RoutineModel.defaults;
    }
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastDate = getRoutinesLastDate();

    final routines = list.map((m) => RoutineModel.fromJson(m)).toList();

    if (lastDate != null && lastDate != todayStr) {
      // Gün değişti: tamamlandı bayraklarını sıfırla
      final resetRoutines = routines.map((r) => r.copyWith(isCompleted: false)).toList();
      saveRoutines(resetRoutines);
      setRoutinesLastDate(todayStr);
      return resetRoutines;
    }

    if (lastDate == null) {
      setRoutinesLastDate(todayStr);
    }

    return routines;
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
}

