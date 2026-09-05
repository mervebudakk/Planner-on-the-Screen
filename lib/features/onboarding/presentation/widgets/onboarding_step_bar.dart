import 'package:flutter/material.dart';
import '../../../../core/widgets/bouncing_widget.dart';

/// 🧵 Masalsı Dikişli & Noktalı İlerleme Çubuğu
class OnboardingStepBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  const OnboardingStepBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 8,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF4A2B33);
    const inactiveColor = Color(0xFFEADBCE);
    const inactiveBorderColor = Color(0xFFDECFC2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          // ── 1. Geri Dön Butonu (Zarif Dairesel iOS Chevron Buton) ──
          BouncingWidget(
            scaleFactor: 0.90,
            onTap: onBack,
            borderRadius: BorderRadius.circular(19),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.92),
                border: Border.all(color: const Color(0xFFEADBCE), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2B33).withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 2), // Optik merkezleme
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: activeColor,
                  ),
                ),
              ),
            ),
          ),

          // ── 2. Tam Ortalanmış İlerleme Noktaları (Çizgisiz, Saf Daireler) ──
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(totalSteps, (index) {
                  final isCompleted = index < currentStep;
                  final isCurrent = index == currentStep;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: totalSteps > 7 ? 4.0 : 5.0,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isCompleted || isCurrent)
                            ? activeColor
                            : inactiveColor,
                        border: Border.all(
                          color: (isCompleted || isCurrent)
                              ? activeColor
                              : inactiveBorderColor,
                          width: 1.0,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.22),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isCompleted
                          ? const Center(
                              child: Icon(
                                Icons.check_rounded,
                                size: 9.5,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── 3. Sağ Taraf Dengeleyici (Geri butonuyla eşit genişlikte simetri alanı) ──
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}
