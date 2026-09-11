import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/achievement.dart';
import '../../../../core/models/desk_item.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import 'modern_achievement_badge.dart';
import 'share_cards/share_card_picker_sheet.dart';

/// 📜 Başarı Detay ve Paylaşım Bottom Sheet'i
class AchievementDetailSheet extends StatelessWidget {
  final Achievement achievement;

  const AchievementDetailSheet({
    super.key,
    required this.achievement,
  });

  static Future<void> show(BuildContext context, Achievement achievement) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AchievementDetailSheet(achievement: achievement),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final isEn = lang == 'en';
    final isUnlocked = achievement.isUnlocked;

    // Bağlı masa nesnesi
    DeskItem? linkedItem;
    if (achievement.deskItemId != null) {
      final allItems = AchievementService.instance.deskItems;
      for (final it in allItems) {
        if (it.id == achievement.deskItemId) {
          linkedItem = it;
          break;
        }
      }
    }

    final dateStr = achievement.unlockedAt != null
        ? DateFormat('d MMMM yyyy', isEn ? 'en_US' : 'tr_TR').format(achievement.unlockedAt!)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF142018) : const Color(0xFFFAFBF8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2B3F32) : const Color(0xFFDBE8D3),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tutamaç çizgisi
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF33463B) : const Color(0xFFD3DEC8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Büyük Rozet
          ModernAchievementBadge(
            achievement: achievement,
            size: 96.0,
          ),
          const SizedBox(height: 18),

          // Kategori & Aşama Rozeti
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF23382B) : const Color(0xFFE4EDE0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${achievement.getCategoryTitle(lang).toUpperCase()} • ${isEn ? 'STAGE' : 'AŞAMA'} ${achievement.chainIndex}/${achievement.chainTotal}',
              style: AppTypography.sfProRounded(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Başlık
          Text(
            achievement.getTitle(lang),
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Açıklama
          Text(
            achievement.getDescription(lang),
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),

          // İlerleme Çubuğu
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B281F) : const Color(0xFFF1F6EE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? const Color(0xFF2B3F32) : const Color(0xFFDEE8D9),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUnlocked
                          ? (isEn ? 'Completed' : 'Tamamlandı')
                          : (isEn ? 'Progress' : 'İlerleme'),
                      style: AppTypography.sfPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    Text(
                      '${achievement.currentProgress} / ${achievement.targetValue}',
                      style: AppTypography.sfProRounded(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isUnlocked
                            ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435))
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: achievement.progressRatio,
                    minHeight: 7,
                    backgroundColor: isDark ? const Color(0xFF283A2E) : const Color(0xFFD6E3D0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUnlocked
                          ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435))
                          : (isDark ? const Color(0xFF4C7D5C) : const Color(0xFF5E8B6B)),
                    ),
                  ),
                ),
                if (dateStr != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${isEn ? 'Unlocked on:' : 'Kazanıldı:'} $dateStr',
                      style: AppTypography.sfPro(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bağlı Çalışma Masası Nesnesi
          if (linkedItem != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B281F) : const Color(0xFFF1F6EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: linkedItem.accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      linkedItem.icon,
                      size: 20,
                      color: linkedItem.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'Desk Reward' : 'Masa Ödülü',
                          style: AppTypography.sfPro(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                        Text(
                          linkedItem.getName(lang),
                          style: AppTypography.sfProRounded(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                    size: 18,
                    color: isUnlocked
                        ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF2E6342))
                        : (isDark ? const Color(0xFF5E7364) : const Color(0xFF8C9B90)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Aksiyon Butonları
          Row(
            children: [
              if (isUnlocked) ...[
                Expanded(
                  child: BouncingWidget(
                    onTap: () {
                      Navigator.pop(context);
                      ShareCardPickerSheet.show(context, initialAchievement: achievement);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF285435) : const Color(0xFF224A2E),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF224A2E).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            isEn ? 'Share Card' : 'Kart Olarak Paylaş',
                            style: AppTypography.sfProRounded(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: BouncingWidget(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF202C23) : const Color(0xFFE4EDE0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isEn ? 'Close' : 'Kapat',
                      style: AppTypography.sfProRounded(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFB4D8C2) : const Color(0xFF2E5E3A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
