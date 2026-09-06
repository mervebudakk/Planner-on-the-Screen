import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/schedule_event.dart';
import '../models/user_profile.dart';
import '../models/widget_theme_config.dart';
import 'error_logger.dart';

/// SharedPreferences tabanlı güvenli yerel depolama servisi
class StorageService {
  final SharedPreferences _prefs;

  static const int _maxPayloadBytes = 2 * 1024 * 1024; // 2MB
  static const int _maxCustomColors = 20;
  static const int _retentionDays = 7; // 1 hafta (7 gün) saklama kuralı

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
  Future<bool> setOnboardingCompleted() async {
    return _prefs.setBool(_keyOnboardingCompleted, true);
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

  /// Kullanıcının tüm yerel verilerini ve ayarlarını sıfırlar
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
