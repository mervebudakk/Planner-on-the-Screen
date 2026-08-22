import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Calenda & Timezy Huzurlu, Tertemiz Pastel Matcha / Adaçayı Yeşili Arka Plan
class AppleAmbientBackground extends StatelessWidget {
  final Widget child;

  const AppleAmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. Temiz, Düz ve Pürüzsüz Arka Plan (Baloncuklar ve leke küreleri tamamen kaldırıldı)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.darkBackground,
                        AppColors.darkBackgroundEnd,
                      ]
                    : [
                        const Color(0xFFEEF5E4), // Açık Pastel Matcha
                        const Color(0xFFEDF3E6),
                      ],
              ),
            ),
          ),
        ),

        // 2. Ön Plan İçeriği
        child,
      ],
    );
  }
}
