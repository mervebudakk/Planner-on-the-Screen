import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

/// Calenda Masalsı & Pastel Watercolor Arka Plan (wallpaper.jpg Entegreli)
class AppleAmbientBackground extends StatelessWidget {
  final Widget child;

  const AppleAmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. Masalsı Suluboya Pastel Arka Plan Duvar Kağıdı (wallpaper.jpg)
        Positioned.fill(
          child: isDark
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.darkBackground,
                        AppColors.darkBackgroundEnd,
                      ],
                    ),
                  ),
                )
              : Image.asset(
                  AppAssets.wallpaper,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    // Güvenli Yedek Gradyan (Pembe/Nane Masal Tonları)
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFDEEF2), // Pastel Pudra Pembesi
                            Color(0xFFFFFDF7), // Krem / Vanilya
                            Color(0xFFEBF7EE), // Pastel Adaçayı / Nane Yeşili
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // 2. Ön Plan İçeriği
        child,
      ],
    );
  }
}
