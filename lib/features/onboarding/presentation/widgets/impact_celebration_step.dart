import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../models/onboarding_state.dart';

/// ✨ Adım 4: Masalsı Yıllık Hedef Projeksiyonu & Konfeti Kutlaması
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

class _ImpactCelebrationStepState extends State<ImpactCelebrationStep> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1800));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
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
    final daysPerYear = days * 52;
    final hoursPerWeekFormatted = hoursPerWeek % 1 == 0 ? hoursPerWeek.toInt().toString() : hoursPerWeek.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // ── 🎊 KONFETİ VE KUTLAMA AMBLEMİ ──
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Konfeti Patlama Efekti (360 Derece Patlama)
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  numberOfParticles: 32,
                  maxBlastForce: 28,
                  minBlastForce: 10,
                  emissionFrequency: 0.04,
                  gravity: 0.18,
                  particleDrag: 0.05,
                  colors: const [
                    Color(0xFFF7A5B2), // Rose blush
                    Color(0xFFE5B869), // Warm gold
                    Color(0xFFB5CFA8), // Soft sage
                    Color(0xFF8E79AB), // Lavender
                    Color(0xFFFFD166), // Buttercup
                    Color(0xFF83C5BE), // Mint
                    Color(0xFFF4B2A8), // Coral
                  ],
                  createParticlePath: _drawStar,
                ),
              ),

              // Dış Işıma Halkası
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFDE1E4).withValues(alpha: 0.35),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE6ABA7).withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),

              // Ana Mühür / Rozet (Dokununca tekrar konfeti fırlatır)
              BouncingWidget(
                onTap: () {
                  _confettiController.stop();
                  _confettiController.play();
                },
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFDF9), Color(0xFFFCE4E8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE6ABA7).withValues(alpha: 0.7),
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A2B33).withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFE29578), Color(0xFFC47B89), Color(0xFFE5B869)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Başlık ──
          Text(
            isFreeMode ? 'Harika bir başlangıç!' : 'Muazzam bir potansiyel!',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isFreeMode
                ? 'Süre ve hedef baskısı olmadan, tamamen kendi temponda plan yapmaya hazırsın.'
                : 'Seçtiğin bu tempoyla 1 yılda elde edeceğin birikim:',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const Spacer(flex: 1),

          // ── 📊 PROJEKSİYON KARTLARI ──
          if (!isFreeMode) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2B33).withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Saat Kartı
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDEBF0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.hourglass_bottom_rounded, color: Color(0xFFC47B89), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yılda ~$hoursPerYear Saat Odak',
                              style: AppTypography.sfProRounded(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Haftada $hoursPerWeekFormatted saatlik çalışma',
                              style: AppTypography.sfPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: Color(0xFFF0EBE3)),
                  ),

                  // Gün Kartı
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF7EE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF6B9B78), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yılda $daysPerYear Planlı Gün',
                              style: AppTypography.sfProRounded(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Düzenli ve istikrarlı haftalık akış',
                              style: AppTypography.sfPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2B33).withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 12),
                  Text(
                    'Esnek ve Özgür Planlama',
                    style: AppTypography.sfProRounded(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Calenda’yı ajandanı tutmak, günlük yapılacakları not etmek ve hedeflerini düzenlemek için dilediğin gibi kullanabilirsin.',
                    textAlign: TextAlign.center,
                    style: AppTypography.sfPro(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: subtitleColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(flex: 2),

          // ── Devam Et Butonu ──
          AestheticPlannerButton(
            text: 'Harika, Devam Edelim',
            height: 52,
            onPressed: widget.onNext,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
