import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/widgets/vintage_framed_avatar.dart';
import '../../../planner/providers/planner_provider.dart';

/// 🌸 Calenda — Tek Ekran Zarafetinde Profil ve Hedef Düzenleme Merkezi
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _dayController;
  late TextEditingController _monthController;
  late TextEditingController _yearController;

  late String _selectedAnimal;
  late String _selectedAccessory;
  late String _selectedBgColor;
  late int _weeklyGoalDays;
  late int _dailyFocusMinutes;
  late String _coreFocusArea;

  bool _isUsernameLocked = true;
  bool _isSaving = false;
  String? _usernameError;

  // 🐾 Karakter Seçenekleri
  final List<Map<String, String>> _animals = const [
    {'id': 'rabbit', 'asset': 'assets/avatars/rabbit.webp'},
    {'id': 'bear', 'asset': 'assets/avatars/bear.webp'},
    {'id': 'seal', 'asset': 'assets/avatars/seal.webp'},
    {'id': 'cat', 'asset': 'assets/avatars/cat.webp'},
    {'id': 'fox', 'asset': 'assets/avatars/fox.webp'},
    {'id': 'deer', 'asset': 'assets/avatars/deer.webp'},
    {'id': 'puppy', 'asset': 'assets/avatars/puppy.webp'},
  ];

  // 🎀 Aksesuar Seçenekleri
  final List<Map<String, String>> _accessories = const [
    {'id': 'none', 'asset': ''},
    {'id': 'strawberry_beret', 'asset': 'assets/accessories/strawberry_beret.webp'},
    {'id': 'flower_crown', 'asset': 'assets/accessories/flower_crown.webp'},
    {'id': 'sprout_clip', 'asset': 'assets/accessories/sprout_clip.webp'},
    {'id': 'sleep_mask', 'asset': 'assets/accessories/sleep_mask.webp'},
    {'id': 'velvet_bowtie', 'asset': 'assets/accessories/velvet_bowtie.webp'},
    {'id': 'gold_crown', 'asset': 'assets/accessories/gold_crown.webp'},
    {'id': 'teacup_hat', 'asset': 'assets/accessories/teacup_hat.webp'},
  ];

  // 🎨 Pastel Arka Plan Renkleri
  final List<Map<String, dynamic>> _bgColors = const [
    {'hex': '#FAF7F2', 'color': Color(0xFFFAF7F2)},
    {'hex': '#F4E8D7', 'color': Color(0xFFF4E8D7)},
    {'hex': '#FDEBF0', 'color': Color(0xFFFDEBF0)},
    {'hex': '#DAEAF6', 'color': Color(0xFFDAEAF6)},
    {'hex': '#EBF7EE', 'color': Color(0xFFEBF7EE)},
    {'hex': '#FCF4DD', 'color': Color(0xFFFCF4DD)},
    {'hex': '#E8DFF5', 'color': Color(0xFFE8DFF5)},
  ];

  // ⏱️ Günlük Odaklanma Seçenekleri (Dakika)
  final List<int> _focusMinutesOptions = const [0, 15, 25, 45, 60, 90, 120];

  // 🎯 Ana Odak Alanı Seçenekleri
  final List<String> _focusAreas = const [
    'Sakin & Huzurlu Haftalık Ajanda',
    'Dersler & Akademik Başarı',
    'Sınavlara Hazırlık (YKS / KPSS / Dil)',
    'Kişisel Gelişim & Sağlıklı Rutinler',
    'İş, Proje & Kariyer',
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<PlannerProvider>().userProfile;

    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);

    // Eğer kullanıcı adı calenda_user, apple_user veya boş ise kullanıcı ilk kez belirleyebilir
    final hasValidUsername = profile.username.isNotEmpty &&
        profile.username != 'calenda_user' &&
        profile.username != 'apple_user' &&
        profile.username != 'misafir';

    _isUsernameLocked = hasValidUsername;
    _usernameController = TextEditingController(
      text: hasValidUsername ? profile.username : '',
    );

    _selectedAnimal = _cleanAnimalId(profile.avatarAnimal);
    _selectedAccessory = profile.avatarAccessory.isNotEmpty ? profile.avatarAccessory : 'none';
    _selectedBgColor = profile.avatarBgColor.isNotEmpty ? profile.avatarBgColor : '#FAF7F2';
    _weeklyGoalDays = profile.weeklyGoalDays;
    _dailyFocusMinutes = profile.dailyFocusMinutes;
    _coreFocusArea = profile.coreFocusArea.isNotEmpty ? profile.coreFocusArea : _focusAreas.first;

    if (profile.birthDate != null) {
      _dayController = TextEditingController(text: profile.birthDate!.day.toString());
      _monthController = TextEditingController(text: profile.birthDate!.month.toString());
      _yearController = TextEditingController(text: profile.birthDate!.year.toString());
    } else {
      _dayController = TextEditingController();
      _monthController = TextEditingController();
      _yearController = TextEditingController();
    }
  }

  String _cleanAnimalId(String raw) {
    return raw
        .replaceAll('01_', '')
        .replaceAll('02_', '')
        .replaceAll('03_', '')
        .replaceAll('04_', '')
        .replaceAll('05_', '')
        .replaceAll('06_', '')
        .replaceAll('07_', '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    final currentProfile = context.read<PlannerProvider>().userProfile;

    String finalUsername = _usernameController.text.trim().replaceAll('@', '').toLowerCase();

    // Eğer kullanıcı adı kilitli değilse doğrulama yap
    if (!_isUsernameLocked) {
      final clean = finalUsername.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
      if (clean.length < 3 || clean.length > 20) {
        setState(() => _usernameError = 'Kullanıcı adı 3-20 karakter arasında olmalıdır.');
        AestheticSnackBar.showError(context, 'Lütfen geçerli bir kullanıcı adı belirleyin.');
        return;
      }

      setState(() => _isSaving = true);
      final isAvailable = await SupabaseService.instance.isUsernameAvailable(
        clean,
        excludeUserId: currentProfile.id,
      );

      if (!mounted) return;
      if (!isAvailable) {
        setState(() {
          _isSaving = false;
          _usernameError = 'Bu kullanıcı adı zaten kullanımda.';
        });
        AestheticSnackBar.showError(context, 'Bu kullanıcı adı zaten alınmış.');
        return;
      }
      finalUsername = clean;
    } else {
      finalUsername = currentProfile.username;
    }

    setState(() => _isSaving = true);

    // Doğum tarihi çözümleme
    DateTime? birthDate;
    final d = int.tryParse(_dayController.text.trim());
    final m = int.tryParse(_monthController.text.trim());
    final y = int.tryParse(_yearController.text.trim());
    if (d != null && m != null && y != null && d >= 1 && d <= 31 && m >= 1 && m <= 12 && y >= 1920 && y <= DateTime.now().year) {
      birthDate = DateTime(y, m, d);
    } else {
      birthDate = currentProfile.birthDate;
    }

    final updated = currentProfile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: finalUsername,
      birthDate: birthDate,
      avatarAnimal: _selectedAnimal,
      avatarAccessory: _selectedAccessory,
      avatarBgColor: _selectedBgColor,
      weeklyGoalDays: _weeklyGoalDays,
      dailyFocusMinutes: _dailyFocusMinutes,
      coreFocusArea: _coreFocusArea,
    );

    await context.read<PlannerProvider>().updateUserProfile(updated);

    if (!mounted) return;
    AppHaptics.mediumImpact();
    AestheticSnackBar.showSuccess(context, 'Profilin başarıyla güncellendi ✨');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    final cardColor = isDark ? const Color(0xFF1B2E21) : const Color(0xFFFAF7F2);
    final borderColor = isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE);

    final animalAsset = 'assets/avatars/$_selectedAnimal.webp';
    final accessoryAsset = _selectedAccessory != 'none' ? 'assets/accessories/$_selectedAccessory.webp' : null;

    return AppleAmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: BouncingWidget(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: const Icon(Icons.close_rounded, size: 20, color: titleColor),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Profili Düzenle',
            style: AppTypography.sfProRounded(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: BouncingWidget(
                  onTap: _isSaving ? () {} : _handleSave,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2B33),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Kaydet',
                            style: AppTypography.sfProRounded(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          children: [
            // ── 1. CANLI AVATAR ÖNİZLEMESİ ──
            Center(
              child: Column(
                children: [
                  VintageFramedAvatar(
                    animalAsset: animalAsset,
                    accessoryAsset: accessoryAsset,
                    backgroundColor: AppColors.hexToColor(_selectedBgColor),
                    height: 140,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Karakter ve Çerçeve',
                    style: AppTypography.sfPro(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── 2. AVATAR STÜDYOSU (HAYVAN / AKSESUAR / ARKA PLAN) ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Karakter Seçimi', titleColor),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 58,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _animals.length,
                      itemBuilder: (context, i) {
                        final a = _animals[i];
                        final isSelected = _selectedAnimal == a['id'];
                        return GestureDetector(
                          onTap: () {
                            AppHaptics.lightImpact();
                            setState(() => _selectedAnimal = a['id']!);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 54,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF3E7DC) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? titleColor : const Color(0xFFE5DACD),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(a['asset']!),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildSectionTitle('Aksesuar Seçimi', titleColor),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 58,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _accessories.length,
                      itemBuilder: (context, i) {
                        final acc = _accessories[i];
                        final isSelected = _selectedAccessory == acc['id'];
                        return GestureDetector(
                          onTap: () {
                            AppHaptics.lightImpact();
                            setState(() => _selectedAccessory = acc['id']!);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 54,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF3E7DC) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? titleColor : const Color(0xFFE5DACD),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: acc['id'] == 'none'
                                ? Center(
                                    child: Icon(Icons.block_rounded, size: 20, color: titleColor.withValues(alpha: 0.5)),
                                  )
                                : Image.asset(acc['asset']!),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildSectionTitle('Arka Plan Rengi', titleColor),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _bgColors.length,
                      itemBuilder: (context, i) {
                        final bg = _bgColors[i];
                        final isSelected = _selectedBgColor == bg['hex'];
                        return GestureDetector(
                          onTap: () {
                            AppHaptics.lightImpact();
                            setState(() => _selectedBgColor = bg['hex'] as String);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 38,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: bg['color'] as Color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? titleColor : const Color(0xFFD4C7BA),
                                width: isSelected ? 2.5 : 1.2,
                              ),
                            ),
                            child: isSelected
                                ? const Center(child: Icon(Icons.check_rounded, size: 18, color: titleColor))
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 3. KİŞİSEL BİLGİLER (İSİM, SOYİSİM, KULLANICI ADI, DOĞUM TARİHİ) ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Kişisel Bilgiler', titleColor),
                  const SizedBox(height: 14),

                  // Ad ve Soyad
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('AD (İSTEĞE BAĞLI)', titleColor),
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
                            _buildLabel('SOYAD (İSTEĞE BAĞLI)', titleColor),
                            const SizedBox(height: 6),
                            _buildTextField(_lastNameController, 'Soyadın', titleColor),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Kullanıcı Adı (Değiştirilemez veya ilk kez tanımlanır)
                  _buildLabel(
                    _isUsernameLocked ? 'KULLANICI ADI (DEĞİŞTİRİLEMEZ)' : 'KULLANICI ADI (ZORUNLU)',
                    titleColor,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isUsernameLocked
                          ? const Color(0xFFEDE5DC).withValues(alpha: 0.65)
                          : Colors.white.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _usernameError != null
                            ? Colors.redAccent
                            : (_isUsernameLocked ? const Color(0xFFDCD2C7) : const Color(0xFFE5DACD)),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Text(
                          '@',
                          style: AppTypography.sfProRounded(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: titleColor.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextField(
                            controller: _usernameController,
                            enabled: !_isUsernameLocked,
                            style: AppTypography.sfProRounded(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _isUsernameLocked ? titleColor.withValues(alpha: 0.7) : titleColor,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'kullaniciadi',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_isUsernameLocked)
                          const Icon(Icons.lock_rounded, size: 18, color: Color(0xFF8A7A74)),
                      ],
                    ),
                  ),
                  if (_usernameError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _usernameError!,
                      style: AppTypography.sfPro(fontSize: 12, color: Colors.redAccent),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Doğum Tarihi (İsteğe Bağlı)
                  _buildLabel('DOĞUM TARİHİ (İSTEĞE BAĞLI)', titleColor),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildDateBox(_dayController, 'Gün', 2, titleColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: _buildDateBox(_monthController, 'Ay', 2, titleColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: _buildDateBox(_yearController, 'Yıl', 4, titleColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 4. VERİMLİLİK VE HAFTALIK HEDEFLER ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Verimlilik ve Alışkanlıklar', titleColor),
                  const SizedBox(height: 14),

                  _buildLabel('GÜNLÜK ÇALIŞMA & ODAKLANMA HEDEFİ', titleColor),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _focusMinutesOptions.map((mins) {
                      final isSelected = _dailyFocusMinutes == mins;
                      final label = mins == 0 ? 'Serbest' : '$mins dk';
                      return GestureDetector(
                        onTap: () {
                          AppHaptics.lightImpact();
                          setState(() => _dailyFocusMinutes = mins);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF4A2B33) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF4A2B33) : const Color(0xFFE5DACD),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            label,
                            style: AppTypography.sfProRounded(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : titleColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  _buildLabel('HAFTADA KAÇ GÜN ÇALIŞACAKSIN?', titleColor),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (idx) {
                      final dayNum = idx + 1;
                      final isSelected = _weeklyGoalDays == dayNum;
                      return GestureDetector(
                        onTap: () {
                          AppHaptics.lightImpact();
                          setState(() => _weeklyGoalDays = dayNum);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 40,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF4A2B33) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF4A2B33) : const Color(0xFFE5DACD),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$dayNum',
                              style: AppTypography.sfProRounded(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : titleColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 18),

                  _buildLabel('ANA ODAK ALANI', titleColor),
                  const SizedBox(height: 8),
                  Column(
                    children: _focusAreas.map((area) {
                      final isSelected = _coreFocusArea == area;
                      return GestureDetector(
                        onTap: () {
                          AppHaptics.lightImpact();
                          setState(() => _coreFocusArea = area);
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF3ECE2) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? titleColor : const Color(0xFFE5DACD),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                size: 18,
                                color: isSelected ? titleColor : const Color(0xFFB5A69B),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  area,
                                  style: AppTypography.sfProRounded(
                                    fontSize: 13.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── 5. KAYDET BUTONU ──
            _isSaving
                ? Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6ABA7),
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      ),
                    ),
                  )
                : AestheticPlannerButton(
                    text: 'Değişiklikleri Kaydet',
                    height: 54,
                    onPressed: _handleSave,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text, Color color) {
    return Text(
      text,
      style: AppTypography.sfProRounded(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: AppTypography.sfPro(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color.withValues(alpha: 0.65),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color titleColor) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DACD), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        style: AppTypography.sfProRounded(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDateBox(TextEditingController controller, String hint, int maxLength, Color titleColor) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DACD), width: 1.2),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: maxLength,
          textAlign: TextAlign.center,
          style: AppTypography.sfProRounded(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
