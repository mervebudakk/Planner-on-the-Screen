import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/schedule_event.dart';
import 'error_logger.dart';

/// Cihazın yerel alarm motoru üzerinden internetsiz ve tam zamanında çalışan bildirim servisi.
///
/// 🔒 GÜVENLİK & KARARLILIK:
///  - Doğru IANA saat dilimi (flutter_timezone) ile cihaz saatine %100 senkron çalışır.
///  - iOS Darwin (Time-Sensitive) ve Android MAX öncelikli kanallar ile kilit ekranında ve açıkken banner basar.
///  - Bildirim başlığı doğrudan planın adıdır.
///  - FNV-1a hash ile notification ID çakışması minimize edilir.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// 📲 Bildirime tıklandığında gelen payload dinleyicisi (örn: 'tab:clubs', 'tab:focus')
  static final ValueNotifier<String?> onNotificationPayload =
      ValueNotifier<String?>(null);

  // ⏱️ Odak Bildirim Sabitleri
  static const int focusOngoingNotificationId = 88888;
  static const int focusCompletionNotificationId = 88889;

  static const String focusOngoingChannelId = 'focus_ongoing_v1';
  static const String focusCompletedChannelId = 'focus_completed_v1';

  /// Bildirim servisini başlatır
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      try {
        // 🌐 Cihazın gerçek IANA saat dilimini al (Örn: Europe/Istanbul)
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
      } catch (e, st) {
        ErrorLogger.log('NotificationService.init.timezone', e, st);
        try {
          final String timeZoneName = DateTime.now().timeZoneName;
          if (tz.timeZoneDatabase.locations.containsKey(timeZoneName)) {
            tz.setLocalLocation(tz.getLocation(timeZoneName));
          }
        } catch (_) {}
      }

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null && details.payload!.isNotEmpty) {
            onNotificationPayload.value = details.payload;
          }
        },
      );

      // 🚀 Uygulama kapalıyken bildirime tıklanarak açılmışsa:
      try {
        final launchDetails = await _plugin.getNotificationAppLaunchDetails();
        if (launchDetails?.didNotificationLaunchApp == true &&
            launchDetails?.notificationResponse?.payload != null) {
          onNotificationPayload.value =
              launchDetails!.notificationResponse!.payload;
        }
      } catch (_) {}

      // 🔔 Android 8.0+ için MAX ÖNCELİKLİ Heads-Up Bildirim Kanalını Kaydet (v3)
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        const channel = AndroidNotificationChannel(
          'schedule_reminders_v3',
          'Plan ve Ders Hatırlatıcıları',
          description: 'Haftalık ajandanızdaki plan ve etkinlik hatırlatmaları',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color(0xFF4CAF50),
          showBadge: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        await androidImpl.createNotificationChannel(channel);

        const ongoingChannel = AndroidNotificationChannel(
          focusOngoingChannelId,
          'Aktif Odak Sayacı',
          description: 'Devam eden odaklanma seansı canlı bildirimi',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
          showBadge: false,
        );
        await androidImpl.createNotificationChannel(ongoingChannel);

        const completedChannel = AndroidNotificationChannel(
          focusCompletedChannelId,
          'Odak Seansı Tamamlandı',
          description: 'Odaklanma süresi dolduğunda çalan alarm ve bildirim',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color(0xFF2E7D32),
          showBadge: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        await androidImpl.createNotificationChannel(completedChannel);
      }

      _isInitialized = true;
    } catch (e, st) {
      ErrorLogger.log('NotificationService.init', e, st);
    }
  }

  /// Android 13+ ve iOS için bildirim izni ister
  Future<bool> requestPermissions() async {
    // 1. Android 13+ izni
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      if (granted != null) return granted;
    }

    // 2. iOS izni (IOSFlutterLocalNotificationsPlugin)
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted != null) return granted;
    }

    return true;
  }

  /// Belirli bir etkinlik için haftalık tekrarlayan veya tarihe bağlı yerel bildirim kurar
  Future<void> scheduleWeeklyNotification(ScheduleEvent event) async {
    if (!event.isNotificationEnabled || !event.hasSpecificTime) {
      await cancelNotification(event.id);
      return;
    }

    if (!_isInitialized) {
      await init();
    }
    if (!_isInitialized) return;

    // 🔒 GÜVENLİK: FNV-1a hash ile deterministik notification ID (çakışma minimize)
    final int notificationId = _fnv1aHash(event.id);

    // Hatırlatma vakti hesabı (dakika veya çoklu saat farklarını tam destekler)
    final int totalStartMinutes = event.startHour * 60 + event.startMinute;
    int totalTriggerMinutes = totalStartMinutes - event.reminderMinutesBefore;
    int dayOffset = 0;
    while (totalTriggerMinutes < 0) {
      totalTriggerMinutes += 24 * 60;
      dayOffset -= 1;
    }
    final int triggerHour = (totalTriggerMinutes ~/ 60) % 24;
    final int triggerMinute = totalTriggerMinutes % 60;
    int triggerDayOfWeek = event.dayOfWeek + dayOffset;
    while (triggerDayOfWeek < 1) {
      triggerDayOfWeek += 7;
    }
    while (triggerDayOfWeek > 7) {
      triggerDayOfWeek -= 7;
    }

    final androidDetails = AndroidNotificationDetails(
      'schedule_reminders_v3',
      'Plan ve Ders Hatırlatıcıları',
      channelDescription:
          'Haftalık ajandanızdaki plan ve etkinlik hatırlatmaları',
      importance: Importance.max,
      priority: Priority.max,
      ticker: event.title,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      enableLights: true,
      ledColor: const Color(0xFF4CAF50),
      ledOnMs: 1000,
      ledOffMs: 500,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = _scheduledDateForEvent(
      event,
      fallbackDayOfWeek: triggerDayOfWeek,
      fallbackHour: triggerHour,
      fallbackMinute: triggerMinute,
    );
    if (scheduledDate == null) {
      await cancelNotification(event.id);
      return;
    }

    // 🏷️ Bildirim Başlığı: Kullanıcının belirlediği plan adı (Örn: "Toplantı")
    final String title = event.title.trim().isNotEmpty
        ? event.title.trim()
        : 'Plan Hatırlatıcısı';

    // ⏱️ Bildirim İçeriği (Body): Başlangıç zamanı ve detay
    final String timingText;
    if (event.reminderMinutesBefore > 0) {
      final String reminderText = event.reminderMinutesBefore >= 60
          ? (event.reminderMinutesBefore % 60 == 0
              ? '${event.reminderMinutesBefore ~/ 60} saat'
              : '${event.reminderMinutesBefore ~/ 60} sa ${event.reminderMinutesBefore % 60} dk')
          : '${event.reminderMinutesBefore} dk';
      timingText = '$reminderText sonra başlıyor (${event.formattedTimeRange})';
    } else {
      timingText = 'Şimdi başlıyor (${event.formattedTimeRange})';
    }

    final String body = event.subtitle.trim().isNotEmpty
        ? '$timingText • ${event.subtitle.trim()}'
        : timingText;

    // 🔒 GÜVENLİK: Payload'da yalnızca eventId geçirilir, PII içermez.
    final String safePayload = 'eventId:${event.id}';

    try {
      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: safePayload,
        matchDateTimeComponents: event.dateStr == null
            ? DateTimeComponents.dayOfWeekAndTime
            : null,
      );
    } on Object catch (e, st) {
      ErrorLogger.log(
        'NotificationService.scheduleWeeklyNotification',
        e,
        st,
        'eventId=${event.id}',
      );
    }
  }

  /// Belirli bir etkinliğin bildirimini iptal eder
  Future<void> cancelNotification(String eventId) async {
    if (!_isInitialized) return;
    try {
      await _plugin.cancel(id: _fnv1aHash(eventId));
    } on Object catch (e, st) {
      ErrorLogger.log('NotificationService.cancelNotification', e, st, 'eventId=$eventId');
    }
  }

  /// Tüm etkinlik bildirimlerini topluca senkronize eder
  Future<void> syncAll(List<ScheduleEvent> events) async {
    if (!_isInitialized) {
      await init();
    }
    if (!_isInitialized) return;
    try {
      await _plugin.cancelAll();
      for (final event in events) {
        if (event.isNotificationEnabled) {
          await scheduleWeeklyNotification(event);
        }
      }
    } on Object catch (e, st) {
      ErrorLogger.log('NotificationService.syncAll', e, st);
    }
  }

  /// Bir sonraki hedef gün ve saati hesaplayan yardımcı fonksiyon
  tz.TZDateTime? _scheduledDateForEvent(
    ScheduleEvent event, {
    required int fallbackDayOfWeek,
    required int fallbackHour,
    required int fallbackMinute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    final eventDateStr = event.dateStr;

    if (eventDateStr == null || eventDateStr.isEmpty) {
      return _nextInstanceOfDayAndTime(
        fallbackDayOfWeek,
        fallbackHour,
        fallbackMinute,
      );
    }

    final parsedDate = DateTime.tryParse(eventDateStr);
    if (parsedDate == null) return null;

    final eventStart = tz.TZDateTime(
      tz.local,
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      event.startHour,
      event.startMinute,
    );

    final reminderTime = eventStart.subtract(
      Duration(minutes: event.reminderMinutesBefore),
    );

    // 🔔 Yalnızca kullanıcının seçtiği hatırlatma anı (örn: 10 dk önce -> 17:50) henüz gelmemişse bildir!
    // Hatırlatma vakti geçmişse asla ikinci kez veya etkinlik başlangıcında tekrar bildirim kurulmaz.
    // Kullanıcı ne zaman seçtiyse sadece o anda tek sefer bildirim gider.
    if (reminderTime.isAfter(now)) {
      return reminderTime;
    }

    // Hatırlatma vakti zaten geçmişse hiçbir şey planlama (tek seferlik bildirim kuralı)
    return null;
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(
    int targetDayOfWeek,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != targetDayOfWeek || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// 🔒 GÜVENLİK: FNV-1a 32-bit hash.
  /// `hashCode % N` modülosuna kıyasla UUID için çakışma oranı çok daha düşüktür.
  static int _fnv1aHash(String input) {
    const int fnvPrime = 16777619;
    int hash = 0x811c9dc5; // FNV offset basis
    for (final int byte in input.codeUnits) {
      hash ^= byte;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF; // Pozitif 32-bit int
  }

  /// 🔔 Anlık Heads-up bildirim gösterir (Örn: Kulüp canlı seans daveti)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
    int? notificationId,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'schedule_reminders_v3',
        'Plan ve Ders Hatırlatıcıları',
        channelDescription:
            'Haftalık ajandanızdaki plan ve etkinlik hatırlatmaları',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final id = notificationId ?? (DateTime.now().millisecondsSinceEpoch % 100000);
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e, st) {
      ErrorLogger.log('NotificationService.showImmediateNotification', e, st);
    }
  }

  /// Tüm planlanmış yerel bildirimleri iptal eder
  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (e, st) {
      ErrorLogger.log('NotificationService.cancelAllNotifications', e, st);
    }
  }

  /// ⏱️ Aktif odaklanma veya mola seansı için kilit ekranı & bildirim çekmecesi canlı geri sayım bildirimi
  Future<void> showFocusOngoingNotification({
    required DateTime targetEndTime,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await init();
    try {
      final androidDetails = AndroidNotificationDetails(
        focusOngoingChannelId,
        'Aktif Odak Sayacı',
        channelDescription: 'Devam eden odaklanma seansı canlı bildirimi',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        showWhen: true,
        when: targetEndTime.millisecondsSinceEpoch,
        usesChronometer: true,
        chronometerCountDown: true,
        icon: '@mipmap/ic_launcher',
        category: AndroidNotificationCategory.stopwatch,
        color: const Color(0xFF2E7D32),
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
        presentBanner: true,
        presentList: true,
        interruptionLevel: InterruptionLevel.passive,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        id: focusOngoingNotificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload ?? 'tab:focus',
      );
    } catch (e, st) {
      ErrorLogger.log('NotificationService.showFocusOngoingNotification', e, st);
    }
  }

  /// 🔔 Odak seansı süresi dolduğunda (00:00) çalacak yüksek öncelikli alarm/bildirim planlar
  Future<void> scheduleFocusCompletionNotification({
    required DateTime targetEndTime,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await init();
    try {
      if (targetEndTime.isBefore(DateTime.now())) return;

      final scheduledDate = tz.TZDateTime.from(targetEndTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        focusCompletedChannelId,
        'Odak Seansı Tamamlandı',
        channelDescription: 'Odaklanma süresi dolduğunda çalan alarm ve bildirim',
        importance: Importance.max,
        priority: Priority.max,
        ticker: 'Odak Seansı Tamamlandı!',
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
        enableLights: true,
        ledColor: Color(0xFF2E7D32),
        ledOnMs: 1000,
        ledOffMs: 500,
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.zonedSchedule(
        id: focusCompletionNotificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload ?? 'tab:focus',
      );
    } catch (e, st) {
      ErrorLogger.log('NotificationService.scheduleFocusCompletionNotification', e, st);
    }
  }

  /// 🛑 Odak canlı sayacı bildirimini (devam eden kronometreyi) kapatır
  Future<void> cancelFocusOngoingNotification() async {
    try {
      await _plugin.cancel(id: focusOngoingNotificationId);
    } catch (e, st) {
      ErrorLogger.log('NotificationService.cancelFocusOngoingNotification', e, st);
    }
  }

  /// 🛑 Tüm odak bildirimlerini (canlı sayaç ve zamanlanmış bitiş alarmı) temizler
  Future<void> cancelFocusNotifications() async {
    try {
      await _plugin.cancel(id: focusOngoingNotificationId);
      await _plugin.cancel(id: focusCompletionNotificationId);
    } catch (e, st) {
      ErrorLogger.log('NotificationService.cancelFocusNotifications', e, st);
    }
  }
}

