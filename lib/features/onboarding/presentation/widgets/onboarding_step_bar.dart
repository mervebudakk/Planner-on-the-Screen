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
    const completedColor = Color(0xFFD48B86);
    const inactiveColor = Color(0xFFE8DDD2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          // ── Geri Dön Butonu (Vintage Kağıt Buton) ──
          BouncingWidget(
            scaleFactor: 0.92,
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEADBCE), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 18, color: activeColor),
            ),
          ),

          const SizedBox(width: 14),

          // ── İlerleme Noktaları ──
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(totalSteps, (index) {
                final isCompleted = index < currentStep;
                final isCurrent = index == currentStep;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isCurrent ? 22 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? activeColor
                        : (isCompleted ? completedColor : inactiveColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isCompleted
                      ? const Center(
                          child: Icon(Icons.check_rounded, size: 8, color: Colors.white),
                        )
                      : null,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
