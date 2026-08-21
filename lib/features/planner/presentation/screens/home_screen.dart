import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../providers/planner_provider.dart';
import '../widgets/daily_timeline_list.dart';
import '../widgets/weekly_grid_bar.dart';
import 'edit_event_screen.dart';
import 'settings_screen.dart';

/// 🍎 Calenda Apple iOS & Bento Grid Standartlarında Lüks Ana Ekran
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Saate göre selamlama metni
  String _getGreetingText(int hour) {
    if (hour >= 6 && hour < 12) {
      return 'Günaydın';
    } else if (hour >= 12 && hour < 18) {
      return 'İyi Günler';
    } else if (hour >= 18 && hour < 22) {
      return 'İyi Akşamlar';
    } else {
      return 'İyi Geceler';
    }
  }

  /// Sönük renkte sade çizim ikonu
  Widget _buildMutedGreetingIcon(int hour, Color color) {
    if (hour >= 6 && hour < 12) {
      return Icon(Icons.wb_sunny_outlined, size: 15, color: color);
    } else if (hour >= 12 && hour < 18) {
      return Icon(Icons.wb_cloudy_outlined, size: 15, color: color);
    } else if (hour >= 18 && hour < 22) {
      return Icon(Icons.wb_twilight_rounded, size: 15, color: color);
    } else {
      return Icon(Icons.nightlight_outlined, size: 15, color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentHour = DateTime.now().hour;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final monthName = DateTimeUtils.formatMonthYear(provider.selectedDate).split(' ').first;
        final isLoggedIn = provider.userProfile.isLoggedIn && provider.userProfile.name.trim().isNotEmpty;
        final userName = provider.userProfile.name.trim();

        // 🌿 Renkler
        final greetingMutedColor = isDark ? const Color(0xFF6B8E73) : const Color(0xFF7A9981);
        final nameDarkColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

        // 📊 Canlı İstatistikler
        final totalEventsCount = provider.events.length;
        final todayEventsCount = provider.currentDayEvents.length;
        final upcomingEventsCount = provider.currentDayEvents.where((e) => e.startHour >= currentHour).length;
        final reminderCount = provider.events.where((e) => e.isNotificationEnabled).length;

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: AppleAmbientBackground(
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ─── 1. ÜST BAŞLIK (SOLDA SELAMLAMA + SAĞDA DUAL TOGGLE) ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SOL: Selamlama ve İsim
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildMutedGreetingIcon(currentHour, greetingMutedColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getGreetingText(currentHour),
                                      style: AppTypography.sfPro(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: greetingMutedColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isLoggedIn ? userName : 'Calenda Ajanda',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.sfProRounded(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: nameDarkColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // SAĞ: İkili Apple Toggle & Tarih
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 44,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF14241B)
                                      : Colors.white.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? Colors.black : const Color(0xFF284834)).withValues(alpha: isDark ? 0.25 : 0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Takvim İkonu
                                    BouncingWidget(
                                      onTap: () => provider.selectDate(DateTimeUtils.today),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E3827) : Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.06),
                                              blurRadius: 6,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.calendar_month_rounded,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 4),

                                    // Dört Yuvarlaklı Araçlar İkonu
                                    BouncingWidget(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const SettingsScreen(),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.widgets_rounded,
                                            size: 18,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Ay Kapsülü
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF14241B)
                                      : Colors.white.withValues(alpha: 0.70),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  monthName,
                                  style: AppTypography.sfPro(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── 2. "CREATE NEW TASK" ANA EYLEM KAPSÜLÜ (H: 66px, R: 33px) ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: BouncingWidget(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditEventScreen(
                                initialDayOfWeek: provider.selectedDay,
                                initialDate: provider.selectedDate,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(33),
                        child: Container(
                          height: 66,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF14241B) : Colors.white,
                            borderRadius: BorderRadius.circular(33),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.black : const Color(0xFF284834)).withValues(alpha: isDark ? 0.25 : 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Sol Dairesel Rozet (46x46 Koyu Yeşil)
                              Container(
                                width: 46,
                                height: 46,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_calendar_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Orta Metin Grubu
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Yeni Plan Ekle',
                                      style: AppTypography.sfProRounded(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Haftalık akışınıza etkinlik oluşturun',
                                      style: AppTypography.sfPro(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: isDark ? AppColors.darkTextMuted : const Color(0xFF688770),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Sağ Ok İkonu
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 15,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── 3. ÖZET BENTO IZGARASI (SUMMARY 2x2 GRID) ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                      child: Text(
                        'Özet',
                        style: AppTypography.sfProRounded(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.62, // 98px / 160px
                      children: [
                        _buildSummaryBentoCard(
                          title: 'Toplam Plan',
                          count: '$totalEventsCount',
                          icon: Icons.work_outline_rounded,
                          badgeBgColor: isDark ? const Color(0xFF1B3B26) : const Color(0xFFE1F5E8),
                          iconColor: const Color(0xFF102E19),
                          isDark: isDark,
                        ),
                        _buildSummaryBentoCard(
                          title: 'Bugün',
                          count: '$todayEventsCount',
                          icon: Icons.calendar_today_rounded,
                          badgeBgColor: isDark ? const Color(0xFF1A334B) : const Color(0xFFE6EDF8),
                          iconColor: const Color(0xFF1E3A5F),
                          isDark: isDark,
                        ),
                        _buildSummaryBentoCard(
                          title: 'Devam Eden',
                          count: '$upcomingEventsCount',
                          icon: Icons.timer_outlined,
                          badgeBgColor: isDark ? const Color(0xFF3B1E2F) : const Color(0xFFF8EAF3),
                          iconColor: const Color(0xFF5B1A40),
                          isDark: isDark,
                        ),
                        _buildSummaryBentoCard(
                          title: 'Hatırlatıcı',
                          count: '$reminderCount',
                          icon: Icons.notifications_active_outlined,
                          badgeBgColor: isDark ? const Color(0xFF36321D) : const Color(0xFFF2F1DF),
                          iconColor: const Color(0xFF4A4418),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  // ─── 4. AKTİVİTE & ÇİZELGE BAŞLIĞI ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Haftalık Akış',
                            style: AppTypography.sfProRounded(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            DateTimeUtils.getFullDayName(provider.selectedDate.weekday),
                            style: AppTypography.sfPro(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── 5. 7 GÜNLÜK HAFTA ÇİZELGESİ (PZT -> PAZ) ───
                  const SliverToBoxAdapter(
                    child: WeeklyGridBar(),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 10),
                  ),

                  // ─── 6. YÜZEN BENTO GÜNLÜK AKIŞ HÜCRESİ ───
                  SliverToBoxAdapter(
                    child: Container(
                      height: 380,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF14241B) : const Color(0xFFF7FAF4),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : const Color(0xFF284834)).withValues(alpha: isDark ? 0.30 : 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: const DailyTimelineList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🧩 2x2 Özet Bento Kartı
  Widget _buildSummaryBentoCard({
    required String title,
    required String count,
    required IconData icon,
    required Color badgeBgColor,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14241B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF284834)).withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol Üst Dairesel Pastel İkon Rozeti (38x38)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: badgeBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 17,
              color: isDark ? Colors.white70 : iconColor,
            ),
          ),

          // Alt Metin ve Sayı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                title,
                style: AppTypography.sfPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF688770),
                ),
              ),
              Text(
                count,
                style: AppTypography.sfProRounded(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
