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
      'subtitle': 'Hedefsiz ve esnek tempo',
    },
    {
      'minutes': 45,
      'title': '1 Saatten Az',
      'subtitle': 'Günde 25 – 45 dakika',
    },
    {
      'minutes': 120,
      'title': '1 – 3 Saat Arası',
      'subtitle': 'Günde yaklaşık 2 saat',
    },
    {
      'minutes': 210,
      'title': '3 Saatten Fazla',
      'subtitle': 'Günde 3.5 saat ve üzeri',
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
          const SizedBox(height: 12),

          // ── Başlık ──
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
            'Her çalışma gününde ne kadar süre odaklanmak istersin?',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 16),

          // ── Dengeli & Ortalı Seçim Kartları ──
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int index = 0; index < _focusOptions.length; index++) ...[
                        if (index > 0) const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final option = _focusOptions[index];
                            final minutes = option['minutes'] as int;
                            final isSelected = _selectedMinutes == minutes;
                            final title = option['title'] as String;
                            final subtitle = option['subtitle'] as String;

                            return BouncingWidget(
                              scaleFactor: 0.98,
                              onTap: () {
                                setState(() {
                                  _selectedMinutes = minutes;
                                  widget.state.dailyFocusMinutes = minutes;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFF9F8)
                                      : Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? buttonPink : const Color(0xFFEADBCE),
                                    width: isSelected ? 2.0 : 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: buttonPink.withValues(alpha: 0.28),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: AppTypography.sfProRounded(
                                              fontSize: 16,
                                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                              color: titleColor,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            subtitle,
                                            style: AppTypography.sfPro(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w400,
                                              color: subtitleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? buttonPink : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFFD48B86) : const Color(0xFFD6C8BB),
                                          width: 1.8,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Center(
                                              child: Icon(Icons.check_rounded, size: 15, color: Colors.white),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Devam Et Butonu ──
          AestheticPlannerButton(
            text: 'Devam Et',
            height: 52,
            onPressed: widget.onNext,
          ),

          const SizedBox(height: 44),
        ],
      ),
    );
  }
}
