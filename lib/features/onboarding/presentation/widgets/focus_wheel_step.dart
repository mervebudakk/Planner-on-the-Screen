import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../models/onboarding_state.dart';

/// ⏱️ Adım 2: Günlük Odak Süresi Seçimi
class FocusWheelStep extends StatefulWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const FocusWheelStep({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  State<FocusWheelStep> createState() => _FocusWheelStepState();
}

class _FocusWheelStepState extends State<FocusWheelStep> {
  final List<Map<String, dynamic>> _focusOptions = const [
    {
      'minutes': 0,
      'title': 'Serbest Mod',
      'desc': 'Süre kısıtı veya hedef baskısı olmadan, canın ne zaman isterse.',
      'tag': 'Esnek Ritim',
      'icon': Icons.spa_outlined,
      'color': Color(0xFFF3EDF9), // Soft Lavender
      'accent': Color(0xFF8E79AB),
    },
    {
      'minutes': 45,
      'title': '1 Saatten Az',
      'desc': 'Günde kısa ve hafif odak seansları (25 - 45 dk).',
      'tag': 'Hafif & Pratik',
      'icon': Icons.local_cafe_outlined,
      'color': Color(0xFFFDEEF0), // Soft Peach/Rose
      'accent': Color(0xFFC47B89),
    },
    {
      'minutes': 120,
      'title': '1 - 3 Saat Arası',
      'desc': 'Düzenli ders çalışma ve verimli proje geliştirme için ideal (Günde ~2 saat).',
      'tag': '⭐ En Popüler',
      'icon': Icons.auto_stories_outlined,
      'color': Color(0xFFEDF7F0), // Soft Sage Mint
      'accent': Color(0xFF4A7C59),
    },
    {
      'minutes': 210,
      'title': '3 Saatten Fazla',
      'desc': 'Yoğun sınav maratonları (YKS, KPSS) ve derin akademik çalışmalar (Günde ~3.5+ saat).',
      'tag': 'Derin Odak',
      'icon': Icons.workspace_premium_outlined,
      'color': Color(0xFFFCF5E3), // Soft Buttercup
      'accent': Color(0xFFB58E42),
    },
  ];

  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.state.dailyFocusMinutes;
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    const buttonPink = Color(0xFFE6ABA7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // ── Başlık (Önceki ekranlarla birebir uyumlu) ──
          Text(
            'Günlük odak süren',
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
            'Her çalışma gününde kendine ne kadarlık bir odak veya çalışma alanı ayırmak istersin?',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 18),

          // ── Masalsı & Zarif Kırtasiye Kartları ──
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _focusOptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = _focusOptions[index];
                final minutes = option['minutes'] as int;
                final isSelected = _selectedMinutes == minutes;
                final iconColor = option['color'] as Color;
                final accentColor = option['accent'] as Color;

                return BouncingWidget(
                  scaleFactor: 0.98,
                  onTap: () {
                    setState(() {
                      _selectedMinutes = minutes;
                      widget.state.dailyFocusMinutes = minutes;
                    });
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFF9F8)
                          : Colors.white.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? buttonPink : const Color(0xFFEADBCE),
                        width: isSelected ? 2.0 : 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: buttonPink.withValues(alpha: 0.32),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.025),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Pastel Tematik İkon Kutusu
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isSelected ? iconColor : iconColor.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected
                                  ? accentColor.withValues(alpha: 0.5)
                                  : const Color(0xFFEADBCE),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            option['icon'] as IconData,
                            size: 23,
                            color: accentColor,
                          ),
                        ),

                        const SizedBox(width: 14),

                        // 2. Başlık, Rozet ve Açıklama Metni
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    option['title'] as String,
                                    style: AppTypography.sfProRounded(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                      color: titleColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Zarif Mini Etiket (Pill)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? buttonPink.withValues(alpha: 0.22)
                                          : const Color(0xFFF3ECE4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      option['tag'] as String,
                                      style: AppTypography.sfPro(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF9E4B5B)
                                            : const Color(0xFF8C7972),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                option['desc'] as String,
                                style: AppTypography.sfPro(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: subtitleColor,
                                  height: 1.32,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 3. Masalsı Seçim Mührü (Check Badge)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? buttonPink : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? const Color(0xFFD48B86) : const Color(0xFFD6C8BB),
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: buttonPink.withValues(alpha: 0.45),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(Icons.check_rounded, size: 14, color: Colors.white),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

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
