import 'package:flutter/material.dart';
import '../../core/constants/app_typography.dart';

/// 🌿 Uygulama genelinde kullanılan estetik SnackBar yardımcısı.
/// Welcome SnackBar tarzında: yuvarlak ikon + mesaj + koyu yeşil tema.
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

  /// 🗑️ Silme mesajı (Kırmızı 🗑 ikon)
  static void showDelete(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.delete_outline_rounded, type: _SnackType.delete);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required _SnackType type,
    Duration duration = const Duration(seconds: 2),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.maybeSizeOf(context)?.width ?? 400.0;
    final horizontalMargin = (screenWidth < 360) ? 12.0 : 18.0;

    final Color bgColor;
    final Color borderColor;
    final Color iconBgColor;
    final Color iconColor;

    switch (type) {
      case _SnackType.success:
        bgColor = isDark ? const Color(0xFF18261E) : const Color(0xFF102E19);
        borderColor = isDark ? const Color(0xFF283D30) : const Color(0xFF234B2D);
        iconBgColor = isDark ? const Color(0xFF2C6843) : const Color(0xFF1E4627);
        iconColor = Colors.white;
        break;
      case _SnackType.info:
        bgColor = isDark ? const Color(0xFF18261E) : const Color(0xFF102E19);
        borderColor = isDark ? const Color(0xFF283D30) : const Color(0xFF234B2D);
        iconBgColor = isDark ? const Color(0xFF2A4A6B) : const Color(0xFF1B3A5C);
        iconColor = const Color(0xFF93C5FD);
        break;
      case _SnackType.warning:
        bgColor = isDark ? const Color(0xFF261E18) : const Color(0xFF2E2110);
        borderColor = isDark ? const Color(0xFF3D3028) : const Color(0xFF4B3D23);
        iconBgColor = isDark ? const Color(0xFF685C2C) : const Color(0xFF46391E);
        iconColor = const Color(0xFFFCD34D);
        break;
      case _SnackType.delete:
        bgColor = isDark ? const Color(0xFF261818) : const Color(0xFF2E1010);
        borderColor = isDark ? const Color(0xFF3D2828) : const Color(0xFF4B2323);
        iconBgColor = isDark ? const Color(0xFF682C2C) : const Color(0xFF461E1E);
        iconColor = const Color(0xFFFCA5A5);
        break;
    }

    final bottomInset = MediaQuery.maybePaddingOf(context)?.bottom ?? 0.0;
    final bottomMargin = bottomInset + 96.0;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, bottomMargin),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1.0),
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

enum _SnackType { success, info, warning, delete }
