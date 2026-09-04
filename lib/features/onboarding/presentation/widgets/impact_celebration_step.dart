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

          // ── 📚 KİTAP KULESİ / ODAK BİRİKİMİ İLLÜSTRASYONU ──
          _buildBookStack(hoursPerYear, isFreeMode),

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

  /// 📚 Üst Üste Yığılmış Renkli Pastel Kitap Kulesi
  Widget _buildBookStack(int hours, bool isFree) {
    final bookColors = [
      {'color': const Color(0xFFC84B31), 'line': Colors.white}, // Terracotta Kırmızı
      {'color': const Color(0xFF2D6187), 'line': const Color(0xFFFFD166)}, // Klasik Mavi
      {'color': const Color(0xFF6B8E23), 'line': Colors.white}, // Zeytin Yeşili
      {'color': const Color(0xFF3F72AF), 'line': const Color(0xFFFFE0AC)}, // İndigo Mavi
      {'color': const Color(0xFF2E7D32), 'line': Colors.white}, // Canlı Yeşil
      {'color': const Color(0xFF6D4C41), 'line': const Color(0xFFFFD166)}, // Sıcak Kahve
      {'color': const Color(0xFF388E3C), 'line': Colors.white}, // Zümrüt Yeşili
      {'color': const Color(0xFF43A047), 'line': Colors.white}, // Orman Yeşili
      {'color': const Color(0xFF7CB342), 'line': Colors.white}, // Açık Adaçayı
      {'color': const Color(0xFF1E88E5), 'line': const Color(0xFFFFD166)}, // Gökyüzü Mavisi
      {'color': const Color(0xFF00897B), 'line': Colors.white}, // Turkuaz / Mint
      {'color': const Color(0xFFE65100), 'line': Colors.white}, // Sıcak Turuncu
    ];

    final count = isFree ? 6 : min(12, max(6, (hours / 65).round()));
    final booksToShow = bookColors.take(count).toList();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 270),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: booksToShow.map((book) {
              final color = book['color'] as Color;
              final lineColor = book['line'] as Color;
              return Container(
                margin: const EdgeInsets.only(bottom: 2.5),
                width: 156,
                height: 19.5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sol ve Sağ Cilt İçi Dikiş Çizgileri
                    Positioned(
                      left: 14,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 1, color: Colors.black.withValues(alpha: 0.2)),
                    ),
                    Positioned(
                      right: 14,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 1, color: Colors.black.withValues(alpha: 0.2)),
                    ),
                    // Cilt Üzeri Başlık / Karalama Çizgileri
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 2,
                          decoration: BoxDecoration(
                            color: lineColor.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 42,
                          height: 2,
                          decoration: BoxDecoration(
                            color: lineColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 16,
                          height: 2,
                          decoration: BoxDecoration(
                            color: lineColor.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

