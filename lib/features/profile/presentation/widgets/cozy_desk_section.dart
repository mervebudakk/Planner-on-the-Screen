import 'package:flutter/material.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../screens/cozy_room_editor_screen.dart';

/// 🪴 The Cozy Room — Profil Ekranı 3D İzometrik Oda Kartı
/// Yalnızca sade, estetik ve şık 3D oda görüntüsünü sergiler.
/// Dokunulduğunda tüm düzenleme, renk değiştirme ve özelleştirme stüdyosu açılır.
class CozyDeskSection extends StatelessWidget {
  const CozyDeskSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: AchievementService.instance,
      builder: (context, _) {
        final selectedTheme = AchievementService.instance.roomThemeColor;

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
              child: AspectRatio(
                aspectRatio: 800 / 600,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Boş Oda Kabuğu (Zemin, Parke, Kaide, Sabah Güneşi)
                    Image.asset(
                      'assets/images/room/room_base.png',
                      fit: BoxFit.contain,
                    ),

                    // 2. Sabah Penceresi
                    Image.asset(
                      'assets/images/room/window_lv1.png',
                      fit: BoxFit.contain,
                    ),

                    // 3. Duvar Tablosu
                    Image.asset(
                      'assets/images/room/wall_decor_lv1.png',
                      fit: BoxFit.contain,
                    ),

                    // 4. Renk Temalı Eşyalar (Yumuşak AnimatedSwitcher ile Canlı Geçiş)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Image.asset(
                        'assets/images/room/rug_lv1_$selectedTheme.png',
                        key: ValueKey('rug_$selectedTheme'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Image.asset(
                        'assets/images/room/bed_lv1_$selectedTheme.png',
                        key: ValueKey('bed_$selectedTheme'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Image.asset(
                        'assets/images/room/desk_lv1_$selectedTheme.png',
                        key: ValueKey('desk_$selectedTheme'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Image.asset(
                        'assets/images/room/decor_lv1_$selectedTheme.png',
                        key: ValueKey('decor_$selectedTheme'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
