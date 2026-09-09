import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import 'bouncing_widget.dart';

/// 🌿 Calenda Bento ve Apple HIG tarzında estetik onay/uyarı diyaloğu.
/// Standart gri ve kaba sistem alert kutuları yerine organik matcha ve zarif cam estetiği sunar.
class AestheticDialog {
  AestheticDialog._();

  /// 🌸 Özel tasarımlı onay diyaloğu gösterir.
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    IconData? icon,
    Color? iconColor,
    bool? isStacked,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : const Color(0xFF102E19);
    final mutedText = isDark ? AppColors.darkTextMuted : const Color(0xFF556958);

    final resolvedIcon = icon ??
        (isDestructive ? Icons.delete_forever_rounded : Icons.info_outline_rounded);

    final resolvedConfirm = confirmText ?? 'Onayla';
    final resolvedCancel = cancelText ?? 'Vazgeç';

    // Uzun buton metinlerinde dikey hizalama, kısa metinlerde yan yana
    final bool shouldStack = isStacked ?? ((resolvedConfirm.length + resolvedCancel.length) > 15);

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: isDark ? 0.65 : 0.45),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: anim,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF15261B) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2E4D37).withValues(alpha: 0.6)
                        : const Color(0xFFE2EBE0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Rozet İkon
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isDestructive
                            ? (isDark ? const Color(0xFF381C20) : const Color(0xFFFDECEE))
                            : (isDark ? const Color(0xFF1F3526) : const Color(0xFFEAF2EB)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDestructive
                              ? (isDark ? const Color(0xFF5E262E) : const Color(0xFFF7CCD1))
                              : (isDark ? const Color(0xFF2F4F39) : const Color(0xFFD3E4D6)),
                          width: 1.1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          resolvedIcon,
                          color: iconColor ??
                              (isDestructive
                                  ? (isDark ? const Color(0xFFF87171) : const Color(0xFFD94A4A))
                                  : (isDark ? const Color(0xFFA8D5BA) : const Color(0xFF2D6A42))),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. Başlık
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.sfProRounded(
                        fontSize: 18.5,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. İçerik Açıklaması
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTypography.sfPro(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: mutedText,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Aksiyon Butonları
                    if (shouldStack) ...[
                      // Dikey Yığın (Uzun Metinler İçin)
                      BouncingWidget(
                        onTap: () => Navigator.of(ctx).pop(true),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDestructive
                                ? const Color(0xFFD94A4A)
                                : const Color(0xFF2E6B44),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (isDestructive
                                        ? const Color(0xFFD94A4A)
                                        : const Color(0xFF2E6B44))
                                    .withValues(alpha: 0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            resolvedConfirm,
                            style: AppTypography.sfProRounded(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      BouncingWidget(
                        onTap: () => Navigator.of(ctx).pop(false),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFEFF4ED),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFDFE8DD),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            resolvedCancel,
                            style: AppTypography.sfProRounded(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: mutedText,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Yatay Yan Yana (Kısa Metinler İçin)
                      Row(
                        children: [
                          Expanded(
                            child: BouncingWidget(
                              onTap: () => Navigator.of(ctx).pop(false),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 46,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFEFF4ED),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : const Color(0xFFDFE8DD),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  resolvedCancel,
                                  style: AppTypography.sfProRounded(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: mutedText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BouncingWidget(
                              onTap: () => Navigator.of(ctx).pop(true),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 46,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isDestructive
                                      ? const Color(0xFFD94A4A)
                                      : const Color(0xFF2E6B44),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDestructive
                                              ? const Color(0xFFD94A4A)
                                              : const Color(0xFF2E6B44))
                                          .withValues(alpha: 0.28),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  resolvedConfirm,
                                  style: AppTypography.sfProRounded(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
