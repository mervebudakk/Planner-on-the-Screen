import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/services/glb_room_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../screens/cozy_room_editor_screen.dart';

/// 🪴 The Cozy Room — Profil Ekranı Yan Yana 3D Canlı Diorama Galerisi
/// Kullanıcının referansındaki gibi odalar X ekseninde yan yana dizilir.
/// Kilitli odalar yarı saydam görünür ve üzerinde kilit rozeti yer alır.
/// Açık odalara dokunulduğunda 360° interaktif düzenleme stüdyosu açılır.
class CozyDeskSection extends StatefulWidget {
  const CozyDeskSection({super.key});

  @override
  State<CozyDeskSection> createState() => _CozyDeskSectionState();
}

class _CozyDeskSectionState extends State<CozyDeskSection> {
  late final PageController _pageController;
  int _selectedRoomIndex = 0;
  String? _modelDataUri;
  bool _isLoadingModel = true;

  static const List<_RoomLevelConfig> _rooms = [
    _RoomLevelConfig(
      level: 1,
      assetPath: 'assets/models/room_level_1.glb',
      previewImagePath: 'assets/images/room/room_level_1_preview.png',
      nameTr: '1. Kat · Huzurlu Köşe',
      nameEn: '1st Floor · Cozy Nook',
      subtitleTr: 'Başlangıç Yatak Odası',
      subtitleEn: 'Starter Bedroom',
      icon: '🪴',
      requiredXP: 0,
    ),
    _RoomLevelConfig(
      level: 2,
      assetPath: 'assets/models/room_level_2.glb',
      previewImagePath: 'assets/images/room/room_level_2_preview.png',
      nameTr: '2. Kat · Çalışma Loftu',
      nameEn: '2nd Floor · Study Loft',
      subtitleTr: '2 Katlı Asma Kat & Kedi',
      subtitleEn: '2-Story Loft & Cat',
      icon: '🏠',
      requiredXP: 300,
    ),
    _RoomLevelConfig(
      level: 3,
      assetPath: 'assets/models/room_level_3.glb',
      previewImagePath: 'assets/images/room/room_level_3_preview.png',
      nameTr: '3. Kat · Sevimli Yuva',
      nameEn: '3rd Floor · Sweet Studio',
      subtitleTr: 'Modern Kreatif Stüdyo',
      subtitleEn: 'Modern Creative Studio',
      icon: '✨',
      requiredXP: 800,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86, initialPage: 0);
    _loadActiveModel();
    AchievementService.instance.addListener(_onAchievementsChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    AchievementService.instance.removeListener(_onAchievementsChanged);
    super.dispose();
  }

  void _onAchievementsChanged() {
    _loadActiveModel();
  }

  Future<void> _loadActiveModel() async {
    final service = AchievementService.instance;
    final focusXP = service.focusXP;
    final currentRoom = _rooms[_selectedRoomIndex];

    // Eğer oda kilitliyse 3D model yerine saydam önizleme kartı gösterilir
    if (!currentRoom.isUnlocked(focusXP)) {
      if (mounted) {
        setState(() {
          _modelDataUri = null;
          _isLoadingModel = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoadingModel = true);
    }

    try {
      final unlocked = service.unlockedDioramaItems;
      final uri = await GlbRoomService.instance.generateFilteredGlbDataUri(
        unlockedItemIds: unlocked,
        assetPath: currentRoom.assetPath,
      );
      if (mounted) {
        setState(() {
          _modelDataUri = uri;
          _isLoadingModel = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingModel = false);
      }
    }
  }

  void _onPageChanged(int index) {
    if (_selectedRoomIndex == index) return;
    AppHaptics.selectionClick();
    setState(() {
      _selectedRoomIndex = index;
    });
    _loadActiveModel();
  }

  void _goToPrevious() {
    if (_selectedRoomIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goToNext() {
    if (_selectedRoomIndex < _rooms.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
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
        final focusXP = service.focusXP;
        final unlockedCount = service.dioramaUnlockedCount;
        final totalCount = service.dioramaTotalCount;

        return SizedBox(
          width: double.infinity,
          height: 275,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── 1. Yan Yana Odalar Carousel (PageView) ──
              PageView.builder(
                controller: _pageController,
                itemCount: _rooms.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  final isUnlocked = room.isUnlocked(focusXP);
                  final isCurrent = index == _selectedRoomIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: BouncingWidget(
                      onTap: () async {
                        if (isUnlocked) {
                          AppHaptics.lightImpact();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CozyRoomEditorScreen(initialFloor: index),
                            ),
                          );
                          _loadActiveModel();
                        } else {
                          AppHaptics.mediumImpact();
                          final remaining = room.requiredXP - focusXP;
                          AestheticSnackBar.showWarning(
                            context,
                            isEn
                                ? '🔒 ${room.nameEn} unlocks at ${room.requiredXP} XP ($remaining XP remaining)'
                                : '🔒 ${room.nameTr} ${room.requiredXP} XP ile açılır ($remaining XP kaldı)',
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isDark
                                ? [
                                    const Color(0xFF131D16),
                                    const Color(0xFF18261D),
                                    const Color(0xFF142018),
                                  ]
                                : [
                                    const Color(0xFFFAFBF8),
                                    const Color(0xFFF3F7F0),
                                    const Color(0xFFE8EFE5),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: isDark
                                ? (isCurrent ? const Color(0xFF3E5A44) : const Color(0xFF283A2E)).withValues(alpha: 0.9)
                                : (isCurrent ? const Color(0xFF9EC597) : const Color(0xFFDBE8D3)).withValues(alpha: 0.95),
                            width: isCurrent ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF102E19))
                                  .withValues(alpha: isDark ? (isCurrent ? 0.40 : 0.20) : (isCurrent ? 0.08 : 0.03)),
                              blurRadius: isCurrent ? 18 : 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // ── A. Canlı 3D Model veya Yüksek Çözünürlüklü Önizleme ──
                              if (isCurrent && isUnlocked && !_isLoadingModel && _modelDataUri != null)
                                IgnorePointer(
                                  child: ModelViewer(
                                    key: ValueKey('carousel_${index}_$_modelDataUri'),
                                    src: _modelDataUri!,
                                    alt: room.localizedName(isEn),
                                    autoRotate: false,
                                    cameraControls: false,
                                    cameraOrbit: '45deg 60deg 105%',
                                    backgroundColor: Colors.transparent,
                                    disableZoom: true,
                                    disablePan: true,
                                    shadowIntensity: 0.6,
                                    shadowSoftness: 0.8,
                                    exposure: 1.05,
                                    interactionPrompt: InteractionPrompt.none,
                                  ),
                                )
                              else
                                // Önizleme Görseli (Saydam veya Yükleniyor)
                                Opacity(
                                  opacity: isUnlocked ? 0.95 : 0.38,
                                  child: Image.asset(
                                    room.previewImagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Text('🪴', style: TextStyle(fontSize: 40)),
                                    ),
                                  ),
                                ),

                              // Yükleniyor Göstergesi
                              if (isCurrent && isUnlocked && _isLoadingModel)
                                Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                    ),
                                  ),
                                ),

                              // ── B. Kilitli Durum Katmanı (Buzlu Cam & Kilit Simgesi) ──
                              if (!isUnlocked)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: (isDark ? const Color(0xFF0F1712) : Colors.white).withValues(alpha: 0.88),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF2E4836) : const Color(0xFFD6E4D1),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🔒', style: TextStyle(fontSize: 26)),
                                        const SizedBox(height: 5),
                                        Text(
                                          isEn ? 'Locked' : 'Kilitli',
                                          style: AppTypography.sfProRounded(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          isEn ? 'Unlocks at ${room.requiredXP} XP' : '${room.requiredXP} XP ile Açılır',
                                          style: AppTypography.sfPro(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // XP İlerleme Çubuğu
                                        SizedBox(
                                          width: 90,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(3),
                                            child: LinearProgressIndicator(
                                              value: (focusXP / room.requiredXP).clamp(0.0, 1.0),
                                              minHeight: 3.5,
                                              backgroundColor: isDark ? const Color(0xFF243B2A) : const Color(0xFFE2EBE0),
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                isDark ? const Color(0xFF8CEFA5) : const Color(0xFF3B734C),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // ── C. Sol Üst: Zarif Oda Seviye Rozeti ──
                              Positioned(
                                top: 12,
                                left: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: (isDark ? const Color(0xFF111E15) : Colors.white).withValues(alpha: 0.90),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (isDark ? const Color(0xFF2E4836) : const Color(0xFFD6E4D1)).withValues(alpha: 0.9),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(isUnlocked ? room.icon : '🔒', style: const TextStyle(fontSize: 11)),
                                      const SizedBox(width: 5),
                                      Text(
                                        index == 0
                                            ? (isEn
                                                ? '${room.localizedName(isEn)} · $unlockedCount/$totalCount'
                                                : '${room.localizedName(isEn)} · $unlockedCount/$totalCount Eşya')
                                            : room.localizedName(isEn),
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

                              // ── D. Sağ Alt: Düzenle İpucu (Sadece Açık Olanlarda) ──
                              if (isUnlocked)
                                Positioned(
                                  bottom: 12,
                                  right: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                    decoration: BoxDecoration(
                                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.72),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.touch_app_rounded,
                                          size: 11,
                                          color: isDark ? Colors.white70 : const Color(0xFF285435),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isEn ? 'Tap to view' : 'Odayı aç',
                                          style: AppTypography.sfPro(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white70 : const Color(0xFF285435),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ── 2. Sol Gezinme Oku (Referans Görselindeki Gibi) ──
              if (_selectedRoomIndex > 0)
                Positioned(
                  left: 2,
                  top: 0,
                  bottom: 24,
                  child: Center(
                    child: BouncingWidget(
                      onTap: _goToPrevious,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark ? const Color(0xFF18261D) : Colors.white).withValues(alpha: 0.90),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334E39) : const Color(0xFFD0DFC9),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 14,
                          color: isDark ? Colors.white : const Color(0xFF1E3F26),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── 3. Sağ Gezinme Oku (Referans Görselindeki Gibi) ──
              if (_selectedRoomIndex < _rooms.length - 1)
                Positioned(
                  right: 2,
                  top: 0,
                  bottom: 24,
                  child: Center(
                    child: BouncingWidget(
                      onTap: _goToNext,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark ? const Color(0xFF18261D) : Colors.white).withValues(alpha: 0.90),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334E39) : const Color(0xFFD0DFC9),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? Colors.white : const Color(0xFF1E3F26),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── 4. Alt Sayfa Noktaları (Oda İndikatörü) ──
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_rooms.length, (i) {
                    final isSelected = i == _selectedRoomIndex;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isSelected ? 18 : 6,
                        height: 5.5,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435))
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoomLevelConfig {
  final int level;
  final String assetPath;
  final String previewImagePath;
  final String nameTr;
  final String nameEn;
  final String subtitleTr;
  final String subtitleEn;
  final String icon;
  final int requiredXP;

  const _RoomLevelConfig({
    required this.level,
    required this.assetPath,
    required this.previewImagePath,
    required this.nameTr,
    required this.nameEn,
    required this.subtitleTr,
    required this.subtitleEn,
    required this.icon,
    required this.requiredXP,
  });

  bool isUnlocked(int focusXP) => focusXP >= requiredXP;
  String localizedName(bool isEn) => isEn ? nameEn : nameTr;
  String localizedSubtitle(bool isEn) => isEn ? subtitleEn : subtitleTr;
}
