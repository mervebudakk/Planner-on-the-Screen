import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../models/schedule_event.dart';
import '../models/widget_theme_config.dart';
import 'error_logger.dart';

/// Verileri yerel hafızada (SharedPreferences) saklayan ve yöneten servis
class StorageService {
  final SharedPreferences _prefs;
  static const _uuid = Uuid();

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// Kayıtlı tüm etkinlikleri getirir, ilk açılışta estetik örnek veriler yükler.
  ///
  /// 🔒 GÜVENLİK:
  ///  - Payload boyutu 2 MB ile sınırlıdır (bellek tüketimi / DoS önlemi).
  ///  - Her etkinlik ayrı ayrı parse edilir; bozuk kayıtlar atlanır, uygulama çökmez.
  ///  - Tüm hatalar ErrorLogger'a iletilir.
  List<ScheduleEvent> getEvents() {
    final rawJson = _prefs.getString(AppConstants.keyEvents);
    if (rawJson == null || rawJson.isEmpty) {
      return _generateInitialSeedData();
    }

    // Payload boyutu kontrolü: 2 MB üzeri verileri kabul etme
    const int maxPayloadBytes = 2 * 1024 * 1024;
    if (rawJson.length > maxPayloadBytes) {
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

      // Her etkinliği bağımsız parse et; bozuk kayıtları atla (uygulama çökmesin)
      final events = <ScheduleEvent>[];
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        try {
          events.add(ScheduleEvent.fromJson(item));
        } on Object catch (e) {
          ErrorLogger.log('StorageService.getEvents', e, null, 'Corrupted event skipped');
        }
      }
      return events;
    } on FormatException catch (e, st) {
      ErrorLogger.log('StorageService.getEvents', e, st, 'JSON parse hatası');
      return _generateInitialSeedData();
    } on Object catch (e, st) {
      ErrorLogger.log('StorageService.getEvents', e, st);
      return _generateInitialSeedData();
    }
  }


  /// Etkinlik listesini kaydeder
  Future<bool> saveEvents(List<ScheduleEvent> events) async {
    final jsonList = events.map((e) => e.toJson()).toList();
    return _prefs.setString(AppConstants.keyEvents, jsonEncode(jsonList));
  }

  /// Widget tema ayarlarını getirir
  WidgetThemeConfig getWidgetTheme() {
    final rawJson = _prefs.getString(AppConstants.keyWidgetTheme);
    if (rawJson == null || rawJson.isEmpty) {
      return const WidgetThemeConfig();
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(rawJson) as Map<String, dynamic>;
      return WidgetThemeConfig.fromJson(decoded);
    } catch (_) {
      return const WidgetThemeConfig();
    }
  }

  /// Widget tema ayarlarını kaydeder
  Future<bool> saveWidgetTheme(WidgetThemeConfig theme) async {
    return _prefs.setString(AppConstants.keyWidgetTheme, jsonEncode(theme.toJson()));
  }

  /// Kullanıcı ilk kez açtığında gösterilecek örnek estetik haftalık plan
  List<ScheduleEvent> _generateInitialSeedData() {
    return [
      // Pazartesi (1)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Psychology 101',
        subtitle: 'Hall B',
        dayOfWeek: 1,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        colorHex: '#60A5FA',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Study @ Library',
        subtitle: 'Group room 3',
        dayOfWeek: 1,
        startHour: 10,
        startMinute: 0,
        endHour: 12,
        endMinute: 0,
        colorHex: '#38BDF8',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Lunch with Maya',
        subtitle: 'Campus Cafe',
        dayOfWeek: 1,
        startHour: 12,
        startMinute: 30,
        endHour: 13,
        endMinute: 30,
        colorHex: '#E2E8F0',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Marketing lecture',
        subtitle: 'Online zoom',
        dayOfWeek: 1,
        startHour: 14,
        startMinute: 0,
        endHour: 16,
        endMinute: 0,
        colorHex: '#60A5FA',
      ),

      // Salı (2) - Referans ekran görüntüsüyle birebir
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Quick workout',
        subtitle: 'Morning routine',
        dayOfWeek: 2,
        startHour: 6,
        startMinute: 0,
        endHour: 7,
        endMinute: 0,
        colorHex: '#FBBF24',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Business class',
        subtitle: 'Presentation',
        dayOfWeek: 2,
        startHour: 9,
        startMinute: 0,
        endHour: 12,
        endMinute: 0,
        colorHex: '#60A5FA',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Coffee & lunch',
        subtitle: 'Break',
        dayOfWeek: 2,
        startHour: 12,
        startMinute: 30,
        endHour: 13,
        endMinute: 0,
        colorHex: '#E2E8F0',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Part-time shift',
        subtitle: 'Design work',
        dayOfWeek: 2,
        startHour: 13,
        startMinute: 0,
        endHour: 16,
        endMinute: 0,
        colorHex: '#F472B6',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: "Trader Joe's",
        subtitle: 'Grocery shopping',
        dayOfWeek: 2,
        startHour: 17,
        startMinute: 30,
        endHour: 18,
        endMinute: 15,
        colorHex: '#E2E8F0',
      ),

      // Çarşamba (3)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Statistics',
        subtitle: 'Lab 2',
        dayOfWeek: 3,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        colorHex: '#60A5FA',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Project meeting',
        subtitle: 'Tech stack discussion',
        dayOfWeek: 3,
        startHour: 11,
        startMinute: 0,
        endHour: 12,
        endMinute: 0,
        colorHex: '#34D399',
      ),

      // Perşembe (4)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Economics',
        subtitle: 'Lecture hall 1',
        dayOfWeek: 4,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        colorHex: '#60A5FA',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Office hours',
        subtitle: 'Prof. Miller',
        dayOfWeek: 4,
        startHour: 11,
        startMinute: 0,
        endHour: 12,
        endMinute: 0,
        colorHex: '#F472B6',
      ),

      // Cuma (5)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Assignment update',
        subtitle: 'Final touches',
        dayOfWeek: 5,
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 30,
        colorHex: '#34D399',
      ),
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Night out',
        subtitle: 'Friends meetup',
        dayOfWeek: 5,
        startHour: 21,
        startMinute: 0,
        endHour: 23,
        endMinute: 0,
        colorHex: '#E2E8F0',
      ),

      // Cumartesi (6)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Badminton',
        subtitle: 'Sports club',
        dayOfWeek: 6,
        startHour: 14,
        startMinute: 0,
        endHour: 16,
        endMinute: 30,
        colorHex: '#FBBF24',
      ),

      // Pazar (7)
      ScheduleEvent(
        id: _uuid.v4(),
        title: 'Farm market',
        subtitle: 'Fresh supplies',
        dayOfWeek: 7,
        startHour: 9,
        startMinute: 0,
        endHour: 11,
        endMinute: 0,
        colorHex: '#E2E8F0',
      ),
    ];
  }
}
