import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/routine_model.dart';
import '../../../core/models/schedule_event.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/widget_theme_config.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/error_logger.dart';
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

  static final DateFormat _dateFmt = DateFormat('yyyy-MM-dd');

  final Map<String, List<ScheduleEvent>> _eventsByDateCache = {};
  final Map<int, List<ScheduleEvent>> _eventsByDayCache = {};
  Map<int, List<ScheduleEvent>>? _cachedGroupedByHour;
  List<int>? _cachedSortedHours;

  void _clearEventCaches() {
    _eventsByDateCache.clear();
    _eventsByDayCache.clear();
    _cachedGroupedByHour = null;
    _cachedSortedHours = null;
  }

  void _invalidateCurrentDayGrouping() {
    _cachedGroupedByHour = null;
    _cachedSortedHours = null;
  }

  /// Seçili günün bugün olup olmadığı
  bool get isSelectedDateToday => DateTimeUtils.isToday(_selectedDate);

  DateTime? _cachedCalendarDaysForDate;
  List<DateTime>? _cachedCalendarDays;

  /// 15 gün öncesinden başlayıp max 15 gün sonrasına kadar uzanan takvim günleri (Toplam 31 gün, önbellekli)
  List<DateTime> get calendarDays {
    final today = DateTimeUtils.today;
    if (_cachedCalendarDays != null &&
        _cachedCalendarDaysForDate != null &&
        DateTimeUtils.isSameDay(_cachedCalendarDaysForDate!, today)) {
      return _cachedCalendarDays!;
    }
    final startDate = today.subtract(const Duration(days: 15));
    final days = List<DateTime>.generate(
      31,
      (index) => startDate.add(Duration(days: index)),
      growable: false,
    );
    _cachedCalendarDaysForDate = today;
    _cachedCalendarDays = days;
    return days;
  }

  /// Seçili güne ait etkinlikleri kronolojik sıralı olarak döndürür
  List<ScheduleEvent> get currentDayEvents {
    return getEventsForDate(_selectedDate);
  }

  /// Belirli bir tarihe ait etkinlikleri döndürür (önbellekli)
  List<ScheduleEvent> getEventsForDate(DateTime date) {
    final dateStr = _dateFmt.format(date);
    final cached = _eventsByDateCache[dateStr];
    if (cached != null) return cached;

    final dayOfWeek = date.weekday;
    final filtered = _events.where((e) {
      if (e.dateStr != null && e.dateStr!.isNotEmpty) {
        return e.dateStr == dateStr;
      }
      return e.dayOfWeek == dayOfWeek;
    }).toList();

    final sorted = DateTimeUtils.sortEventsChronologically(filtered);
    _eventsByDateCache[dateStr] = sorted;
    return sorted;
  }

  /// Belirli bir haftanın gününe ait etkinlikleri döndürür (önbellekli)
  List<ScheduleEvent> getEventsForDay(int day) {
    final cached = _eventsByDayCache[day];
    if (cached != null) return cached;

    final filtered = _events.where((e) => e.dayOfWeek == day).toList();
    final sorted = DateTimeUtils.sortEventsChronologically(filtered);
    _eventsByDayCache[day] = sorted;
    return sorted;
  }

  /// Seçili günün saat belirtilmemiş (saatsiz) etkinliklerini döner
  List<ScheduleEvent> get currentDayUntimedEvents {
    return currentDayEvents.where((e) => !e.hasSpecificTime).toList();
  }

  /// Seçili günün saatli etkinliklerini başlangıç saatlerine göre gruplanmış olarak döner (önbellekli)
  Map<int, List<ScheduleEvent>> get currentDayGroupedByHour {
    if (_cachedGroupedByHour != null) return _cachedGroupedByHour!;
    final events = currentDayEvents.where((e) => e.hasSpecificTime);
    final Map<int, List<ScheduleEvent>> grouped = {};
    for (final event in events) {
      grouped.putIfAbsent(event.startHour, () => []).add(event);
    }
    _cachedGroupedByHour = grouped;
    return grouped;
  }

  /// Seçili günün etkinlik bulunan sıralı saat listesini döner (önbellekli)
  List<int> get currentDaySortedHours {
    if (_cachedSortedHours != null) return _cachedSortedHours!;
    final sorted = currentDayGroupedByHour.keys.toList()..sort();
    _cachedSortedHours = sorted;
    return sorted;
  }

  /// Başlangıç verilerini yükler ve widget'la senkronize eder
  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    _events = _storageService.getEvents();
    _clearEventCaches();
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

  /// ☀️ Tema Modu (Daima Açık Tema - Quiet Luxury)
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = ThemeMode.light;
    notifyListeners();
    await _storageService.saveThemeMode(ThemeMode.light);
  }

  /// 🔵 Google ile Giriş Yapar
  Future<bool> signInWithGoogle() async {
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        _userProfile = user;
        notifyListeners();
        await _storageService.saveUserProfile(_userProfile);
        await _postAuthSync();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// 🍎 Apple ile Giriş Yapar
  Future<bool> signInWithApple() async {
    try {
      final user = await AuthService().signInWithApple();
      if (user != null) {
        _userProfile = user;
        notifyListeners();
        await _storageService.saveUserProfile(_userProfile);
        await _postAuthSync();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// ✉️ E-posta ile Giriş Yapar
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final user = await AuthService().signInWithEmail(email: email, password: password);
      if (user != null) {
        _userProfile = user;
        notifyListeners();
        await _storageService.saveUserProfile(_userProfile);
        await _postAuthSync();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// ✉️ E-posta ile Yeni Kayıt Oluşturur
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? username,
  }) async {
    try {
      final user = await AuthService().signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        username: username,
      );
      if (user != null) {
        _userProfile = user;
        notifyListeners();
        await _storageService.saveUserProfile(_userProfile);
        await _postAuthSync();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// Giriş sonrası yerel ve bulut verilerini senkronize eder
  Future<void> _postAuthSync() async {
    try {
      // 1. Buluttan bu kullanıcının etkinliklerini çek
      final cloudEvents = await SupabaseService.instance.fetchEvents();
      if (cloudEvents.isNotEmpty) {
        _events = cloudEvents;
        _clearEventCaches();
        await _storageService.saveEvents(_events);
        _syncServices();
        notifyListeners();
      } else {
        // Bulutta henüz etkinlik yoksa (yeni kullanıcı):
        // Önceki kullanıcının etkinliklerinin sızmasını kesinlikle önle!
        _events = [];
        _clearEventCaches();
        await _storageService.saveEvents(_events);
        _syncServices();
        notifyListeners();
      }

      // 2. Buluttan bu kullanıcının rutinlerini çek
      final cloudRoutines = await SupabaseService.instance.fetchRoutines();
      if (cloudRoutines.isNotEmpty) {
        final routines = cloudRoutines.map((cr) => RoutineModel.fromJson(cr)).toList();
        await _storageService.saveRoutines(routines);
      } else {
        await _storageService.saveRoutines(RoutineModel.defaults);
      }

      // 3. Buluttan bu kullanıcının odaklanma seanslarını çek ve haftalık ritmi geri yükle
      await _syncFocusSessionsFromCloud();

      notifyListeners();
    } catch (e, st) {
      ErrorLogger.log('PlannerProvider._postAuthSync', e, st);
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
    try {
      await SupabaseService.instance.syncUserProfile(_userProfile);
    } catch (e, st) {
      ErrorLogger.log('PlannerProvider.updateUserProfile.sync', e, st);
    }
  }

  /// ⏱️ Tamamlanan odak seansını yerel hafızaya kaydeder ve arayüzü günceller
  Future<void> recordFocusSession(int minutes) async {
    if (minutes <= 0) return;
    await _storageService.recordDailyFocusMinutes(DateTime.now(), minutes);
    notifyListeners();
  }

  /// ⏱️ Belirli bir günün toplam odaklanma süresini dakika olarak döndürür
  int getFocusMinutesForDay(DateTime date) {
    return _storageService.getDailyFocusMinutes(date);
  }

  /// ⏱️ Bu haftanın (Pzt-Paz) her günü için odak dakikaları haritası
  Map<int, int> getCurrentWeekFocusMinutes() {
    return _storageService.getWeeklyFocusMinutes(DateTime.now());
  }

  /// 🚪 Kullanıcı Çıkışı Yapar (Tüm yerel verileri, alarmları ve oturumları temizler)
  Future<void> logoutUser() async {
    _events = [];
    _clearEventCaches();
    _userProfile = UserProfile.guest();
    _customColors = [];

    await _storageService.clearUserData();
    await NotificationService().cancelAllNotifications();
    await AuthService().signOut();

    _syncServices();
    notifyListeners();
  }

  /// 🗑️ Hesabı ve Tüm Verileri Tamamen Siler (Apple Guideline 5.1.1)
  Future<bool> deleteAccountAndAllData() async {
    try {
      // 1. Buluttaki tüm verileri kalıcı olarak sil ve oturumu kapat
      await AuthService().deleteAccount();

      // 2. Bildirim alarmlarını iptal et
      await NotificationService().cancelAllNotifications();

      // 3. Yerel depolamayı (SharedPreferences) tamamen temizle
      await _storageService.clearUserData();
      await _storageService.clearAllData();

      // 4. Durumu sıfırla
      _events = [];
      _clearEventCaches();
      _userProfile = UserProfile.guest();
      _customColors = [];
      _syncServices();
      notifyListeners();

      return true;
    } catch (e, st) {
      ErrorLogger.log('PlannerProvider.deleteAccountAndAllData', e, st);
      return false;
    }
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
    _invalidateCurrentDayGrouping();
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
    _clearEventCaches();

    // 3. UI'ı hemen güncelle — ağ beklemeden
    notifyListeners();

    // 4. Arka plan servisleri — UI'ı bloklamaz
    _syncServices();

    // 5. Oturum açıksa arka planda sessizce bulut senkronizasyonu
    if (_userProfile.isLoggedIn) {
      unawaited(_backgroundCloudSync());
    }
  }

  Future<void> _backgroundCloudSync() async {
    try {
      final cloudEvents = await SupabaseService.instance.fetchEvents();
      if (cloudEvents.isNotEmpty) {
        _events = _mergeEvents(_events, cloudEvents);
        _clearEventCaches();
        await _storageService.saveEvents(_events);
        _syncServices();
        notifyListeners();
      }
      final cloudRoutines = await SupabaseService.instance.fetchRoutines();
      if (cloudRoutines.isNotEmpty) {
        final localRoutines = _storageService.getRoutines();
        final Map<String, RoutineModel> routineMap = {for (var r in localRoutines) r.id: r};
        for (final cr in cloudRoutines) {
          final r = RoutineModel.fromJson(cr);
          routineMap[r.id] = r;
        }
        await _storageService.saveRoutines(routineMap.values.toList());
      }
      // 3. Odak seanslarını senkronize et
      await _syncFocusSessionsFromCloud();
    } catch (e, st) {
      ErrorLogger.log('PlannerProvider._backgroundCloudSync', e, st);
    }
  }

  /// ⏱️ Supabase bulutundan geçmiş odaklanma seanslarını çekip yerel haftalık ritim verilerini günceller
  Future<void> _syncFocusSessionsFromCloud() async {
    try {
      final uid = _userProfile.id.isNotEmpty && !_userProfile.id.startsWith('usr_') && _userProfile.id != 'guest'
          ? _userProfile.id
          : SupabaseService.instance.currentUserId;
      if (uid == null) return;

      // Son 60 günün seanslarını çek
      final sixtyDaysAgo = DateTime.now().subtract(const Duration(days: 60));
      final sessions = await SupabaseService.instance.fetchFocusSessions(
        userId: uid,
        since: sixtyDaysAgo,
      );

      if (sessions.isEmpty) return;

      // Tarihlere göre (YYYY-MM-DD) toplam dakikaları hesapla
      final dailyTotals = <String, int>{};
      for (final s in sessions) {
        final completedAtStr = s['completed_at'] as String?;
        final duration = (s['duration_minutes'] as num?)?.toInt() ?? 0;
        if (completedAtStr != null && duration > 0) {
          final date = DateTime.tryParse(completedAtStr)?.toLocal();
          if (date != null) {
            final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + duration;
          }
        }
      }

      // Yerel hafızaya (StorageService) kaydet
      for (final entry in dailyTotals.entries) {
        final parts = entry.key.split('-').map(int.parse).toList();
        final d = DateTime(parts[0], parts[1], parts[2]);
        final currentLocal = _storageService.getDailyFocusMinutes(d);
        final finalMinutes = max(currentLocal, entry.value);
        await _storageService.setDailyFocusMinutes(d, finalMinutes);
      }

      notifyListeners();
    } catch (e, st) {
      ErrorLogger.log('PlannerProvider._syncFocusSessionsFromCloud', e, st);
    }
  }

  /// Tarih seçimi (Yatay takvim barından bir güne dokunulduğunda)
  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _selectedDay = date.weekday;
    _invalidateCurrentDayGrouping();
    notifyListeners();
  }

  /// Yeni ders / etkinlik ekler
  Future<void> addEvent(ScheduleEvent event) async {
    final safeEvent = _sanitizeEvent(event);
    _events.add(safeEvent);
    _clearEventCaches();
    notifyListeners();

    // Yerel kayıt önce, bulut arka planda
    await _storageService.saveEvents(_events);
    await _notificationService.scheduleWeeklyNotification(safeEvent);
    _syncWidget();
    unawaited(
      SupabaseService.instance.upsertEvent(safeEvent).catchError((e, st) {
        ErrorLogger.log('PlannerProvider.addEvent.upsert', e, st);
      }),
    );
  }

  /// Mevcut ders / etkinliği günceller
  Future<void> updateEvent(ScheduleEvent updatedEvent) async {
    final safeEvent = _sanitizeEvent(updatedEvent);
    final index = _events.indexWhere((e) => e.id == safeEvent.id);
    if (index != -1) {
      _events[index] = safeEvent;
      _clearEventCaches();
      notifyListeners();

      await _storageService.saveEvents(_events);
      await _notificationService.scheduleWeeklyNotification(safeEvent);
      _syncWidget();
      unawaited(
        SupabaseService.instance.upsertEvent(safeEvent).catchError((e, st) {
          ErrorLogger.log('PlannerProvider.updateEvent.upsert', e, st);
        }),
      );
    }
  }

  /// 🎯 Planı tamamlandı / tamamlanmadı olarak işaretler
  Future<void> toggleEventCompletion(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _events[index];
      final updated = event.copyWith(
        isCompleted: !event.isCompleted,
        updatedAt: DateTime.now().toUtc(),
      );
      _events[index] = updated;
      _clearEventCaches();
      notifyListeners();

      await _storageService.saveEvents(_events);
      _syncWidget();
      unawaited(
        SupabaseService.instance.upsertEvent(updated).catchError((e, st) {
          ErrorLogger.log('PlannerProvider.toggleEventCompletion.upsert', e, st);
        }),
      );
    }
  }

  /// Etkinliği siler
  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    _clearEventCaches();
    notifyListeners();

    await _storageService.saveEvents(_events);
    unawaited(_notificationService.cancelNotification(eventId));
    _syncWidget();
    unawaited(
      SupabaseService.instance.deleteEvent(eventId).catchError((e, st) {
        ErrorLogger.log('PlannerProvider.deleteEvent', e, st);
      }),
    );
  }

  /// 🌙 Günü Toparla: Tamamlanmayan planları hedef güne (yarın) kopyalar
  Future<int> copyEventsToDate(List<ScheduleEvent> eventsToCopy, DateTime targetDate) async {
    if (eventsToCopy.isEmpty) return 0;

    final targetDateStr = DateFormat('yyyy-MM-dd').format(targetDate);
    final targetDayOfWeek = targetDate.weekday;
    final List<ScheduleEvent> newEvents = [];

    for (final original in eventsToCopy) {
      final newEvent = ScheduleEvent(
        id: const Uuid().v4(),
        title: original.title,
        subtitle: original.subtitle,
        dayOfWeek: targetDayOfWeek,
        dateStr: targetDateStr,
        startHour: original.startHour,
        startMinute: original.startMinute,
        endHour: original.endHour,
        endMinute: original.endMinute,
        colorHex: original.colorHex,
        isNotificationEnabled: original.isNotificationEnabled,
        reminderMinutesBefore: original.reminderMinutesBefore,
        hasSpecificTime: original.hasSpecificTime,
        isCompleted: false,
        updatedAt: DateTime.now().toUtc(),
      );
      newEvents.add(_sanitizeEvent(newEvent));
    }

    _events.addAll(newEvents);
    _clearEventCaches();
    notifyListeners();

    await _storageService.saveEvents(_events);
    for (final e in newEvents) {
      unawaited(
        _notificationService.scheduleWeeklyNotification(e).catchError((err, st) {
          ErrorLogger.log('PlannerProvider.copyEventsToDate.notification', err, st);
        }),
      );
    }
    _syncWidget();

    unawaited(
      SupabaseService.instance.syncAllEvents(_events).catchError((e, st) {
        ErrorLogger.log('PlannerProvider.copyEventsToDate.sync', e, st);
      }),
    );

    return newEvents.length;
  }

  /// Widget görünüm ayarlarını günceller
  Future<void> updateThemeConfig(WidgetThemeConfig newConfig) async {
    _themeConfig = newConfig;
    notifyListeners();

    await _storageService.saveWidgetTheme(_themeConfig);
    _syncWidget();
    unawaited(
      SupabaseService.instance.syncWidgetConfig(
        config: _themeConfig,
        customColors: _customColors,
      ).catchError((e, st) {
        ErrorLogger.log('PlannerProvider.updateThemeConfig.sync', e, st);
      }),
    );
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
    final sanitized = ScheduleEvent.fromJson(event.toJson());
    return sanitized.copyWith(
      updatedAt: event.updatedAt ?? DateTime.now().toUtc(),
    );
  }

  /// 🔄 Akıllı Çakışma Yönetimi (Last-Write-Wins - Fix #6)
  /// Çevrimdışı yapılan düzenlemeler bulut verisi tarafından ezilmez;
  /// son güncelleme zaman damgasına (updatedAt) göre daha yeni olan versiyon kazanır.
  List<ScheduleEvent> _mergeEvents(List<ScheduleEvent> local, List<ScheduleEvent> cloud) {
    final Map<String, ScheduleEvent> merged = {};
    for (final e in cloud) {
      merged[e.id] = e;
    }
    for (final e in local) {
      final existing = merged[e.id];
      if (existing == null) {
        // Yalnızca lokalde var (örn: çevrimdışıyken eklendi) -> yereli koru
        merged[e.id] = e;
      } else {
        // Her ikisinde de var -> updatedAt daha yeniyse yerel kazanır
        final localTime = e.updatedAt ?? DateTime(2000);
        final cloudTime = existing.updatedAt ?? DateTime(1999);
        if (localTime.isAfter(cloudTime)) {
          merged[e.id] = e;
        }
      }
    }
    return merged.values.toList()
      ..sort((a, b) {
        final dayComp = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dayComp != 0) return dayComp;
        final hourComp = a.startHour.compareTo(b.startHour);
        if (hourComp != 0) return hourComp;
        return a.startMinute.compareTo(b.startMinute);
      });
  }
}
