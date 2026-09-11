import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/achievement.dart';
import '../../../../core/widgets/bouncing_widget.dart';

/// 🔘 Calenda Modern Mineli Seramik Rozet (Unisex & Minimalist)
/// Tüm 18 başarı için pikseli pikseline aynı dış çerçeve formunu korur.
class ModernAchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final double size;
  final VoidCallback? onTap;
  final bool showLabel;

  const ModernAchievementBadge({
    super.key,
    required this.achievement,
    this.size = 64.0,
    this.onTap,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlocked = achievement.isUnlocked;
    final lang = Localizations.localeOf(context).languageCode;

    final badgeWidget = BouncingWidget(
      onTap: onTap,
      scaleFactor: 0.94,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // 1. Zemin rengi: Açıkta mat sıcak keten/fildişi, koyuda derin obsidyen
          color: isUnlocked
              ? (isDark ? const Color(0xFF142219) : const Color(0xFFFAF8F5))
              : (isDark ? const Color(0xFF111713) : const Color(0xFFF1F3EE)),
          // 2. Çerçeve: %100 özdeş kalınlıkta mat adaçayı / titanyum kontur
          border: Border.all(
            color: isUnlocked
                ? (isDark ? const Color(0xFF4C7D5C) : const Color(0xFF264E32))
                : (isDark ? const Color(0xFF25332A) : const Color(0xFFD6DFD2)),
            width: size >= 70 ? 3.0 : 2.2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF000000) : const Color(0xFF102E19))
                        .withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // İç dekoratif ince halka (İkili seramik pin efekti)
            Container(
              width: size * 0.82,
              height: size * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked
                      ? (isDark
                          ? const Color(0xFF33583E).withValues(alpha: 0.4)
                          : const Color(0xFF2E5E3A).withValues(alpha: 0.15))
                      : Colors.transparent,
                  width: 1.0,
                ),
              ),
            ),

            // Merkez İkon (Saf İllüstrasyon / Vektör)
            Opacity(
              opacity: isUnlocked ? 1.0 : 0.25,
              child: Icon(
                achievement.icon,
                size: size * 0.44,
                color: isUnlocked
                    ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF255233))
                    : (isDark ? const Color(0xFF6B7F72) : const Color(0xFF8C9B90)),
              ),
            ),

            // Kilitliyse: Üzerinde zarif ve minik 🔒 ikonu
            if (!isUnlocked)
              Positioned(
                bottom: size * 0.06,
                right: size * 0.06,
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B2620) : const Color(0xFFE2EBE0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF2C3E32) : const Color(0xFFCFDACB),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: size * 0.20,
                    color: isDark ? const Color(0xFF7A9684) : const Color(0xFF627B6B),
                  ),
                ),
              ),

            // Zincir Aşama Belirteci (Örn: 2/6 - sağ üstte minik nokta / rozet)
            if (achievement.chainTotal > 1 && isUnlocked)
              Positioned(
                top: size * 0.06,
                right: size * 0.06,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF25422E) : const Color(0xFFE2EEE2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF4C7D5C) : const Color(0xFFA5C9AF),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${achievement.chainIndex}',
                    style: TextStyle(
                      fontSize: size * 0.16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF98E8AD) : const Color(0xFF255433),
                      height: 1.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (!showLabel) return badgeWidget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        badgeWidget,
        const SizedBox(height: 6),
        SizedBox(
          width: size + 20,
          child: Text(
            achievement.getTitle(lang),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 11.5,
              fontWeight: isUnlocked ? FontWeight.w700 : FontWeight.w500,
              color: isUnlocked
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                  : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
          ),
        ),
      ],
    );
  }
}
