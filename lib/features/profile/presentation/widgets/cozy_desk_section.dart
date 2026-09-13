import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/services/glb_room_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../screens/cozy_room_editor_screen.dart';

/// 🪴 The Cozy Room — Profil Ekranı 3D Canlı Diorama Kartı
/// Sade, estetik ve şık 3D oda görüntüsünü canlı hafif rotasyonla sergiler.
/// Dokunulduğunda tüm 360° döndürülebilir düzenleme ve eşya satın alma stüdyosu açılır.
class CozyDeskSection extends StatefulWidget {
  const CozyDeskSection({super.key});

  @override
  State<CozyDeskSection> createState() => _CozyDeskSectionState();
}

class _CozyDeskSectionState extends State<CozyDeskSection> {
  String? _modelDataUri;

  @override
  void initState() {
    super.initState();
    _load3DModel();
    AchievementService.instance.addListener(_onAchievementsChanged);
  }

  @override
  void dispose() {
    AchievementService.instance.removeListener(_onAchievementsChanged);
    super.dispose();
  }

  void _onAchievementsChanged() {
    _load3DModel();
  }

  Future<void> _load3DModel() async {
    final unlocked = AchievementService.instance.unlockedDioramaItems;
    try {
      final uri = await GlbRoomService.instance.generateFilteredGlbDataUri(
        unlockedItemIds: unlocked,
      );
      if (mounted) {
        setState(() {
          _modelDataUri = uri;
        });
      }
    } catch (_) {}
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
        final unlockedCount = service.dioramaUnlockedCount;
        final totalCount = service.dioramaTotalCount;

        return BouncingWidget(
          onTap: () async {
            AppHaptics.lightImpact();
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CozyRoomEditorScreen()),
            );
            _load3DModel();
          },
          child: Container(
            width: double.infinity,
            height: 250,
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
                    ? const Color(0xFF283A2E).withValues(alpha: 0.85)
                    : const Color(0xFFDBE8D3).withValues(alpha: 0.95),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF102E19))
                      .withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                children: [
                  // 1. Canlı 3D Diorama Tuvali
                  Positioned.fill(
                    child: _modelDataUri != null
                        ? IgnorePointer(
                            child: ModelViewer(
                              key: ValueKey(_modelDataUri),
                              src: _modelDataUri!,
                              alt: 'The Cozy Room 3D',
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
                        : Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                              ),
                            ),
                          ),
                  ),

                  // 2. Sol Üst: Zarif 3D Oda Rozeti
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF111E15) : Colors.white)
                            .withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isDark ? const Color(0xFF2E4836) : const Color(0xFFD6E4D1))
                              .withValues(alpha: 0.9),
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
                          const Text('🪴', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 5),
                          Text(
                            isEn
                                ? 'The Cozy Room · $unlockedCount/$totalCount'
                                : 'Odam · $unlockedCount/$totalCount Eşya',
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

                  // 3. Sağ Alt: Düzenle İpucu
                  Positioned(
                    bottom: 10,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.70),
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
                            isEn ? 'Tap to edit' : 'Düzenlemek için dokun',
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
        );
      },
    );
  }
}
