import 'package:flutter/material.dart';

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
    const inactiveColor = Color(0xFFE5DCD0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // ── Geri Dön Butonu (Vintage Kağıt Buton) ──
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                    color: isCompleted || isCurrent ? activeColor : inactiveColor,
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
