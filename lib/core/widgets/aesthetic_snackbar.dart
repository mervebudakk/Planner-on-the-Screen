import 'package:flutter/material.dart';
import '../../core/constants/app_typography.dart';
import '../utils/app_haptics.dart';
import 'bouncing_widget.dart';

/// 🌿 Uygulama genelinde kullanılan estetik SnackBar yardımcısı.
/// Apple HIG tarzında: yarı saydam buzlu cam kapsülü + pastel tonlar + ekranın en alt hizası.
class AestheticSnackBar {
  AestheticSnackBar._();

  /// ✅ Başarı mesajı
  static void showSuccess(BuildContext context, String message, {bool hasDock = false}) {
    _show(context, message: message, icon: Icons.check_rounded, type: _SnackType.success, hasDock: hasDock);
  }

  /// ℹ️ Bilgi mesajı
  static void showInfo(BuildContext context, String message, {bool hasDock = false}) {
    _show(context, message: message, icon: Icons.info_outline_rounded, type: _SnackType.info, hasDock: hasDock);
  }

  /// ⚠️ Uyarı mesajı
  static void showWarning(BuildContext context, String message, {bool hasDock = false}) {
    _show(context, message: message, icon: Icons.warning_amber_rounded, type: _SnackType.warning, hasDock: hasDock);
  }

  /// ❌ Hata mesajı
  static void showError(BuildContext context, String message, {bool hasDock = false}) {
    _show(context, message: message, icon: Icons.error_outline_rounded, type: _SnackType.error, hasDock: hasDock);
  }

  /// 🗑️ Silme mesajı
  static void showDelete(
    BuildContext context,
    String message, {
    bool hasDock = false,
    VoidCallback? onUndo,
    String? undoLabel,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.delete_outline_rounded,
      type: _SnackType.error,
      hasDock: hasDock,
      onUndo: onUndo,
      undoLabel: undoLabel,
    );
  }

  /// 🗓️ Yarına aktarma / erteleme mesajı (Geri al butonlu)
  static void showTransfer(
    BuildContext context,
    String message, {
    bool hasDock = true,
    VoidCallback? onUndo,
    String? undoLabel,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.next_plan_outlined,
      type: _SnackType.transfer,
      hasDock: hasDock,
      duration: const Duration(seconds: 4),
      onUndo: onUndo,
      undoLabel: undoLabel,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required _SnackType type,
    bool hasDock = false,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onUndo,
    String? undoLabel,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.maybeSizeOf(context)?.width ?? 400.0;
    // Geniş ekranda max 420px genişlik, mobilde 18px kenar boşluğu
    final horizontalMargin = screenWidth > 480
        ? (screenWidth - 420) / 2
        : (screenWidth < 360 ? 12.0 : 18.0);

    final Color bgColor;
    final Color borderColor;
    final Color iconBgColor;
    final Color iconColor;
    final Color textColor;

    switch (type) {
      case _SnackType.success:
        bgColor = isDark
            ? const Color(0xFF1B2D21).withValues(alpha: 0.90)
            : const Color(0xFFF3F7F2).withValues(alpha: 0.94);
        borderColor = isDark
            ? const Color(0xFF32563C).withValues(alpha: 0.50)
            : const Color(0xFFC2D9C6).withValues(alpha: 0.55);
        iconBgColor = isDark
            ? const Color(0xFF24472F)
            : const Color(0xFFDFEDE1);
        iconColor = isDark
            ? const Color(0xFF8CE4A4)
            : const Color(0xFF255B32);
        textColor = isDark
            ? const Color(0xFFE4EDE6)
            : const Color(0xFF1A3822);
        break;
      case _SnackType.info:
        bgColor = isDark
            ? const Color(0xFF172533).withValues(alpha: 0.90)
            : const Color(0xFFF2F6FA).withValues(alpha: 0.94);
        borderColor = isDark
            ? const Color(0xFF2B4765).withValues(alpha: 0.50)
            : const Color(0xFFC0D6EC).withValues(alpha: 0.55);
        iconBgColor = isDark
            ? const Color(0xFF213B56)
            : const Color(0xFFDFEDF8);
        iconColor = isDark
            ? const Color(0xFF90C2F7)
            : const Color(0xFF235582);
        textColor = isDark
            ? const Color(0xFFE3EDF6)
            : const Color(0xFF193650);
        break;
      case _SnackType.warning:
        bgColor = isDark
            ? const Color(0xFF2C2216).withValues(alpha: 0.90)
            : const Color(0xFFFAF7F0).withValues(alpha: 0.94);
        borderColor = isDark
            ? const Color(0xFF574128).withValues(alpha: 0.50)
            : const Color(0xFFEADBBE).withValues(alpha: 0.55);
        iconBgColor = isDark
            ? const Color(0xFF47341D)
            : const Color(0xFFF8ECDA);
        iconColor = isDark
            ? const Color(0xFFFCD34D)
            : const Color(0xFF8B5E1A);
        textColor = isDark
            ? const Color(0xFFF7EFE3)
            : const Color(0xFF4A3414);
        break;
      case _SnackType.error:
        bgColor = isDark
            ? const Color(0xFF2C1616).withValues(alpha: 0.90)
            : const Color(0xFFFAF2F2).withValues(alpha: 0.94);
        borderColor = isDark
            ? const Color(0xFF5B2B2B).withValues(alpha: 0.50)
            : const Color(0xFFECC2C2).withValues(alpha: 0.55);
        iconBgColor = isDark
            ? const Color(0xFF4B1F1F)
            : const Color(0xFFFCE1E1);
        iconColor = isDark
            ? const Color(0xFFFCA5A5)
            : const Color(0xFF9E2A2B);
        textColor = isDark
            ? const Color(0xFFF7EAEA)
            : const Color(0xFF541819);
        break;
      case _SnackType.transfer:
        bgColor = isDark
            ? const Color(0xFF2C2216).withValues(alpha: 0.90)
            : const Color(0xFFFAF6EE).withValues(alpha: 0.94);
        borderColor = isDark
            ? const Color(0xFF5A4122).withValues(alpha: 0.50)
            : const Color(0xFFEADBBE).withValues(alpha: 0.55);
        iconBgColor = isDark
            ? const Color(0xFF4A3416)
            : const Color(0xFFF7ECDA);
        iconColor = isDark
            ? const Color(0xFFE5A958)
            : const Color(0xFFB87825);
        textColor = isDark
            ? const Color(0xFFF5ECE0)
            : const Color(0xFF452E10);
        break;
    }

    // 📱 Ekranın En Altına Yakın, iOS Home Çubuğunun Hemen Üzerinde Konumlanma
    final bottomInset = MediaQuery.maybePaddingOf(context)?.bottom ?? 0.0;
    final bottomMargin = hasDock
        ? bottomInset + 76.0
        : (bottomInset > 0 ? bottomInset + 8.0 : 16.0);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, bottomMargin),
        padding: EdgeInsets.zero,
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF14241B))
                    .withValues(alpha: isDark ? 0.30 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.sfProRounded(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onUndo != null) ...[
                const SizedBox(width: 10),
                BouncingWidget(
                  onTap: () {
                    AppHaptics.mediumImpact();
                    try {
                      onUndo();
                    } finally {
                      messenger.hideCurrentSnackBar();
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: iconColor.withValues(alpha: isDark ? 0.45 : 0.28),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      undoLabel ?? 'Geri Al',
                      style: AppTypography.sfProRounded(
                        color: iconColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.0,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _SnackType { success, info, warning, error, transfer }
