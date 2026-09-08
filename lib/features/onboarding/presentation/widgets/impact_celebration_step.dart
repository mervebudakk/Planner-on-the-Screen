import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../models/onboarding_state.dart';

/// ✨ Adım 4: Masalsı Yıllık Hedef Projeksiyonu
class ImpactCelebrationStep extends StatefulWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const ImpactCelebrationStep({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  State<ImpactCelebrationStep> createState() => _ImpactCelebrationStepState();
}

class _ImpactCelebrationStepState extends State<ImpactCelebrationStep>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flowController;
  late Animation<double> _glowAnimation;
  late final List<Widget> _hourglassWidgets;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _glowAnimation = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _hourglassWidgets = [
      for (final frame in AppAssets.kawaiiHourglassFrames)
        Image.asset(
          frame,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          filterQuality: FilterQuality.high,
        ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final frame in AppAssets.kawaiiHourglassFrames) {
      precacheImage(AssetImage(frame), context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);

    final days = widget.state.weeklyGoalDays;
    final mins = widget.state.dailyFocusMinutes;
    final isFreeMode = days == 0 || mins == 0;

    final hoursPerWeek = (days * mins) / 60.0;
    final hoursPerYear = (hoursPerWeek * 52).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
              const SizedBox(height: 16),

              if (isFreeMode)
                Text(
                  'Zamanını kendi akışında\nplanlayabilirsin',
                  textAlign: TextAlign.center,
                  style: AppTypography.sfProRounded(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hedeflerine uyarak yılda',
                      textAlign: TextAlign.center,
                      style: AppTypography.sfProRounded(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$hoursPerYear+',
                      textAlign: TextAlign.center,
                      style: AppTypography.sfProRounded(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFB82846),
                        letterSpacing: -1.0,
                      ).copyWith(
                        shadows: [
                          BoxShadow(
                            color: const Color(0xFFB82846).withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'saat odaklanabilirsin',
                      textAlign: TextAlign.center,
                      style: AppTypography.sfProRounded(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 6),

              // ── Alt Başlık (Önceki ekranlarla birebir uyumlu) ──
              Text(
                isFreeMode
                    ? 'Hedef ve süre baskısı olmadan huzurlu bir ritim yakala.'
                    : 'Minimum odak hedefinle yılda harika bir birikim yapacaksın.',
                textAlign: TextAlign.center,
                style: AppTypography.sfPro(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 12),

              // ── ⏳ MASALSI ANTİKA KUM SAATİ (Tam Ekran Ortasında & Büyütülmüş) ──
              Expanded(
                child: Center(
                  child: _buildHourglassVisual(),
                ),
              ),

              const SizedBox(height: 16),

              // ── Buton ──
              AestheticPlannerButton(
                text: 'Harika!',
                height: 52,
                onPressed: widget.onNext,
              ),

              const SizedBox(height: 44),
            ],
          ),
        );
      }

  /// ⏳ Masalsı Kawaii Kum Saati (Tamamen Sabit, Pürüzsüz & Beyazlamayan Kare Animasyonu)
  Widget _buildHourglassVisual() {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: GestureDetector(
          onTap: () => AppHaptics.lightImpact(),
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _flowController]),
            builder: (context, _) {
              final frameIndex = (_flowController.value * 4).floor().clamp(0, 3);

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Arka plandaki yumuşak pastel gül & altın ışıltısı
                  Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF7A5B2).withValues(
                            alpha: 0.22 * _glowAnimation.value,
                          ),
                          blurRadius: 36,
                          spreadRadius: 8 * _glowAnimation.value,
                        ),
                        BoxShadow(
                          color: const Color(0xFFFFE0A3).withValues(
                            alpha: 0.16 * _glowAnimation.value,
                          ),
                          blurRadius: 48,
                          spreadRadius: 4 * _glowAnimation.value,
                        ),
                      ],
                    ),
                  ),

                  // Kum Saati (Sallanma/süzülme olmadan tamamen sabit ve katı opak)
                  SizedBox(
                    height: 195,
                    width: 104,
                    child: IndexedStack(
                      index: frameIndex,
                      alignment: Alignment.center,
                      children: _hourglassWidgets,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

