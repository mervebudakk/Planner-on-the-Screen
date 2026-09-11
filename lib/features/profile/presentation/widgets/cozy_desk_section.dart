import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/desk_item.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import 'achievement_detail_sheet.dart';
import 'modern_achievement_badge.dart';
import 'share_cards/share_card_picker_sheet.dart';

/// 🧸 The Cozy Desk & Başarılar Bölümü (Profil Ekranı Bento Kartı)
class CozyDeskSection extends StatelessWidget {
  const CozyDeskSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final isEn = lang == 'en';

    return ListenableBuilder(
      listenable: AchievementService.instance,
      builder: (context, _) {
        final achievements = AchievementService.instance.achievements;
        final deskItems = AchievementService.instance.deskItems;
        final unlockedCount = AchievementService.instance.unlockedCount;
        final totalCount = AchievementService.instance.totalCount;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF16231A).withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2C3E32).withValues(alpha: 0.8)
                  : const Color(0xFFDBE8D3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF102E19))
                    .withValues(alpha: isDark ? 0.35 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Başlık ve İlerleme Rozeti ──
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF263D2E) : const Color(0xFFE5EEE2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.table_restaurant_rounded,
                      size: 18,
                      color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'The Cozy Desk' : 'Çalışma Masam',
                          style: AppTypography.sfProRounded(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          isEn ? 'Earn rewards as you focus' : 'Odaklandıkça masan canlanır',
                          style: AppTypography.sfPro(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Paylaş Butonu
                  BouncingWidget(
                    onTap: () {
                      AppHaptics.lightImpact();
                      ShareCardPickerSheet.show(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF223528) : const Color(0xFFEAF2E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334F3D) : const Color(0xFFCFDFC9),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.ios_share_rounded,
                            size: 14,
                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isEn ? 'Share' : 'Paylaş',
                            style: AppTypography.sfProRounded(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sayaç Rozeti
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2C21) : const Color(0xFFE2EEE0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unlockedCount/$totalCount',
                      style: AppTypography.sfProRounded(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF255233),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── 2. İnteraktif Çalışma Masası Canvas'ı ──
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF121B15),
                            const Color(0xFF1A261E),
                            const Color(0xFF152018),
                          ]
                        : [
                            const Color(0xFFFAFBF8),
                            const Color(0xFFF3F7F0),
                            const Color(0xFFE8EFE5),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? const Color(0xFF283A2E) : const Color(0xFFD6E3D0),
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      return Stack(
                        children: [
                          // Arka Duvar Raf Çizgisi (Minimalist)
                          Positioned(
                            left: w * 0.10,
                            right: w * 0.10,
                            top: h * 0.26,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2B3D30) : const Color(0xFFDBE5D5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Ahşap Masa Ön Çizgisi
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: h * 0.32,
                            child: Container(
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2E4233) : const Color(0xFFD3E0CD),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Masa Nesneleri
                          ...deskItems.map((item) {
                            final isUnlocked = item.isUnlocked;
                            final posX = (item.normalizedX * w) - (item.size / 2);
                            final posY = (item.normalizedY * h) - (item.size / 2);

                            return Positioned(
                              left: posX.clamp(6.0, w - item.size - 6.0),
                              top: posY.clamp(6.0, h - item.size - 6.0),
                              child: BouncingWidget(
                                onTap: () {
                                  AppHaptics.selectionClick();
                                  _showItemInfo(context, item, isEn);
                                },
                                child: Container(
                                  width: item.size,
                                  height: item.size,
                                  decoration: BoxDecoration(
                                    color: isUnlocked
                                        ? (isDark
                                            ? item.accentColor.withValues(alpha: 0.25)
                                            : item.accentColor.withValues(alpha: 0.18))
                                        : (isDark
                                            ? const Color(0xFF1E2B22).withValues(alpha: 0.35)
                                            : const Color(0xFFE4EDE1).withValues(alpha: 0.4)),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isUnlocked
                                          ? item.accentColor.withValues(alpha: isDark ? 0.6 : 0.45)
                                          : (isDark ? const Color(0xFF2C3E32) : const Color(0xFFCAD8C5)),
                                      width: isUnlocked ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isUnlocked
                                        ? [
                                            BoxShadow(
                                              color: item.accentColor.withValues(alpha: 0.25),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    item.icon,
                                    size: item.size * 0.52,
                                    color: isUnlocked
                                        ? item.accentColor
                                        : (isDark ? const Color(0xFF5E7364) : const Color(0xFF8C9B90)),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── 3. Başarı Rozetleri Şeridi ──
              Text(
                isEn ? 'ACHIEVEMENTS' : 'BAŞARI MADALYONLARI',
                style: AppTypography.sfProRounded(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF38553F),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: achievements.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final achv = achievements[index];
                    return ModernAchievementBadge(
                      achievement: achv,
                      size: 64,
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

  void _showItemInfo(BuildContext context, DeskItem item, bool isEn) {
    final lang = isEn ? 'en' : 'tr';
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(item.icon, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${item.getName(lang)}: ${item.getDescription(lang)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF102E19),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
