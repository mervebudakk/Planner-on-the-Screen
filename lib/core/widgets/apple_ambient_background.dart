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
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF090D16),
                      const Color(0xFF131C2E),
                    ]
                  : [
                      const Color(0xFFF8FAFC),
                      const Color(0xFFEFF6FF),
                      const Color(0xFFF1F5F9),
                    ],
            ),
          ),
        ),

        // 2. Yumuşak Ambient Işık Küreleri (Buzlu camın arkasından sızan Apple derinliği)
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark
                      ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                      : const Color(0xFFA5B4FC).withValues(alpha: 0.35)),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.12)
                      : const Color(0xFFBAE6FD).withValues(alpha: 0.30)),
            ),
          ),
        ),
        Positioned(
          top: 300,
          right: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark
                      ? const Color(0xFFF472B6).withValues(alpha: 0.10)
                      : const Color(0xFFFBCFE8).withValues(alpha: 0.25)),
            ),
          ),
        ),

        // 3. Ön Plan İçeriği
        child,
      ],
    );
  }
}
