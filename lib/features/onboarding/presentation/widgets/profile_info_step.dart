import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../models/onboarding_state.dart';

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
  bool _isCheckingUsername = false;

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
  }

  @override
  void dispose() {
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

  Future<void> _validateAndSubmit() async {
    final firstName = _firstNameController.text.trim();
    final rawUsername = _usernameController.text.trim().replaceAll('@', '');
    final cleanUsername = rawUsername.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    if (firstName.isEmpty && cleanUsername.isEmpty) {
      setState(() => _errorMessage = 'Lütfen adınızı ve kullanıcı adınızı girin.');
      return;
    }

    if (cleanUsername.isEmpty || cleanUsername.length < 3) {
      setState(() => _errorMessage = 'Kullanıcı adı en az 3 karakter olmalı ve yalnızca harf, rakam veya alt çizgi içermelidir.');
      return;
    }

    if (cleanUsername.length > 20) {
      setState(() => _errorMessage = 'Kullanıcı adı en fazla 20 karakter olabilir.');
      return;
    }

    // 🔍 Supabase üzerinden benzersizlik kontrolü (Username Uniqueness)
    setState(() {
      _isCheckingUsername = true;
      _errorMessage = null;
    });

    try {
      final isAvailable = await SupabaseService.instance.isUsernameAvailable(cleanUsername);
      if (!isAvailable && mounted) {
        setState(() {
          _isCheckingUsername = false;
          _errorMessage = '@$cleanUsername kullanıcı adı zaten alınmış. Lütfen farklı bir kullanıcı adı seçin.';
        });
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isCheckingUsername = false);

    widget.state.firstName = firstName.isNotEmpty ? firstName : 'Kullanıcı';
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
                  Container(
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

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
            text: _isCheckingUsername ? 'Kontrol Ediliyor...' : 'Devam Et',
            height: 52,
            onPressed: _isCheckingUsername ? () {} : _validateAndSubmit,
          ),

          const SizedBox(height: 44),
        ],
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
