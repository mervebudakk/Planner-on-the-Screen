import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/room_furniture.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';

/// 🪴 The Cozy Room - Odam Düzenleme & Özelleştirme Stüdyosu
class CozyRoomEditorScreen extends StatefulWidget {
  final RoomCategory initialCategory;

  const CozyRoomEditorScreen({
    super.key,
    this.initialCategory = RoomCategory.bed,
  });

  @override
  State<CozyRoomEditorScreen> createState() => _CozyRoomEditorScreenState();
}

class _CozyRoomEditorScreenState extends State<CozyRoomEditorScreen> {
  late RoomCategory _selectedCategory;

  static const List<Map<String, dynamic>> _themeOptions = [
    {
      'key': 'pink',
      'labelTr': 'Pembe',
      'labelEn': 'Blush',
      'color': Color(0xFFFFC8DD),
      'dotColor': Color(0xFFFFAFCC),
    },
    {
      'key': 'purple',
      'labelTr': 'Mor',
      'labelEn': 'Lilac',
      'color': Color(0xFFCDB4DB),
      'dotColor': Color(0xFFB58DB6),
    },
    {
      'key': 'blue',
      'labelTr': 'Mavi',
      'labelEn': 'Mavi',
      'color': Color(0xFFA2D2FF),
      'dotColor': Color(0xFF70B2F5),
    },
    {
      'key': 'green',
      'labelTr': 'Yeşil',
      'labelEn': 'Matcha',
      'color': Color(0xFFA8D5BA),
      'dotColor': Color(0xFF4A7C59),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final isEn = lang == 'en';

    return ListenableBuilder(
      listenable: AchievementService.instance,
      builder: (context, _) {
        final currentTheme = AchievementService.instance.roomThemeColor;
        final categoryItems = RoomFurnitureItem.catalog
            .where((item) => item.category == _selectedCategory)
            .toList();

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F1712) : const Color(0xFFFAFBF8),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              onPressed: () {
                AppHaptics.lightImpact();
                Navigator.of(context).pop();
              },
            ),
            centerTitle: true,
            title: Text(
              isEn ? 'The Cozy Room' : 'Odam',
              style: AppTypography.sfProRounded(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── 1. İnteraktif 3D İzometrik Oda Tuvali (Hotspot Özellikli) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                const Color(0xFF141F17),
                                const Color(0xFF1A281E),
                                const Color(0xFF152219),
                              ]
                            : [
                                const Color(0xFFFAFBF8),
                                const Color(0xFFF4F7F1),
                                const Color(0xFFE9F0E6),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0xFF283A2E) : const Color(0xFFD6E3D0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : const Color(0xFF102E19))
                              .withValues(alpha: isDark ? 0.35 : 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 800 / 600,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;
                            final h = constraints.maxHeight;

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                // Katmanlar (Zemin & Duvarlar)
                                Image.asset(
                                  'assets/images/room/room_base.png',
                                  fit: BoxFit.contain,
                                ),
                                Image.asset(
                                  'assets/images/room/window_lv1.png',
                                  fit: BoxFit.contain,
                                ),
                                Image.asset(
                                  'assets/images/room/wall_decor_lv1.png',
                                  fit: BoxFit.contain,
                                ),
                                // Renkli Eşya Katmanları
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Image.asset(
                                    'assets/images/room/rug_lv1_.png',
                                    key: ValueKey('rug_'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Image.asset(
                                    'assets/images/room/bed_lv1_.png',
                                    key: ValueKey('bed_'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Image.asset(
                                    'assets/images/room/desk_lv1_.png',
                                    key: ValueKey('desk_'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Image.asset(
                                    'assets/images/room/decor_lv1_.png',
                                    key: ValueKey('decor_'),
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                // ── İnteraktif Dokunma Alanları (Hotspots) ──
                                // 1. Yatak Alanı (Sol-Orta Zemin)
                                Positioned(
                                  left: w * 0.18,
                                  top: h * 0.46,
                                  width: w * 0.36,
                                  height: h * 0.32,
                                  child: _buildHotspotTarget(
                                    category: RoomCategory.bed,
                                    label: isEn ? 'Bed' : 'Yatak',
                                    isDark: isDark,
                                  ),
                                ),

                                // 2. Çalışma Masası Alanı (Sağ-Orta Zemin)
                                Positioned(
                                  left: w * 0.56,
                                  top: h * 0.44,
                                  width: w * 0.36,
                                  height: h * 0.34,
                                  child: _buildHotspotTarget(
                                    category: RoomCategory.desk,
                                    label: isEn ? 'Desk' : 'Masa',
                                    isDark: isDark,
                                  ),
                                ),

                                // 3. Zemin Halısı Alanı (Orta Zemin)
                                Positioned(
                                  left: w * 0.38,
                                  top: h * 0.62,
                                  width: w * 0.24,
                                  height: h * 0.20,
                                  child: _buildHotspotTarget(
                                    category: RoomCategory.rug,
                                    label: isEn ? 'Rug' : 'Halı',
                                    isDark: isDark,
                                  ),
                                ),

                                // 4. Pencere Alanı (Sol Duvar Üst)
                                Positioned(
                                  left: w * 0.20,
                                  top: h * 0.18,
                                  width: w * 0.24,
                                  height: h * 0.28,
                                  child: _buildHotspotTarget(
                                    category: RoomCategory.window,
                                    label: isEn ? 'Window' : 'Pencere',
                                    isDark: isDark,
                                  ),
                                ),

                                // 5. Masa Dekoru Alanı (Masa Üstü)
                                Positioned(
                                  left: w * 0.62,
                                  top: h * 0.42,
                                  width: w * 0.16,
                                  height: h * 0.14,
                                  child: _buildHotspotTarget(
                                    category: RoomCategory.decor,
                                    label: isEn ? 'Decor' : 'Dekor',
                                    isDark: isDark,
                                  ),
                                ),

                                // 6. Duvar Tablosu Alanı (Sağ Duvar Üst)
                                Positioned(
                                  left: w * 0.68,
                                  top: h * 0.20,
                                  width: w * 0.18,
                                  height: h * 0.24,
                                  child: _buildHotspotTarget(
                                    category: RoomCategory.wallDecor,
                                    label: isEn ? 'Art' : 'Tablo',
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── 2. Eşya Seçenekleri Çekmecesi ──
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141F17) : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      border: Border.all(
                        color: isDark ? const Color(0xFF26382B) : const Color(0xFFDCE7D6),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Minik Zarif Tutma Çubuğu (Drag Handle)
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Eşya Kartları Yatay Listesi
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: categoryItems.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final item = categoryItems[index];
                              return _buildItemCard(
                                item: item,
                                currentTheme: currentTheme,
                                isDark: isDark,
                                lang: lang,
                                isEn: isEn,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Oda üzerindeki interaktif dokunma alanı (Hotspot)
  Widget _buildHotspotTarget({
    required RoomCategory category,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppHaptics.selectionClick();
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : const Color(0xFFB0C4A8).withValues(alpha: 0.8),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.2 : 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category.iconEmoji,
                style: const TextStyle(fontSize: 11),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.sfProRounded(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? (isDark ? const Color(0xFF102E19) : Colors.white)
                      : const Color(0xFF102E19),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Alt çekmecedeki sade mobilya kartı
  Widget _buildItemCard({
    required RoomFurnitureItem item,
    required String currentTheme,
    required bool isDark,
    required String lang,
    required bool isEn,
  }) {
    final isUnlocked = item.isUnlocked;
    final thumbAsset = item.getThumbnailAsset(currentTheme);

    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? const Color(0xFF1A271E) : const Color(0xFFFAFBF8))
            : (isDark ? const Color(0xFF162019) : const Color(0xFFF3F6F0)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? (isDark ? const Color(0xFF38553F) : const Color(0xFFCAD8C4))
              : (isDark ? const Color(0xFF243227) : const Color(0xFFE2ECE0)),
          width: isUnlocked ? 1.5 : 1.0,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: const Color(0xFF102E19)
                      .withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kilit Rozeti: Kilitliyse sağ üstte sade kilit ikonu
          if (!isUnlocked)
            const Align(
              alignment: Alignment.topRight,
              child: Icon(
                Icons.lock_rounded,
                size: 16,
                color: Color(0xFF8B9B90),
              ),
            )
          else
            const SizedBox(height: 6),

          // Görsel ve Dikey Renk Seçici Alanı
          Expanded(
            child: Row(
              children: [
                // Mobilya Görseli
                Expanded(
                  child: Center(
                    child: isUnlocked && thumbAsset.isNotEmpty
                        ? Image.asset(
                            thumbAsset,
                            fit: BoxFit.contain,
                          )
                        : Opacity(
                            opacity: 0.35,
                            child: Icon(
                              item.category.iconData,
                              size: 44,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF285435),
                            ),
                          ),
                  ),
                ),

                // Renk seçeneği olan eşyalar için dikey 4 renk seçici nokta
                if (isUnlocked && item.isThemeable) ...[
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _themeOptions.map((opt) {
                      final key = opt['key'] as String;
                      final isSelected = currentTheme == key;
                      final color = opt['color'] as Color;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.5),
                        child: BouncingWidget(
                          onTap: () {
                            AppHaptics.selectionClick();
                            AchievementService.instance.setRoomThemeColor(key);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 20 : 15,
                            height: isSelected ? 20 : 15,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? (isDark
                                        ? Colors.white
                                        : const Color(0xFF102E19))
                                    : Colors.white.withValues(alpha: 0.7),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.6),
                                        blurRadius: 6,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Eşya İsmi
          Text(
            item.getName(lang),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sfProRounded(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isUnlocked
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                  : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
          ),
          const SizedBox(height: 3),

          // Açılma Gereksinimi / Durumu
          Text(
            item.getUnlockRequirement(lang),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sfPro(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isUnlocked
                  ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF38553F))
                  : const Color(0xFFB57065),
            ),
          ),
        ],
      ),
    );
  }
}
