import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../models/onboarding_state.dart';

/// 🎯 Adım 3: Ana Odak Alanı Seçimi (Çoklu Seçim Desteği)
class CoreGoalStep extends StatefulWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const CoreGoalStep({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  State<CoreGoalStep> createState() => _CoreGoalStepState();
}

class _CoreGoalStepState extends State<CoreGoalStep> {
  static const List<String> _goals = [
    'Dersler & Sınavlar',
    'Projeler & Çalışma Hayatı',
    'Günlük Rutinler & Alışkanlıklar',
    'Kişisel Planlama & Notlar',
  ];

  late Set<String> _selectedGoals;

  @override
  void initState() {
    super.initState();
    _selectedGoals = Set<String>.from(widget.state.coreGoals);
    if (_selectedGoals.isEmpty) {
      _selectedGoals.add('Dersler & Sınavlar');
    }
  }

  void _toggleGoal(String title) {
    setState(() {
      if (_selectedGoals.contains(title)) {
        if (_selectedGoals.length > 1) {
          _selectedGoals.remove(title);
        }
      } else {
        _selectedGoals.add(title);
      }
      widget.state.coreGoals = _selectedGoals.toList();
    });
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

          // ── Başlık ──
          Text(
            'Calenda sana nasıl eşlik etsin?',
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
            'Kullanmak istediğin alanları seçebilirsin.',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 22),

          // ── Sade & Profesyonel Kartlar Listesi (Gereksiz ikonlar ve etiketler kaldırıldı) ──
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _goals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final title = _goals[index];
                final isSelected = _selectedGoals.contains(title);

                return BouncingWidget(
                  scaleFactor: 0.98,
                  onTap: () => _toggleGoal(title),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                          child: Text(
                            title,
                            style: AppTypography.sfProRounded(
                              fontSize: 16.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: titleColor,
                            ),
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
