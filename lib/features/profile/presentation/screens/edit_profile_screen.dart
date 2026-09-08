import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/widgets/vintage_framed_avatar.dart';
import '../../../planner/providers/planner_provider.dart';

/// 🌿 Calenda — Estetik Profil, Karakter ve Ritim Düzenleme Merkezi
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dayController;
  late TextEditingController _monthController;
  late TextEditingController _yearController;

  late String _selectedAnimal;
  late String _selectedAccessory;
  late String _selectedBgColor;
  late int _weeklyGoalDays;
  late int _dailyFocusMinutes;
  late Set<String> _selectedFocusAreas;

  bool _isSaving = false;

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

  // ⏱️ Günlük Odaklanma Seçenekleri (Kurulum Sihirbazı FocusWheelStep ile Birebir Aynı)
  final List<Map<String, dynamic>> _focusOptions = const [
    {
      'minutes': 0,
      'title': 'Serbest Mod',
      'subtitle': 'Hedefsiz ve esnek tempo',
    },
    {
      'minutes': 45,
      'title': '1 Saatten Az',
      'subtitle': 'Günde 25 – 45 dakika',
    },
    {
      'minutes': 120,
      'title': '1 – 3 Saat Arası',
      'subtitle': 'Günde yaklaşık 2 saat',
    },
    {
      'minutes': 210,
      'title': '3 Saatten Fazla',
      'subtitle': 'Günde 3.5 saat ve üzeri',
    },
  ];

  // 🎯 Calenda Sana Nasıl Eşlik Etsin? (Kurulum Sihirbazı CoreGoalStep ile Birebir Aynı)
  final List<String> _focusAreas = const [
    'Dersler & Sınavlar',
    'Projeler & Çalışma Hayatı',
    'Günlük Rutinler & Alışkanlıklar',
    'Kişisel Planlama & Notlar',
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<PlannerProvider>().userProfile;

    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);

    _selectedAnimal = _cleanAnimalId(profile.avatarAnimal);
    _selectedAccessory = profile.avatarAccessory.isNotEmpty ? profile.avatarAccessory : 'none';
    _selectedBgColor = profile.avatarBgColor.isNotEmpty ? profile.avatarBgColor : '#FAF7F2';
    _weeklyGoalDays = profile.weeklyGoalDays;

    // Günlük odak süresini kurulum sihirbazındaki 4 seçenekle eşleştir
    final rawMins = profile.dailyFocusMinutes;
    if (_focusOptions.any((o) => o['minutes'] == rawMins)) {
      _dailyFocusMinutes = rawMins;
    } else if (rawMins <= 0) {
      _dailyFocusMinutes = 0;
    } else if (rawMins <= 45) {
      _dailyFocusMinutes = 45;
    } else if (rawMins <= 120) {
      _dailyFocusMinutes = 120;
    } else {
      _dailyFocusMinutes = 210;
    }

    final rawGoals = profile.coreFocusArea
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    _selectedFocusAreas = rawGoals.where((g) => _focusAreas.contains(g)).toSet();
    if (_selectedFocusAreas.isEmpty) {
      if (profile.coreFocusArea.contains('Ders') || profile.coreFocusArea.contains('Sınav')) {
        _selectedFocusAreas = {'Dersler & Sınavlar'};
      } else if (profile.coreFocusArea.contains('İş') || profile.coreFocusArea.contains('Proje')) {
        _selectedFocusAreas = {'Projeler & Çalışma Hayatı'};
      } else if (profile.coreFocusArea.contains('Rutin')) {
        _selectedFocusAreas = {'Günlük Rutinler & Alışkanlıklar'};
      } else {
        _selectedFocusAreas = {'Kişisel Planlama & Notlar'};
      }
    }

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

  String _getRhythmDescription(int days) {
    switch (days) {
      case 0:
        return 'Hedef baskısı olmadan dilediğin günlerde serbestçe plan yaparsın.';
      case 1:
      case 2:
        return 'Haftayı hafif ve sakin bir başlangıçla keşfet.';
      case 3:
      case 4:
        return 'Dengeli ve sürdürülebilir ideal bir haftalık ritim.';
      case 5:
        return 'Hafta içi odaklanma, hafta sonu hak edilmiş dinlenme!';
      case 6:
      case 7:
        return 'Yüksek verimlilik ve güçlü bir odaklanma hedefi!';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    final currentProfile = context.read<PlannerProvider>().userProfile;

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
      username: currentProfile.username, // Kullanıcı adı değiştirilmeden korunur
      birthDate: birthDate,
      avatarAnimal: _selectedAnimal,
      avatarAccessory: _selectedAccessory,
      avatarBgColor: _selectedBgColor,
      weeklyGoalDays: _weeklyGoalDays,
      dailyFocusMinutes: _dailyFocusMinutes,
      coreFocusArea: _selectedFocusAreas.join(', '),
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

    // 🌿 Calenda Soft Matcha Tasarım Paleti
    const titleColor = Color(0xFF1B3B26); // Koyu Doğal Orman / Matcha Yeşili
    const subtitleColor = Color(0xFF4E6B56); // Koyu Adaçayı Yeşili
    const matchaPrimary = Color(0xFF244E33); // Ana Matcha Vurgusu
    const matchaBorder = Color(0xFFDCE8DB); // Yumuşak Matcha Sınırı

    final cardColor = isDark ? const Color(0xFF18241D) : const Color(0xFFFAFBF9);
    final borderColor = isDark ? const Color(0xFF283D30) : matchaBorder;

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
                  color: Colors.white.withValues(alpha: 0.90),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: matchaPrimary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: matchaPrimary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
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
                      fontSize: 13.0,
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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
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
                              color: isSelected ? const Color(0xFFF0F6F0) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? matchaPrimary : const Color(0xFFE2EBE0),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: matchaPrimary.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
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
                              color: isSelected ? const Color(0xFFF0F6F0) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? matchaPrimary : const Color(0xFFE2EBE0),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: matchaPrimary.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: acc['id'] == 'none'
                                ? Center(
                                    child: Icon(Icons.block_rounded, size: 20, color: titleColor.withValues(alpha: 0.4)),
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
                                color: isSelected ? matchaPrimary : const Color(0xFFD6E2D4),
                                width: isSelected ? 2.5 : 1.2,
                              ),
                            ),
                            child: isSelected
                                ? const Center(child: Icon(Icons.check_rounded, size: 18, color: matchaPrimary))
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

            // ── 3. KİŞİSEL BİLGİLER (İSİM, SOYİSİM, DOĞUM TARİHİ) ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Kişisel Bilgiler', titleColor),
                  const SizedBox(height: 4),
                  Text(
                    'İsmin ajanda ve hatırlatıcılarında sana hitap etmek için kullanılır.',
                    style: AppTypography.sfPro(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
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

            // ── 4. PLANLAMA RİTMİN & HEDEFLERİN (Kurulum Sihirbazı ile Tam Uyumlu) ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Planlama Ritmin & Hedeflerin', titleColor),
                  const SizedBox(height: 4),
                  Text(
                    'Kurulum sihirbazında belirlediğin ritim ve hedefleri dilediğin zaman güncelleyebilirsin.',
                    style: AppTypography.sfPro(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Alt Bölüm A: Günlük Odaklanma Süresi (Kartlar) ──
                  _buildLabel('GÜNLÜK ODAKLANMA SÜREN', titleColor),
                  const SizedBox(height: 4),
                  Text(
                    'Her çalışma gününde ne kadar süre odaklanmak istersin?',
                    style: AppTypography.sfPro(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Column(
                    children: _focusOptions.map((option) {
                      final minutes = option['minutes'] as int;
                      final title = option['title'] as String;
                      final subtitle = option['subtitle'] as String;
                      final isSelected = _dailyFocusMinutes == minutes;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: BouncingWidget(
                          scaleFactor: 0.98,
                          onTap: () {
                            AppHaptics.lightImpact();
                            setState(() => _dailyFocusMinutes = minutes);
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF2F7F2) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? matchaPrimary : const Color(0xFFE2EBE0),
                                width: isSelected ? 1.8 : 1.1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: matchaPrimary.withValues(alpha: 0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: AppTypography.sfProRounded(
                                          fontSize: 14.5,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: titleColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        subtitle,
                                        style: AppTypography.sfPro(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? matchaPrimary : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? matchaPrimary : const Color(0xFFCCDACC),
                                      width: 1.8,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(Icons.check_rounded, size: 14, color: Colors.white),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // ── Alt Bölüm B: Haftada Kaç Gün Odaklanacaksın? ──
                  _buildLabel('HAFTALIK PLANLAMA RİTMİ', titleColor),
                  const SizedBox(height: 4),
                  Text(
                    'Haftada kaç gün odaklanma veya ders çalışmayı hedefliyorsun?',
                    style: AppTypography.sfPro(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (idx) {
                      final dayNum = idx + 1;
                      final isSelected = _weeklyGoalDays == dayNum;
                      return GestureDetector(
                        onTap: () {
                          AppHaptics.lightImpact();
                          setState(() {
                            if (_weeklyGoalDays == dayNum) {
                              _weeklyGoalDays = 0; // Tekrar basılırsa seçim serbest mod (0) olur
                            } else {
                              _weeklyGoalDays = dayNum;
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 42,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isSelected ? matchaPrimary : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? matchaPrimary : const Color(0xFFE2EBE0),
                              width: 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: matchaPrimary.withValues(alpha: 0.22),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
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

                  const SizedBox(height: 10),

                  // Ritim Bilgi Kartı (Sihirbazdaki Washi Tape Ritim Notu Hissi)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF5EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD6E6D4), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco_rounded, size: 18, color: Color(0xFF2D5A3A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getRhythmDescription(_weeklyGoalDays),
                            style: AppTypography.sfPro(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D5A3A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Alt Bölüm C: Calenda Sana Nasıl Eşlik Etsin? ──
                  _buildLabel('CALENDA SANA NASIL EŞLİK ETSİN?', titleColor),
                  const SizedBox(height: 4),
                  Text(
                    'Kullanmak istediğin alanları seçebilirsin.',
                    style: AppTypography.sfPro(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Column(
                    children: _focusAreas.map((area) {
                      final isSelected = _selectedFocusAreas.contains(area);
                      return GestureDetector(
                        onTap: () {
                          AppHaptics.lightImpact();
                          setState(() {
                            if (_selectedFocusAreas.contains(area)) {
                              if (_selectedFocusAreas.length > 1) {
                                _selectedFocusAreas.remove(area);
                              }
                            } else {
                              _selectedFocusAreas.add(area);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF2F7F2) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? matchaPrimary : const Color(0xFFE2EBE0),
                              width: isSelected ? 1.8 : 1.1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: matchaPrimary.withValues(alpha: 0.12),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  area,
                                  style: AppTypography.sfProRounded(
                                    fontSize: 14.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? matchaPrimary : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? matchaPrimary : const Color(0xFFCCDACC),
                                    width: 1.8,
                                  ),
                                ),
                                child: isSelected
                                    ? const Center(
                                        child: Icon(Icons.check_rounded, size: 14, color: Colors.white),
                                      )
                                    : null,
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
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: AppTypography.sfPro(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color.withValues(alpha: 0.7),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color titleColor) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8DB), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
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
          hintStyle: AppTypography.sfPro(
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFB0A59B),
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDateBox(TextEditingController controller, String hint, int maxLength, Color titleColor) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8DB), width: 1.2),
      ),
      alignment: Alignment.center,
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
          hintStyle: AppTypography.sfPro(
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFB0A59B),
          ),
          counterText: '',
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
