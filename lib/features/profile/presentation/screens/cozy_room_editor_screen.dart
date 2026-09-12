import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/room_furniture.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../widgets/parallax_room_canvas.dart';

/// 🪴 The Cozy Room - Odam Düzenleme & Özelleştirme Stüdyosu
/// Sade, estetik ve dingin oda deneyimi.
/// İlk açılışta yalnızca oda görünür. Eşyaya dokunulduğunda alt çekmece açılır,
/// aşağı kaydırıldığında ise tekrar kaybolarak odayı baş başa bırakır.
class CozyRoomEditorScreen extends StatefulWidget {
  final RoomCategory? initialCategory;

  const CozyRoomEditorScreen({
    super.key,
    this.initialCategory,
  });

  @override
  State<CozyRoomEditorScreen> createState() => _CozyRoomEditorScreenState();
}

class _CozyRoomEditorScreenState extends State<CozyRoomEditorScreen> {
  RoomCategory? _selectedCategory;

  static const List<Map<String, dynamic>> _themeOptions = [
    {
      'key': 'pink',
      'labelTr': 'Pembe',
      'labelEn': 'Blush',
      'color': Color(0xFFFFC8DD),
    },
    {
      'key': 'purple',
      'labelTr': 'Mor',
      'labelEn': 'Lilac',
      'color': Color(0xFFCDB4DB),
    },
    {
      'key': 'blue',
      'labelTr': 'Mavi',
      'labelEn': 'Mavi',
      'color': Color(0xFFA2D2FF),
    },
    {
      'key': 'green',
      'labelTr': 'Yeşil',
      'labelEn': 'Matcha',
      'color': Color(0xFFA8D5BA),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  void _dismissDrawer() {
    if (_selectedCategory != null) {
      AppHaptics.lightImpact();
      setState(() {
        _selectedCategory = null;
      });
    }
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
        final focusXP = service.focusXP;

        final categoryItems = _selectedCategory != null
            ? service.getFurnitureCatalogForCategory(_selectedCategory!)
            : <RoomFurnitureItem>[];

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
            actions: [
              // Sağ Üst: Kullanıcının Toplam Odak Puanı / XP
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF223528) : const Color(0xFFEBF3E8)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (isDark ? const Color(0xFF35523E) : const Color(0xFFD3E2CF)),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          '$focusXP XP',
                          style: AppTypography.sfProRounded(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // ── 1. ANA İÇERİK (Kat Seçici & Temiz Oda Tuvali) ──
                Positioned.fill(
                  child: Column(
                    children: [
                      // Kat Değiştirme Segmenti (1. Kat & 2. Kat Loft)
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

                              // 2. Kat Butonu
                              Expanded(
                                child: BouncingWidget(
                                  onTap: () {
                                    AppHaptics.selectionClick();
                                    service.setActiveRoomFloor(1);
                                    setState(() {
                                      _selectedCategory = null;
                                    });
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

                      const SizedBox(height: 10),

                      // İzometrik Oda Tuvali (Üzerinde yazı barındırmaz, doğrudan eşyalara dokunulur)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _dismissDrawer,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            child: Center(
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
                          ),
                        ),
                      ),

                      // İpucu Metni (Yalnızca alt çekmece kapalıyken görünür)
                      if (_selectedCategory == null && !isFloor2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24, top: 8),
                          child: Text(
                            isEn ? 'Tap any furniture in the room to customize' : 'Düzenlemek için odadaki herhangi bir eşyaya dokun',
                            style: AppTypography.sfPro(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ── 2. KAYDIRILABİLİR & GİZLENEBİLİR ALT EŞYA ÇEKMECESİ ──
                // İlk açılışta tamamen gizlidir. Eşyaya dokununca açılır, aşağı çekilince kapanır.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: 0,
                  right: 0,
                  bottom: _selectedCategory != null ? 0 : -320,
                  height: 290,
                  child: GestureDetector(
                    onVerticalDragEnd: (details) {
                      // Kullanıcı aşağı doğru kaydırınca çekmeceyi gizle
                      if (details.primaryVelocity != null && details.primaryVelocity! > 80) {
                        _dismissDrawer();
                      }
                    },
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
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Zarif Tutma Çubuğu (Drag Handle)
                          const SizedBox(height: 10),
                          Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Başlık & Kapatma Butonu
                          if (_selectedCategory != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedCategory!.iconEmoji,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    _selectedCategory!.getTitle(lang),
                                    style: AppTypography.sfProRounded(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Aşağı Kapat Butonu
                                  IconButton(
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      size: 26,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: _dismissDrawer,
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 6),

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
                                final isActive = _selectedCategory != null &&
                                    roomState.getActiveItem(_selectedCategory!) == item.id;

                                return _buildItemCard(
                                  item: item,
                                  isActive: isActive,
                                  focusXP: focusXP,
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

                          const SizedBox(height: 18),
                        ],
                      ),
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

  /// Alt çekmecedeki sade ve etkileşimli mobilya kartı
  Widget _buildItemCard({
    required RoomFurnitureItem item,
    required bool isActive,
    required int focusXP,
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
        width: 195,
        padding: const EdgeInsets.all(12),
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
                                size: 42,
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

            const SizedBox(height: 6),

            // Eşya İsmi
            Text(
              item.getName(lang),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sfProRounded(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isUnlocked
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
            ),
            const SizedBox(height: 2),

            // Açılma Gereksinimi / Odak Durumu
            Text(
              isUnlocked
                  ? (isActive ? (isEn ? 'Currently displayed' : 'Odanda sergileniyor') : (isEn ? 'Tap to use' : 'Kullanmak için dokun'))
                  : '${item.getUnlockRequirement(lang)} ($focusXP/${item.requiredXP} XP)',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sfPro(
                fontSize: 10,
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
