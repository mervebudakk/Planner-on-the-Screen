import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/models/achievement.dart';
import '../../../../../core/models/user_profile.dart';
import '../../../../../core/widgets/vintage_framed_avatar.dart';
import '../modern_achievement_badge.dart';

/// 🏆 "Odak Zaferi / Başarı Rozeti" Paylaşım Kartı (9:16 Instagram Story Formatı)
class FocusMilestoneCard extends StatelessWidget {
  final UserProfile profile;
  final Achievement achievement;
  final int totalHours;

  const FocusMilestoneCard({
    super.key,
    required this.profile,
    required this.achievement,
    required this.totalHours,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAFBF9),
              Color(0xFFEFF5ED),
              Color(0xFFE2EBE0),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFD2DEC9), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
        child: Column(
          children: [
            // Üst: Avatar & İsim
            Row(
              children: [
                SizedBox(
                  width: 54,
                  height: 64,
                  child: VintageFramedAvatar(
                    animalAsset: profile.avatarAnimal,
                    accessoryAsset: profile.avatarAccessory,
                    backgroundColor: AppColors.hexToColor(profile.avatarBgColor),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: AppTypography.sfProRounded(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF102E19),
                        ),
                      ),
                      Text(
                        '@${profile.username.isNotEmpty ? profile.username : 'calenda.user'}',
                        style: AppTypography.sfPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A6B53),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF285435),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'YENİ BAŞARI',
                    style: AppTypography.sfProRounded(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF8CEFA5),
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Büyük Rozet
            ModernAchievementBadge(
              achievement: achievement,
              size: 110.0,
            ),
            const SizedBox(height: 20),

            // Başlık
            Text(
              achievement.titleTr.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.sfProRounded(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF102E19),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Açıklama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                achievement.descriptionTr,
                textAlign: TextAlign.center,
                style: AppTypography.sfPro(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF38553F),
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Kümülatif İstatistik Hapı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFDBE7D4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF102E19).withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_rounded, size: 20, color: Color(0xFF2E6342)),
                  const SizedBox(width: 8),
                  Text(
                    'Toplam $totalHours Saat Derin Odaklanma',
                    style: AppTypography.sfProRounded(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF102E19),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Marka İmzası
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF2E6342)),
                const SizedBox(width: 6),
                Text(
                  'Calenda • The Cozy Desk',
                  style: AppTypography.sfProRounded(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF102E19),
                    letterSpacing: 0.4,
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
