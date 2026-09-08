import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/bouncing_widget.dart';

/// 🏷️ Calenda — Odak Konusu Etiketi Seçici Alt Sayfası (Translucent & Minimalist)
class FocusTagPickerSheet extends StatelessWidget {
  final List<String> tags;
  final String activeTag;
  final ValueChanged<String> onTagSelected;

  const FocusTagPickerSheet({
    super.key,
    required this.tags,
    required this.activeTag,
    required this.onTagSelected,
  });

  static String getLocalizedTag(String tag, AppLocalizations l10n) {
    switch (tag) {
      case 'Ders & Çalışma':
        return l10n.tagStudy;
      case 'Proje & İş':
        return l10n.tagProject;
      case 'Kitap & Okuma':
        return l10n.tagReading;
      case 'Sakin Odak':
        return l10n.tagCalm;
      case 'Yaratıcı & Tasarım':
        return l10n.tagCreative;
      case 'Kodlama':
        return l10n.tagCoding;
      case 'Tasarım':
        return l10n.tagDesign;
      case 'Yazı':
        return l10n.tagWriting;
      case 'Çalışma':
        return l10n.tagWork;
      case 'Genel':
        return l10n.tagGeneral;
      default:
        return tag;
    }
  }

  static IconData getTagIcon(String tag) {
    switch (tag) {
      case 'Ders & Çalışma':
        return Icons.school_outlined;
      case 'Proje & İş':
        return Icons.work_outline_rounded;
      case 'Kitap & Okuma':
        return Icons.auto_stories_outlined;
      case 'Sakin Odak':
        return Icons.spa_outlined;
      case 'Yaratıcı & Tasarım':
        return Icons.palette_outlined;
      default:
        return Icons.label_outline_rounded;
    }
  }

  static void show(
    BuildContext context, {
    required List<String> tags,
    required String activeTag,
    required ValueChanged<String> onTagSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => FocusTagPickerSheet(
        tags: tags,
        activeTag: activeTag,
        onTagSelected: onTagSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A);
    final ctaColor = isDark ? AppColors.darkPrimary : const Color(0xFF0E260A);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF14241B).withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.85),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Sürükleme Çubuğu (Drag Handle)
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Sade ve Profesyonel Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.focusTopic,
                  style: AppTypography.sfProRounded(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primaryText,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, color: mutedText, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Etiket Seçenekleri (Saydam, Modern ve Sade)
            ...tags.map((tag) {
              final isSelected = activeTag == tag;
              final localizedTag = getLocalizedTag(tag, context.l10n);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BouncingWidget(
                  onTap: () {
                    onTagSelected(tag);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF24422F) : const Color(0xFFEFF6EE))
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.65)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? const Color(0xFF6B9E78) : const Color(0xFF1E3A1E))
                            : Colors.white.withValues(alpha: isDark ? 0.12 : 0.70),
                        width: isSelected ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ctaColor.withValues(alpha: isDark ? 0.25 : 0.12)
                                : (isDark ? Colors.white10 : const Color(0xFFF4F6F2)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            getTagIcon(tag),
                            size: 18,
                            color: isSelected ? (isDark ? AppColors.darkPrimary : ctaColor) : mutedText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localizedTag,
                            style: AppTypography.sfProRounded(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: isDark ? AppColors.darkPrimary : ctaColor,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
