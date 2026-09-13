import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/widgets/dynamic_hourglass_icon.dart';
import '../../../clubs/presentation/screens/club_hub_screen.dart';
import '../../../clubs/providers/club_provider.dart';
import '../../../focus/presentation/screens/focus_timer_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../routines/presentation/screens/routines_screen.dart';
import '../../providers/planner_provider.dart';
import '../widgets/daily_timeline_list.dart';
import '../widgets/weekly_grid_bar.dart';
import 'edit_event_screen.dart';

/// 🍎 Calenda — Masalsı Bento Grid & Alt Toolbox Navigasyonlu Ana Ekran
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentTabIndex = 0; // 0: Planlayıcı, 1: Odak, 2: Kulüpler, 3: Profil
  Timer? _minuteTicker;
  DateTime _lastObservedDate = DateTimeUtils.today;
  late final ValueNotifier<DateTime> _minuteNotifier;

  @override
  void initState() {
    super.initState();
    _minuteNotifier = ValueNotifier<DateTime>(DateTime.now());
    WidgetsBinding.instance.addObserver(this);
    NotificationService.onNotificationPayload.addListener(_handleNotificationPayload);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlannerProvider>().refreshOnResume();
        _handleNotificationPayload();
        context.read<ClubProvider>().checkAndReconcileActiveSession();
        context.read<ClubProvider>().reconcileLostSessionToday();
      }
    });

    // Gün ve dakika değişimini takip et (Yalnızca ilgili ikonlar izole güncellenir)
    _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final currentToday = DateTimeUtils.today;
      if (!DateTimeUtils.isSameDay(_lastObservedDate, currentToday)) {
        _lastObservedDate = currentToday;
        context.read<PlannerProvider>().refreshOnResume();
      }
      _minuteNotifier.value = DateTime.now();
    });
  }

  @override
  void dispose() {
    NotificationService.onNotificationPayload.removeListener(_handleNotificationPayload);
    _minuteTicker?.cancel();
    _minuteNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleNotificationPayload() {
    final payload = NotificationService.onNotificationPayload.value;
    if (payload != null && mounted) {
      if (payload.startsWith('tab:focus') || payload.startsWith('focus_')) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        setState(() {
          _currentTabIndex = 1; // Odak Sayacı sekmesine geç
        });
        NotificationService.onNotificationPayload.value = null;
      } else if (payload.startsWith('tab:clubs') || payload.startsWith('club_')) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        setState(() {
          _currentTabIndex = 2; // Kulüpler sekmesine geç
        });
        NotificationService.onNotificationPayload.value = null;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _lastObservedDate = DateTimeUtils.today;
      _minuteNotifier.value = DateTime.now();
      context.read<PlannerProvider>().refreshOnResume();
      context.read<ClubProvider>().checkAndReconcileActiveSession();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // 💓 KESİNTİSİZ ODAK KALBİ: Telefon aniden kapansa veya arka plana atılsa dahi son durumu kaydet
      context.read<ClubProvider>().flushProgressHeartbeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // isLoading değişince sadece bu kısım rebuild olur
    final isLoading = context.select<PlannerProvider, bool>((p) => p.isLoading);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Sekme Ekranları — RepaintBoundary her sekmeyi izole eder ──
          IndexedStack(
            index: _currentTabIndex,
            children: const [
              RepaintBoundary(child: _PlannerTabView()),
              RepaintBoundary(child: FocusTimerScreen()),
              RepaintBoundary(child: ClubHubScreen()),
              RepaintBoundary(child: ProfileScreen()),
            ],
          ),

          // ── 🛡️ ALT MENÜ KORUYUCU ARKA PLAN PERDESİ ──
          // Menünün altından kayan içeriklerin (madalyonlar, listeler vb.) görünmesini engeller
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: (MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom
                        : 16.0) +
                    72.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? const Color(0xFF0E1511) : const Color(0xFFFAFBF8))
                          .withValues(alpha: 0.0),
                      (isDark ? const Color(0xFF0E1511) : const Color(0xFFFAFBF8))
                          .withValues(alpha: 0.85),
                      isDark ? const Color(0xFF0E1511) : const Color(0xFFFAFBF8),
                      isDark ? const Color(0xFF0E1511) : const Color(0xFFFAFBF8),
                    ],
                    stops: const [0.0, 0.35, 0.70, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── 🧰 YÜZEN ALT TOOLBOX DOCK (APPLE BUZLU CAM DOCK) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom > 0
                ? (MediaQuery.of(context).padding.bottom * 0.45)
                : 8.0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _buildBottomToolbox(isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧰 Yüzen Alt Toolbox Navigasyon Barı (Apple Buzlu Cam & Dinamik İkonlar)
  Widget _buildBottomToolbox(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF15261C).withValues(alpha: 0.72)
                : Colors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.85),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF142918))
                    .withValues(alpha: isDark ? 0.35 : 0.07),
                blurRadius: 22,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToolboxItem(
                index: 0,
                label: context.l10n.tabPlanner,
                iconWidget: (color, isSelected) => ValueListenableBuilder<DateTime>(
                  valueListenable: _minuteNotifier,
                  builder: (context, _, child) => CalendarDateIcon(
                    size: 20.0,
                    color: color,
                    isSelected: isSelected,
                  ),
                ),
                isDark: isDark,
              ),
              _buildToolboxItem(
                index: 1,
                label: context.l10n.tabFocus,
                iconWidget: (color, isSelected) => ValueListenableBuilder<DateTime>(
                  valueListenable: _minuteNotifier,
                  builder: (context, time, child) => DynamicHourglassIcon(
                    size: 20.0,
                    color: color,
                    isSelected: isSelected,
                    customTime: time,
                  ),
                ),
                isDark: isDark,
              ),
              _buildToolboxItem(
                index: 2,
                label: context.l10n.tabClubs,
                iconWidget: (color, isSelected) => Icon(
                  Icons.diversity_3_rounded,
                  size: 20.0,
                  color: color,
                ),
                isDark: isDark,
              ),
              _buildToolboxItem(
                index: 3,
                label: context.l10n.tabProfile,
                iconWidget: (color, isSelected) => Icon(
                  Icons.person_rounded, // İçi dolu profil ikonu
                  size: 20.0,
                  color: color,
                ),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolboxItem({
    required int index,
    required String label,
    required Widget Function(Color color, bool isSelected) iconWidget,
    required bool isDark,
  }) {
    final isSelected = _currentTabIndex == index;

    // Apple tarzı seçili durum renkleri (Calenda matcha & sakin orman)
    final activeBg = isDark
        ? const Color(0xFF284834).withValues(alpha: 0.90)
        : const Color(0xFFE4EDE2);
    final activeBorder = isDark
        ? const Color(0xFF3C6648)
        : const Color(0xFFD0E0CC);
    final activeTextColor = isDark
        ? const Color(0xFF9CF0AC)
        : const Color(0xFF1E3E24);
    final inactiveTextColor = isDark
        ? const Color(0xFF86A08A)
        : const Color(0xFF6B806E);

    final color = isSelected ? activeTextColor : inactiveTextColor;

    return Expanded(
      child: BouncingWidget(
        onTap: () {
          if (_currentTabIndex != index) {
            AppHaptics.selectionClick();
            setState(() => _currentTabIndex = index);
          }
        },
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isSelected ? activeBorder : Colors.transparent,
              width: 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.black : const Color(0xFF1E3E24))
                          .withValues(alpha: isDark ? 0.22 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 22,
                child: Center(
                  child: iconWidget(color, isSelected),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.sfPro(
                  fontSize: 11.0,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 📅 _PlannerTabView — Planlayıcı & Rutinler Birleşik Sekmesi
// ─────────────────────────────────────────────────────────────────────────────
class _PlannerTabView extends StatefulWidget {
  const _PlannerTabView();

  @override
  State<_PlannerTabView> createState() => _PlannerTabViewState();
}

class _PlannerTabViewState extends State<_PlannerTabView> {
  int _subTabIndex = 0; // 0: Planlayıcı, 1: Rutinler

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _textPrimary = AppColors.lightTextPrimary;
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  String _getGreetingText(BuildContext context, int hour) {
    if (hour >= 6 && hour < 12) return context.l10n.goodMorning;
    if (hour >= 12 && hour < 18) return context.l10n.goodAfternoon;
    if (hour >= 18 && hour < 22) return context.l10n.goodEvening;
    return context.l10n.goodNight;
  }

  Widget _buildMutedGreetingIcon(int hour, Color color) {
    if (hour >= 6 && hour < 12) return Icon(Icons.wb_sunny_outlined, size: 16, color: color);
    if (hour >= 12 && hour < 18) return Icon(Icons.wb_cloudy_outlined, size: 16, color: color);
    if (hour >= 18 && hour < 22) return Icon(Icons.wb_twilight_rounded, size: 16, color: color);
    return Icon(Icons.nightlight_outlined, size: 16, color: color);
  }

  // ─── Takvim İkonu: Üstünde bugünün tarihi ───────────────────────────────
  Widget _buildCalendarDateIcon(bool forceWhite, bool isDark, Color ctaColor) {
    final today = DateTime.now().day;
    final iconColor = forceWhite
        ? Colors.white
        : (isDark ? const Color(0xFFB4D8C2) : ctaColor);
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 21, color: iconColor),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '$today',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: iconColor,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Rutinler İkonu: Tikli Görev İkonu ──────────────────────────────────
  Widget _buildRoutinesIcon(bool forceWhite, bool isDark, Color ctaColor) {
    final iconColor = forceWhite
        ? Colors.white
        : (isDark ? const Color(0xFFB4D8C2) : ctaColor);
    return Icon(
      Icons.task_alt_rounded,
      size: 21,
      color: iconColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hour = DateTime.now().hour;

    // Selector: sadece ihtiyaç duyulan alanlar değişince rebuild
    final selectedDate = context.select<PlannerProvider, DateTime>((p) => p.selectedDate);
    final userProfile = context.select<PlannerProvider, UserProfile>((p) => p.userProfile);

    final monthName = DateTimeUtils.getMonthName(selectedDate, locale: context.l10n.locale.languageCode);
    final isLoggedIn = userProfile.isLoggedIn && userProfile.name.trim().isNotEmpty;
    final userName = userProfile.displayName;

    final greetingColor = isDark ? const Color(0xFF8EBA9D) : _textMuted;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── HEADER (Kullanıcı Adı & Sağda İkili Toggle Kapsülü) ───
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top > 0 ? 3.0 : 8.0,
                20,
                10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Sol: Selamlama + Kullanıcı Adı (Her iki sekmede de sade ve tutarlı)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildMutedGreetingIcon(hour, greetingColor),
                            const SizedBox(width: 6),
                            Text(
                              _getGreetingText(context, hour),
                              style: AppTypography.sfPro(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: greetingColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLoggedIn ? userName : context.l10n.guestUser,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sfProRounded(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sağ: İkili Geçiş Toggle'ı (Takvim | Rutinler)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(26),
                      border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : const Color(0xFF142814))
                              .withValues(alpha: isDark ? 0.25 : 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Takvim / Planlayıcı Butonu
                        BouncingWidget(
                          onTap: () {
                            if (_subTabIndex != 0) {
                              setState(() => _subTabIndex = 0);
                            }
                          },
                          borderRadius: BorderRadius.circular(22),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _subTabIndex == 0 ? ctaColor : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: _buildCalendarDateIcon(_subTabIndex == 0, isDark, ctaColor),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Rutinler Butonu
                        BouncingWidget(
                          onTap: () {
                            if (_subTabIndex != 1) {
                              setState(() => _subTabIndex = 1);
                            }
                          },
                          borderRadius: BorderRadius.circular(22),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _subTabIndex == 1 ? ctaColor : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: _buildRoutinesIcon(_subTabIndex == 1, isDark, ctaColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── İÇERİK: PLANLAYICI veya RUTİNLER ───
            Expanded(
              child: IndexedStack(
                index: _subTabIndex,
                children: [
                  // 0: Planlayıcı Akışı
                  _buildPlannerContent(context, isDark, primaryText, mutedText, cardColor, ctaColor, monthName),
                  // 1: Rutinler Akışı
                  const RoutinesScreen(isEmbedded: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlannerContent(
    BuildContext context,
    bool isDark,
    Color primaryText,
    Color mutedText,
    Color cardColor,
    Color ctaColor,
    String monthName,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final dockOffset = (bottomPadding > 0 ? 4.0 : 10.0) + bottomPadding;
    final dockTotalHeight = dockOffset + 60.0;
    final cardBottomMargin = dockTotalHeight + 10.0;

    return Column(
      children: [
        // ─── CTA: YENİ PLAN EKLE ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BouncingWidget(
            onTap: () {
              final provider = context.read<PlannerProvider>();
              EditEventSheet.show(
                context,
                initialDayOfWeek: provider.selectedDay,
                initialDate: provider.selectedDate,
              );
            },
            borderRadius: BorderRadius.circular(26),
            child: Container(
              height: 66,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(26),
                border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF142814))
                        .withValues(alpha: isDark ? 0.30 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: ctaColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_calendar_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.addNewPlan,
                          style: AppTypography.sfProRounded(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.addNewPlanSubtitle,
                          style: AppTypography.sfPro(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── HAFTALIK PLANLAR & AY ROZETİ ───
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.l10n.weeklySchedule,
                style: AppTypography.sfProRounded(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : const Color(0xFF142814))
                          .withValues(alpha: isDark ? 0.25 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: isDark ? const Color(0xFFB4D8C2) : ctaColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      monthName,
                      style: AppTypography.sfProRounded(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ─── 7 GÜNLÜK HAFTA BARI ───
        const WeeklyGridBar(),
        const SizedBox(height: 6),

        // ─── GÜNLÜK PLAN LİSTESİ BENTO KARTI ───
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, cardBottomMargin),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(32),
              border: isDark
                  ? Border.all(color: AppColors.darkBorder, width: 1.0)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF142814))
                      .withValues(alpha: isDark ? 0.22 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(32)),
              child: DailyTimelineList(),
            ),
          ),
        ),
      ],
    );
  }
}

