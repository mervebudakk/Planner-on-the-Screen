import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/schedule_event.dart';
import 'error_logger.dart';

/// Cihazın yerel alarm motoru üzerinden internetsiz ve tam zamanında çalışan bildirim servisi.
///
/// 🔒 GÜVENLİK:
///  - Bildirim içeriği kilit ekranında gizlenir (NotificationVisibility.private).
///  - Payload yalnızca eventId taşır, PII içermez.
///  - FNV-1a hash ile notification ID çakışması minimize edilir.
///  - Tüm hatalar ErrorLogger'a iletilir; sessiz yutma yok.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Bildirim servisini başlatır
  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

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
        // Bildirime tıklandığında yapılacak işlemler.
        // 🔒 Payload'da yalnızca eventId bulunur, PII içermez.
      },
    );

    _isInitialized = true;
  }

  /// Android 13+ ve iOS için bildirim izni ister
  Future<bool> requestPermissions() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      return (await androidImpl.requestNotificationsPermission()) ?? false;
    }

    // iOS: IOSFlutterLocalNotificationsPlugin (v22'de Darwin yerine iOS kullanılıyor)
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      return (await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          )) ??
          false;
    }

    return true;
  }

  /// Belirli bir etkinlik için haftalık tekrarlayan yerel bildirim kurar
  Future<void> scheduleWeeklyNotification(ScheduleEvent event) async {
    if (!event.isNotificationEnabled) {
      await cancelNotification(event.id);
      return;
    }

    // 🔒 GÜVENLİK: FNV-1a hash ile deterministik notification ID (çakışma minimize)
    final int notificationId = _fnv1aHash(event.id);

    // Hatırlatma vakti hesabı (bitiş saati kontrolü ile gece yarısı geçişi)
    int triggerHour = event.startHour;
    int triggerMinute = event.startMinute - event.reminderMinutesBefore;
    while (triggerMinute < 0) {
      triggerMinute += 60;
      triggerHour -= 1;
    }
    if (triggerHour < 0) triggerHour += 24;

    // 🔒 GÜVENLİK: visibility=private → Kilit ekranında yalnızca genel bir başlık
    // görünür, ders adı ve lokasyon bilgisi gizlenir.
    final androidDetails = AndroidNotificationDetails(
      'schedule_reminders',
      'Ders ve Görev Hatırlatıcıları',
      channelDescription:
          'Haftalık programınızdaki ders ve etkinlik hatırlatmaları',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      visibility: NotificationVisibility.private,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = _nextInstanceOfDayAndTime(
      event.dayOfWeek,
      triggerHour,
      triggerMinute,
    );

    final String title = event.reminderMinutesBefore > 0
        ? '${event.reminderMinutesBefore} dk sonra: ${event.title}'
        : 'Şimdi başlıyor: ${event.title}';

    final String body = event.subtitle.isNotEmpty
        ? '${event.subtitle} • (${event.formattedTimeRange})'
        : event.formattedTimeRange;

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
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } on Object catch (e, st) {
      // 🔒 Sessiz yutma yerine merkezi hata kaydı
      ErrorLogger.log(
          'NotificationService.scheduleWeeklyNotification', e, st,
          'eventId=${event.id}');
    }
  }

  /// Belirli bir etkinliğin bildirimini iptal eder
  Future<void> cancelNotification(String eventId) async {
    try {
      await _plugin.cancel(id: _fnv1aHash(eventId));
    } on Object catch (e, st) {
      ErrorLogger.log('NotificationService.cancelNotification', e, st, 'eventId=$eventId');
    }
  }

  /// Tüm etkinlik bildirimlerini topluca senkronize eder
  Future<void> syncAll(List<ScheduleEvent> events) async {
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
  tz.TZDateTime _nextInstanceOfDayAndTime(
      int targetDayOfWeek, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduled.weekday != targetDayOfWeek ||
        scheduled.isBefore(now)) {
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
}
