import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/room_furniture.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../widgets/parallax_room_canvas.dart';

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
        final service = AchievementService.instance;
        final roomState = service.roomState;
        final currentTheme = roomState.themeColor;
        final isFloor2 = roomState.activeFloor == 1;
        final tier = roomState.currentTier;
        final nextTier = roomState.nextTier;
        final categoryItems = service.getFurnitureCatalogForCategory(_selectedCategory);

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
                // ── 0. Kat Değiştirme Segmenti (1. Kat & 2. Kat) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162319) : const Color(0xFFEDF3E9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF283D2D) : const Color(0xFFD6E4D1),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 1. Kat Butonu
                        Expanded(
                          child: BouncingWidget(
                            onTap: () {
                              AppHaptics.selectionClick();
                              service.setActiveRoomFloor(0);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !isFloor2
                                    ? (isDark ? const Color(0xFF243B2A) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: !isFloor2
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🏠', style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 5),
                                    Text(
                                      isEn ? '1st Floor' : '1. Kat',
                                      style: AppTypography.sfProRounded(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: !isFloor2
                                            ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                                            : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 2. Kat Butonu (Kilit Durumu ile Birlikte)
                        Expanded(
                          child: BouncingWidget(
                            onTap: () {
                              AppHaptics.selectionClick();
                              service.setActiveRoomFloor(1);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isFloor2
                                    ? (isDark ? const Color(0xFF243B2A) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: isFloor2
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(roomState.isFloor2Unlocked ? '📚' : '🔒', style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: 5),
                                    Text(
                                      isEn ? '2nd Floor Loft' : '2. Kat Loft',
                                      style: AppTypography.sfProRounded(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isFloor2
                                            ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                                            : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 1. İnteraktif 3D İzometrik Oda Tuvali (Hotspot & Parallax) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
                      child: ParallaxRoomCanvas(
                        roomState: roomState,
                        isInteractive: !isFloor2,
                        selectedCategory: _selectedCategory,
                        onSelectCategory: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        enableParallax: true,
                      ),
                    ),
                  ),
                ),

                // ── 2. Seviye ve XP İlerleme Çubuğu ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF203225) : const Color(0xFFE8F2E4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334F3A) : const Color(0xFFCFE0CA),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 4),
                            Text(
                              '${tier.getTitle(lang)} · Seviye ${tier.level}',
                              style: AppTypography.sfProRounded(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (nextTier != null)
                        Text(
                          '${roomState.xp} / ${nextTier.xpRequired} XP',
                          style: AppTypography.sfProRounded(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        )
                      else
                        Text(
                          'Max XP',
                          style: AppTypography.sfProRounded(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // ── 3. Eşya Kataloğu / Kat Bilgisi Çekmecesi ──
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
                    child: !isFloor2
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Minik Zarif Tutma Çubuğu (Drag Handle)
                              const SizedBox(height: 10),
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
                              const SizedBox(height: 8),

                              // Kategori Başlığı
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 22),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedCategory.iconEmoji,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedCategory.getTitle(lang),
                                      style: AppTypography.sfProRounded(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${categoryItems.where((i) => i.isUnlocked).length}/${categoryItems.length} ${isEn ? 'Unlocked' : 'Açık'}',
                                      style: AppTypography.sfPro(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

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
                                    final isActive = roomState.getActiveItem(_selectedCategory) == item.id;

                                    return _buildItemCard(
                                      item: item,
                                      isActive: isActive,
                                      currentTheme: currentTheme,
                                      isDark: isDark,
                                      lang: lang,
                                      isEn: isEn,
                                      onSelect: () {
                                        if (item.isUnlocked) {
                                          AppHaptics.selectionClick();
                                          service.setActiveRoomItem(item.category, item.id);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                          )
                        : _buildFloor2InfoSheet(isDark, lang, isEn),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 2. Kat Kilitli Bilgilendirme Kartı
  Widget _buildFloor2InfoSheet(bool isDark, String lang, bool isEn) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFC98A3C).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.architecture_rounded,
                color: Color(0xFFC98A3C),
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isEn ? '2nd Floor: Study Loft & Library' : '2. Kat: Çalışma Loftu & Kütüphane',
            style: AppTypography.sfProRounded(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEn
                ? 'Complete focus sessions, habits, and tasks to gain XP. Reaching Level 2 (300 XP) will construct and unlock the upper loft floor!'
                : 'Odaklanma seansları, rutinler ve planlar tamamlayarak XP kazan. Seviye 2\'ye (300 XP) ulaştığında üst kat çalışma loftu inşa edilip açılacak!',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Alt çekmecedeki sade ve etkileşimli mobilya kartı
  Widget _buildItemCard({
    required RoomFurnitureItem item,
    required bool isActive,
    required String currentTheme,
    required bool isDark,
    required String lang,
    required bool isEn,
    required VoidCallback onSelect,
  }) {
    final isUnlocked = item.isUnlocked;
    final thumbAsset = item.getThumbnailAsset(currentTheme);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF1F3526) : const Color(0xFFF3F8F1))
              : isUnlocked
                  ? (isDark ? const Color(0xFF1A271E) : const Color(0xFFFAFBF8))
                  : (isDark ? const Color(0xFF162019) : const Color(0xFFF3F6F0)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435))
                : isUnlocked
                    ? (isDark ? const Color(0xFF38553F) : const Color(0xFFCAD8C4))
                    : (isDark ? const Color(0xFF243227) : const Color(0xFFE2ECE0)),
            width: isActive ? 2.0 : 1.0,
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
            // Üst Durum Rozeti: Seçili ise "Seçili", kilitliyse kilit ikonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A5035) : const Color(0xFFD6EADB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isEn ? 'Active' : 'Seçili',
                          style: AppTypography.sfProRounded(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (!isUnlocked)
                  const Icon(
                    Icons.lock_rounded,
                    size: 15,
                    color: Color(0xFF8B9B90),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),

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
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: BouncingWidget(
                            onTap: () {
                              AppHaptics.selectionClick();
                              AchievementService.instance.setRoomThemeColor(key);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSelected ? 18 : 13,
                              height: isSelected ? 18 : 13,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? Colors.white : const Color(0xFF102E19))
                                      : Colors.white.withValues(alpha: 0.7),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.6),
                                          blurRadius: 5,
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

            const SizedBox(height: 8),

            // Eşya İsmi
            Text(
              item.getName(lang),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sfProRounded(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isUnlocked
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
            ),
            const SizedBox(height: 2),

            // Açılma Gereksinimi / Durumu
            Text(
              item.getUnlockRequirement(lang),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sfPro(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: isUnlocked
                    ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF38553F))
                    : const Color(0xFFB57065),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
