import 'package:flutter/foundation.dart';

/// Merkezi hata kayıt servisi (Fix #16)
/// Tüm önemli istisnalar buraya iletilir.
/// Bellekte son 50 hatayı saklar; debug modunda konsola yazar,
/// production'da crash raporlama kancalarına hazırdır.
class ErrorLogger {
  ErrorLogger._();

  static final List<Map<String, dynamic>> _recentLogs = [];
  static const int _maxLogHistory = 50;

  /// Son kaydedilen hataları döner (Geri bildirim veya hata teşhisi için)
  static List<Map<String, dynamic>> get recentLogs => List.unmodifiable(_recentLogs);

  /// Hata kaydeder.
  static void log(
    String source,
    Object error, [
    StackTrace? stackTrace,
    String? extraContext,
  ]) {
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'source': source,
      'error': error.toString(),
      'context': extraContext,
      'stackTrace': stackTrace?.toString(),
    };

    _recentLogs.add(entry);
    if (_recentLogs.length > _maxLogHistory) {
      _recentLogs.removeAt(0);
    }

    if (kDebugMode) {
      final msg = StringBuffer('[ERROR] [$source] $error');
      if (extraContext != null) msg.write(' | Context: $extraContext');
      if (stackTrace != null) msg.write('\n$stackTrace');
      debugPrint(msg.toString());
    }

    // Production Crashlytics / Sentry kancası:
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: source, fatal: false);
  }

  /// Kritik bir güvenlik olayı için uyarı kaydeder.
  static void security(String message) {
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'SECURITY_WARNING',
      'message': message,
    };
    _recentLogs.add(entry);
    if (_recentLogs.length > _maxLogHistory) {
      _recentLogs.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('[SECURITY WARNING] $message');
    }
  }
}
