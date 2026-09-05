import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/schedule_event.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/widget_theme_config.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/supabase_service.dart';
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
  String? _customWallpaperPath;

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
  List<ScheduleEvent> get events => _events;
  WidgetThemeConfig get themeConfig => _themeConfig;
  ThemeMode get themeMode => _themeMode;
  List<String> get customColors => _customColors;
  UserProfile get userProfile => _userProfile;
  String? get customWallpaperPath => _customWallpaperPath;
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
    _customWallpaperPath = _storageService.getCustomWallpaperPath();

    // 📍 Açılışta doğrudan bugünün tarihi ve günü seçili
    _selectedDate = DateTimeUtils.today;
    _selectedDay = DateTimeUtils.currentDayOfWeek;

    _isLoading = false;
    notifyListeners();

    _syncServices();
  }

  /// 🖼️ Önizleme için özel duvar kâğıdı ayarlar (null ise temizler)
  Future<void> setCustomWallpaperPath(String? path) async {
    _customWallpaperPath = path;
    notifyListeners();
    await _storageService.saveCustomWallpaperPath(path);
  }

  /// ☀️/🌙 Tema Modunu Değiştirir
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _storageService.saveThemeMode(mode);
  }

  /// 🔵 Google ile Giriş Yapar
  Future<bool> signInWithGoogle() async {
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        _userProfile = user;
        notifyListeners();
        await _storageService.saveUserProfile(_userProfile);

        // Supabase'den kullanıcının buluttaki etkinliklerini çekip birleştir
        try {
          final cloudEvents = await SupabaseService.instance.fetchEvents();
          if (cloudEvents.isNotEmpty) {
            _events = cloudEvents;
            await _storageService.saveEvents(_events);
            _syncServices();
            notifyListeners();
          } else if (_events.isNotEmpty) {
            // Yerel etkinlikleri buluta yükle
            await SupabaseService.instance.syncAllEvents(_events);
          }
        } catch (_) {}

        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// 👤 Kullanıcı Girişi Yapar
  Future<void> loginUser({required String name, required String email, String? avatarUrl}) async {
    final safeName = _limitText(
      name.trim().isEmpty ? 'Kullanıcı' : name.trim(),
      80,
    );
    final safeEmail = _limitText(email.trim(), 160);

    final names = safeName.split(' ');
    final firstName = names.isNotEmpty ? names.first : safeName;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
    final username = safeEmail.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    _userProfile = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: safeEmail,
      avatarAnimal: '01_rabbit',
      avatarAccessory: 'none',
      avatarBgColor: '#FAF7F2',
      isLoggedIn: true,
      createdAt: DateTime.now(),
    );
    notifyListeners();
    await _storageService.saveUserProfile(_userProfile);
    // Bulut senkronizasyonu arka planda, UI'ı bekletmez
    unawaited(SupabaseService.instance.syncUserProfile(_userProfile));
  }

  /// 💾 Kullanıcı Profilini Günceller ve Kaydeder
  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    notifyListeners();
    await _storageService.saveUserProfile(_userProfile);
    unawaited(SupabaseService.instance.syncUserProfile(_userProfile));
  }

  /// 🚪 Kullanıcı Çıkışı Yapar
  Future<void> logoutUser() async {
    _userProfile = UserProfile.guest();
    notifyListeners();
    await _storageService.clearUserProfile();
    await AuthService().signOut();
  }

  /// 🎨 Yeni bir özel pastel renk ekler
  Future<void> addCustomColor(String hexColor) async {
    final normalized = AppColors.normalizeHexColor(hexColor, fallback: '');
    if (normalized.isEmpty) return;

    if (!_customColors.contains(normalized)) {
      _customColors.add(normalized);
      notifyListeners();
      await _storageService.saveCustomColor(normalized);
      unawaited(SupabaseService.instance.syncWidgetConfig(
        config: _themeConfig,
        customColors: _customColors,
      ));
    }
  }

  /// 🗑️ Kullanıcının oluşturduğu özel rengi kaldırır
  Future<void> removeCustomColor(String hexColor) async {
    final normalized = AppColors.normalizeHexColor(hexColor, fallback: '');
    if (normalized.isEmpty) return;

    _customColors.removeWhere((c) => c.toUpperCase() == normalized.toUpperCase());
    notifyListeners();
    await _storageService.removeCustomColor(normalized);
    unawaited(SupabaseService.instance.syncWidgetConfig(
      config: _themeConfig,
      customColors: _customColors,
    ));
  }

  /// 📍 Doğrudan bugüne döner
  void selectToday() {
    _selectedDate = DateTimeUtils.today;
    _selectedDay = DateTimeUtils.currentDayOfWeek;
    notifyListeners();
  }

  /// 🔄 Uygulama ön plana geldiğinde, açıldığında veya gece yarısı geçildiğinde tam senkronizasyon yapar
  Future<void> refreshOnResume() async {
    final today = DateTimeUtils.today;

    // 1. Yerel veriyi anında yükle
    _events = _storageService.getEvents();

    // 2. Seçili tarihi doğrudan bugünün tarihine senkronize et
    _selectedDate = today;
    _selectedDay = today.weekday;

    // 3. UI'ı hemen güncelle — ağ beklemeden
    notifyListeners();

    // 4. Arka plan servisleri — UI'ı bloklamaz
    _syncServices();
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

    // Yerel kayıt önce, bulut arka planda
    await _storageService.saveEvents(_events);
    unawaited(_notificationService.scheduleWeeklyNotification(safeEvent));
    _syncWidget();
    unawaited(SupabaseService.instance.upsertEvent(safeEvent));
  }

  /// Mevcut ders / etkinliği günceller
  Future<void> updateEvent(ScheduleEvent updatedEvent) async {
    final safeEvent = _sanitizeEvent(updatedEvent);
    final index = _events.indexWhere((e) => e.id == safeEvent.id);
    if (index != -1) {
      _events[index] = safeEvent;
      notifyListeners();

      await _storageService.saveEvents(_events);
      unawaited(_notificationService.scheduleWeeklyNotification(safeEvent));
      _syncWidget();
      unawaited(SupabaseService.instance.upsertEvent(safeEvent));
    }
  }

  /// Etkinliği siler
  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();

    await _storageService.saveEvents(_events);
    unawaited(_notificationService.cancelNotification(eventId));
    _syncWidget();
    unawaited(SupabaseService.instance.deleteEvent(eventId));
  }

  /// Widget görünüm ayarlarını günceller
  Future<void> updateThemeConfig(WidgetThemeConfig newConfig) async {
    _themeConfig = newConfig;
    notifyListeners();

    await _storageService.saveWidgetTheme(_themeConfig);
    _syncWidget();
    unawaited(SupabaseService.instance.syncWidgetConfig(
      config: _themeConfig,
      customColors: _customColors,
    ));
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
