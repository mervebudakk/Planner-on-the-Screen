import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 📳 Güvenli Dokunsal Geri Bildirim (Haptic Feedback) Yöneticisi
/// Web ortamında Chrome [Intervention] Blocked call to navigator.vibrate
/// güvenlik uyarısını engeller, mobil cihazlarda (iOS & Android) donanımsal Taptic Engine'i tam performansla çalıştırır.
class AppHaptics {
  AppHaptics._();

  /// Seçim veya hafif buton tıklaması
  static void selectionClick() {
    if (!kIsWeb) {
      HapticFeedback.selectionClick();
    }
  }

  /// Hafif dokunma geri bildirimi
  static void lightImpact() {
    if (!kIsWeb) {
      HapticFeedback.lightImpact();
    }
  }

  /// Orta seviye dokunma geri bildirimi
  static void mediumImpact() {
    if (!kIsWeb) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Güçlü hata / uyarı dokunma geri bildirimi
  static void heavyImpact() {
    if (!kIsWeb) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Standart titreşim
  static void vibrate() {
    if (!kIsWeb) {
      HapticFeedback.vibrate();
    }
  }
}
