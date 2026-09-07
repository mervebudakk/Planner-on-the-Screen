import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_typography.dart';
import '../services/error_logger.dart';
import '../widgets/bouncing_widget.dart';
import '../../features/planner/providers/planner_provider.dart';
import '../models/user_profile.dart';

/// ✉️ Calenda — Apple Estetiğinde E-Posta ile Giriş / Kayıt Alt Sayfası
class EmailAuthSheet extends StatefulWidget {
  final bool isLoginInitial;
  final Function(UserProfile profile) onSuccess;

  const EmailAuthSheet({
    super.key,
    this.isLoginInitial = true,
    required this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    bool isLoginInitial = true,
    required Function(UserProfile profile) onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: EmailAuthSheet(
          isLoginInitial: isLoginInitial,
          onSuccess: onSuccess,
        ),
      ),
    );
  }

  @override
  State<EmailAuthSheet> createState() => _EmailAuthSheetState();
}

class _EmailAuthSheetState extends State<EmailAuthSheet> {
  late bool _isLogin;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLoginInitial;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Lütfen geçerli bir e-posta adresi girin.');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Şifre en az 6 karakter olmalıdır.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final planner = context.read<PlannerProvider>();
      bool success = false;
      if (_isLogin) {
        success = await planner.signInWithEmail(email, password);
      } else {
        success = await planner.signUpWithEmail(email: email, password: password);
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        widget.onSuccess(planner.userProfile);
      } else {
        setState(() {
          _errorMessage = _isLogin
              ? 'Giriş yapılamadı. Bilgilerinizi kontrol edin.'
              : 'Kayıt oluşturulamadı. Lütfen tekrar deneyin.';
        });
      }
    } catch (e, st) {
      ErrorLogger.log('EmailAuthSheet._handleSubmit', e, st);
      if (!mounted) return;
      final raw = e.toString();
      String msg = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      if (raw.contains('Invalid login credentials') || raw.contains('invalid_grant')) {
        msg = 'E-posta veya şifre hatalı.';
      } else if (raw.contains('User already registered')) {
        msg = 'Bu e-posta ile zaten bir hesap var. Lütfen giriş yapın.';
      } else if (raw.contains('SocketException') || raw.contains('network')) {
        msg = 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
      }
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    const buttonPink = Color(0xFFE6ABA7);
    const cardBg = Color(0xFFFAF7F2);

    return Container(
      decoration: const BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sürükleme Tutamacı
            Center(
              child: Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6C8BB),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Başlık
            Text(
              _isLogin ? 'E-posta ile Giriş Yap' : 'E-posta ile Hesap Oluştur',
              textAlign: TextAlign.center,
              style: AppTypography.sfProRounded(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isLogin
                  ? 'Kayıtlı hesabına giriş yaparak kaldığın yerden devam et.'
                  : 'Yeni bir hesap açarak planlarını ve hedeflerini güvende tut.',
              textAlign: TextAlign.center,
              style: AppTypography.sfPro(
                fontSize: 13,
                color: subtitleColor,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),

            // Giriş / Kayıt Segment Değiştirici
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFE8DF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isLogin = true;
                        _errorMessage = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _isLogin ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isLogin
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Giriş Yap',
                            style: AppTypography.sfProRounded(
                              fontSize: 14,
                              fontWeight: _isLogin ? FontWeight.w700 : FontWeight.w500,
                              color: _isLogin ? titleColor : subtitleColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isLogin = false;
                        _errorMessage = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: !_isLogin ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !_isLogin
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Hesap Oluştur',
                            style: AppTypography.sfProRounded(
                              fontSize: 14,
                              fontWeight: !_isLogin ? FontWeight.w700 : FontWeight.w500,
                              color: !_isLogin ? titleColor : subtitleColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // E-posta Alanı
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              style: AppTypography.sfPro(fontSize: 15, color: titleColor),
              decoration: InputDecoration(
                hintText: 'E-posta adresi',
                hintStyle: AppTypography.sfPro(fontSize: 14, color: subtitleColor.withValues(alpha: 0.6)),
                prefixIcon: const Icon(Icons.mail_outline_rounded, color: subtitleColor, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFEADBCE), width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFEADBCE), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: buttonPink, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Şifre Alanı
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: AppTypography.sfPro(fontSize: 15, color: titleColor),
              decoration: InputDecoration(
                hintText: 'Şifre (en az 6 karakter)',
                hintStyle: AppTypography.sfPro(fontSize: 14, color: subtitleColor.withValues(alpha: 0.6)),
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: subtitleColor, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: subtitleColor,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFEADBCE), width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFEADBCE), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: buttonPink, width: 1.8),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: AppTypography.sfPro(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ],

            const SizedBox(height: 22),

            // Ana Aksiyon Butonu
            BouncingWidget(
              onTap: _isLoading ? () {} : _handleSubmit,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A2B33),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A2B33).withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          _isLogin ? 'Giriş Yap' : 'Kayıt Ol ve Devam Et',
                          style: AppTypography.sfProRounded(
                            fontSize: 15.5,
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
    );
  }
}
