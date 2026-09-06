import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/bouncing_widget.dart';

/// 🏷️ Calenda — Odak Konusu Etiketi Seçici Alt Sayfası
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
    final cardColor = isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2);
    final primaryText = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A2B1D);
    final mutedText = isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A);
    final ctaColor = isDark ? AppColors.darkPrimary : const Color(0xFF0E260A);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sürükleme Çubuğu
            Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),

            // Başlık & Kapatma Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Odak Konusu',
                      style: AppTypography.sfProRounded(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bu seansta ne üzerine çalışacaksınız?',
                      style: AppTypography.sfPro(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: mutedText, size: 22),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Etiket Seçenekleri
            ...tags.map((tag) {
              final isSelected = activeTag == tag;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BouncingWidget(
                  onTap: () {
                    onTagSelected(tag);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF1E3326) : const Color(0xFFEBF3EA))
                          : (isDark ? const Color(0xFF18261E) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? AppColors.darkPrimary : const Color(0xFF6B9080))
                            : (isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                        width: isSelected ? 1.5 : 1.0,
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
                            tag,
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
