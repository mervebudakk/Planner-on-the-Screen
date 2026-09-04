import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../models/onboarding_state.dart';

/// 🎨 Adım 7: İnteraktif Canlı Avatar & Aksesuar Stüdyosu
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
    {'id': 'rabbit', 'name': 'Tavşan', 'asset': 'assets/avatars/rabbit.png'},
    {'id': 'fox', 'name': 'Tilki', 'asset': 'assets/avatars/fox.png'},
    {'id': 'deer', 'name': 'Geyik', 'asset': 'assets/avatars/deer.png'},
    {'id': 'cat', 'name': 'Kedi', 'asset': 'assets/avatars/cat.png'},
    {'id': 'bear', 'name': 'Ayı', 'asset': 'assets/avatars/bear.png'},
    {'id': 'seal', 'name': 'Fok', 'asset': 'assets/avatars/seal.png'},
    {'id': 'puppy', 'name': 'Köpek', 'asset': 'assets/avatars/puppy.png'},
  ];

  // 🎀 Aksesuarlar
  final List<Map<String, String>> _accessories = const [
    {'id': 'none', 'name': 'Yok', 'asset': ''},
    {'id': 'strawberry_beret', 'name': 'Çilek Bere', 'asset': 'assets/accessories/strawberry_beret.png'},
    {'id': 'flower_crown', 'name': 'Çiçek Tacı', 'asset': 'assets/accessories/flower_crown.png'},
    {'id': 'star_glasses', 'name': 'Gözlük', 'asset': 'assets/accessories/star_glasses.png'},
    {'id': 'sprout_clip', 'name': 'Filiz Toka', 'asset': 'assets/accessories/sprout_clip.png'},
    {'id': 'sleep_mask', 'name': 'Uyku Bandı', 'asset': 'assets/accessories/sleep_mask.png'},
    {'id': 'velvet_bowtie', 'name': 'Papyon', 'asset': 'assets/accessories/velvet_bowtie.png'},
    {'id': 'gold_crown', 'name': 'Altın Taç', 'asset': 'assets/accessories/gold_crown.png'},
    {'id': 'teacup_hat', 'name': 'Fincan Şapka', 'asset': 'assets/accessories/teacup_hat.png'},
  ];

  // 🎨 Pastel Arka Plan Renkleri
  final List<Map<String, dynamic>> _bgColors = const [
    {'hex': '#FAF7F2', 'color': Color(0xFFFAF7F2), 'name': 'Krem'},
    {'hex': '#FDEBF0', 'color': Color(0xFFFDEBF0), 'name': 'Gül Pembe'},
    {'hex': '#EBF7EE', 'color': Color(0xFFEBF7EE), 'name': 'Adaçayı'},
    {'hex': '#DAEAF6', 'color': Color(0xFFDAEAF6), 'name': 'Bebek Mavi'},
    {'hex': '#FCF4DD', 'color': Color(0xFFFCF4DD), 'name': 'Pastel Sarı'},
    {'hex': '#E8DFF5', 'color': Color(0xFFE8DFF5), 'name': 'Lavanta'},
  ];

  int _selectedTab = 0; // 0: Karakter, 1: Aksesuar, 2: Renk

  late String _currentAnimal;
  late String _currentAccessory;
  late String _currentBgColorHex;

  @override
  void initState() {
    super.initState();
    _currentAnimal = widget.state.avatarAnimal.replaceAll('01_', '').replaceAll('02_', '').replaceAll('03_', '').replaceAll('04_', '').replaceAll('05_', '').replaceAll('06_', '').replaceAll('07_', '');
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

    final currentAnimalAsset = 'assets/avatars/$_currentAnimal.png';
    final currentAccessoryAsset = _currentAccessory == 'none'
        ? null
        : 'assets/accessories/$_currentAccessory.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          // ── Başlık ──
          Text(
            'Kendi Avatarını Yarat',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Calenda’da seni temsil edecek sevimli dostunu ve aksesuarlarını seç.',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
            ),
          ),

          const SizedBox(height: 16),

          // ── 🖼️ CANLI BÜYÜK AVATAR ÖNİZLEME ÇERÇEVESİ ──
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: _parseHex(_currentBgColorHex),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: const Color(0xFFEADBCE), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2B33).withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(33),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Hayvan Katmanı
                    Image.asset(
                      currentAnimalAsset,
                      width: 130,
                      height: 130,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 50, color: Color(0xFF9E8D86)),
                    ),

                    // Aksesuar Katmanı (Eğer seçildiyse)
                    if (currentAccessoryAsset != null)
                      Image.asset(
                        currentAccessoryAsset,
                        width: 130,
                        height: 130,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Segmented Seçici Butonlar (Karakter / Aksesuar / Renk) ──
          Container(
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEADBCE)),
            ),
            child: Row(
              children: [
                _buildSegmentTab(0, 'Karakter', Icons.cruelty_free_outlined),
                _buildSegmentTab(1, 'Aksesuar', Icons.auto_awesome_outlined),
                _buildSegmentTab(2, 'Renk', Icons.palette_outlined),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Seçenek Galerisi ──
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedTab == 0
                  ? _buildAnimalGrid()
                  : _selectedTab == 1
                      ? _buildAccessoryGrid()
                      : _buildColorGrid(),
            ),
          ),

          const SizedBox(height: 8),

          // ── Devam Et Butonu ──
          AestheticPlannerButton(
            text: 'Bu Görünümü Seç',
            height: 52,
            onPressed: _saveAndNext,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(int index, String title, IconData icon) {
    final isSelected = _selectedTab == index;
    const activeColor = Color(0xFF4A2B33);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : const Color(0xFF8B7970),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: AppTypography.sfPro(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF8B7970),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalGrid() {
    return GridView.builder(
      key: const ValueKey('animals'),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _animals.length,
      itemBuilder: (context, index) {
        final item = _animals[index];
        final id = item['id']!;
        final isSelected = _currentAnimal == id;

        return BouncingWidget(
          onTap: () => setState(() => _currentAnimal = id),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? const Color(0xFFE6ABA7) : const Color(0xFFEADBCE),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE6ABA7).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    item['asset']!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 28, color: Color(0xFF9E8D86)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['name']!,
                  style: AppTypography.sfPro(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: const Color(0xFF4A2B33),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccessoryGrid() {
    return GridView.builder(
      key: const ValueKey('accessories'),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _accessories.length,
      itemBuilder: (context, index) {
        final item = _accessories[index];
        final id = item['id']!;
        final isSelected = _currentAccessory == id;

        return BouncingWidget(
          onTap: () => setState(() => _currentAccessory = id),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? const Color(0xFFE6ABA7) : const Color(0xFFEADBCE),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE6ABA7).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: id == 'none'
                      ? const Center(child: Icon(Icons.block_rounded, size: 28, color: Color(0xFFBFB2A7)))
                      : Image.asset(
                          item['asset']!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.star, size: 24, color: Color(0xFFBFB2A7)),
                        ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['name']!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sfPro(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: const Color(0xFF4A2B33),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorGrid() {
    return GridView.builder(
      key: const ValueKey('colors'),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: _bgColors.length,
      itemBuilder: (context, index) {
        final item = _bgColors[index];
        final hex = item['hex'] as String;
        final color = item['color'] as Color;
        final name = item['name'] as String;
        final isSelected = _currentBgColorHex == hex;

        return BouncingWidget(
          onTap: () => setState(() => _currentBgColorHex = hex),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? const Color(0xFF4A2B33) : const Color(0xFFEADBCE),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF4A2B33)),
                  if (isSelected) const SizedBox(width: 4),
                  Text(
                    name,
                    style: AppTypography.sfPro(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF4A2B33),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
