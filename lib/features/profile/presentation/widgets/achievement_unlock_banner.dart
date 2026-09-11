import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/achievement.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import 'achievement_detail_sheet.dart';

/// 🎊 Başarı Kazanım Bildirim Kartı (Non-Intrusive Floating Banner)
class AchievementUnlockBanner {
  static void show(BuildContext context, Achievement achievement) {
    AppHaptics.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final isEn = lang == 'en';

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16241B) : const Color(0xFF102E19),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF385542) : const Color(0xFF285435),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF285435),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  size: 22,
                  color: const Color(0xFF8CEFA5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? '🎉 Achievement Unlocked!' : '🎉 Yeni Başarı Açıldı!',
                      style: AppTypography.sfProRounded(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF8CEFA5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.getTitle(lang),
                      style: AppTypography.sfProRounded(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              BouncingWidget(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  AchievementDetailSheet.show(context, achievement);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CEFA5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isEn ? 'View' : 'İncele',
                    style: AppTypography.sfProRounded(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF102E19),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
