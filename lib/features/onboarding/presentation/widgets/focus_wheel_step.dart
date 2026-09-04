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
    },
    {
      'minutes': 45,
      'title': '1 Saatten Az',
      'desc': 'Günde kısa ve hafif odak seansları (25 - 45 dk).',
    },
    {
      'minutes': 90,
      'title': '1 - 3 Saat Arası',
      'desc': 'Düzenli ders çalışma ve verimli proje geliştirme için ideal.',
    },
    {
      'minutes': 180,
      'title': '3 Saatten Fazla',
      'desc': 'Yoğun sınav maratonları (YKS, KPSS) ve derin akademik çalışmalar.',
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
          const SizedBox(height: 20),

          // ── Başlık ──
          Text(
            'Günlük odak süren',
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
            'Her çalışma gününde kendine ne kadarlık bir odak veya çalışma alanı ayırmak istersin?',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 24),

          // ── Seçenek Listesi ──
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _focusOptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = _focusOptions[index];
                final minutes = option['minutes'] as int;
                final isSelected = _selectedMinutes == minutes;

                return BouncingWidget(
                  onTap: () {
                    setState(() {
                      _selectedMinutes = minutes;
                      widget.state.dailyFocusMinutes = minutes;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? buttonPink : const Color(0xFFEADBCE),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: buttonPink.withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        // Metinler
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['title'] as String,
                                style: AppTypography.sfProRounded(
                                  fontSize: 16.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                option['desc'] as String,
                                style: AppTypography.sfPro(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: subtitleColor,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Seçim Çemberi
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? buttonPink : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? buttonPink : const Color(0xFFD6C8BB),
                              width: 2,
                            ),
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
