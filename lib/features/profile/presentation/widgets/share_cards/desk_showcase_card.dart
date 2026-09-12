import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/models/desk_item.dart';
import '../../../../../core/models/user_profile.dart';
import '../../../../../core/services/achievement_service.dart';
import '../../../../../core/widgets/vintage_framed_avatar.dart';

/// 🪴 "Odam" (The Cozy Room) Paylaşım Kartı (1:1 Instagram Post Formatı)
class DeskShowcaseCard extends StatelessWidget {
  final UserProfile profile;
  final List<DeskItem> deskItems;
  final int unlockedAchievementCount;

  const DeskShowcaseCard({
    super.key,
    required this.profile,
    required this.deskItems,
    required this.unlockedAchievementCount,
  });

  @override
  Widget build(BuildContext context) {
    final selectedTheme = AchievementService.instance.roomThemeColor;

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F9F5),
              Color(0xFFEBF2E8),
              Color(0xFFDFE9DC),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFD2DEC9), width: 1.5),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            // Üst Bar
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 56,
                  child: VintageFramedAvatar(
                    animalAsset: profile.animalAssetPath,
                    accessoryAsset: profile.accessoryAssetPath,
                    backgroundColor: AppColors.hexToColor(profile.avatarBgColor),
                    height: 56,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: AppTypography.sfProRounded(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF102E19),
                        ),
                      ),
                      Text(
                        'THE COZY ROOM',
                        style: AppTypography.sfProRounded(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF38553F),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF102E19),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SEVİYE 1 ODA',
                    style: AppTypography.sfProRounded(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF8CEFA5),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Oda Alanı (3D Isometric Room Canvas)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFDCE6D7)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF102E19).withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AspectRatio(
                    aspectRatio: 800 / 600,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
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
                        Image.asset(
                          'assets/images/room/rug_lv1_$selectedTheme.png',
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          'assets/images/room/bed_lv1_$selectedTheme.png',
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          'assets/images/room/desk_lv1_$selectedTheme.png',
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          'assets/images/room/decor_lv1_$selectedTheme.png',
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Marka İmzası
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cottage_rounded, size: 15, color: Color(0xFF2E6342)),
                const SizedBox(width: 6),
                Text(
                  'Calenda • The Cozy Room',
                  style: AppTypography.sfProRounded(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF102E19),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
