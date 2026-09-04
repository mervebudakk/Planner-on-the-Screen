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

          // ── 📖 DEFTER YAPRAĞI VE YAPIŞKAN NOTLAR (STICKY NOTES) ──
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2B33).withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: [
                      // 1. Defter Temel Görseli
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/notebook_base.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF8F3),
                              border: Border.all(color: const Color(0xFFEADBCE), width: 2),
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),

                      // 2. Sırayla Eklenen Yapışkan Notlar (Sticky Notes)
                      // Gün 1: Pzt (Sol Üst)
                      _buildStickyNote(
                        visible: days >= 1,
                        topPercent: 0.24,
                        leftPercent: 0.15,
                        angle: -0.06,
                        color: const Color(0xFFFDE1E4),
                        tapeColor: const Color(0xFFF7B1BC),
                        dayTitle: 'Pzt',
                        subText: 'Odak',
                        icon: Icons.star_rounded,
                      ),

                      // Gün 2: Sal (Sol Orta)
                      _buildStickyNote(
                        visible: days >= 2,
                        topPercent: 0.46,
                        leftPercent: 0.18,
                        angle: 0.05,
                        color: const Color(0xFFE8DFF5),
                        tapeColor: const Color(0xFFC7B3E5),
                        dayTitle: 'Sal',
                        subText: 'Ders',
                        icon: Icons.edit_note_rounded,
                      ),

                      // Gün 3: Çar (Sol Alt)
                      _buildStickyNote(
                        visible: days >= 3,
                        topPercent: 0.68,
                        leftPercent: 0.14,
                        angle: -0.04,
                        color: const Color(0xFFDAEAF6),
                        tapeColor: const Color(0xFFA5C8E4),
                        dayTitle: 'Çar',
                        subText: 'Rutin',
                        icon: Icons.spa_rounded,
                      ),

                      // Gün 4: Per (Sağ Üst)
                      _buildStickyNote(
                        visible: days >= 4,
                        topPercent: 0.24,
                        rightPercent: 0.15,
                        angle: 0.06,
                        color: const Color(0xFFB5EAD7),
                        tapeColor: const Color(0xFF86D5B9),
                        dayTitle: 'Per',
                        subText: 'Hedef',
                        icon: Icons.flag_rounded,
                      ),

                      // Gün 5: Cum (Sağ Orta-Üst)
                      _buildStickyNote(
                        visible: days >= 5,
                        topPercent: 0.44,
                        rightPercent: 0.18,
                        angle: -0.05,
                        color: const Color(0xFFFCF4DD),
                        tapeColor: const Color(0xFFEBD99F),
                        dayTitle: 'Cum',
                        subText: 'Proje',
                        icon: Icons.auto_awesome_rounded,
                      ),

                      // Gün 6: Cmt (Sağ Orta-Alt)
                      _buildStickyNote(
                        visible: days >= 6,
                        topPercent: 0.62,
                        rightPercent: 0.14,
                        angle: 0.04,
                        color: const Color(0xFFFFDAC1),
                        tapeColor: const Color(0xFFF3B896),
                        dayTitle: 'Cmt',
                        subText: 'Akış',
                        icon: Icons.coffee_rounded,
                      ),

                      // Gün 7: Paz (Sağ Alt)
                      _buildStickyNote(
                        visible: days >= 7,
                        topPercent: 0.78,
                        rightPercent: 0.19,
                        angle: -0.08,
                        color: const Color(0xFFFDEBF0),
                        tapeColor: const Color(0xFFE6ABA7),
                        dayTitle: 'Paz',
                        subText: 'Kutlama',
                        icon: Icons.celebration_rounded,
                      ),

                      // 3. 0 Gün Seçiliyse Huzurlu Serbest Mod Notu
                      if (days == 0)
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A2B33).withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🌿', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  'Tertemiz bir başlangıç',
                                  style: AppTypography.sfProRounded(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: titleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
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

  Widget _buildStickyNote({
    required bool visible,
    required double topPercent,
    double? leftPercent,
    double? rightPercent,
    required double angle,
    required Color color,
    required Color tapeColor,
    required String dayTitle,
    required String subText,
    required IconData icon,
  }) {
    return Positioned(
      top: topPercent * 300,
      left: leftPercent != null ? leftPercent * 300 : null,
      right: rightPercent != null ? rightPercent * 300 : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        opacity: visible ? 1.0 : 0.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          scale: visible ? 1.0 : 0.2,
          child: Transform.rotate(
            angle: angle,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Post-it Not Kutusu
                Container(
                  width: 76,
                  height: 48,
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withValues(alpha: 0.8),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 6,
                        offset: const Offset(1, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: const Color(0xFF5D4037)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayTitle,
                              style: AppTypography.sfProRounded(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF4A2B33),
                              ),
                            ),
                            Text(
                              subText,
                              style: AppTypography.sfPro(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7A5861),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Washi Tape (Üstte Tutan Bant)
                Positioned(
                  top: 0,
                  child: Container(
                    width: 30,
                    height: 9,
                    decoration: BoxDecoration(
                      color: tapeColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
