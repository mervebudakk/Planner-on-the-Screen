import 'package:flutter/foundation.dart';
import '../../../core/models/schedule_event.dart';
import '../../../core/models/widget_theme_config.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/widget_sync_service.dart';
import '../../../core/utils/date_time_utils.dart';

/// Haftalık plan, seçili gün ve widget ayarlarının reaktif durum yöneticisi
class PlannerProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService = NotificationService();

  List<ScheduleEvent> _events = [];
  WidgetThemeConfig _themeConfig = const WidgetThemeConfig();
  int _selectedDay = DateTimeUtils.currentDayOfWeek;
  bool _isLoading = true;

  PlannerProvider(this._storageService) {
    _initData();
  }

  // Getters
  List<ScheduleEvent> get allEvents => _events;
  WidgetThemeConfig get themeConfig => _themeConfig;
  int get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;

  /// Seçili güne ait etkinlikleri kronolojik sıralı olarak döndürür
  List<ScheduleEvent> get currentDayEvents {
    return getEventsForDay(_selectedDay);
  }

  /// Belirli bir güne ait etkinlikleri döndürür
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
    _selectedDay = DateTimeUtils.currentDayOfWeek;

    _isLoading = false;
    notifyListeners();

    // Arka plan senkronizasyonu
    _syncServices();
  }

  /// Günü değiştirir (Pzt - Paz)
  void selectDay(int day) {
    if (_selectedDay != day) {
      _selectedDay = day;
      notifyListeners();
    }
  }

  /// Yeni ders / etkinlik ekler
  Future<void> addEvent(ScheduleEvent event) async {
    _events.add(event);
    notifyListeners();

    await _storageService.saveEvents(_events);
    await _notificationService.scheduleWeeklyNotification(event);
    _syncWidget();
  }

  /// Mevcut ders / etkinliği günceller
  Future<void> updateEvent(ScheduleEvent updatedEvent) async {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();

      await _storageService.saveEvents(_events);
      await _notificationService.scheduleWeeklyNotification(updatedEvent);
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
}
