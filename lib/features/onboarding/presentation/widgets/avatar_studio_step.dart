import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/widgets/vintage_framed_avatar.dart';
import '../../models/onboarding_state.dart';

/// 🎨 Adım 7: İnteraktif Canlı Avatar & Aksesuar Stüdyosu (Yatay Kaydırmalı, İsimsiz Kartlar)
class AvatarStudioStep extends StatefulWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const AvatarStudioStep({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  State<AvatarStudioStep> createState() => _AvatarStudioStepState();
}

class _AvatarStudioStepState extends State<AvatarStudioStep> {
  // 🐾 7 Standart Hayvan Karakteri
  final List<Map<String, String>> _animals = const [
    {'id': 'rabbit', 'asset': 'assets/avatars/rabbit.png'},
    {'id': 'bear', 'asset': 'assets/avatars/bear.png'},
    {'id': 'seal', 'asset': 'assets/avatars/seal.png'},
    {'id': 'cat', 'asset': 'assets/avatars/cat.png'},
    {'id': 'fox', 'asset': 'assets/avatars/fox.png'},
    {'id': 'deer', 'asset': 'assets/avatars/deer.png'},
    {'id': 'puppy', 'asset': 'assets/avatars/puppy.png'},
  ];

  // 🎀 Aksesuarlar (İsimsiz, sadece görsel)
  final List<Map<String, String>> _accessories = const [
    {'id': 'none', 'asset': ''},
    {'id': 'strawberry_beret', 'asset': 'assets/accessories/strawberry_beret.png'},
    {'id': 'flower_crown', 'asset': 'assets/accessories/flower_crown.png'},
    {'id': 'sprout_clip', 'asset': 'assets/accessories/sprout_clip.png'},
    {'id': 'sleep_mask', 'asset': 'assets/accessories/sleep_mask.png'},
    {'id': 'velvet_bowtie', 'asset': 'assets/accessories/velvet_bowtie.png'},
    {'id': 'gold_crown', 'asset': 'assets/accessories/gold_crown.png'},
    {'id': 'teacup_hat', 'asset': 'assets/accessories/teacup_hat.png'},
  ];

  // 🎨 Pastel Arka Plan Renkleri
  final List<Map<String, dynamic>> _bgColors = const [
    {'hex': '#FAF7F2', 'color': Color(0xFFFAF7F2)}, // Krem / Beyaz
    {'hex': '#F4E8D7', 'color': Color(0xFFF4E8D7)}, // Sıcak Bej
    {'hex': '#FDEBF0', 'color': Color(0xFFFDEBF0)}, // Gül Pembe
    {'hex': '#DAEAF6', 'color': Color(0xFFDAEAF6)}, // Bebek Mavi
    {'hex': '#EBF7EE', 'color': Color(0xFFEBF7EE)}, // Adaçayı Yeşili
    {'hex': '#FCF4DD', 'color': Color(0xFFFCF4DD)}, // Pastel Sarı
    {'hex': '#E8DFF5', 'color': Color(0xFFE8DFF5)}, // Lavanta
  ];

  late String _currentAnimal;
  late String _currentAccessory;
  late String _currentBgColorHex;

  @override
  void initState() {
    super.initState();
    _currentAnimal = widget.state.avatarAnimal
        .replaceAll('01_', '')
        .replaceAll('02_', '')
        .replaceAll('03_', '')
        .replaceAll('04_', '')
        .replaceAll('05_', '')
        .replaceAll('06_', '')
        .replaceAll('07_', '');
    if (_animals.every((a) => a['id'] != _currentAnimal)) {
      _currentAnimal = 'rabbit';
    }

    _currentAccessory = widget.state.avatarAccessory;
    _currentBgColorHex = widget.state.avatarBgColor;
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFFFAF7F2);
    }
  }

  void _saveAndNext() {
    widget.state.avatarAnimal = _currentAnimal;
    widget.state.avatarAccessory = _currentAccessory;
    widget.state.avatarBgColor = _currentBgColorHex;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    const activeBorderColor = Color(0xFF4A2B33);
    const defaultBorderColor = Color(0xFFEADBCE);

    final currentAnimalAsset = 'assets/avatars/$_currentAnimal.png';
    final currentAccessoryAsset = _currentAccessory == 'none'
        ? null
        : 'assets/accessories/$_currentAccessory.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),

          // ── Başlık ──
          Text(
            'Profil karakterini oluştur',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Karakterini, aksesuarını ve arka plan rengini seç.',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
            ),
          ),

          const SizedBox(height: 14),

          // ── 🖼️ ANTİKA VİNTAGE ÇERÇEVELİ CANLI ÖNİZLEME ──
          Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2B33).withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: VintageFramedAvatar(
                animalAsset: currentAnimalAsset,
                accessoryAsset: currentAccessoryAsset,
                backgroundColor: _parseHex(_currentBgColorHex),
                height: 160,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── 📜 ALT ALTA SIRALI YATAY SEÇİM LİSTELERİ ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🐾 1. BÖLÜM: KARAKTER
                  Text(
                    'Karakter',
                    style: AppTypography.sfProRounded(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _animals.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = _animals[index];
                        final id = item['id']!;
                        final isSelected = _currentAnimal == id;

                        return BouncingWidget(
                          onTap: () => setState(() => _currentAnimal = id),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 72,
                            height: 72,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? activeBorderColor : defaultBorderColor,
                                width: isSelected ? 2.2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF4A2B33).withValues(alpha: 0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Image.asset(
                              item['asset']!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.pets, size: 28, color: Color(0xFF9E8D86)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🎀 2. BÖLÜM: AKSESUAR
                  Text(
                    'Aksesuar',
                    style: AppTypography.sfProRounded(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _accessories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = _accessories[index];
                        final id = item['id']!;
                        final isSelected = _currentAccessory == id;

                        return BouncingWidget(
                          onTap: () => setState(() => _currentAccessory = id),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 72,
                            height: 72,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? activeBorderColor : defaultBorderColor,
                                width: isSelected ? 2.2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF4A2B33).withValues(alpha: 0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: id == 'none'
                                ? Center(
                                    child: Icon(
                                      Icons.not_interested_rounded,
                                      size: 26,
                                      color: isSelected ? const Color(0xFF4A2B33) : const Color(0xFFBDB2A7),
                                    ),
                                  )
                                : Image.asset(
                                    item['asset']!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.star, size: 24, color: Color(0xFFBFB2A7)),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🎨 3. BÖLÜM: ARKA PLAN RENGİ
                  Text(
                    'Arka plan rengi',
                    style: AppTypography.sfProRounded(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _bgColors.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = _bgColors[index];
                        final hex = item['hex'] as String;
                        final color = item['color'] as Color;
                        final isSelected = _currentBgColorHex == hex;

                        return BouncingWidget(
                          onTap: () => setState(() => _currentBgColorHex = hex),
                          borderRadius: BorderRadius.circular(25),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? activeBorderColor : const Color(0xFFD6C8BB),
                                width: isSelected ? 3.0 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Center(
                                    child: Icon(Icons.check_rounded, size: 22, color: Color(0xFF4A2B33)),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Devam Et Butonu ──
          AestheticPlannerButton(
            text: 'Bu Görünümü Seç',
            height: 52,
            onPressed: _saveAndNext,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
