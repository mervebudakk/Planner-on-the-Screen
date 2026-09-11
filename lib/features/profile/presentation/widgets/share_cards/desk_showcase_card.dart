import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/models/desk_item.dart';
import '../../../../../core/models/user_profile.dart';
import '../../../../../core/widgets/vintage_framed_avatar.dart';

/// 🧸 "Çalışma Masam" Paylaşım Kartı (1:1 Instagram Post Formatı)
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
    final unlockedItems = deskItems.where((i) => i.isUnlocked).toList();

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
                    animalAsset: profile.avatarAnimal,
                    accessoryAsset: profile.avatarAccessory,
                    backgroundColor: AppColors.hexToColor(profile.avatarBgColor),
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
                        'THE COZY DESK',
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
                    '${unlockedItems.length} MASA NESNESİ',
                    style: AppTypography.sfProRounded(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF8CEFA5),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Masa Alanı (Canvas)
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;

                    return Stack(
                      children: [
                        // Ahşap Masa Çizgisi
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: h * 0.28,
                          child: Container(
                            height: 2,
                            color: const Color(0xFFE4EDE0),
                          ),
                        ),

                        // Masa Nesneleri
                        ...deskItems.map((item) {
                          final isUnlocked = item.isUnlocked;
                          final posX = (item.normalizedX * w) - (item.size / 2);
                          final posY = (item.normalizedY * h) - (item.size / 2);

                          return Positioned(
                            left: posX.clamp(8.0, w - item.size - 8.0),
                            top: posY.clamp(8.0, h - item.size - 8.0),
                            child: Opacity(
                              opacity: isUnlocked ? 1.0 : 0.18,
                              child: Container(
                                width: item.size,
                                height: item.size,
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? item.accentColor.withValues(alpha: 0.15)
                                      : const Color(0xFFE6EDE3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isUnlocked
                                        ? item.accentColor.withValues(alpha: 0.35)
                                        : const Color(0xFFCFDACB),
                                    width: 1.0,
                                  ),
                                ),
                                child: Icon(
                                  item.icon,
                                  size: item.size * 0.52,
                                  color: isUnlocked ? item.accentColor : const Color(0xFF7D9485),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Marka İmzası
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco_rounded, size: 15, color: Color(0xFF2E6342)),
                const SizedBox(width: 6),
                Text(
                  'Calenda • The Cozy Desk',
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
