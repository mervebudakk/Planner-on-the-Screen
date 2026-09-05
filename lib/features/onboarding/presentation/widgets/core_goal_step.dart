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
  final List<Map<String, dynamic>> _goals = const [
    {
      'title': 'Dersler & Sınavlar',
      'subtitle': 'YKS, KPSS, Üniversite, Lise ve akademik ders takibi',
      'tag': '🎓 Akademik',
      'icon': Icons.school_outlined,
      'color': Color(0xFFFDEBF0), // Soft Pink
      'accent': Color(0xFFC47B89),
    },
    {
      'title': 'Projeler & Çalışma Hayatı',
      'subtitle': 'İş, yazılım, tasarım ve kişisel projeler',
      'tag': '💼 Proje & İş',
      'icon': Icons.laptop_chromebook_rounded,
      'color': Color(0xFFE8DFF5), // Lavender
      'accent': Color(0xFF8E79AB),
    },
    {
      'title': 'Günlük Rutinler & Alışkanlıklar',
      'subtitle': 'Kitap okuma, spor, su takibi ve günlük düzen',
      'tag': '🌿 Yaşam & Rutin',
      'icon': Icons.spa_outlined,
      'color': Color(0xFFEBF7EE), // Mint
      'accent': Color(0xFF6B9B78),
    },
    {
      'title': 'Kişisel Planlama & Notlar',
      'subtitle': 'Günlük yapılacaklar, haftalık planlar ve hatırlatıcılar',
      'tag': '✨ Kişisel Ajanda',
      'icon': Icons.draw_outlined,
      'color': Color(0xFFFCF4DD), // Buttercup
      'accent': Color(0xFFB59A57),
    },
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
            'Kullanmak istediğin tüm alanları seçebilirsin.',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 18),

          // ── Masalsı Kırtasiye Parşömen Kartlar Listesi ──
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _goals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _goals[index];
                final title = item['title'] as String;
                final isSelected = _selectedGoals.contains(title);
                final accent = item['accent'] as Color;
                final color = item['color'] as Color;

                return BouncingWidget(
                  scaleFactor: 0.98,
                  onTap: () => _toggleGoal(title),
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
                            color: isSelected ? color : color.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected
                                  ? accent.withValues(alpha: 0.5)
                                  : const Color(0xFFEADBCE),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 23,
                            color: accent,
                          ),
                        ),

                        const SizedBox(width: 14),

                        // 2. Başlık, Rozet ve Açıklama Metni
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Zarif Mini Etiket (Pill)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? buttonPink.withValues(alpha: 0.22)
                                      : const Color(0xFFF3ECE4),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['tag'] as String,
                                  style: AppTypography.sfPro(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? const Color(0xFF9E4B5B)
                                        : const Color(0xFF8C7972),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title,
                                style: AppTypography.sfProRounded(
                                  fontSize: 15.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item['subtitle'] as String,
                                style: AppTypography.sfPro(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: subtitleColor,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 3. Çoklu Seçim Tik Rozeti (Check Badge)
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

          const SizedBox(height: 44),
        ],
      ),
    );
  }
}
