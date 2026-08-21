import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import 'home_screen.dart';

/// 🍎 Calenda Apple iOS SF Pro Karşılama Ekranı
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _onGetStarted(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryDarkColor = AppColors.lightTextPrimary; // Çok Çok Koyu Matcha Yeşili
    const textSecondaryColor = AppColors.lightTextSecondary; // Koyu Adaçayı Yeşili

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // ─── 1. KULLANICININ YERLEŞTİRDİĞİ TAM EKRAN "CALENDA.png" İLLÜSTRASYONU ───
          Positioned.fill(
            child: Image.asset(
              'assets/images/calenda_welcome.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/welcome_illustration.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'CALENDA.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    );
                  },
                );
              },
            ),
          ),

          // ─── 2. ALTTAN SOLA YASLI GEOMETRİK BAŞLIK, AÇIKLAMA VE BUTON ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── A. ANA BAŞLIK (APPLE SF PRO ROUNDED TITLE 1) ──
                    Text(
                      'Daha Akıllı Planla,\nHuzurla Çalış',
                      textAlign: TextAlign.left,
                      style: AppTypography.sfProRounded(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: primaryDarkColor,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── B. AÇIKLAMA METNİ (APPLE SF PRO BODY) ──
                    Text(
                      'Haftalık ders ve etkinliklerinizi zahmetsizce düzenleyin.',
                      textAlign: TextAlign.left,
                      style: AppTypography.sfPro(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        color: textSecondaryColor,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── C. "HEMEN BAŞLA" YAYLANAN BUTON (SF PRO ROUNDED) ──
                    BouncingWidget(
                      onTap: () => _onGetStarted(context),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: primaryDarkColor,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: primaryDarkColor.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Hemen Başla',
                            style: AppTypography.sfProRounded(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
