import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/schedule_event.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/widget_theme_config.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/widget_sync_service.dart';
import '../../../core/utils/date_time_utils.dart';

/// Haftalık plan, seçili tarih/gün, kullanıcı profili ve tema durum yöneticisi
class PlannerProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService = NotificationService();

  List<ScheduleEvent> _events = [];
  WidgetThemeConfig _themeConfig = const WidgetThemeConfig();
  ThemeMode _themeMode = ThemeMode.light;
  List<String> _customColors = [];
  UserProfile _userProfile = UserProfile.guest();

  // Seçili Tarih ve Gün (Açılışta doğrudan bugün seçili)
  late DateTime _selectedDate;
  late int _selectedDay;
  bool _isLoading = true;

  PlannerProvider(this._storageService) {
    _selectedDate = DateTimeUtils.today;
    _selectedDay = DateTimeUtils.currentDayOfWeek;
    _initData();
  }

  // Getters
  List<ScheduleEvent> get allEvents => _events;
  WidgetThemeConfig get themeConfig => _themeConfig;
  ThemeMode get themeMode => _themeMode;
  List<String> get customColors => _customColors;
  UserProfile get userProfile => _userProfile;
  DateTime get selectedDate => _selectedDate;
  int get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;

  /// Seçili günün bugün olup olmadığı
  bool get isSelectedDateToday => DateTimeUtils.isToday(_selectedDate);

  /// 15 gün öncesinden başlayıp max 15 gün sonrasına kadar uzanan takvim günleri (Toplam 31 gün)
  List<DateTime> get calendarDays {
    final today = DateTimeUtils.today;
    final startDate = today.subtract(const Duration(days: 15));
    // 15 gün önce + bugün + 15 gün ileri = 31 gün
    return List.generate(31, (index) => startDate.add(Duration(days: index)));
  }

  /// Seçili güne ait etkinlikleri kronolojik sıralı olarak döndürür
  List<ScheduleEvent> get currentDayEvents {
    return getEventsForDate(_selectedDate);
  }

  /// Belirli bir tarihe ait etkinlikleri döndürür
  List<ScheduleEvent> getEventsForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final dayOfWeek = date.weekday;

    final filtered = _events.where((e) {
      if (e.dateStr != null && e.dateStr!.isNotEmpty) {
        return e.dateStr == dateStr;
      }
      return e.dayOfWeek == dayOfWeek;
    }).toList();

    return DateTimeUtils.sortEventsChronologically(filtered);
  }

  /// Belirli bir haftanın gününe ait etkinlikleri döndürür
  List<ScheduleEvent> getEventsForDay(int day) {
    final filtered = _events.where((e) => e.dayOfWeek == day).toList();
    return DateTimeUtils.sortEventsChronologically(filtered);
  }

  /// Başlangıç verilerini yükler ve widget'la senkronize eder
  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    _events = _storageService.getEvents();
    _themeConfig = _storageService.getWidgetTheme();
    _themeMode = _storageService.getThemeMode();
    _customColors = _storageService.getCustomColors();
    _userProfile = _storageService.getUserProfile();

    // 📍 Açılışta doğrudan bugünün tarihi ve günü seçili
    _selectedDate = DateTimeUtils.today;
    _selectedDay = DateTimeUtils.currentDayOfWeek;

    _isLoading = false;
    notifyListeners();

    _syncServices();
  }

  /// ☀️/🌙 Tema Modunu Değiştirir
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _storageService.saveThemeMode(mode);
  }

  /// 👤 Kullanıcı Girişi Yapar
  Future<void> loginUser({required String name, required String email}) async {
    final safeName = _limitText(
      name.trim().isEmpty ? 'Kullanıcı' : name.trim(),
      80,
    );
    final safeEmail = _limitText(email.trim(), 160);

    _userProfile = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: safeName,
      email: safeEmail,
      isLoggedIn: true,
      createdAt: DateTime.now(),
    );
    notifyListeners();
    await _storageService.saveUserProfile(_userProfile);
  }

  /// 🚪 Kullanıcı Çıkışı Yapar
  Future<void> logoutUser() async {
    _userProfile = UserProfile.guest();
    notifyListeners();
    await _storageService.clearUserProfile();
  }

  /// 🎨 Yeni bir özel pastel renk ekler
  Future<void> addCustomColor(String hexColor) async {
    final normalized = AppColors.normalizeHexColor(hexColor, fallback: '');
    if (normalized.isEmpty) return;

    if (!_customColors.contains(normalized)) {
      _customColors.add(normalized);
      notifyListeners();
      await _storageService.saveCustomColor(normalized);
    }
  }

  /// 📍 Doğrudan bugüne döner
  void selectToday() {
    _selectedDate = DateTimeUtils.today;
    _selectedDay = DateTimeUtils.currentDayOfWeek;
    notifyListeners();
  }

  /// Tarih seçimi (Yatay takvim barından bir güne dokunulduğunda)
  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _selectedDay = date.weekday;
    notifyListeners();
  }

  /// Yeni ders / etkinlik ekler
  Future<void> addEvent(ScheduleEvent event) async {
    final safeEvent = _sanitizeEvent(event);
    _events.add(safeEvent);
    notifyListeners();

    await _storageService.saveEvents(_events);
    await _notificationService.scheduleWeeklyNotification(safeEvent);
    _syncWidget();
  }

  /// Mevcut ders / etkinliği günceller
  Future<void> updateEvent(ScheduleEvent updatedEvent) async {
    final safeEvent = _sanitizeEvent(updatedEvent);
    final index = _events.indexWhere((e) => e.id == safeEvent.id);
    if (index != -1) {
      _events[index] = safeEvent;
      notifyListeners();

      await _storageService.saveEvents(_events);
      await _notificationService.scheduleWeeklyNotification(safeEvent);
      _syncWidget();
    }
  }

  /// Etkinliği siler
  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();

    await _storageService.saveEvents(_events);
    await _notificationService.cancelNotification(eventId);
    _syncWidget();
  }

  /// Widget görünüm ayarlarını günceller
  Future<void> updateThemeConfig(WidgetThemeConfig newConfig) async {
    _themeConfig = newConfig;
    notifyListeners();

    await _storageService.saveWidgetTheme(_themeConfig);
    _syncWidget();
  }

  /// Widget köprüsünü günceller
  void _syncWidget() {
    WidgetSyncService.updateWidgetData(
      allEvents: _events,
      themeConfig: _themeConfig,
    );
  }

  /// Bildirim ve Widget servislerini tam senkronize eder
  void _syncServices() {
    _notificationService.syncAll(_events);
    _syncWidget();
  }

  String _limitText(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength);
  }

  ScheduleEvent _sanitizeEvent(ScheduleEvent event) {
    return ScheduleEvent.fromJson(event.toJson());
  }
}
