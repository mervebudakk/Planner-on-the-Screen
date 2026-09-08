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
import '../../../planner/providers/planner_provider.dart';
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
                // ─── 1. ÜST BAR: BAŞLIK & SAĞ ÜSTTE 3 ÇİZGİ AYARLAR BUTONU ───
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.profile,
                        style: AppTypography.sfProRounded(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                        ),
                      ),
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
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: isDark
                                ? Border.all(color: AppColors.darkBorder, width: 1.0)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.black : const Color(0xFF142814))
                                    .withValues(alpha: isDark ? 0.20 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.menu_rounded,
                              color: primaryText,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ─── 2. PROFİL RESMİ (ÜST ORTA, ÇERÇEVELİ, ARKA KARTSIZ) ───
                Center(
                  child: Column(
                    children: [
                      // Antika Vintage Çerçeveli Avatar
                      VintageFramedAvatar(
                        animalAsset: animalAsset,
                        accessoryAsset: accessoryAsset,
                        backgroundColor: AppColors.hexToColor(user.avatarBgColor),
                        height: 135,
                      ),
                      const SizedBox(height: 14),

                      // İsim Soyisim (varsa) ve Kullanıcı Adı
                      if (user.firstName.trim().isNotEmpty) ...[
                        Text(
                          '${user.firstName} ${user.lastName}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sfProRounded(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                        if (displayUsername.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            displayUsername,
                            style: AppTypography.sfPro(
                              fontSize: 14,
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
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                      ],

                      const SizedBox(height: 5),

                      // Kayıt Olunan Tarih
                      Text(
                        _getMemberSinceText(context, user.createdAt),
                        style: AppTypography.sfPro(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── 3. HAFTALIK RİTİM (KARTSIZ, DOĞRUDAN PROFİLE ENTEGRE ÇİZGİ TABLOSU) ───
                _WeeklyRhythmSection(
                  isDark: isDark,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  ctaColor: ctaColor,
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
          // ─── 1. BAŞLIK ───
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 2),
              Text(
                totalWeekMinutes > 0
                    ? (l10n.isTurkish
                        ? 'Toplam: ${_formatDuration(context, totalWeekMinutes)} odak'
                        : 'Total: ${_formatDuration(context, totalWeekMinutes)} focused')
                    : (l10n.isTurkish
                        ? 'Bu hafta henüz odak kaydı yok'
                        : 'No focus recorded this week'),
                style: AppTypography.sfPro(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: mutedText,
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
