import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
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
  late Animation<double> _floatAnimation;

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

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
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
    const accentPurple = Color(0xFF7A58B0);

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
          // ── 🎊 KONFETİ PATLAMA ALANI ──
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

          const SizedBox(height: 12),

          // ── 📖 ÜST BAŞLIK ──
          Text(
            isFreeMode
                ? 'Hedef ve süre baskısı olmadan yılda'
                : 'Minimum odak hedefini tutturarak yılda',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 6),

          // ── 🔢 DEV SAYISAL ETKİ RAKAMI ──
          Text(
            isFreeMode ? 'Özgür' : '$hoursPerYear+',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 66,
              fontWeight: FontWeight.w900,
              color: accentPurple,
              letterSpacing: -2,
              height: 1.05,
            ),
          ),

          const SizedBox(height: 6),

          // ── 🎯 VURUCU ALT BAŞLIK ──
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTypography.sfPro(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
              children: [
                TextSpan(text: isFreeMode ? 'kendi akışında ' : 'saat '),
                TextSpan(
                  text: isFreeMode ? 'planlayabilirsin' : 'odaklanabilirsin',
                  style: AppTypography.sfProRounded(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: accentPurple,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          // ── ⏳ MASALSI ANTİKA KUM SAATİ ──
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
    );
  }

  /// ⏳ Masalsı & Nefes Alan Barok Kum Saati İllüstrasyonu
  Widget _buildHourglassVisual() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arka plandaki yumuşak altın güneş ışıltısı
                Container(
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
                ),

                // Antika Barok Kum Saati
                Image.asset(
                  'assets/images/vintage_hourglass.png',
                  height: 248,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

