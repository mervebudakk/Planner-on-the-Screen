import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import 'home_screen.dart';

/// 🍎 Calenda Apple iOS SF Pro Karşılama Ekranı
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _onGetStarted(BuildContext context) async {
    final nav = Navigator.of(context);
    await context.read<StorageService>().setOnboardingCompleted();
    nav.pushReplacement(
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
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/welcome_illustration.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'CALENDA.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
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
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── A. ANA BAŞLIK (APPLE SF PRO ROUNDED TITLE 1) ──
                    Text(
                      'Daha Akıllı Planla,\nHuzurla Çalış',
                      textAlign: TextAlign.left,
                      style: AppTypography.sfProRounded(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: primaryDarkColor,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ── B. AÇIKLAMA METNİ (APPLE SF PRO BODY) ──
                    Text(
                      'Haftalık ders ve etkinliklerinizi zahmetsizce düzenleyin.',
                      textAlign: TextAlign.left,
                      style: AppTypography.sfPro(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondaryColor,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── C. "HEMEN BAŞLA" YAYLANAN BUTON (SF PRO ROUNDED) ──
                    BouncingWidget(
                      onTap: () => _onGetStarted(context),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: primaryDarkColor,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            'Hemen Başla',
                            style: AppTypography.sfProRounded(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w800,
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
