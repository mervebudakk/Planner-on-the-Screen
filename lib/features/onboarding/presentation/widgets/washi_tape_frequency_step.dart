import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../models/onboarding_state.dart';

/// 🏷️ Adım 1: Washi Tape (Defter Bandı) Haftalık Hedef Sayacı
class WashiTapeFrequencyStep extends StatefulWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const WashiTapeFrequencyStep({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  State<WashiTapeFrequencyStep> createState() => _WashiTapeFrequencyStepState();
}

class _WashiTapeFrequencyStepState extends State<WashiTapeFrequencyStep> {
  // Pastel Washi Tape Renkleri
  static const List<Color> _washiColors = [
    Color(0xFFFDE1E4), // Blush Pink
    Color(0xFFE8DFF5), // Lavender
    Color(0xFFDAEAF6), // Baby Blue
    Color(0xFFB5EAD7), // Soft Mint
    Color(0xFFFCF4DD), // Buttercup
    Color(0xFFFFDAC1), // Peach
    Color(0xFFDDEDEA), // Sage
  ];

  static const List<String> _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  void _decrement() {
    if (widget.state.weeklyGoalDays > 0) {
      setState(() => widget.state.weeklyGoalDays--);
    }
  }

  void _increment() {
    if (widget.state.weeklyGoalDays < 7) {
      setState(() => widget.state.weeklyGoalDays++);
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);

    final days = widget.state.weeklyGoalDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // ── Soru Başlığı ──
          Text(
            'Haftalık planlama ritmini bul',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Gerçekçi bir hedef seçelim. Haftada kaç gün odaklanma veya ders rutini planlıyorsun?',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const Spacer(flex: 1),

          // ── 🏷️ WASHI TAPE (DEFTER BANDI) GÜN BLOKLARI ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A2B33).withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isSelected = index < days;
                final color = _washiColors[index % _washiColors.length];

                return Column(
                  children: [
                    // Washi Bant
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected ? color : const Color(0xFFF0EBE3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? color.withValues(alpha: 0.8) : const Color(0xFFE2DAD0),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isSelected
                            ? const Icon(Icons.star_rounded, size: 18, color: Color(0xFF7A5861))
                            : Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD4CBC0),
                                  shape: BoxShape.circle,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _dayNames[index],
                      style: AppTypography.sfPro(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? titleColor : const Color(0xFFA09488),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 28),

          // ── [-] ve [+] Sayaç Kontrolü ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BouncingWidget(
                onTap: _decrement,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.remove_rounded, size: 24, color: titleColor),
                ),
              ),

              const SizedBox(width: 24),

              SizedBox(
                width: 140,
                child: Text(
                  days == 0 ? 'Serbest Mod' : '$days gün',
                  textAlign: TextAlign.center,
                  style: AppTypography.sfProRounded(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
              ),

              const SizedBox(width: 24),

              BouncingWidget(
                onTap: _increment,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, size: 24, color: titleColor),
                ),
              ),
            ],
          ),

          if (days == 0) ...[
            const SizedBox(height: 12),
            Text(
              'Herhangi bir hedef baskısı olmadan dilediğin zaman serbestçe plan yaparsın.',
              textAlign: TextAlign.center,
              style: AppTypography.sfPro(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.w400),
            ),
          ],

          const Spacer(flex: 2),

          // ── Devam Et Butonu ──
          AestheticPlannerButton(
            text: 'Devam Et',
            height: 52,
            onPressed: widget.onNext,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
