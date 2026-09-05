import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../models/onboarding_state.dart';

/// Kullanıcı adı doğrulama durumları
enum _UsernameValidationStatus {
  idle,
  checking,
  valid,
  invalid,
}

/// 📝 Adım 6: Kişisel Bilgiler & 3 Kutulu Doğum Tarihi
class ProfileInfoStep extends StatefulWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const ProfileInfoStep({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  State<ProfileInfoStep> createState() => _ProfileInfoStepState();
}

class _ProfileInfoStepState extends State<ProfileInfoStep> {
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  late TextEditingController _dayController;
  late TextEditingController _monthController;
  late TextEditingController _yearController;

  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  String? _errorMessage;
  Timer? _debounceTimer;
  _UsernameValidationStatus _usernameStatus = _UsernameValidationStatus.idle;
  String? _usernameValidationMessage;
  String? _lastCheckedUsername;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.state.username);
    _firstNameController = TextEditingController(text: widget.state.firstName);
    _lastNameController = TextEditingController(text: widget.state.lastName);

    _dayController = TextEditingController(
      text: widget.state.birthDay != null ? widget.state.birthDay.toString().padLeft(2, '0') : '',
    );
    _monthController = TextEditingController(
      text: widget.state.birthMonth != null ? widget.state.birthMonth.toString().padLeft(2, '0') : '',
    );
    _yearController = TextEditingController(
      text: widget.state.birthYear != null ? widget.state.birthYear.toString() : '',
    );

    if (_usernameController.text.trim().isNotEmpty) {
      _onUsernameChanged(_usernameController.text);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounceTimer?.cancel();
    final clean = value.trim().replaceAll('@', '');

    if (clean.isEmpty) {
      setState(() {
        _usernameStatus = _UsernameValidationStatus.idle;
        _usernameValidationMessage = null;
      });
      return;
    }

    if (clean.length < 3) {
      setState(() {
        _usernameStatus = _UsernameValidationStatus.invalid;
        _usernameValidationMessage = 'Kullanıcı adı en az 3 karakter olmalıdır';
      });
      return;
    }

    if (clean.length > 20) {
      setState(() {
        _usernameStatus = _UsernameValidationStatus.invalid;
        _usernameValidationMessage = 'Kullanıcı adı en fazla 20 karakter olabilir';
      });
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(clean)) {
      setState(() {
        _usernameStatus = _UsernameValidationStatus.invalid;
        _usernameValidationMessage = 'Sadece harf, rakam ve alt çizgi (_) kullanılabilir';
      });
      return;
    }

    // Doğrulama kontrolüne geçiş
    setState(() {
      _usernameStatus = _UsernameValidationStatus.checking;
      _usernameValidationMessage = 'Kullanıcı adı kontrol ediliyor...';
    });

    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      _checkUsernameAvailability(clean);
    });
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    final lower = username.toLowerCase();
    _lastCheckedUsername = lower;
    try {
      final isAvailable = await SupabaseService.instance.isUsernameAvailable(lower);
      if (!mounted) return isAvailable;

      // Kullanıcı bu sırada metni değiştirmişse sonucu yok say
      final currentClean = _usernameController.text.trim().replaceAll('@', '').toLowerCase();
      if (currentClean != lower) return isAvailable;

      setState(() {
        if (isAvailable) {
          _usernameStatus = _UsernameValidationStatus.valid;
          _usernameValidationMessage = 'Bu kullanıcı adı kullanılabilir!';
        } else {
          _usernameStatus = _UsernameValidationStatus.invalid;
          _usernameValidationMessage = '@$lower zaten alınmış, lütfen farklı bir kullanıcı adı seçin';
        }
      });
      return isAvailable;
    } catch (_) {
      if (mounted) {
        setState(() {
          _usernameStatus = _UsernameValidationStatus.valid;
          _usernameValidationMessage = 'Bu kullanıcı adı kullanılabilir!';
        });
      }
      return true;
    }
  }

  Future<void> _validateAndSubmit() async {
    final firstName = _firstNameController.text.trim();
    final rawUsername = _usernameController.text.trim().replaceAll('@', '');
    final cleanUsername = rawUsername.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    if (firstName.isEmpty && cleanUsername.isEmpty) {
      setState(() => _errorMessage = 'Lütfen adınızı ve kullanıcı adınızı girin.');
      HapticFeedback.lightImpact();
      return;
    }

    if (cleanUsername.isEmpty || cleanUsername.length < 3) {
      setState(() {
        _usernameStatus = _UsernameValidationStatus.invalid;
        _usernameValidationMessage = 'Kullanıcı adı en az 3 karakter olmalı ve yalnızca harf, rakam veya alt çizgi içermelidir.';
        _errorMessage = 'Lütfen geçerli bir kullanıcı adı belirleyin.';
      });
      HapticFeedback.lightImpact();
      return;
    }

    if (cleanUsername.length > 20) {
      setState(() {
        _usernameStatus = _UsernameValidationStatus.invalid;
        _usernameValidationMessage = 'Kullanıcı adı en fazla 20 karakter olabilir.';
        _errorMessage = 'Kullanıcı adı en fazla 20 karakter olabilir.';
      });
      HapticFeedback.lightImpact();
      return;
    }

    // Bekleyen debounce varsa iptal edip hemen kontrol et
    _debounceTimer?.cancel();
    if (_usernameStatus != _UsernameValidationStatus.valid || _lastCheckedUsername != cleanUsername) {
      setState(() {
        _usernameStatus = _UsernameValidationStatus.checking;
        _usernameValidationMessage = 'Kullanıcı adı kontrol ediliyor...';
      });
      final available = await _checkUsernameAvailability(cleanUsername);
      if (!available && mounted) {
        HapticFeedback.heavyImpact();
        return;
      }
    }

    if (firstName.isEmpty) {
      setState(() => _errorMessage = 'Lütfen adınızı girin.');
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => _errorMessage = null);

    widget.state.firstName = firstName;
    widget.state.lastName = _lastNameController.text.trim();
    widget.state.username = cleanUsername;

    final d = int.tryParse(_dayController.text);
    final m = int.tryParse(_monthController.text);
    final y = int.tryParse(_yearController.text);

    if (d != null && d >= 1 && d <= 31) widget.state.birthDay = d;
    if (m != null && m >= 1 && m <= 12) widget.state.birthMonth = m;
    if (y != null && y >= 1920 && y <= 2026) widget.state.birthYear = y;

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // ── Başlık (Önceki ekranlarla birebir uyumlu) ──
          Text(
            'Seni Yakından Tanıyalım',
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
            'Ajandanda sana nasıl hitap edelim ve doğum gününü ne zaman kutlayalım?',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Kullanıcı Adı ──
                  _buildLabel('KULLANICI ADI', titleColor),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _getUsernameBorderColor(),
                        width: _usernameStatus == _UsernameValidationStatus.valid || _usernameStatus == _UsernameValidationStatus.invalid ? 1.4 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getUsernameShadowColor(),
                          blurRadius: _usernameStatus != _UsernameValidationStatus.idle ? 8 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4ECE4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '@',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF8C7972),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _usernameController,
                            onChanged: _onUsernameChanged,
                            style: AppTypography.sfPro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'kullaniciadi',
                              hintStyle: TextStyle(color: Color(0xFFBFB2A7), fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildUsernameStatusIcon(),
                      ],
                    ),
                  ),

                  _buildUsernameHelperBadge(),

                  const SizedBox(height: 14),

                  // ── Ad ve Soyad (İki Kutu Yan Yana) ──
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('AD', titleColor),
                            const SizedBox(height: 6),
                            _buildTextField(_firstNameController, 'Adın', titleColor),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('SOYAD', titleColor),
                            const SizedBox(height: 6),
                            _buildTextField(_lastNameController, 'Soyadın', titleColor),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Doğum Tarihi (3 Ayrı Pastel Kutu) ──
                  _buildLabel('DOĞUM TARİHİ', titleColor),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // GÜN
                      Expanded(
                        flex: 3,
                        child: _buildDateBox(
                          controller: _dayController,
                          focusNode: _dayFocus,
                          hint: 'Gün',
                          maxLength: 2,
                          titleColor: titleColor,
                          onChanged: (val) {
                            if (val.length == 2) _monthFocus.requestFocus();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // AY
                      Expanded(
                        flex: 3,
                        child: _buildDateBox(
                          controller: _monthController,
                          focusNode: _monthFocus,
                          hint: 'Ay',
                          maxLength: 2,
                          titleColor: titleColor,
                          onChanged: (val) {
                            if (val.length == 2) _yearFocus.requestFocus();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // YIL
                      Expanded(
                        flex: 4,
                        child: _buildDateBox(
                          controller: _yearController,
                          focusNode: _yearFocus,
                          hint: 'Yıl',
                          maxLength: 4,
                          titleColor: titleColor,
                          onChanged: (_) {},
                        ),
                      ),
                    ],
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: AppTypography.sfPro(fontSize: 12.5, color: const Color(0xFFC45A65), fontWeight: FontWeight.w600),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Devam Et Butonu ──
          AestheticPlannerButton(
            text: 'Devam Et',
            height: 52,
            onPressed: _validateAndSubmit,
          ),

          const SizedBox(height: 44),
        ],
      ),
    );
  }

  Color _getUsernameBorderColor() {
    switch (_usernameStatus) {
      case _UsernameValidationStatus.valid:
        return const Color(0xFF3E7E52).withValues(alpha: 0.7);
      case _UsernameValidationStatus.invalid:
        return const Color(0xFFC45A65).withValues(alpha: 0.7);
      case _UsernameValidationStatus.checking:
        return const Color(0xFFD4A373).withValues(alpha: 0.6);
      case _UsernameValidationStatus.idle:
        return const Color(0xFFEADBCE);
    }
  }

  Color _getUsernameShadowColor() {
    switch (_usernameStatus) {
      case _UsernameValidationStatus.valid:
        return const Color(0xFF3E7E52).withValues(alpha: 0.08);
      case _UsernameValidationStatus.invalid:
        return const Color(0xFFC45A65).withValues(alpha: 0.08);
      case _UsernameValidationStatus.checking:
      case _UsernameValidationStatus.idle:
        return Colors.black.withValues(alpha: 0.02);
    }
  }

  Widget _buildUsernameStatusIcon() {
    switch (_usernameStatus) {
      case _UsernameValidationStatus.idle:
        return const SizedBox(width: 24, height: 24);

      case _UsernameValidationStatus.checking:
        return Tooltip(
          message: 'Kullanıcı adı kontrol ediliyor...',
          triggerMode: TooltipTriggerMode.tap,
          preferBelow: false,
          verticalOffset: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF4A2B33),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8C7972)),
            ),
          ),
        );

      case _UsernameValidationStatus.valid:
        return Tooltip(
          message: _usernameValidationMessage ?? 'Bu kullanıcı adı kullanılabilir!',
          triggerMode: TooltipTriggerMode.tap,
          preferBelow: false,
          verticalOffset: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF2E5A36),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF2E7D32),
              size: 16,
            ),
          ),
        );

      case _UsernameValidationStatus.invalid:
        return Tooltip(
          message: _usernameValidationMessage ?? 'Geçersiz kullanıcı adı',
          triggerMode: TooltipTriggerMode.tap,
          preferBelow: false,
          verticalOffset: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF5A2A33),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFFC45A65),
              size: 16,
            ),
          ),
        );
    }
  }

  Widget _buildUsernameHelperBadge() {
    if (_usernameStatus == _UsernameValidationStatus.idle || _usernameValidationMessage == null) {
      return const SizedBox(height: 6);
    }

    Color textColor;
    switch (_usernameStatus) {
      case _UsernameValidationStatus.valid:
        textColor = const Color(0xFF2E7D32);
        break;
      case _UsernameValidationStatus.invalid:
        textColor = const Color(0xFFC45A65);
        break;
      case _UsernameValidationStatus.checking:
        textColor = const Color(0xFF8C7972);
        break;
      case _UsernameValidationStatus.idle:
        return const SizedBox(height: 6);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
      child: Text(
        _usernameValidationMessage!,
        style: AppTypography.sfPro(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.25,
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: AppTypography.sfPro(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF8B7970),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color color) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        style: AppTypography.sfPro(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBFB2A7), fontSize: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDateBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required int maxLength,
    required Color titleColor,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLength),
        ],
        onChanged: onChanged,
        style: AppTypography.sfProRounded(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBFB2A7), fontSize: 13),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
