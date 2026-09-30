import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../screens/cozy_room_editor_screen.dart';

/// 🪴 Odalarım — Yan Yana Dizili 15 Odalı İzometrik Köy Dioraması
/// Kullanıcının referans görselindeki gibi odalar çapraz kenarları birbirine
/// yapışacak şekilde (hafif boşlukla) bal peteği / zikzak düzeninde sıralanır.
/// Kilitli odalar yarı saydam görünür ve kilit simgesi taşır; içeri giriş engellenir.
/// Açık odalara dokunulduğunda 360° interaktif 3D düzenleme stüdyosu açılır.
class CozyDeskSection extends StatefulWidget {
  const CozyDeskSection({super.key});

  @override
  State<CozyDeskSection> createState() => _CozyDeskSectionState();
}

class _CozyDeskSectionState extends State<CozyDeskSection> {
  late final ScrollController _scrollController;

  static const double _roomWidth = 186.0;
  static const double _roomHeight = 186.0;
  static const double _stepX = 104.0;
  static const double _stepY = 60.0;
  static const double _topBase = 8.0;
  static const double _leftBase = 12.0;

  static const List<_VillageRoomConfig> _rooms = [
    _VillageRoomConfig(
      level: 1,
      modelFloor: 0,
      assetPath: 'assets/models/room_level_1.glb',
      previewImagePath: 'assets/images/room/room_level_1_preview.png',
      nameTr: '1. Seviye · Huzurlu Köşe',
      nameEn: 'Level 1 · Cozy Bedroom',
      subtitleTr: 'Başlangıç Yatak Odası',
      subtitleEn: 'Starter Bedroom',
      icon: '🪴',
      requiredXP: 0,
    ),
    _VillageRoomConfig(
      level: 2,
      modelFloor: 1,
      assetPath: 'assets/models/room_level_2.glb',
      previewImagePath: 'assets/images/room/room_level_2_preview.png',
      nameTr: '2. Seviye · Çalışma Loftu',
      nameEn: 'Level 2 · Study Loft',
      subtitleTr: '2 Katlı Asma Kat & Kedi',
      subtitleEn: '2-Story Loft & Cat',
      icon: '🏠',
      requiredXP: 150,
    ),
    _VillageRoomConfig(
      level: 3,
      modelFloor: 2,
      assetPath: 'assets/models/room_level_3.glb',
      previewImagePath: 'assets/images/room/room_level_3_preview.png',
      nameTr: '3. Seviye · Sevimli Stüdyo',
      nameEn: 'Level 3 · Sweet Studio',
      subtitleTr: 'Modern Kreatif Stüdyo',
      subtitleEn: 'Modern Creative Studio',
      icon: '✨',
      requiredXP: 350,
    ),
    _VillageRoomConfig(
      level: 4,
      modelFloor: 3,
      assetPath: 'assets/models/room_level_4.glb',
      previewImagePath: 'assets/images/room/room_level_4_preview.png',
      nameTr: '4. Seviye · Pembe Ocaklı Çatı',
      nameEn: 'Level 4 · Pink Hearth Nook',
      subtitleTr: 'Şömineli L-Oda & Asma Yatak',
      subtitleEn: 'Sunken Hearth & Loft Bed',
      icon: '🌸',
      requiredXP: 600,
    ),
    _VillageRoomConfig(
      level: 5,
      modelFloor: 4,
      assetPath: 'assets/models/room_level_5.glb',
      previewImagePath: 'assets/images/room/room_level_5_preview.png',
      nameTr: '5. Seviye · Geliştirici Stüdyosu',
      nameEn: 'Level 5 · Developer Lounge',
      subtitleTr: 'Çift Ekran & Dinlenme Salonu',
      subtitleEn: 'Dual Battlestation & Lounge',
      icon: '💻',
      requiredXP: 950,
    ),
    _VillageRoomConfig(
      level: 6,
      modelFloor: 5,
      assetPath: 'assets/models/room_level_6.glb',
      previewImagePath: 'assets/images/room/room_level_6_preview.png',
      nameTr: '6. Seviye · Sıcak Yatak Odası',
      nameEn: 'Level 6 · Warm Bedroom',
      subtitleTr: 'Pencereli Dinlenme Alanı',
      subtitleEn: 'Window Study & Bed',
      icon: '🛏️',
      requiredXP: 1400,
    ),
    _VillageRoomConfig(
      level: 7,
      modelFloor: 0,
      assetPath: 'assets/models/room_level_1.glb',
      previewImagePath: 'assets/images/room/room_level_1_preview.png',
      nameTr: '7. Seviye · Plak & Kahve Köşesi',
      nameEn: 'Level 7 · Vinyl & Coffee',
      subtitleTr: 'Nostaljik Müzik Köşesi',
      subtitleEn: 'Nostalgic Melody Corner',
      icon: '☕',
      requiredXP: 1950,
    ),
    _VillageRoomConfig(
      level: 8,
      modelFloor: 1,
      assetPath: 'assets/models/room_level_2.glb',
      previewImagePath: 'assets/images/room/room_level_2_preview.png',
      nameTr: '8. Seviye · Sanatçı Çatı Katı',
      nameEn: 'Level 8 · Artist Attic',
      subtitleTr: 'Kreatif Çizim & Boyama',
      subtitleEn: 'Creative Art & Painting',
      icon: '🎨',
      requiredXP: 2600,
    ),
    _VillageRoomConfig(
      level: 9,
      modelFloor: 2,
      assetPath: 'assets/models/room_level_3.glb',
      previewImagePath: 'assets/images/room/room_level_3_preview.png',
      nameTr: '9. Seviye · Gece Gözlemevi',
      nameEn: 'Level 9 · Night Observatory',
      subtitleTr: 'Yıldızlar & Teleskop',
      subtitleEn: 'Stars & Telescope',
      icon: '🔭',
      requiredXP: 3350,
    ),
    _VillageRoomConfig(
      level: 10,
      modelFloor: 3,
      assetPath: 'assets/models/room_level_4.glb',
      previewImagePath: 'assets/images/room/room_level_4_preview.png',
      nameTr: '10. Seviye · Masal Ocak Evi',
      nameEn: 'Level 10 · Fairy Hearth Cottage',
      subtitleTr: 'Sıcak Ateş & Kitap Köşesi',
      subtitleEn: 'Warm Fire & Reading Nook',
      icon: '🔥',
      requiredXP: 4200,
    ),
    _VillageRoomConfig(
      level: 11,
      modelFloor: 4,
      assetPath: 'assets/models/room_level_5.glb',
      previewImagePath: 'assets/images/room/room_level_5_preview.png',
      nameTr: '11. Seviye · Kreatif Kodlama Üssü',
      nameEn: 'Level 11 · Coding Battlestation',
      subtitleTr: 'Gece Mesaisi & Kahve',
      subtitleEn: 'Midnight Code & Coffee',
      icon: '⚡',
      requiredXP: 5150,
    ),
    _VillageRoomConfig(
      level: 12,
      modelFloor: 5,
      assetPath: 'assets/models/room_level_6.glb',
      previewImagePath: 'assets/images/room/room_level_6_preview.png',
      nameTr: '12. Seviye · Sakura Kitaplığı',
      nameEn: 'Level 12 · Sakura Library',
      subtitleTr: 'Geleneksel Çay & Dinginlik',
      subtitleEn: 'Tea Ritual & Peace',
      icon: '🌸',
      requiredXP: 6200,
    ),
    _VillageRoomConfig(
      level: 13,
      modelFloor: 0,
      assetPath: 'assets/models/room_level_1.glb',
      previewImagePath: 'assets/images/room/room_level_1_preview.png',
      nameTr: '13. Seviye · Botanik Gökyüzü Terası',
      nameEn: 'Level 13 · Botanical Terrace',
      subtitleTr: 'Bulutların Üzerinde Manzara',
      subtitleEn: 'Above the Clouds',
      icon: '☁️',
      requiredXP: 7350,
    ),
    _VillageRoomConfig(
      level: 14,
      modelFloor: 1,
      assetPath: 'assets/models/room_level_2.glb',
      previewImagePath: 'assets/images/room/room_level_2_preview.png',
      nameTr: '14. Seviye · Antika Asma Arşiv',
      nameEn: 'Level 14 · Vintage Archives',
      subtitleTr: 'Nadir Kitaplar & Haritalar',
      subtitleEn: 'Rare Books & Maps',
      icon: '📜',
      requiredXP: 8600,
    ),
    _VillageRoomConfig(
      level: 15,
      modelFloor: 4,
      assetPath: 'assets/models/room_level_5.glb',
      previewImagePath: 'assets/images/room/room_level_5_preview.png',
      nameTr: '15. Seviye · Usta Cozy Malikanesi',
      nameEn: 'Level 15 · Grand Cozy Villa',
      subtitleTr: 'Nihai Huzur & Stüdyo Köşkü',
      subtitleEn: 'Ultimate Cozy Haven',
      icon: '👑',
      requiredXP: 10000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Sıralı kilit açma kuralı: Oda N, sadece Oda N-1 tamamlanmış ve gerekli XP sağlanmışsa açılır.
  bool _isRoomUnlocked(int index, int focusXP) {
    if (index == 0) return true; // İlk oda her zaman açıktır
    if (!_isRoomUnlocked(index - 1, focusXP)) return false; // Önceki oda bitmeden açılamaz
    return focusXP >= _rooms[index].requiredXP;
  }

  int _countUnlockedRooms(int focusXP) {
    int count = 0;
    for (int i = 0; i < _rooms.length; i++) {
      if (_isRoomUnlocked(i, focusXP)) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  void _onRoomTap(BuildContext context, int index, int focusXP, bool isEn) {
    final room = _rooms[index];
    final isUnlocked = _isRoomUnlocked(index, focusXP);

    if (isUnlocked) {
      AppHaptics.lightImpact();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CozyRoomEditorScreen(initialFloor: room.modelFloor),
        ),
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else {
      AppHaptics.mediumImpact();
      final prevUnlocked = _isRoomUnlocked(index - 1, focusXP);
      if (!prevUnlocked) {
        AestheticSnackBar.showWarning(
          context,
          isEn
              ? '🔒 Level ${room.level} is locked. Complete the previous level first!'
              : '🔒 ${room.level}. Seviye kilitli. Önceki seviyenin tamamlanmış olması gerekmektedir.',
        );
      } else {
        final remaining = room.requiredXP - focusXP;
        AestheticSnackBar.showWarning(
          context,
          isEn
              ? '🔒 ${room.nameEn} unlocks at ${room.requiredXP} XP ($remaining XP remaining)'
              : '🔒 ${room.nameTr} ${room.requiredXP} XP ile açılır ($remaining XP kaldı)',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final lang = Localizations.localeOf(context).languageCode;
    final isEn = lang == 'en';

    return ListenableBuilder(
      listenable: AchievementService.instance,
      builder: (context, _) {
        final service = AchievementService.instance;
        final focusXP = service.focusXP;
        final unlockedCount = _countUnlockedRooms(focusXP);

        // Toplam Stack genişliği: 15 oda çapraz kenar adımıyla hesaplanır
        final totalWidth = _leftBase + ((_rooms.length - 1) * _stepX) + _roomWidth + 24.0;
        const totalHeight = _topBase + _stepY + _roomHeight + 16.0;

        // İzometrik derinlik sıralaması: Üst sıradaki (arkadaki) odalar önce,
        // alt sıradaki (öndeki) odalar sonra çizilir (Painter's algorithm).
        final upperIndices = <int>[];
        final lowerIndices = <int>[];
        for (int i = 0; i < _rooms.length; i++) {
          if (i % 2 == 0) {
            upperIndices.add(i);
          } else {
            lowerIndices.add(i);
          }
        }
        final sortedIndices = [...upperIndices, ...lowerIndices];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Başlık: "Odalarım" & Açık Oda Rozeti ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Text(
                    isEn ? 'My Rooms' : 'Odalarım',
                    style: AppTypography.sfProRounded(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2E23) : const Color(0xFFEFF5EC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C4835) : const Color(0xFFD6E5D1),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      '$unlockedCount / ${_rooms.length} ${isEn ? 'Unlocked' : 'Açık'}',
                      style: AppTypography.sfPro(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isEn ? 'Scroll to explore →' : 'Kaydırarak keşfet →',
                    style: AppTypography.sfPro(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── 2. Çapraz / İzometrik Bal Peteği Oda Köyü (Scrollable Canvas) ──
            SizedBox(
              height: totalHeight,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: totalWidth,
                  height: totalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: sortedIndices.map((index) {
                      final room = _rooms[index];
                      final isUnlocked = _isRoomUnlocked(index, focusXP);
                      final isUpper = (index % 2 == 0);

                      final left = _leftBase + (index * _stepX);
                      final top = isUpper ? _topBase : (_topBase + _stepY);

                      return Positioned(
                        left: left,
                        top: top,
                        width: _roomWidth,
                        height: _roomHeight,
                        child: BouncingWidget(
                          onTap: () => _onRoomTap(context, index, focusXP, isEn),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // ── A. Saydam Arka Planlı İzometrik Oda Görseli ──
                              Opacity(
                                opacity: isUnlocked ? 0.98 : 0.38,
                                child: Image.asset(
                                  room.previewImagePath,
                                  width: _roomWidth,
                                  height: _roomHeight,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Text('🪴', style: TextStyle(fontSize: 36)),
                                  ),
                                ),
                              ),

                              // ── B. Kilitli Oda Rozeti (🔒 ve Seviye) ──
                              if (!isUnlocked)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: (isDark ? const Color(0xFF0F1712) : Colors.white).withValues(alpha: 0.90),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF2E4836) : const Color(0xFFD6E4D1),
                                        width: 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🔒', style: TextStyle(fontSize: 20)),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${room.level}. Kat',
                                          style: AppTypography.sfProRounded(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${room.requiredXP} XP',
                                          style: AppTypography.sfPro(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // ── C. Açık Oda Etiketi (Sol Üst Köşede Zarif Rozet) ──
                              if (isUnlocked)
                                Positioned(
                                  top: 10,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                    decoration: BoxDecoration(
                                      color: (isDark ? const Color(0xFF111E15) : Colors.white).withValues(alpha: 0.92),
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
                                        Text(room.icon, style: const TextStyle(fontSize: 10.5)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${room.level}. Kat',
                                          style: AppTypography.sfProRounded(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // ── D. Açık Oda Aç İpucu (Sağ Alt Köşe) ──
                              if (isUnlocked)
                                Positioned(
                                  bottom: 12,
                                  right: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.touch_app_rounded,
                                          size: 10,
                                          color: isDark ? Colors.white70 : const Color(0xFF285435),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          isEn ? 'Open' : 'Aç',
                                          style: AppTypography.sfPro(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
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
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VillageRoomConfig {
  final int level;
  final int modelFloor;
  final String assetPath;
  final String previewImagePath;
  final String nameTr;
  final String nameEn;
  final String subtitleTr;
  final String subtitleEn;
  final String icon;
  final int requiredXP;

  const _VillageRoomConfig({
    required this.level,
    required this.modelFloor,
    required this.assetPath,
    required this.previewImagePath,
    required this.nameTr,
    required this.nameEn,
    required this.subtitleTr,
    required this.subtitleEn,
    required this.icon,
    required this.requiredXP,
  });

  String localizedName(bool isEn) => isEn ? nameEn : nameTr;
  String localizedSubtitle(bool isEn) => isEn ? subtitleEn : subtitleTr;
}
