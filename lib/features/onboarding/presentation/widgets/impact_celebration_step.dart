import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../models/onboarding_state.dart';

/// ✨ Adım 4: Masalsı Yıllık Hedef Projeksiyonu & Kutlama
class ImpactCelebrationStep extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const ImpactCelebrationStep({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    const buttonPink = Color(0xFFE6ABA7);
    const buttonPinkDarker = Color(0xFFDF9E99);

    final days = state.weeklyGoalDays;
    final mins = state.dailyFocusMinutes;
    final isFreeMode = days == 0 || mins == 0;

    final hoursPerWeek = (days * mins) / 60.0;
    final hoursPerYear = (hoursPerWeek * 52).round();
    final daysPerYear = days * 52;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // ── Parıldayan İkon ──
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF1EB), Color(0xFFFDE1E4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE6ABA7).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '✨',
                style: TextStyle(fontSize: 34),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Başlık ──
          Text(
            isFreeMode ? 'Huzurlu bir başlangıç!' : 'Muazzam bir potansiyel!',
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
                ? 'Hedef baskısı olmadan, tamamen kendi huzurlu temponda plan yapmaya hazırsın.'
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
                              'Haftada ${hoursPerWeek.toStringAsFixed(1)} saatlik kaliteli çalışma',
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
                    'Özgür ve Sakin Planlama',
                    style: AppTypography.sfProRounded(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Calenda’yı yalnızca ajandanı tutmak, yapılacakları not etmek ve zihnini boşaltmak için sakin bir sığınak olarak kullanabilirsin.',
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
          BouncingWidget(
            onTap: onNext,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [buttonPink, buttonPinkDarker],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40E6ABA7),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Harika, Devam Edelim',
                  style: AppTypography.sfProRounded(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
