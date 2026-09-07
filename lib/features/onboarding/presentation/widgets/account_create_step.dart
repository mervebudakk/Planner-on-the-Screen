import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/error_logger.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/widgets/email_auth_sheet.dart';
import '../../../planner/presentation/screens/home_screen.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../models/onboarding_state.dart';

/// 🔐 Adım 5: Google / Apple / E-posta ile Hesap Oluşturma
class AccountCreateStep extends StatefulWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const AccountCreateStep({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  State<AccountCreateStep> createState() => _AccountCreateStepState();
}

class _AccountCreateStepState extends State<AccountCreateStep> {
  bool _isLoading = false;

  Future<void> _handleAuthSuccess(UserProfile profile) async {
    // 🌸 Eğer kullanıcının zaten kayıtlı ve tamamlanmış bir profili varsa (önceden bir kullanıcı adı varsa)
    // Onboarding'i atla ve doğrudan Ana Ekrana geç
    if (profile.username.isNotEmpty &&
        profile.username != 'calenda_user' &&
        profile.username != 'apple_user') {
      await context.read<StorageService>().setOnboardingCompleted();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, a1, a2) => const HomeScreen(),
          transitionsBuilder: (context, a1, a2, child) =>
              FadeTransition(opacity: a1, child: child),
        ),
        (route) => false,
      );
      return;
    }

    // 🌸 Onboarding akışındaki yeni kullanıcı (Apple, Google veya E-posta ile giriş yapsa dahi)
    // kesinlikle e-posta ön ekiyle (örn: merome813) sınırlandırılmaz!
    // Kullanıcı adı bilinçli olarak BOŞ bırakılır ve sonraki sayfada (ProfileInfoStep)
    // kullanıcının kendi istediği ve müsait olan kullanıcı adını seçmesi sağlanır.
    widget.state.isGoogleAuthed = true;
    if (profile.firstName.isNotEmpty && profile.firstName != 'Kullanıcı' && profile.firstName != 'Calenda') {
      widget.state.firstName = profile.firstName;
    }
    if (profile.lastName.isNotEmpty) {
      widget.state.lastName = profile.lastName;
    }
    widget.state.username = ''; // 🚨 Kullanıcı adı boş! Kullanıcı sonraki sayfada kendi belirleyecek!
    widget.onNext();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await context.read<PlannerProvider>().signInWithGoogle();
      if (success && mounted) {
        final profile = context.read<PlannerProvider>().userProfile;
        await _handleAuthSuccess(profile);
      }
    } on PlatformException catch (e, st) {
      if (mounted) {
        if (e.code == 'sign_in_canceled' || e.code == 'canceled') {
          return;
        }
        ErrorLogger.log('AccountCreateStep.Google.PlatformException', e, st);
        String userMsg = 'Giriş yapılamadı. Lütfen tekrar deneyin.';
        if (e.code == 'network_error') {
          userMsg = 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
        } else if (e.message != null && e.message!.isNotEmpty && e.message!.length < 100) {
          userMsg = e.message!;
        }
        AestheticSnackBar.showError(context, userMsg);
      }
    } catch (e, st) {
      if (mounted) {
        final errorStr = e.toString();
        if (!errorStr.contains('sign_in_canceled') &&
            !errorStr.contains('canceled') &&
            !errorStr.contains('popup_closed_by_user')) {
          ErrorLogger.log('AccountCreateStep.Google', e, st);
          String userMsg = 'Giriş yapılamadı. Lütfen tekrar deneyin.';
          if (errorStr.contains('network') || errorStr.contains('SocketException')) {
            userMsg = 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
          } else if (errorStr.contains('origin_mismatch') || errorStr.contains('unauthorized_client')) {
            userMsg = 'Google yetkilendirme yapılandırması kontrol edilmelidir.';
          } else if (errorStr.length < 100 && !errorStr.contains('file:///')) {
            userMsg = 'Giriş yapılamadı: $errorStr';
          }
          AestheticSnackBar.showError(context, userMsg);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await context.read<PlannerProvider>().signInWithApple();
      if (success && mounted) {
        final profile = context.read<PlannerProvider>().userProfile;
        await _handleAuthSuccess(profile);
      }
    } catch (e, st) {
      if (mounted) {
        final errorStr = e.toString();
        if (!errorStr.contains('canceled') &&
            !errorStr.contains('Canceled') &&
            !errorStr.contains('authorization error 1001')) {
          ErrorLogger.log('AccountCreateStep.Apple', e, st);
          AestheticSnackBar.showError(context, 'Apple ile giriş yapılamadı: $errorStr');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleEmailAuth() {
    EmailAuthSheet.show(
      context,
      isLoginInitial: false,
      onSuccess: (profile) async {
        await _handleAuthSuccess(profile);
      },
    );
  }

  void _showTermsDialog(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFFFAF7F2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6C8BB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: AppTypography.sfProRounded(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2B33),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    content,
                    style: AppTypography.sfPro(
                      fontSize: 14,
                      color: const Color(0xFF7A5861),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              BouncingWidget(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A2B33),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Anladım',
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    const buttonPink = Color(0xFFE6ABA7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // ── Başlık (Önceki ekranlarla birebir uyumlu) ──
          Text(
            'Hesabını Oluştur',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Planlarını, hedeflerini ve özel avatarını güvende tutmak için bir hesap oluştur.',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const Spacer(flex: 1),

          // ── 1. APPLE İLE DEVAM ET BUTONU ──
          BouncingWidget(
            scaleFactor: 0.98,
            onTap: _isLoading ? () {} : _handleAppleSignIn,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1F),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.apple,
                          size: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Apple ile Devam Et',
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

          // ── 2. GOOGLE İLE DEVAM ET BUTONU ──
          BouncingWidget(
            scaleFactor: 0.98,
            onTap: _isLoading ? () {} : _handleGoogleSignIn,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: titleColor),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                          width: 22,
                          height: 22,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 28, color: titleColor),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Google ile Devam Et',
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

          const SizedBox(height: 12),

          // ── 3. E-POSTA İLE DEVAM ET BUTONU ──
          BouncingWidget(
            scaleFactor: 0.98,
            onTap: _isLoading ? () {} : _handleEmailAuth,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF3ECE2),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5DACD), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mail_outline_rounded,
                    size: 22,
                    color: titleColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'E-posta ile Devam Et',
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

          // ── E-Posta İzni Checkbox ──
          GestureDetector(
            onTap: () {
              setState(() {
                widget.state.marketingEmailOptIn = !widget.state.marketingEmailOptIn;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: widget.state.marketingEmailOptIn ? buttonPink : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: widget.state.marketingEmailOptIn ? buttonPink : const Color(0xFFD4C7BA),
                      width: 1.5,
                    ),
                  ),
                  child: widget.state.marketingEmailOptIn
                      ? const Center(child: Icon(Icons.check_rounded, size: 15, color: Colors.white))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Haftalık planlama ilhamları ve güncellemeler almak istiyorum.',
                    style: AppTypography.sfPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: subtitleColor,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          // ── Kullanım Şartları ve Gizlilik Politikası ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  'Devam ederek ',
                  style: AppTypography.sfPro(fontSize: 11.5, color: const Color(0xFFA69389)),
                ),
                GestureDetector(
                  onTap: () => _showTermsDialog(
                    context,
                    'Kullanım Koşulları',
                    'Calenda uygulamasını kullanarak kişisel verilerinizin cihazınızda ve güvenli bulut altyapısında işlenmesini onaylamış olursunuz.\n\n1. Hesap Güvenliği: Giriş işlemleriniz Sign in with Apple ve Google Identity altyapısı ile korunur.\n2. Veri Mülkiyeti: Tüm plan, rutin ve not içerikleri münhasıran kullanıcıya aittir.\n3. Lisans ve Koşullar: Uygulama kişisel kullanım lisansı ile sunulmaktadır.\n\nResmi Destek: calenda.support@gmail.com',
                  ),
                  child: Text(
                    'Kullanım Koşulları',
                    style: AppTypography.sfPro(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  ' ve ',
                  style: AppTypography.sfPro(fontSize: 11.5, color: const Color(0xFFA69389)),
                ),
                GestureDetector(
                  onTap: () => _showTermsDialog(
                    context,
                    'Gizlilik Politikası',
                    'Calenda, kullanıcı gizliliğini ve kişisel verilerin korunmasını temel ilke olarak kabul eder.\n\n1. Veri Güvenliği: Ad ve e-posta verileriniz yalnızca hesap doğrulama ve senkronizasyon amacıyla işlenir; üçüncü taraflara satılmaz veya reklam amaçlı aktarılmaz.\n2. Şifreli Depolama: Tüm takvim kayıtlarınız cihazınızda ve Supabase altyapısında uçtan uca şifrelenir.\n3. Hesap Silme: Ayarlar ekranı üzerinden dilediğiniz an tüm verilerinizi kalıcı olarak silebilirsiniz.\n\nResmi İletişim: calenda.support@gmail.com',
                  ),
                  child: Text(
                    'Gizlilik Politikası',
                    style: AppTypography.sfPro(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  '\'nı kabul etmiş sayılırsınız.',
                  style: AppTypography.sfPro(fontSize: 11.5, color: const Color(0xFFA69389)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 44),
        ],
      ),
    );
  }
}
