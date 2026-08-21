import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../providers/planner_provider.dart';
import '../widgets/daily_timeline_list.dart';
import '../widgets/weekly_grid_bar.dart';
import 'edit_event_screen.dart';
import 'settings_screen.dart';
import 'widget_customizer_screen.dart';

/// Apple iOS Tarzı Buzlu Cam (Frosted Glass) ve Akrilik Haftalık Planlayıcı Ana Ekranı
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: AppleAmbientBackground(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 1. APPLE TARZI BUZLU CAM ÜST BAŞLIK & BUTONLAR ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Haftalık Planlayıcı',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  DateTimeUtils.formatFullDateHeader(provider.selectedDate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: provider.isSelectedDateToday
                                        ? AppColors.primary
                                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                  ),
                                ),
                                if (!provider.isSelectedDateToday) ...[
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: provider.selectToday,
                                    borderRadius: BorderRadius.circular(10),
                                    child: GlassContainer(
                                      blur: 10,
                                      opacity: isDark ? 0.35 : 0.85,
                                      borderRadius: BorderRadius.circular(10),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      child: const Text(
                                        'Bugüne Dön',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Widget Önizleme Butonu (Apple Glass İkon Butonu)
                            GlassContainer(
                              blur: 14,
                              opacity: isDark ? 0.30 : 0.70,
                              borderRadius: BorderRadius.circular(16),
                              padding: const EdgeInsets.all(3),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const WidgetCustomizerScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: Icon(
                                  Icons.widgets_outlined,
                                  size: 20,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // ⚙️ Ayarlar Butonu (Apple Glass İkon Butonu)
                            GlassContainer(
                              blur: 14,
                              opacity: isDark ? 0.30 : 0.70,
                              borderRadius: BorderRadius.circular(16),
                              padding: const EdgeInsets.all(3),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: Icon(
                                  Icons.settings_outlined,
                                  size: 20,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  // ─── 2. APPLE TARZI SAYDAM/KAYDIRILABİLİR GÜNLER BARI ───
                  const WeeklyGridBar(),

                  const SizedBox(height: 6),

                  // ─── 3. GÜNLÜK ZAMAN AKIŞI LİSTESİ ───
                  const Expanded(
                    child: DailyTimelineList(),
                  ),
                ],
              ),
            ),
          ),

          // ─── APPLE TARZI YÜZEN BUZLU CAM PLAN EKLEME BUTONU (FAB) ───
          floatingActionButton: const _AppleFloatingActionButton(),
        );
      },
    );
  }
}

/// Dokunulduğunda hafifçe yaylanan Apple tarzı buzlu cam Floating Action Button
class _AppleFloatingActionButton extends StatefulWidget {
  const _AppleFloatingActionButton();

  @override
  State<_AppleFloatingActionButton> createState() => _AppleFloatingActionButtonState();
}

class _AppleFloatingActionButtonState extends State<_AppleFloatingActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        final provider = context.read<PlannerProvider>();
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
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.38),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.88),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Plan Ekle',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
