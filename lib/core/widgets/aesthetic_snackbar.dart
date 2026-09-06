import 'package:flutter/material.dart';
import '../../core/constants/app_typography.dart';

/// 🌿 Uygulama genelinde kullanılan estetik SnackBar yardımcısı.
/// Apple HIG tarzında: yuvarlak ikon kapsülü + net beyaz mesaj + alt dock menüsünün üzerinde yüzen konum.
class AestheticSnackBar {
  AestheticSnackBar._();

  /// ✅ Başarı mesajı (Yeşil ✓ ikon)
  static void showSuccess(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.check_rounded, type: _SnackType.success);
  }

  /// ℹ️ Bilgi mesajı (Mavi ℹ ikon)
  static void showInfo(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.info_outline_rounded, type: _SnackType.info);
  }

  /// ⚠️ Uyarı mesajı (Turuncu ⚠ ikon)
  static void showWarning(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.warning_amber_rounded, type: _SnackType.warning);
  }

  /// ❌ Hata mesajı (Kırmızı ✕ ikon)
  static void showError(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.error_outline_rounded, type: _SnackType.error);
  }

  /// 🗑️ Silme mesajı (Kırmızı 🗑 ikon)
  static void showDelete(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.delete_outline_rounded, type: _SnackType.error);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required _SnackType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.maybeSizeOf(context)?.width ?? 400.0;
    // Geniş ekranda dock ile aynı hizada max 420px genişlik, mobilde 18px kenar boşluğu
    final horizontalMargin = screenWidth > 480
        ? (screenWidth - 420) / 2
        : (screenWidth < 360 ? 12.0 : 18.0);

    final Color bgColor;
    final Color borderColor;
    final Color iconBgColor;
    final Color iconColor;

    switch (type) {
      case _SnackType.success:
        bgColor = isDark ? const Color(0xFF14241B) : const Color(0xFF0E260A);
        borderColor = isDark ? const Color(0xFF2E4D37) : const Color(0xFF234B2D);
        iconBgColor = isDark ? const Color(0xFF2C6843) : const Color(0xFF1F4A24);
        iconColor = const Color(0xFF7CE49A);
        break;
      case _SnackType.info:
        bgColor = isDark ? const Color(0xFF162330) : const Color(0xFF0F253E);
        borderColor = isDark ? const Color(0xFF28405A) : const Color(0xFF1B3C60);
        iconBgColor = isDark ? const Color(0xFF2A4A6B) : const Color(0xFF1B406A);
        iconColor = const Color(0xFF93C5FD);
        break;
      case _SnackType.warning:
        bgColor = isDark ? const Color(0xFF2B2014) : const Color(0xFF33200C);
        borderColor = isDark ? const Color(0xFF4D3820) : const Color(0xFF553818);
        iconBgColor = isDark ? const Color(0xFF6B5020) : const Color(0xFF6B4818);
        iconColor = const Color(0xFFFCD34D);
        break;
      case _SnackType.error:
        bgColor = isDark ? const Color(0xFF281414) : const Color(0xFF301010);
        borderColor = isDark ? const Color(0xFF4D2525) : const Color(0xFF552020);
        iconBgColor = isDark ? const Color(0xFF682424) : const Color(0xFF6B2020);
        iconColor = const Color(0xFFFCA5A5);
        break;
    }

    // 📱 Alt Menüyü (Dock) Asla Örtmemesi İçin Güvenli Yükseklik Payı
    // Dock konumu: bottom 18px + height 66px = 84px.
    // 106px margin sayesinde dock'un 22px üzerinde ferahça yüzer.
    final bottomInset = MediaQuery.maybePaddingOf(context)?.bottom ?? 0.0;
    final bottomMargin = bottomInset + 106.0;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, bottomMargin),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: borderColor, width: 1.2),
        ),
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.sfProRounded(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: duration,
      ),
    );
  }
}

enum _SnackType { success, info, warning, error }
