import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
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
      'tag': 'Sakin Akış',
      'icon': Icons.spa_outlined,
      'desc': 'Süre kısıtı veya hedef baskısı olmadan, canın ne zaman isterse.',
    },
    {
      'minutes': 25,
      'title': '25 Dakika',
      'tag': 'Pomodoro Klasiği',
      'icon': Icons.timer_outlined,
      'desc': 'Kısa, net ve zihni yormayan ideal odak döngüsü.',
    },
    {
      'minutes': 45,
      'title': '45 Dakika',
      'tag': 'Derin Çalışma',
      'icon': Icons.local_cafe_outlined,
      'desc': 'Ders çalışma veya proje geliştirme için en verimli blok.',
    },
    {
      'minutes': 60,
      'title': '60 Dakika',
      'tag': '1 Saatlik Seans',
      'icon': Icons.hourglass_top_rounded,
      'desc': 'Büyük hedeflere adım adım istikrarla ilerlemek için.',
    },
    {
      'minutes': 90,
      'title': '90 Dakika',
      'tag': 'Sınav Bloğu',
      'icon': Icons.menu_book_rounded,
      'desc': 'YKS, KPSS, üniversite ve yoğun akademik çalışmalar için.',
    },
    {
      'minutes': 120,
      'title': '120 Dakika',
      'tag': 'Odak Maratonu',
      'icon': Icons.rocket_launch_outlined,
      'desc': 'Günde 2 saatlik derin ve kesintisiz odaklanma seansı.',
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
    const buttonPinkDarker = Color(0xFFDF9E99);

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

          const SizedBox(height: 18),

          // ── Seçenek Listesi ──
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _focusOptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                color: buttonPink.withValues(alpha: 0.35),
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
                        // İkon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFDEBF0) : const Color(0xFFF5EFEB),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            option['icon'] as IconData,
                            size: 22,
                            color: isSelected ? titleColor : const Color(0xFF9E8D86),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Metinler
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
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: titleColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFFDEBF0) : const Color(0xFFF0EAE4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      option['tag'] as String,
                                      style: AppTypography.sfPro(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? const Color(0xFF8B5A2B) : const Color(0xFF9E8D86),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                option['desc'] as String,
                                style: AppTypography.sfPro(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
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
          BouncingWidget(
            onTap: widget.onNext,
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
                  'Devam Et',
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
