import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/error_logger.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../onboarding/models/onboarding_state.dart';
import '../../../onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../../planner/presentation/screens/home_screen.dart';
import '../../../planner/providers/planner_provider.dart';

/// 🌸 Calenda Zaten Hesabım Var Google ile Giriş Ekranı
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAppleLoading = false;
  bool _isGoogleLoading = false;
  bool get _isAnyLoading => _isAppleLoading || _isGoogleLoading;

  Future<void> _handleAuthResult(UserProfile profile) async {
    final hasUsername = profile.username.isNotEmpty &&
        profile.username != 'calenda_user' &&
        profile.username != 'apple_user' &&
        profile.username != 'misafir';

    if (hasUsername) {
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
    } else {
      // 🆕 Sistemde daha önce kayıtlı olmayan veya kullanıcı adı henüz belirlenmemiş kullanıcı:
      // Kullanıcı adı seçimi zorunlu olduğu ve sonradan DEĞİŞTİRİLEMEZ olduğu için,
      // doğrudan "Hemen Başla" onboarding adımlarına aktarılır.
      final state = OnboardingState();
      state.isGoogleAuthed = true;
      state.userId = profile.id;
      state.email = profile.email;
      state.username = ''; // Kesinlikle boş! Kullanıcı adı sonraki adımda seçilecek
      if (profile.firstName.isNotEmpty && profile.firstName != 'Kullanıcı' && profile.firstName != 'Calenda') {
        state.firstName = profile.firstName;
      }
      if (profile.lastName.isNotEmpty) {
        state.lastName = profile.lastName;
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, a1, a2) => OnboardingFlowScreen(initialState: state),
          transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    final l10n = context.l10n;
    try {
      final success = await context.read<PlannerProvider>().signInWithGoogle();
      if (!mounted) return;

      if (success) {
        final profile = context.read<PlannerProvider>().userProfile;
        await _handleAuthResult(profile);
      }
    } on PlatformException catch (e, st) {
      if (!mounted) return;
      if (e.code == 'sign_in_canceled' || e.code == 'canceled') {
        return;
      }
      ErrorLogger.log('LoginScreen.Google.PlatformException', e, st);
      String userMsg = l10n.loginFailedTryAgain;
      if (e.code == 'network_error') {
        userMsg = l10n.checkInternetConnection;
      } else if (e.message != null && e.message!.isNotEmpty && e.message!.length < 100) {
        userMsg = e.message!;
      }
      AestheticSnackBar.showError(context, userMsg);
    } catch (e, st) {
      if (!mounted) return;
      final errorStr = e.toString();
      if (!errorStr.contains('sign_in_canceled') &&
          !errorStr.contains('canceled') &&
          !errorStr.contains('popup_closed_by_user')) {
        ErrorLogger.log('LoginScreen.Google', e, st);
        String userMsg = l10n.loginFailedTryAgain;
        if (errorStr.contains('network') || errorStr.contains('SocketException')) {
          userMsg = l10n.checkInternetConnection;
        } else if (errorStr.contains('origin_mismatch') || errorStr.contains('unauthorized_client')) {
          userMsg = l10n.loginFailedTryAgain;
        } else if (errorStr.length < 100 && !errorStr.contains('file:///')) {
          userMsg = errorStr;
        }
        AestheticSnackBar.showError(context, userMsg);
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isAppleLoading = true);
    final l10n = context.l10n;
    try {
      final success = await context.read<PlannerProvider>().signInWithApple();
      if (!mounted) return;

      if (success) {
        final profile = context.read<PlannerProvider>().userProfile;
        await _handleAuthResult(profile);
      }
    } catch (e, st) {
      if (!mounted) return;
      final errorStr = e.toString();
      if (!errorStr.contains('canceled') &&
          !errorStr.contains('Canceled') &&
          !errorStr.contains('authorization error 1001')) {
        ErrorLogger.log('LoginScreen.Apple', e, st);
        AestheticSnackBar.showError(context, '${l10n.loginFailedTryAgain}: $errorStr');
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);

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
              children: [
                // ── 1. ÜST BÖLGE: LOGO, BAŞLIK & AÇIKLAMA (EŞİT ESNEK ALANDA ORTALANMIŞ) ──
                Expanded(
                  flex: 1,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Masalsı Logo & İkon ──
                          Container(
                            width: 98,
                            height: 98,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A1B3822),
                                  blurRadius: 22,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.asset(
                                AppAssets.appIcon,
                                fit: BoxFit.cover,
                                cacheWidth: 200,
                                cacheHeight: 200,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Text('C', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF1B3822))),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Başlık ──
                          Text(
                            l10n.welcomeBack,
                            textAlign: TextAlign.center,
                            style: AppTypography.sfProRounded(
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ── Açıklama ──
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              l10n.loginSubtitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.sfPro(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: subtitleColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── 2. MERKEZ: GİRİŞ BUTONLARI (EKRANIN TAM ORTASINDA) ──
                // Apple ile Giriş Yap Butonu
                BouncingWidget(
                  onTap: _isAnyLoading ? () {} : _handleAppleSignIn,
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
                    child: _isAppleLoading
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
                                l10n.signInWithApple,
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

                // Google ile Giriş Yap Butonu
                BouncingWidget(
                  onTap: _isAnyLoading ? () {} : _handleGoogleSignIn,
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
                    child: _isGoogleLoading
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
                                l10n.signInWithGoogle,
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

                // ── 3. ALT BÖLGE: BUTONLARLA HİZALANMIŞ BİLGİLENDİRME VE DENGE ──
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          l10n.loginFootnote,
                          textAlign: TextAlign.center,
                          style: AppTypography.sfPro(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9E8D86),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
