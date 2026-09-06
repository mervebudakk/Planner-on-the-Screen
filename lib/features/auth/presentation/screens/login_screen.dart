import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../planner/presentation/screens/home_screen.dart';
import '../../../planner/providers/planner_provider.dart';

/// 🌸 Calenda Zaten Hesabım Var Google ile Giriş Ekranı
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await context.read<PlannerProvider>().signInWithGoogle();
      if (!mounted) return;

      if (success) {
        await context.read<StorageService>().setOnboardingCompleted();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, a1, a2) => const HomeScreen(),
            transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorStr = e.toString();
      if (!errorStr.contains('sign_in_canceled') &&
          !errorStr.contains('canceled') &&
          !errorStr.contains('popup_closed_by_user')) {
        String userMsg = 'Giriş yapılamadı. Lütfen tekrar deneyin.';
        if (errorStr.contains('network') || errorStr.contains('SocketException')) {
          userMsg = 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
        } else if (errorStr.contains('origin_mismatch') || errorStr.contains('unauthorized_client')) {
          userMsg = 'Google yetkilendirme yapılandırması kontrol edilmelidir.';
        } else if (errorStr.length < 100 && !errorStr.contains('file:///')) {
          userMsg = errorStr;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userMsg,
              style: AppTypography.sfPro(fontSize: 13, color: Colors.white),
            ),
            backgroundColor: const Color(0xFFD97272),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await context.read<PlannerProvider>().signInWithApple();
      if (!mounted) return;

      if (success) {
        await context.read<StorageService>().setOnboardingCompleted();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, a1, a2) => const HomeScreen(),
            transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorStr = e.toString();
      if (!errorStr.contains('canceled') &&
          !errorStr.contains('Canceled') &&
          !errorStr.contains('authorization error 1001')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Apple ile giriş yapılamadı: $errorStr',
              style: AppTypography.sfPro(fontSize: 13, color: Colors.white),
            ),
            backgroundColor: const Color(0xFFD97272),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    const buttonPink = Color(0xFFE6ABA7);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BouncingWidget(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: titleColor),
            ),
          ),
        ),
      ),
      body: AppleAmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),

                // ── 1. MASALSI LOGO & İKON ──
                Container(
                  width: 110,
                  height: 110,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30E6ABA7),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset(
                      AppAssets.appIcon,
                      fit: BoxFit.cover,
                      cacheWidth: 200,
                      cacheHeight: 200,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text('C', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: buttonPink)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── 2. BAŞLIK & AÇIKLAMA ──
                Text(
                  'Tekrar Hoş Geldin!',
                  textAlign: TextAlign.center,
                  style: AppTypography.sfProRounded(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Kaldığın yerden haftalık planlarına, hedeflerine ve huzurlu ritmine devam et.',
                  textAlign: TextAlign.center,
                  style: AppTypography.sfPro(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                    height: 1.4,
                  ),
                ),

                const Spacer(flex: 1),

                // ── 3. APPLE İLE GİRİŞ YAP BUTONU ──
                BouncingWidget(
                  onTap: _isLoading ? () {} : _handleAppleSignIn,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1D1F),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.apple,
                                size: 26,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Apple ile Giriş Yap',
                                style: AppTypography.sfProRounded(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── 4. GOOGLE İLE GİRİŞ YAP BUTONU ──
                BouncingWidget(
                  onTap: _isLoading ? () {} : _handleGoogleSignIn,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFEADBCE),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A2B33).withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: titleColor,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                width: 22,
                                height: 22,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.g_mobiledata,
                                  size: 28,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Google ile Giriş Yap',
                                style: AppTypography.sfProRounded(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── 4. BİLGİLENDİRME METNİ ──
                Text(
                  'Giriş yaparak kayıtlı tüm haftalık planlarını ve hedeflerini anında geri yüklersin.',
                  textAlign: TextAlign.center,
                  style: AppTypography.sfPro(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9E8D86),
                    height: 1.3,
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
