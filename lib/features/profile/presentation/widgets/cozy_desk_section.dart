import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../screens/cozy_room_editor_screen.dart';
import 'parallax_room_canvas.dart';

/// 🪴 The Cozy Room — Profil Ekranı 3D İzometrik Canlı Parallax Oda Kartı
/// Sade, estetik ve şık 3D oda görüntüsünü canlı parallax ve mikro-animasyonlarla sergiler.
/// Dokunulduğunda tüm düzenleme, mobilya değişimi ve kat yönetimi stüdyosu açılır.
class CozyDeskSection extends StatelessWidget {
  const CozyDeskSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    return ListenableBuilder(
      listenable: AchievementService.instance,
      builder: (context, _) {
        final roomState = AchievementService.instance.roomState;
        final tier = roomState.currentTier;

        return BouncingWidget(
          onTap: () {
            AppHaptics.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CozyRoomEditorScreen()),
            );
          },
          child: Container(
            width: double.infinity,
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
                  // 1. Canlı Parallax Oda Tuvali
                  ParallaxRoomCanvas(
                    roomState: roomState,
                    isInteractive: false,
                    enableParallax: true,
                  ),

                  // 2. Sol Üst: Zarif Seviye & Oda Başlığı Rozeti
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
                          const Text('✨', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 5),
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
                            lang == 'en' ? 'Tap to edit' : 'Düzenlemek için dokun',
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
