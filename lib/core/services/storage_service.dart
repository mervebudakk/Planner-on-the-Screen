import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/schedule_event.dart';
import '../models/user_profile.dart';
import '../models/widget_theme_config.dart';
import 'error_logger.dart';

/// Verileri yerel hafızada (SharedPreferences) saklayan ve yöneten servis
class StorageService {
  final SharedPreferences _prefs;
  static const _uuid = Uuid();
  static const int _maxPayloadBytes = 2 * 1024 * 1024;
  static const int _maxCustomColors = 24;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// 🔒 15 Günlük Geçmiş Veri Temizleme Kuralı (Retention Policy):
  /// 15 günden daha eski belirli tarihli etkinlikleri temizler.
  List<ScheduleEvent> _filterExpiredEvents(List<ScheduleEvent> events) {
    final now = DateTime.now();
    final cutoffDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 15));

    return events.where((event) {
      if (event.dateStr == null || event.dateStr!.isEmpty) {
        return true; // Haftalık tekrarlayan planlar saklanır
      }
      try {
        final eventDate = DateTime.parse(event.dateStr!);
        return !eventDate.isBefore(cutoffDate);
      } catch (_) {
        return true;
      }
    }).toList();
  }

  /// Kayıtlı tüm etkinlikleri getirir, 15 gün öncesini otomatik temizler.
  List<ScheduleEvent> getEvents() {
    final rawJson = _prefs.getString(AppConstants.storageKeyEvents);
    if (rawJson == null || rawJson.isEmpty) {
      return _generateInitialSeedData();
    }

    if (rawJson.length > _maxPayloadBytes) {
      ErrorLogger.security(
        'StorageService: Payload boyutu limiti aşıldı (${rawJson.length} bytes). Seed data yükleniyor.',
      );
      return _generateInitialSeedData();
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List) {
        ErrorLogger.security('StorageService: Beklenmeyen JSON tipi. Seed data yükleniyor.');
        return _generateInitialSeedData();
      }

      final events = <ScheduleEvent>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          events.add(ScheduleEvent.fromJson(Map<String, dynamic>.from(item)));
        } on Object catch (e) {
          ErrorLogger.log('StorageService.getEvents', e, null, 'Corrupted event skipped');
        }
      }

      // 15 günden eski geçmiş verileri filtrele
      final filteredEvents = _filterExpiredEvents(events);
      if (filteredEvents.length != events.length) {
        saveEvents(filteredEvents); // Temizlenmiş listeyi kaydet
      }

      return filteredEvents;
    } on FormatException catch (e, st) {
      ErrorLogger.log('StorageService.getEvents', e, st, 'JSON parse hatası');
      return _generateInitialSeedData();
    } on Object catch (e, st) {
      ErrorLogger.log('StorageService.getEvents', e, st);
      return _generateInitialSeedData();
    }
  }

  /// Etkinlik listesini kaydeder (15 günden eski veriler ayıklanarak)
  Future<bool> saveEvents(List<ScheduleEvent> events) async {
    final validEvents = _filterExpiredEvents(events);
    final jsonList = validEvents.map((e) => e.toJson()).toList();
    return _prefs.setString(AppConstants.storageKeyEvents, jsonEncode(jsonList));
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
  Future<bool> saveWidgetTheme(WidgetThemeConfig theme) async {
    return _prefs.setString(AppConstants.storageKeyWidgetTheme, jsonEncode(theme.toJson()));
  }

  /// Kayıtlı Tema Modunu getirir (Varsayılan: ThemeMode.light)
  ThemeMode getThemeMode() {
    final modeStr = _prefs.getString(AppConstants.storageKeyThemeMode);
    switch (modeStr) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light; // ☀️ Varsayılan: Açık Tema
    }
  }

  /// Tema Modunu kaydeder
  Future<bool> saveThemeMode(ThemeMode mode) async {
    String modeStr;
    switch (mode) {
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      case ThemeMode.system:
        modeStr = 'system';
        break;
      case ThemeMode.light:
        modeStr = 'light';
        break;
    }
    return _prefs.setString(AppConstants.storageKeyThemeMode, modeStr);
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

  // ─── KULLANICI PROFİLİ VE GİRİŞ DURUMU ───
  static const String _keyUserProfile = 'user_profile_data_v1';

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

  /// Kullanıcı ilk kez açtığında gösterilecek örnek estetik haftalık plan
  List<ScheduleEvent> _generateInitialSeedData() {
    return [
      // Pazartesi (1)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Psikoloji 101',
        subtitle: 'B Blok Amfi 2',
        dayOfWeek: 1,
        startHour: 8,
        startMinute: 30,
        endHour: 10,
        endMinute: 0,
        colorHex: '#93C5FD',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Kütüphanede Çalışma',
        subtitle: 'Bireysel Çalışma Alanı',
        dayOfWeek: 1,
        startHour: 10,
        startMinute: 30,
        endHour: 12,
        endMinute: 30,
        colorHex: '#C4B5FD',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Öğle Molası & Kahve',
        subtitle: 'Kampüs Bahçesi',
        dayOfWeek: 1,
        startHour: 12,
        startMinute: 30,
        endHour: 13,
        endMinute: 30,
        colorHex: '#FED7AA',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Pazarlama Dersi',
        subtitle: 'Online Ders',
        dayOfWeek: 1,
        startHour: 14,
        startMinute: 0,
        endHour: 16,
        endMinute: 0,
        colorHex: '#86EFAC',
      ),

      // Salı (2)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Sabah Yürüyüşü',
        subtitle: 'Park Parkuru',
        dayOfWeek: 2,
        startHour: 7,
        startMinute: 0,
        endHour: 8,
        endMinute: 0,
        colorHex: '#FDE047',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'İş Yönetimi Dersi',
        subtitle: 'Proje Sunumu',
        dayOfWeek: 2,
        startHour: 9,
        startMinute: 0,
        endHour: 12,
        endMinute: 0,
        colorHex: '#93C5FD',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Tasarım Çalışması',
        subtitle: 'Figma UI/UX',
        dayOfWeek: 2,
        startHour: 13,
        startMinute: 0,
        endHour: 16,
        endMinute: 0,
        colorHex: '#F9A8D4',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Haftalık Alışveriş',
        subtitle: 'Market',
        dayOfWeek: 2,
        startHour: 17,
        startMinute: 30,
        endHour: 18,
        endMinute: 30,
        colorHex: '#E2E8F0',
      ),

      // Çarşamba (3)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'İstatistik & Veri',
        subtitle: 'Bilgisayar Lab 1',
        dayOfWeek: 3,
        startHour: 9,
        startMinute: 0,
        endHour: 11,
        endMinute: 0,
        colorHex: '#93C5FD',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Ekip Toplantısı',
        subtitle: 'Sprint Planlaması',
        dayOfWeek: 3,
        startHour: 11,
        startMinute: 30,
        endHour: 12,
        endMinute: 30,
        colorHex: '#86EFAC',
      ),

      // Perşembe (4)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Ekonomi Dersi',
        subtitle: 'Amfi 1',
        dayOfWeek: 4,
        startHour: 9,
        startMinute: 0,
        endHour: 11,
        endMinute: 0,
        colorHex: '#93C5FD',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Danışman Görüşmesi',
        subtitle: 'Oda 304',
        dayOfWeek: 4,
        startHour: 13,
        startMinute: 0,
        endHour: 14,
        endMinute: 0,
        colorHex: '#F9A8D4',
      ),

      // Cuma (5)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Ödev & Proje Teslimi',
        subtitle: 'Portal Yüklemesi',
        dayOfWeek: 5,
        startHour: 10,
        startMinute: 0,
        endHour: 11,
        endMinute: 30,
        colorHex: '#86EFAC',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Arkadaşlarla Akşam Yemeği',
        subtitle: 'Restoran',
        dayOfWeek: 5,
        startHour: 19,
        startMinute: 30,
        endHour: 22,
        endMinute: 0,
        colorHex: '#FED7AA',
      ),

      // Cumartesi (6)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Spor & Tenis',
        subtitle: 'Spor Salonu',
        dayOfWeek: 6,
        startHour: 11,
        startMinute: 0,
        endHour: 13,
        endMinute: 0,
        colorHex: '#FDE047',
      ),

      // Pazar (7)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Haftalık Planlama & Dinlenme',
        subtitle: 'Ev & Kitap Okuma',
        dayOfWeek: 7,
        startHour: 10,
        startMinute: 0,
        endHour: 12,
        endMinute: 0,
        colorHex: '#C4B5FD',
      ),
    ];
  }
}
