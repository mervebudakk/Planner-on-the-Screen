import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../models/onboarding_state.dart';

/// 🔐 Adım 5: Google ile Hesap Oluşturma / Bağlama
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await context.read<PlannerProvider>().signInWithGoogle();
      if (success && mounted) {
        final profile = context.read<PlannerProvider>().userProfile;
        widget.state.isGoogleAuthed = true;
        widget.state.firstName = profile.firstName;
        widget.state.lastName = profile.lastName;
        widget.state.username = profile.username;
        widget.onNext();
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        // Kullanıcı pencereyi veya pop-up'ı kapattıysa hata gösterme
        if (!errorStr.contains('sign_in_canceled') &&
            !errorStr.contains('canceled') &&
            !errorStr.contains('popup_closed_by_user')) {
          String userMsg = 'Giriş yapılamadı. Lütfen tekrar deneyin.';
          if (errorStr.contains('network') || errorStr.contains('SocketException')) {
            userMsg = 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
          } else if (errorStr.contains('origin_mismatch') || errorStr.contains('unauthorized_client')) {
            userMsg = 'Google yetkilendirme yapılandırması kontrol edilmelidir.';
          } else if (errorStr.length < 100 && !errorStr.contains('file:///')) {
            userMsg = 'Giriş yapılamadı: $errorStr';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userMsg,
                style: AppTypography.sfPro(fontSize: 13, color: Colors.white),
              ),
              backgroundColor: const Color(0xFFC47B89),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          const SizedBox(height: 20),

          // ── Başlık ──
          Text(
            'Hesabını Oluştur',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Planlarını, hedeflerini ve özel avatarını güvende tutmak için bir hesap oluştur.',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const Spacer(flex: 1),

          // ── Google ile Giriş Yap Butonu ──
          BouncingWidget(
            onTap: _isLoading ? () {} : _handleGoogleSignIn,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              height: 56,
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

          const SizedBox(height: 14),

          // ── Misafir Olarak / Giriş Yapmadan Devam Et ──
          BouncingWidget(
            onTap: () {
              widget.state.isGoogleAuthed = false;
              widget.onNext();
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE8DFD5), width: 1),
              ),
              child: Center(
                child: Text(
                  'Giriş Yapmadan Devam Et',
                  style: AppTypography.sfPro(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

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
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.state.marketingEmailOptIn ? buttonPink : const Color(0xFFD4C7BA),
                      width: 1.5,
                    ),
                  ),
                  child: widget.state.marketingEmailOptIn
                      ? const Center(child: Icon(Icons.check_rounded, size: 16, color: Colors.white))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Calenda\'dan haftalık motivasyon, estetik duvar kâğıtları ve ilham dolu içerikler almak istiyorum.',
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

          const Spacer(flex: 2),

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
                    'Calenda uygulamasını kullanarak kişisel verilerinizin cihazınızda güvenle işlenmesini ve yedeklenmesini onaylamış olursunuz.\n\n1. Hesap Güvenliği: Hesabınız Google Authentication ile güvence altındadır.\n2. Veri Gizliliği: Planlarınız ve notlarınız tamamen size aittir.\n3. Hizmet Standartları: Calenda, günlük odaklanma ve planlama süreçlerinizi kolaylaştırmak için tasarlanmıştır.',
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
                    'Gizliliğiniz bizim için kutsaldır.\n\n1. Kişisel Veriler: Adınız, e-postanız ve doğum tarihiniz asla üçüncü şahıslarla paylaşılmaz.\n2. Yerel Depolama: Tüm plan ve takvim verileriniz öncelikli olarak cihazınızda şifreli tutulur.\n3. Çerezler ve Analiz: Yalnızca uygulamanın performansını artırmak için anonim kullanım verileri toplanır.',
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
