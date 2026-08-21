import 'package:flutter/material.dart';

/// Apple iOS Tarzı İpeksi ve Derinlikli Arka Plan Mesh Gradient Bileşeni
class AppleAmbientBackground extends StatelessWidget {
  final Widget child;

  const AppleAmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. Temel Arka Plan Gradyanı
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF090D16),
                        const Color(0xFF0F172A),
                        const Color(0xFF131C2E),
                      ]
                    : [
                        const Color(0xFFF8FAFC),
                        const Color(0xFFF0F5FF),
                        const Color(0xFFFAF5FF),
                      ],
              ),
            ),
          ),
        ),

        // 2. Yumuşak Ambient Işık Küreleri (Buzlu camın arkasından sızan Apple derinliği)
        Positioned(
          top: -80,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark
                      ? const Color(0xFF6366F1).withValues(alpha: 0.18)
                      : const Color(0xFFA5B4FC).withValues(alpha: 0.40)),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 160,
          left: -70,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                      : const Color(0xFFBAE6FD).withValues(alpha: 0.35)),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 320,
          right: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark
                      ? const Color(0xFFF472B6).withValues(alpha: 0.12)
                      : const Color(0xFFFBCFE8).withValues(alpha: 0.30)),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 3. Ön Plan İçeriği
        child,
      ],
    );
  }
}
