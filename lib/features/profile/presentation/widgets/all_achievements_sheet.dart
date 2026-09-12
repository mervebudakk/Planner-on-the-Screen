import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/achievement.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import 'achievement_detail_sheet.dart';
import 'modern_achievement_badge.dart';

/// 🏆 Tüm Başarı Madalyonları Galerisi (Modal Sheet)
class AllAchievementsSheet extends StatelessWidget {
  const AllAchievementsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AllAchievementsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final isTr = l10n.isTurkish;

    return ListenableBuilder(
      listenable: AchievementService.instance,
      builder: (context, _) {
        final achievements = AchievementService.instance.achievements;
        final unlockedCount = AchievementService.instance.unlockedCount;
        final totalCount = AchievementService.instance.totalCount;

        // Açılan madalyonlar en başta listelenir
        final sortedList = List<Achievement>.from(achievements)
          ..sort((a, b) {
            if (a.isUnlocked && !b.isUnlocked) return -1;
            if (!a.isUnlocked && b.isUnlocked) return 1;
            return 0;
          });

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141F17) : const Color(0xFFFAFBF8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? const Color(0xFF26382B) : const Color(0xFFDCE7D6),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tutma Çubuğu (Drag Handle)
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Başlık & Sayaç Rozeti
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isTr ? 'Başarı Madalyonları' : 'Achievement Medallions',
                      style: AppTypography.sfProRounded(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF223528)
                            : const Color(0xFFEBF3E8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF35523E)
                              : const Color(0xFFD3E2CF),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '$unlockedCount/$totalCount ${isTr ? "Açık" : "Unlocked"}',
                        style: AppTypography.sfProRounded(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFF8CEFA5)
                              : const Color(0xFF285435),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3 Sütunlu Grid
              Flexible(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: sortedList.length,
                  itemBuilder: (context, index) {
                    final achv = sortedList[index];
                    return ModernAchievementBadge(
                      achievement: achv,
                      size: 68,
                      showLabel: true,
                      onTap: () {
                        AppHaptics.lightImpact();
                        AchievementDetailSheet.show(context, achv);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
