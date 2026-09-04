import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import 'home_screen.dart';

/// Calenda Apple iOS SF Pro karşılama ekranı.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _onGetStarted(BuildContext context) async {
    final nav = Navigator.of(context);
    await context.read<StorageService>().setOnboardingCompleted();
    nav.pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _onLogin(BuildContext context) async {
    final nav = Navigator.of(context);
    await context.read<StorageService>().setOnboardingCompleted();
    nav.pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
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
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    const buttonPink = Color(0xFFE6ABA7);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final veryCompactHeight = screenHeight < 640;
          final compactHeight = screenHeight < 720;
          final narrowWidth = screenWidth < 370;

          final horizontalPadding = narrowWidth ? 24.0 : 28.0;
          final bottomPadding = veryCompactHeight
              ? 8.0
              : compactHeight
                  ? 10.0
                  : 16.0;
          final messageButtonGap = veryCompactHeight
              ? 10.0
              : compactHeight
                  ? 12.0
                  : 18.0;
          final loginGap = compactHeight ? 8.0 : 12.0;
          final buttonHeight = veryCompactHeight
              ? 46.0
              : compactHeight
                  ? 48.0
                  : 50.0;

          double messageFontSize = 19.0;
          if (compactHeight) {
            messageFontSize = 18.0;
          }
          if (narrowWidth) {
            messageFontSize = 17.0;
          }
          if (veryCompactHeight) {
            messageFontSize = 16.0;
          }

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/welcome_illustration.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/welcome_illustration.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/calenda_welcome.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFDEEF2),
                                    Color(0xFFEBF7EE),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        const Color(0xFFFAF7F2).withValues(alpha: 0.42),
                      ],
                      stops: const [0.0, 0.62, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      bottomPadding,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Derslerini, hedeflerini ve rutinlerini sana uygun huzurlu bir akışta planla.',
                              textAlign: TextAlign.left,
                              maxLines: veryCompactHeight ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Helvetica Neue',
                                fontFamilyFallback: const [
                                  'Arial',
                                  'Roboto',
                                  'Helvetica',
                                  'sans-serif',
                                ],
                                fontSize: messageFontSize,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5A2C35),
                                height: 1.25,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(height: messageButtonGap),
                            AestheticPlannerButton(
                              text: 'Hemen Başla',
                              width: double.infinity,
                              height: buttonHeight,
                              onPressed: () => _onGetStarted(context),
                            ),
                            SizedBox(height: loginGap),
                            Center(
                              child: BouncingWidget(
                                onTap: () => _onLogin(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      style: AppTypography.sfPro(
                                        fontSize: narrowWidth ? 12.5 : 13.5,
                                        color: subtitleColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Zaten bir hesabın var mı? ',
                                        ),
                                        TextSpan(
                                          text: 'Giriş Yap',
                                          style: AppTypography.sfProRounded(
                                            fontSize:
                                                narrowWidth ? 12.5 : 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: titleColor,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: buttonPink,
                                          ),
                                        ),
                                      ],
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
