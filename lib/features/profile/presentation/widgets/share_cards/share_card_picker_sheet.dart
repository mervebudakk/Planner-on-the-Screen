import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/models/achievement.dart';
import '../../../../../core/services/achievement_service.dart';
import '../../../../../core/services/share_card_service.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../core/utils/app_haptics.dart';
import '../../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../../core/widgets/bouncing_widget.dart';
import '../../../../planner/providers/planner_provider.dart';
import 'desk_showcase_card.dart';
import 'focus_milestone_card.dart';
import 'streak_card.dart';
import 'today_plan_card.dart';
import 'weekly_recap_card.dart';

/// 🎨 Studygram & Story Paylaşım Kartı Seçici Sheet
class ShareCardPickerSheet extends StatefulWidget {
  final Achievement? initialAchievement;

  const ShareCardPickerSheet({
    super.key,
    this.initialAchievement,
  });

  static Future<void> show(BuildContext context, {Achievement? initialAchievement}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareCardPickerSheet(initialAchievement: initialAchievement),
    );
  }

  @override
  State<ShareCardPickerSheet> createState() => _ShareCardPickerSheetState();
}

class _ShareCardPickerSheetState extends State<ShareCardPickerSheet> {
  final GlobalKey _cardKey = GlobalKey();
  int _selectedTemplateIndex = 0;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAchievement != null) {
      _selectedTemplateIndex = 1; // Odak Zaferi şablonu
    }
  }

  Future<void> _shareCard() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    AppHaptics.mediumImpact();

    try {
      final pngBytes = await ShareCardService.instance.captureWidgetToPng(_cardKey);
      if (pngBytes != null && mounted) {
        await ShareCardService.instance.shareStoryImage(pngBytes);
      } else if (mounted) {
        AestheticSnackBar.showError(context, 'Kart görseli oluşturulamadı.');
      }
    } catch (_) {
      if (mounted) {
        AestheticSnackBar.showError(context, 'Paylaşım esnasında bir sorun oluştu.');
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planner = context.watch<PlannerProvider>();
    final storage = StorageService.instance;
    final achievementService = AchievementService.instance;

    final profile = planner.userProfile;
    final weeklyMinutes = storage.getWeeklyFocusMinutes(DateTime.now());
    final totalWeeklyMin = weeklyMinutes.values.fold(0, (a, b) => a + b);
    final completedPlans = storage.getTotalCompletedPlans();

    final routines = storage.getRoutines();
    int maxStreak = 0;
    for (final r in routines) {
      if (r.streak > maxStreak) maxStreak = r.streak;
    }

    final totalHoursAll = (storage.getAllTimeFocusMinutes() / 60).ceil();

    final achievement = widget.initialAchievement ??
        achievementService.achievements.firstWhere(
          (a) => a.isUnlocked,
          orElse: () => achievementService.achievements.first,
        );

    final templates = [
      'Bu Haftam',
      'Odak Zaferi',
      'Günün Akışı',
      'Rutin Serisi',
      'Çalışma Masam',
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D16) : const Color(0xFFFAFBF8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF283A2E) : const Color(0xFFDBE8D3),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Tutamaç
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF33463B) : const Color(0xFFD3DEC8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Başlık Barı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Studygram Paylaşım Kartı',
                  style: AppTypography.sfProRounded(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ],
            ),
          ),

          // Şablon Seçici Yatay Liste
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: templates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedTemplateIndex == index;
                return BouncingWidget(
                  onTap: () {
                    AppHaptics.selectionClick();
                    setState(() => _selectedTemplateIndex = index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                          : (isDark ? const Color(0xFF1C2B21) : const Color(0xFFEBF2E8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      templates[index],
                      style: AppTypography.sfProRounded(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? (isDark ? const Color(0xFF102E19) : Colors.white)
                            : (isDark ? const Color(0xFF98BAA3) : const Color(0xFF38553F)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Canlı Kart Önizleme Alanı
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 330,
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: _buildCardContent(
                        index: _selectedTemplateIndex,
                        profile: profile,
                        totalWeeklyMin: totalWeeklyMin,
                        dailyMinutes: weeklyMinutes,
                        completedPlans: completedPlans,
                        achievement: achievement,
                        totalHoursAll: totalHoursAll,
                        todayEvents: planner.getEventsForDate(DateTime.now()),
                        maxStreak: maxStreak,
                        routines: routines,
                        deskItems: achievementService.deskItems,
                        unlockedCount: achievementService.unlockedCount,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Alt Paylaşım Butonu
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: BouncingWidget(
              onTap: _isSharing ? null : _shareCard,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF285435) : const Color(0xFF102E19),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF102E19).withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _isSharing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share_rounded, size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Hikayede Paylaş (Story / Post)',
                            style: AppTypography.sfProRounded(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent({
    required int index,
    required dynamic profile,
    required int totalWeeklyMin,
    required Map<int, int> dailyMinutes,
    required int completedPlans,
    required Achievement achievement,
    required int totalHoursAll,
    required dynamic todayEvents,
    required int maxStreak,
    required dynamic routines,
    required dynamic deskItems,
    required int unlockedCount,
  }) {
    switch (index) {
      case 0:
        return WeeklyRecapCard(
          profile: profile,
          totalWeeklyMinutes: totalWeeklyMin,
          dailyMinutes: dailyMinutes,
          completedPlansCount: completedPlans,
        );
      case 1:
        return FocusMilestoneCard(
          profile: profile,
          achievement: achievement,
          totalHours: totalHoursAll,
        );
      case 2:
        return TodayPlanCard(
          profile: profile,
          date: DateTime.now(),
          todayEvents: todayEvents,
        );
      case 3:
        return StreakCard(
          profile: profile,
          maxStreak: maxStreak,
          routines: routines,
        );
      case 4:
      default:
        return DeskShowcaseCard(
          profile: profile,
          deskItems: deskItems,
          unlockedAchievementCount: unlockedCount,
        );
    }
  }
}
