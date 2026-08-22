import 'dart:async';
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

/// 🍎 Calenda — Apple HIG & Bento Grid referansına birebir uygun Ana Ekran
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isSettingsActive = false;
  Timer? _minuteTicker;
  DateTime _lastObservedDate = DateTimeUtils.today;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 📍 Uygulama açılışında tam senkronizasyon (Bugünün günü, widget'lar ve bildirimler)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlannerProvider>().refreshOnResume();
      }
    });

    // ⏱️ Canlı Saat ve Gece Yarısı (00:00) Otomatik Takvim Döngüsü
    _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final currentToday = DateTimeUtils.today;
      if (!DateTimeUtils.isSameDay(_lastObservedDate, currentToday)) {
        _lastObservedDate = currentToday;
        context.read<PlannerProvider>().refreshOnResume();
      } else {
        setState(() {}); // Selamlama metnini ve saat ikonunu canlı tazele
      }
    });
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 📱 Uygulama ön plana geldiğinde her zaman BUGÜNE sıfırla ve servisleri tazele
      _lastObservedDate = DateTimeUtils.today;
      context.read<PlannerProvider>().refreshOnResume();
    }
  }

  String _getGreetingText(int hour) {
    if (hour >= 6 && hour < 12) return 'Günaydın';
    if (hour >= 12 && hour < 18) return 'İyi Günler';
    if (hour >= 18 && hour < 22) return 'İyi Akşamlar';
    return 'İyi Geceler';
  }

  Widget _buildMutedGreetingIcon(int hour, Color color) {
    if (hour >= 6 && hour < 12)  return Icon(Icons.wb_sunny_outlined,   size: 16, color: color);
    if (hour >= 12 && hour < 18) return Icon(Icons.wb_cloudy_outlined,  size: 16, color: color);
    if (hour >= 18 && hour < 22) return Icon(Icons.wb_twilight_rounded, size: 16, color: color);
    return Icon(Icons.nightlight_outlined, size: 16, color: color);
  }

  // ─── Renk sabitleri ─────────────────────────────────────────────────────────
  static const Color _cardBg      = Color(0xFFF8FAF5);
  static const Color _textPrimary = Color(0xFF1A2B1D);
  static const Color _textMuted   = Color(0xFF8B948A);
  static const Color _cta         = Color(0xFF0E260A);

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hour   = DateTime.now().hour;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final monthName    = DateTimeUtils.getMonthName(provider.selectedDate);
        final isLoggedIn   = provider.userProfile.isLoggedIn && provider.userProfile.name.trim().isNotEmpty;
        final userName     = provider.userProfile.name.trim();

        final greetingColor = isDark ? const Color(0xFF8EBA9D) : _textMuted;
        final primaryText   = isDark ? AppColors.darkTextPrimary  : _textPrimary;
        final mutedText     = isDark ? AppColors.darkTextMuted    : _textMuted;
        final cardColor     = isDark ? AppColors.darkSurface      : _cardBg;
        final ctaColor      = isDark ? AppColors.darkPrimary      : _cta;

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: AppleAmbientBackground(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ─── HEADER ─────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Sol: Selamlama + İsim
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildMutedGreetingIcon(hour, greetingColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getGreetingText(hour),
                                    style: AppTypography.sfPro(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: greetingColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isLoggedIn ? userName : 'Misafir Kullanıcı',
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

                        const SizedBox(width: 12),

                        // Sağ: TOGGLE PILL KAPSÜLÜ (AKICI VE BELİRGİN KAYMA ANİMASYONLU)
                        Container(
                          height: 52,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF15231B) : cardColor,
                            borderRadius: BorderRadius.circular(30),
                            border: isDark ? Border.all(color: const Color(0xFF2E4D37), width: 1.2) : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.07),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 88,
                            height: 42,
                            child: Stack(
                              children: [
                                // 🌿 Kayar Kapsül İndikatörü (Koyu Modda Canlı Işıltılı Zümrüt)
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeInOutCubic,
                                  alignment: _isSettingsActive
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF387A51) : _cta,
                                      shape: BoxShape.circle,
                                      border: isDark
                                          ? Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.0)
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDark ? const Color(0xFF387A51) : _cta)
                                              .withValues(alpha: isDark ? 0.55 : 0.35),
                                          blurRadius: isDark ? 12 : 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // 🔘 Tıklanabilir İkon Butonları
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // ── Takvim (Sol) ──
                                    BouncingWidget(
                                      onTap: () {
                                        if (_isSettingsActive) {
                                          setState(() => _isSettingsActive = false);
                                        }
                                        provider.selectDate(DateTimeUtils.today);
                                      },
                                      borderRadius: BorderRadius.circular(22),
                                      child: SizedBox(
                                        width: 42,
                                        height: 42,
                                        child: Center(
                                          child: _buildCalendarDateIcon(!_isSettingsActive, isDark),
                                        ),
                                      ),
                                    ),

                                    // ── Araçlar (Sağ) ──
                                    BouncingWidget(
                                      onTap: () async {
                                        setState(() => _isSettingsActive = true);
                                        await Navigator.of(context).push(
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(milliseconds: 240),
                                            reverseTransitionDuration: const Duration(milliseconds: 200),
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                const SettingsScreen(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              final curved = CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutCubic,
                                                reverseCurve: Curves.easeInCubic,
                                              );
                                              return FadeTransition(
                                                opacity: curved,
                                                child: SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: const Offset(0.04, 0),
                                                    end: Offset.zero,
                                                  ).animate(curved),
                                                  child: child,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                        if (mounted) {
                                          setState(() => _isSettingsActive = false);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(22),
                                      child: SizedBox(
                                        width: 42,
                                        height: 42,
                                        child: Center(
                                          child: _buildFourDotGrid(
                                            _isSettingsActive
                                                ? Colors.white
                                                : (isDark ? const Color(0xFF7A9981) : const Color(0xFF102E19)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── CTA: YENİ PLAN EKLE ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: BouncingWidget(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditEventScreen(
                            initialDayOfWeek: provider.selectedDay,
                            initialDate: provider.selectedDate,
                          ),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(28),
                          border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                          boxShadow: _cardShadow(isDark, strong: true),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: ctaColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_calendar_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Yeni Plan Ekle',
                                    style: AppTypography.sfProRounded(
                                      fontSize: 17.5,
                                      fontWeight: FontWeight.w700,
                                      color: primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Haftalık akışına etkinlik oluştur',
                                    style: AppTypography.sfPro(
                                      fontSize: 13.8,
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
                                size: 15,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── SECTION HEADER: HAFTALIK PLANLAR — sağda belirgin Ay Kapsülü ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Haftalık Planlar',
                          style: AppTypography.sfProRounded(
                            fontSize: 19,
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
                                color: isDark ? const Color(0xFFB4D8C2) : _cta,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                monthName,
                                style: AppTypography.sfProRounded(
                                  fontSize: 13.5,
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

                  // ─── 7 GÜNLÜK HAFTA BARI ─────────────────────────────────────
                  const WeeklyGridBar(),
                  const SizedBox(height: 6),

                  // ─── GÜNLÜK PLAN LİSTESİ BENTO KARTI (EKRANI TAM DOLDURAN & İÇTEN AKICI KAYAN) ───
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                        border: isDark ? const Border(
                          top: BorderSide(color: AppColors.darkBorder, width: 1.0),
                          left: BorderSide(color: AppColors.darkBorder, width: 1.0),
                          right: BorderSide(color: AppColors.darkBorder, width: 1.0),
                        ) : null,
                        boxShadow: _cardShadow(isDark, strong: false),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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

  // ─── Takvim İkonu: Üstünde bugünün tarihi ───────────────────────────────
  Widget _buildCalendarDateIcon(bool forceWhite, bool isDark) {
    final today = DateTime.now().day;
    final iconColor = forceWhite
        ? Colors.white
        : (isDark ? const Color(0xFFB4D8C2) : _cta);
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 22, color: iconColor),
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

  // ─── 4 Noktalı Grid İkonu (Büyük ve Sıkı Dairesel Noktalar) ──────────────
  Widget _buildFourDotGrid(Color color) {
    const double dotSize = 9.0;
    const double gap = 2.5;
    return SizedBox(
      width: dotSize * 2 + gap,
      height: dotSize * 2 + gap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(dotSize, color),
              const SizedBox(width: gap),
              _dot(dotSize, color),
            ],
          ),
          const SizedBox(height: gap),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(dotSize, color),
              const SizedBox(width: gap),
              _dot(dotSize, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  // ─── Tutarlı yumuşak kart gölgesi ────────────────────────────────────────
  static List<BoxShadow> _cardShadow(bool isDark, {required bool strong}) {
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF142814))
            .withValues(alpha: isDark ? (strong ? 0.30 : 0.22) : (strong ? 0.08 : 0.05)),
        blurRadius: strong ? 20 : 16,
        offset: const Offset(0, 6),
      ),
    ];
  }
}
