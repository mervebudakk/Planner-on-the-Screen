/// Merkezi hata kayıt servisi
/// Saldırı tespiti ve hata izleme için tüm önemli istisnalar buraya iletilir.
/// İleride Firebase Crashlytics veya Sentry entegrasyonu buraya eklenir.
class ErrorLogger {
  ErrorLogger._();

  /// Hata kaydeder. Release modunda sessiz çalışır; debug modunda konsola yazar.
  static void log(
    String source,
    Object error, [
    StackTrace? stackTrace,
    String? extraContext,
  ]) {
    assert(() {
      // Yalnızca debug build'de konsola yaz, release'te sessiz kal
      final msg = StringBuffer('[ERROR] [$source] $error');
      if (extraContext != null) msg.write(' | Context: $extraContext');
      if (stackTrace != null) msg.write('\n$stackTrace');
      // ignore: avoid_print
      print(msg.toString());
      return true;
    }());

    // İleride Firebase Crashlytics entegrasyonu buraya eklenecektir:
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: source);
  }

  /// Kritik bir güvenlik olayı için uyarı kaydeder.
  static void security(String message) {
    assert(() {
      // ignore: avoid_print
      print('[SECURITY WARNING] $message');
      return true;
    }());
  }
}
