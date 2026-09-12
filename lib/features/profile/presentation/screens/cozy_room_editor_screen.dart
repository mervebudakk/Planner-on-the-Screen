import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/room_furniture.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../widgets/achievement_detail_sheet.dart';
import '../widgets/modern_achievement_badge.dart';
import '../widgets/share_cards/share_card_picker_sheet.dart';

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
  bool _isAchievementsTab = false;

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
        final achievements = AchievementService.instance.achievements;
        final unlockedCount = AchievementService.instance.unlockedCount;
        final totalCount = AchievementService.instance.totalCount;
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
            title: Column(
              children: [
                Text(
                  isEn ? 'The Cozy Room' : 'Odam',
                  style: AppTypography.sfProRounded(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  isEn ? 'Tap any furniture to customize' : 'Eşyalara dokunarak düzenle',
                  style: AppTypography.sfPro(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
            actions: [
              // Başarılar Rozet Butonu
              BouncingWidget(
                onTap: () {
                  AppHaptics.lightImpact();
                  setState(() => _isAchievementsTab = true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isAchievementsTab
                        ? (isDark ? const Color(0xFF2B4431) : const Color(0xFFDCEAD6))
                        : (isDark ? const Color(0xFF1E2D22) : const Color(0xFFEEF4EA)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAchievementsTab
                          ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435))
                          : (isDark ? const Color(0xFF2E4233) : const Color(0xFFD6E3CF)),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 15,
                        color: Color(0xFFE5A93C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$unlockedCount/$totalCount',
                        style: AppTypography.sfProRounded(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),

              IconButton(
                icon: const Icon(Icons.ios_share_rounded, size: 20),
                color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                tooltip: isEn ? 'Share Room' : 'Odamı Paylaş',
                onPressed: () {
                  AppHaptics.lightImpact();
                  ShareCardPickerSheet.show(context);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── 1. Renk Teması Seçici Şerit ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2D22) : const Color(0xFFEEF4EA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.palette_outlined,
                              size: 14,
                              color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isEn ? 'PALETTE' : 'RENK',
                              style: AppTypography.sfProRounded(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ..._themeOptions.map((opt) {
                        final key = opt['key'] as String;
                        final isSelected = currentTheme == key;
                        final color = opt['color'] as Color;
                        final label = isEn ? opt['labelEn'] as String : opt['labelTr'] as String;

                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: BouncingWidget(
                            onTap: () {
                              AppHaptics.selectionClick();
                              AchievementService.instance.setRoomThemeColor(key);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSelected ? 10 : 7,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: isDark ? 0.35 : 0.45)
                                    : (isDark
                                        ? const Color(0xFF19251C)
                                        : const Color(0xFFF2F6EF)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? Colors.white70 : const Color(0xFF102E19))
                                      : Colors.transparent,
                                  width: isSelected ? 1.4 : 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 5),
                                    Text(
                                      label,
                                      style: AppTypography.sfProRounded(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : const Color(0xFF102E19),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // ── 2. İnteraktif 3D İzometrik Oda Tuvali (Hotspot Özellikli) ──
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
                      child: AspectRatio(
                        aspectRatio: 800 / 600,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;
                            final h = constraints.maxHeight;

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                // Katmanlar
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

                const SizedBox(height: 10),

                // ── 3. Yatay Kategori Seçici Bar ──
                SizedBox(
                  height: 42,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...RoomCategory.values.map((cat) {
                        final isSelected = !_isAchievementsTab && _selectedCategory == cat;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: BouncingWidget(
                            onTap: () {
                              AppHaptics.selectionClick();
                              setState(() {
                                _isAchievementsTab = false;
                                _selectedCategory = cat;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                                    : (isDark ? const Color(0xFF1B291F) : const Color(0xFFEEF4EA)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isDark ? const Color(0xFF2C3E32) : const Color(0xFFD6E3CF)),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(cat.iconEmoji, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.getTitle(lang),
                                    style: AppTypography.sfProRounded(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? (isDark ? const Color(0xFF102E19) : Colors.white)
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      // 🏆 Başarı Madalyonları Sekmesi
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: BouncingWidget(
                          onTap: () {
                            AppHaptics.selectionClick();
                            setState(() => _isAchievementsTab = true);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isAchievementsTab
                                  ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                                  : (isDark ? const Color(0xFF1B291F) : const Color(0xFFEEF4EA)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isAchievementsTab
                                    ? Colors.transparent
                                    : (isDark ? const Color(0xFF2C3E32) : const Color(0xFFD6E3CF)),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🏆', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  isEn ? 'Achievements' : 'Başarılar',
                                  style: AppTypography.sfProRounded(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _isAchievementsTab
                                        ? (isDark ? const Color(0xFF102E19) : Colors.white)
                                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── 4. Eşya / Başarı Seçenekleri Listesi ──
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
                        // Çekmece Başlığı
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 16, 22, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isAchievementsTab
                                    ? (isEn ? '🏆 Achievement Medallions' : '🏆 Başarı Madalyonları')
                                    : '${_selectedCategory.iconEmoji} ${_selectedCategory.getTitle(lang)} ${isEn ? "Catalog" : "Kataloğu"}',
                                style: AppTypography.sfProRounded(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF223528) : const Color(0xFFEBF3E8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _isAchievementsTab
                                      ? '$unlockedCount/$totalCount ${isEn ? "Unlocked" : "Açık"}'
                                      : '${categoryItems.where((i) => i.isUnlocked).length}/${categoryItems.length} ${isEn ? "Unlocked" : "Açık"}',
                                  style: AppTypography.sfProRounded(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Eşya Kartları veya Başarılar Yatay Listesi
                        Expanded(
                          child: _isAchievementsTab
                              ? ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: achievements.length,
                                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                                  itemBuilder: (context, index) {
                                    final achv = achievements[index];
                                    return ModernAchievementBadge(
                                      achievement: achv,
                                      size: 64,
                                      showLabel: true,
                                      onTap: () {
                                        AppHaptics.lightImpact();
                                        AchievementDetailSheet.show(context, achv);
                                      },
                                    );
                                  },
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                  scrollDirection: Axis.horizontal,
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
                        const SizedBox(height: 12),
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
    final isSelected = !_isAchievementsTab && _selectedCategory == category;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppHaptics.selectionClick();
        setState(() {
          _isAchievementsTab = false;
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

  /// Alt çekmecedeki mobilya kartı
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
      width: 190,
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
                  color: const Color(0xFF102E19).withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Rozet: Seviye & Kilit Durumu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? (isDark ? const Color(0xFF263C2E) : const Color(0xFFE4F0E1))
                      : (isDark ? const Color(0xFF202C23) : const Color(0xFFE5EDE2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'SEVİYE ',
                  style: AppTypography.sfProRounded(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isUnlocked
                        ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435))
                        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isEn ? 'ACTIVE' : 'AKTİF',
                    style: AppTypography.sfProRounded(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF102E19) : Colors.white,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.lock_rounded,
                  size: 15,
                  color: Color(0xFF8B9B90),
                ),
            ],
          ),

          const Spacer(),

          // Görsel Alanı
          Center(
            child: SizedBox(
              height: 72,
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
                        color: isDark ? Colors.white70 : const Color(0xFF285435),
                      ),
                    ),
            ),
          ),

          const Spacer(),

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
          const SizedBox(height: 3),

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
    );
  }
}
