import 'package:flutter/material.dart';
import '../../core/constants/app_typography.dart';
import '../utils/app_haptics.dart';
import 'bouncing_widget.dart';

/// 🌿 Uygulama genelinde kullanılan estetik SnackBar yardımcısı.
/// Apple HIG tarzında: yarı saydam buzlu cam kapsülü + pastel tonlar + ekranın en alt hizası.
class AestheticSnackBar {
  AestheticSnackBar._();

  /// ✅ Başarı mesajı
  static void showSuccess(BuildContext context, String message, {bool hasDock = true}) {
    _show(context, message: message, icon: Icons.check_rounded, type: _SnackType.success, hasDock: hasDock);
  }

  /// ℹ️ Bilgi mesajı
  static void showInfo(BuildContext context, String message, {bool hasDock = true}) {
    _show(context, message: message, icon: Icons.info_outline_rounded, type: _SnackType.info, hasDock: hasDock);
  }

  /// ⚠️ Uyarı mesajı
  static void showWarning(BuildContext context, String message, {bool hasDock = true}) {
    _show(context, message: message, icon: Icons.warning_amber_rounded, type: _SnackType.warning, hasDock: hasDock);
  }

  /// ❌ Hata mesajı
  static void showError(BuildContext context, String message, {bool hasDock = true}) {
    _show(context, message: message, icon: Icons.error_outline_rounded, type: _SnackType.error, hasDock: hasDock);
  }

  /// 🗑️ Silme mesajı (Geri Al butonlu)
  static void showDelete(
    BuildContext context,
    String message, {
    bool hasDock = true,
    VoidCallback? onUndo,
    String? undoLabel,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.delete_outline_rounded,
      type: _SnackType.error,
      hasDock: hasDock,
      duration: const Duration(seconds: 4),
      onUndo: onUndo,
      undoLabel: undoLabel,
    );
  }

  /// 🗓️ Yarına aktarma / erteleme mesajı (Geri Al butonlu)
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
      icon: Icons.update_rounded,
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
    bool hasDock = true,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onUndo,
    String? undoLabel,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.maybeSizeOf(context)?.width ?? 400.0;
    // Geniş ekranda max 420px genişlik, mobilde 16px kenar boşluğu
    final horizontalMargin = screenWidth > 480
        ? (screenWidth - 420) / 2
        : (screenWidth < 360 ? 12.0 : 16.0);

    final Color accentColor;
    final Color iconBgColor;

    switch (type) {
      case _SnackType.success:
        accentColor = isDark ? const Color(0xFF7FE29E) : const Color(0xFF266736);
        iconBgColor = accentColor.withValues(alpha: isDark ? 0.22 : 0.12);
        break;
      case _SnackType.info:
        accentColor = isDark ? const Color(0xFF90C2F7) : const Color(0xFF235582);
        iconBgColor = accentColor.withValues(alpha: isDark ? 0.22 : 0.12);
        break;
      case _SnackType.warning:
        accentColor = isDark ? const Color(0xFFFCD34D) : const Color(0xFF996716);
        iconBgColor = accentColor.withValues(alpha: isDark ? 0.22 : 0.12);
        break;
      case _SnackType.error:
        accentColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFC0392B);
        iconBgColor = accentColor.withValues(alpha: isDark ? 0.22 : 0.12);
        break;
      case _SnackType.transfer:
        accentColor = isDark ? const Color(0xFFF5B942) : const Color(0xFFB57018);
        iconBgColor = accentColor.withValues(alpha: isDark ? 0.22 : 0.12);
        break;
    }

    // 🌿 Apple Buzlu Cam Tasarımı: Temiz, ferah ve yüksek kontrastlı
    final Color bgColor = isDark
        ? const Color(0xFF1B261F).withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.96);
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFDFE8DF).withValues(alpha: 0.90);
    final Color textColor = isDark
        ? const Color(0xFFF0F5F1)
        : const Color(0xFF1B281E);

    // 📱 Ekranın En Altına Yakın, Yüzen Dock'un Tam Üzerinde Konumlanma
    final bottomInset = MediaQuery.maybePaddingOf(context)?.bottom ?? 0.0;
    final viewInsetsBottom = MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0.0;

    // 🧰 Alt dock yüksekliği ve konumu (Home ekranındaki Apple yüzen bar):
    // Dock tabanı: (bottomInset * 0.45) veya 8.0; Dock yüksekliği: 60.0;
    // Dock üst kenarı: ~75.3px (iPhone) veya ~68px (Android/Desktop)
    final dockTop = (bottomInset > 0 ? (bottomInset * 0.45) : 8.0) + 60.0;
    final baseBottomMargin = hasDock
        ? (dockTop + 14.0)
        : (bottomInset > 0 ? bottomInset + 12.0 : 18.0);
    final bottomMargin = viewInsetsBottom > 0 ? (viewInsetsBottom + 12.0) : baseBottomMargin;

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
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF14241B))
                    .withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: accentColor, size: 17),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.sfProRounded(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    height: 1.25,
                  ),
                  maxLines: 2,
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
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.24 : 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: accentColor.withValues(alpha: isDark ? 0.45 : 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.undo_rounded,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          undoLabel ?? 'Geri Al',
                          style: AppTypography.sfProRounded(
                            color: accentColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
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
