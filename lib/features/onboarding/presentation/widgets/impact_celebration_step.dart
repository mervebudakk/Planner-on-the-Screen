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
  late Animation<double> _floatAnimation;
  late Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1800));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // 🌊 Masalsı dikey süzülme (havada süzülme hissi)
    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // ⏳ Zarif salınım / sallanma açısı (vintage sarkaç/kum saati salınımı, ~1.8 derece)
    _tiltAnimation = Tween<double>(begin: -0.032, end: 0.032).animate(
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

  /// ⏳ Masalsı Antika Kum Saati (Havada Süzülen & Salınan Statik Sanat Eseri)
  Widget _buildHourglassVisual() {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -18), // ⬆️ Kum saatini çok az yukarı al
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Arka plandaki yumuşak altın güneş ışıltısı
                Container(
                  width: 170,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE5B869).withValues(
                          alpha: 0.24 * _glowAnimation.value,
                        ),
                        blurRadius: 40,
                        spreadRadius: 10 * _glowAnimation.value,
                      ),
                    ],
                  ),
                ),

                // Masalsı Antika Kum Saati (Boyutu biraz küçültülmüş & havada süzülen)
                Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Transform.rotate(
                    angle: _tiltAnimation.value,
                    alignment: Alignment.center,
                    child: Image.asset(
                      AppAssets.vintageHourglass,
                      height: 235, // 295'ten 235'e küçültüldü
                      cacheHeight: 600,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

