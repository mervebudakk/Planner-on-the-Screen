import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/vintage_framed_avatar.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/models/achievement.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../planner/providers/planner_provider.dart';
import '../widgets/all_achievements_sheet.dart';
import '../widgets/achievement_detail_sheet.dart';
import '../widgets/cozy_desk_section.dart';
import '../widgets/modern_achievement_badge.dart';
import '../widgets/share_cards/share_card_picker_sheet.dart';
import 'settings_screen.dart';

/// 👤 Calenda — Minimalist Kişisel Profil ve Haftalık Ritim Ekranı
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _textPrimary = AppColors.lightTextPrimary;
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  /// Kullanıcının kayıt tarihini seçili dil formatında döndürür
  String _getMemberSinceText(BuildContext context, DateTime? createdAt) {
    final date = createdAt ?? DateTime(2026, 9, 1);
    final l10n = context.l10n;
    final monthName = DateTimeUtils.getMonthName(date, locale: l10n.locale.languageCode);
    return l10n.memberSince(monthName, date.year);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: Selector<PlannerProvider, UserProfile>(
          selector: (_, p) => p.userProfile,
          builder: (context, user, _) {
            final cleanAnimal = user.avatarAnimal
                .replaceAll('01_', '')
                .replaceAll('02_', '')
                .replaceAll('03_', '')
                .replaceAll('04_', '')
                .replaceAll('05_', '')
                .replaceAll('06_', '')
                .replaceAll('07_', '');

            final animalAsset = 'assets/avatars/$cleanAnimal.webp';
            final accessoryAsset = user.avatarAccessory != 'none'
                ? 'assets/accessories/${user.avatarAccessory}.webp'
                : null;

            final hasValidUsername = user.username.isNotEmpty &&
                user.username != 'calenda_user' &&
                user.username != 'apple_user' &&
                user.username != 'misafir';
            final displayUsername = hasValidUsername ? '@${user.username}' : '';

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top > 0 ? 3.0 : 8.0,
                20,
                MediaQuery.of(context).padding.bottom + 84,
              ),
              children: [
                // ─── 1. ÜST BAR: SAĞ ÜSTTE PAYLAŞ VE AYARLAR BUTONLARI ───
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Studygram Paylaşım Butonu
                      BouncingWidget(
                        onTap: () {
                          AppHaptics.lightImpact();
                          ShareCardPickerSheet.show(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: isDark
                                ? Border.all(color: AppColors.darkBorder, width: 1.0)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.black : const Color(0xFF142814))
                                    .withValues(alpha: isDark ? 0.20 : 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.ios_share_rounded,
                              color: primaryText,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Ayarlar Butonu (3 çizgi)
                      BouncingWidget(
                        onTap: () {
                          AppHaptics.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: isDark
                                ? Border.all(color: AppColors.darkBorder, width: 1.0)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.black : const Color(0xFF142814))
                                    .withValues(alpha: isDark ? 0.20 : 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.menu_rounded,
                              color: primaryText,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── 2. PROFİL RESMİ VE BİLGİLERİ (INSTAGRAM STİLİ: SOLDA AVATAR, SAĞDA İSİM/KULLANICI ADI) ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Antika Vintage Çerçeveli Avatar
                      VintageFramedAvatar(
                        animalAsset: animalAsset,
                        accessoryAsset: accessoryAsset,
                        backgroundColor: AppColors.hexToColor(user.avatarBgColor),
                        height: 96,
                      ),
                      const SizedBox(width: 16),

                      // İsim Soyisim, Kullanıcı Adı ve Kayıt Tarihi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (user.firstName.trim().isNotEmpty) ...[
                              Text(
                                '${user.firstName} ${user.lastName}'.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sfProRounded(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: primaryText,
                                ),
                              ),
                              if (displayUsername.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  displayUsername,
                                  style: AppTypography.sfPro(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: mutedText,
                                  ),
                                ),
                              ],
                            ] else ...[
                              Text(
                                displayUsername.isNotEmpty
                                    ? displayUsername
                                    : (user.displayName.isNotEmpty ? user.displayName : ''),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sfProRounded(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: primaryText,
                                ),
                              ),
                            ],

                            const SizedBox(height: 4),

                            // Kayıt Olunan Tarih
                            Text(
                              _getMemberSinceText(context, user.createdAt),
                              style: AppTypography.sfPro(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: mutedText.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── 3. HAFTALIK RİTİM ───
                _WeeklyRhythmSection(
                  isDark: isDark,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  ctaColor: ctaColor,
                ),

                const SizedBox(height: 20),

                // ─── 4. THE COZY ROOM (GÜNCEL ODA) ───
                const CozyDeskSection(),

                const SizedBox(height: 20),

                // ─── 5. BAŞARI MADALYONLARI ───
                _ProfileAchievementsSection(
                  isDark: isDark,
                  primaryText: primaryText,
                  mutedText: mutedText,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ⚡ _WeeklyRhythmSection — Apple Health & Aesthetic Kart Formatında Haftalık Ritim
// ─────────────────────────────────────────────────────────────────────────────
class _WeeklyRhythmSection extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  final Color mutedText;
  final Color ctaColor;

  const _WeeklyRhythmSection({
    required this.isDark,
    required this.primaryText,
    required this.mutedText,
    required this.ctaColor,
  });

  String _formatDuration(BuildContext context, int minutes) {
    final l10n = context.l10n;
    if (minutes <= 0) return '0 ${l10n.minutesShort}';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '$mins ${l10n.minutesShort}';
    if (mins == 0) return '$hours ${l10n.hoursShort}';
    return '$hours ${l10n.hoursShort} $mins ${l10n.minutesShort}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlannerProvider>();
    final l10n = context.l10n;
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: todayIndex));
    final dayNames = List.generate(
      7,
      (i) => DateTimeUtils.getShortDayName(i + 1, locale: l10n.locale.languageCode),
    );

    final dayMinutesList = <int>[];
    int maxMins = 0;

    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final mins = provider.getFocusMinutesForDay(d);
      dayMinutesList.add(mins);
      if (mins > maxMins) maxMins = mins;
    }

    final totalWeekMinutes = dayMinutesList.fold<int>(0, (sum, m) => sum + m);

    // Çizgi doluluk oranı referans tavanı (en az 60 dk)
    final scaleMax = maxMins > 60 ? maxMins : 60;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF14241B).withValues(alpha: 0.38)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.85),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 1. BAŞLIK & SAĞ DAKİKA ROZETİ ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.weeklyRhythm,
                style: AppTypography.sfProRounded(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              if (totalWeekMinutes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3827) : const Color(0xFFE5EDE2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _formatDuration(context, totalWeekMinutes),
                    style: AppTypography.sfProRounded(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF8CEFA5) : ctaColor,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // ─── 2. DİKEY ÇİZGİLER (BAR CHART) ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final mins = dayMinutesList[index];
              final isToday = index == todayIndex;
              final fillRatio = (mins / scaleMax).clamp(0.0, 1.0);
              const barHeight = 86.0;

              return SizedBox(
                width: 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dakika Etiketi (0'dan büyükse)
                    SizedBox(
                      height: 14,
                      child: mins > 0
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                mins >= 60 ? '${(mins / 60).toStringAsFixed(1)}${l10n.hoursShort}' : '$mins${l10n.minutesShort}',
                                style: AppTypography.sfPro(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isToday
                                      ? (isDark ? const Color(0xFF8CEFA5) : ctaColor)
                                      : mutedText,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 4),

                    // Çizgi Kapsayıcısı
                    Container(
                      width: 14,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1D3024).withValues(alpha: 0.60)
                            : const Color(0xFFE2E9DF).withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Bugün için hafif pulsing arka plan çizgisi
                          if (isToday && fillRatio == 0)
                            Container(
                              width: 14,
                              height: 10,
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFF55C77A)
                                        : const Color(0xFF1B4D25))
                                    .withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          // Dolu Kısım
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            width: 14,
                            height: (barHeight * fillRatio).clamp(mins > 0 ? 10.0 : 0.0, barHeight),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isDark
                                    ? [
                                        const Color(0xFF389154),
                                        isToday ? const Color(0xFF6CE58C) : const Color(0xFF4CB36E),
                                      ]
                                    : [
                                        const Color(0xFF1B4D25),
                                        isToday ? const Color(0xFF3A8A4C) : const Color(0xFF2D6E3B),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: mins > 0
                                  ? [
                                      BoxShadow(
                                        color: (isDark
                                                ? const Color(0xFF55C77A)
                                                : const Color(0xFF0F2C14))
                                            .withValues(alpha: 0.20),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Gün İsmi (Pzt, Sal, ...)
                    Text(
                      dayNames[index],
                      style: AppTypography.sfPro(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isToday
                            ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                            : mutedText,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Bugün Noktası
                    Container(
                      width: 4.5,
                      height: 4.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday
                            ? (isDark ? const Color(0xFF66E384) : const Color(0xFF2E7D32))
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🏆 _ProfileAchievementsSection — Profil Başarı Madalyonları Önizleme Şeridi
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileAchievementsSection extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  final Color mutedText;

  const _ProfileAchievementsSection({
    required this.isDark,
    required this.primaryText,
    required this.mutedText,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF14241B).withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık & Tümü Gör Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        isTr ? 'Başarılar' : 'Achievements',
                        style: AppTypography.sfProRounded(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF223528) : const Color(0xFFEBF3E8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF35523E) : const Color(0xFFD3E2CF),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          '$unlockedCount/$totalCount',
                          style: AppTypography.sfProRounded(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                          ),
                        ),
                      ),
                    ],
                  ),
                  BouncingWidget(
                    onTap: () {
                      AppHaptics.lightImpact();
                      AllAchievementsSheet.show(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            isTr ? 'Tümü' : 'All',
                            style: AppTypography.sfProRounded(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Madalyonlar Yatay Satırı (Açılanlar başta, 3-4 tanesi ekranda, dokunulduğunda tümü veya detay açılır)
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: sortedList.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final achv = sortedList[index];
                    return ModernAchievementBadge(
                      achievement: achv,
                      size: 62,
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
