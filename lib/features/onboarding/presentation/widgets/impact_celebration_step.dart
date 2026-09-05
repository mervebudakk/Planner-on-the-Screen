import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../models/onboarding_state.dart';

/// ✨ Adım 4: Masalsı Yıllık Hedef Projeksiyonu & Kitap Kulesi Kutlaması
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
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1800));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.4;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
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

    return Stack(
      children: [
        // ── 1. Ana İçerik ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // ── Başlık: 'Yılda 234+ saat' belirgin ve büyük, altında 'sadece odaklanabilirsin' ──
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
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTypography.sfProRounded(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                    children: [
                      const TextSpan(text: 'Yılda '),
                      TextSpan(
                        text: '$hoursPerYear+',
                        style: AppTypography.sfProRounded(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFD48B86),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const TextSpan(text: ' saat\n'),
                      TextSpan(
                        text: 'sadece odaklanabilirsin',
                        style: AppTypography.sfProRounded(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
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

              const Spacer(flex: 1),

              // ── ⏳ MASALSI ANTİKA KUM SAATİ (Sabit, Sallanmadan Kum Akışı) ──
              _buildHourglassVisual(),

              const Spacer(flex: 1),

              // ── Buton ──
              AestheticPlannerButton(
                text: 'Harika!',
                height: 52,
                onPressed: widget.onNext,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),

        // ── 2. 🎊 KONFETİ PATLAMA ALANI ──
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 36,
            maxBlastForce: 28,
            minBlastForce: 10,
            emissionFrequency: 0.04,
            gravity: 0.18,
            particleDrag: 0.05,
            colors: const [
              Color(0xFFF7A5B2),
              Color(0xFFE5B869),
              Color(0xFFB5CFA8),
              Color(0xFF8E79AB),
              Color(0xFFFFD166),
              Color(0xFF83C5BE),
              Color(0xFFF4B2A8),
            ],
            createParticlePath: _drawStar,
          ),
        ),
      ],
    );
  }

  /// ⏳ Masalsı Antika Kum Saati (Aşağı Yukarı Sallanmaz, Sabit Durur)
  Widget _buildHourglassVisual() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plandaki yumuşak altın güneş ışıltısı
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 190,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE5B869).withValues(
                        alpha: 0.24 * _glowAnimation.value,
                      ),
                      blurRadius: 44,
                      spreadRadius: 10 * _glowAnimation.value,
                    ),
                  ],
                ),
              );
            },
          ),

          // Antika Barok Kum Saati (Hareketsiz, sadece kumların aktığı video/animasyon)
          Image.asset(
            AppAssets.vintageHourglassAnimated,
            height: 260,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              AppAssets.vintageHourglass,
              height: 260,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

