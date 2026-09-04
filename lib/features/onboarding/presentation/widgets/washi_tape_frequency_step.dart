import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../models/onboarding_state.dart';

/// 📌 Adım 1: Mantar Pano ve Yapışkanlı Notlar (Cork Board Pinboard)
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
          const SizedBox(height: 16),

          // ── Soru Başlığı ──
          Text(
            'Haftalık planlama ritmini bul',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Haftada kaç gün odaklanma veya ders çalışmayı hedefliyorsun?',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const Spacer(flex: 1),

          // ── 📌 MANTAR PANO VE YAPIŞKANLI NOTLAR (CORK PINBOARD) ──
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 350, maxHeight: 245),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2B33).withValues(alpha: 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 1.42,
                  child: Stack(
                    children: [
                      // 1. Mantar Pano Temel Arka Planı (Arka plansız, sade ahşap çerçeveli pano)
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/cork_board.jpg',
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7A779),
                              border: Border.all(color: const Color(0xFFB57D4F), width: 8),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),

                      // 2. Sırayla Eklenen Yapışkanlı Notlar (Sticky Notes - Karalama Çizgili)
                      // Not 1: Sol Üst
                      _buildStickyNote(
                        visible: days >= 1,
                        top: 20,
                        left: 20,
                        angle: -0.06,
                        noteColor: const Color(0xFFFFF6A1), // Pastel Sarı
                        pinColor: const Color(0xFFE53935),  // Kırmızı Raptiye
                      ),

                      // Not 2: Üst Orta
                      _buildStickyNote(
                        visible: days >= 2,
                        top: 16,
                        left: 135,
                        angle: 0.04,
                        noteColor: const Color(0xFFFDE1E4), // Pembe
                        pinColor: const Color(0xFF00ACC1),  // Turkuaz Raptiye
                      ),

                      // Not 3: Sağ Üst
                      _buildStickyNote(
                        visible: days >= 3,
                        top: 22,
                        right: 20,
                        angle: -0.05,
                        noteColor: const Color(0xFFD7F0DB), // Nane Yeşili
                        pinColor: const Color(0xFFFFB300),  // Altın Sarı Raptiye
                      ),

                      // Not 4: Sol Orta
                      _buildStickyNote(
                        visible: days >= 4,
                        top: 96,
                        left: 28,
                        angle: 0.05,
                        noteColor: const Color(0xFFDAEAF6), // Bebek Mavisi
                        pinColor: const Color(0xFF8E24AA),  // Mor Raptiye
                      ),

                      // Not 5: Sağ Orta
                      _buildStickyNote(
                        visible: days >= 5,
                        top: 92,
                        right: 28,
                        angle: -0.04,
                        noteColor: const Color(0xFFE8DFF5), // Lavanta
                        pinColor: const Color(0xFF43A047),  // Yeşil Raptiye
                      ),

                      // Not 6: Sol Alt
                      _buildStickyNote(
                        visible: days >= 6,
                        top: 154,
                        left: 80,
                        angle: -0.03,
                        noteColor: const Color(0xFFFFDAC1), // Şeftali
                        pinColor: const Color(0xFFFF5722),  // Mercan Raptiye
                      ),

                      // Not 7: Sağ Alt
                      _buildStickyNote(
                        visible: days >= 7,
                        top: 152,
                        right: 80,
                        angle: 0.06,
                        noteColor: const Color(0xFFFDEBF0), // Gül Pembesi
                        pinColor: const Color(0xFF1E88E5),  // Mavi Raptiye
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

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
                width: 150,
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

          const SizedBox(height: 8),

          // ── Sabit Yükseklikli Açıklama Metni (Panonun kaymasını önler) ──
          SizedBox(
            height: 34,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: days == 0 ? 1.0 : 0.0,
              child: Center(
                child: Text(
                  'Herhangi bir hedef baskısı olmadan dilediğin zaman serbestçe plan yaparsın.',
                  textAlign: TextAlign.center,
                  style: AppTypography.sfPro(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),

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

  /// 📝 Yapışkanlı Not (Post-it + Raptiye + Karalama Çizgileri)
  Widget _buildStickyNote({
    required bool visible,
    required double top,
    double? left,
    double? right,
    required double angle,
    required Color noteColor,
    required Color pinColor,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
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
                // Post-it Not Kağıdı
                Container(
                  width: 62,
                  height: 58,
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
                  decoration: BoxDecoration(
                    color: noteColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 5,
                        offset: const Offset(1.5, 3.5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Karalama Yazı Çizgileri (Doodle Scribbles)
                      Container(
                        height: 2.2,
                        width: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B5344).withValues(alpha: 0.40),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2.2,
                        width: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B5344).withValues(alpha: 0.32),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2.2,
                        width: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B5344).withValues(alpha: 0.26),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Raptiye (Pushpin)
                Positioned(
                  top: 0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pin gölgesi
                      Transform.translate(
                        offset: const Offset(1.2, 2.0),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      // Pin gövdesi
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pinColor,
                          border: Border.all(color: Colors.white, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: pinColor.withValues(alpha: 0.6),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: const EdgeInsets.all(1.5),
                            width: 2.5,
                            height: 2.5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
