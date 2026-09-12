import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/models/routine_model.dart';
import '../../../../../core/models/user_profile.dart';
import '../../../../../core/widgets/vintage_framed_avatar.dart';

/// 🔥 "Rutin Serisi" Paylaşım Kartı (9:16 Instagram Story)
class StreakCard extends StatelessWidget {
  final UserProfile profile;
  final int maxStreak;
  final List<RoutineModel> routines;

  const StreakCard({
    super.key,
    required this.profile,
    required this.maxStreak,
    required this.routines,
  });

  @override
  Widget build(BuildContext context) {
    final activeRoutines = routines.where((r) => r.streak > 0).take(4).toList();

    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAFBF8),
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
                    animalAsset: profile.animalAssetPath,
                    accessoryAsset: profile.accessoryAssetPath,
                    backgroundColor: AppColors.hexToColor(profile.avatarBgColor),
                    height: 64,
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
                    'RUTİN SERİSİ',
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

            // Büyük Seri Rozeti
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF102E19),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF102E19).withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.local_fire_department_rounded, size: 48, color: Color(0xFF8CEFA5)),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              '$maxStreak GÜN KESİNTİSİZ',
              textAlign: TextAlign.center,
              style: AppTypography.sfProRounded(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF102E19),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Alışkanlıklar her günün ritmini belirler.',
              textAlign: TextAlign.center,
              style: AppTypography.sfPro(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4A6B53),
              ),
            ),
            const SizedBox(height: 24),

            // Aktif Rutinler
            if (activeRoutines.isNotEmpty)
              Column(
                children: activeRoutines.map((r) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDCE6D7)),
                    ),
                    child: Row(
                      children: [
                        Icon(r.icon, size: 18, color: const Color(0xFF285435)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            r.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sfProRounded(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF102E19),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EDE0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🔥 ${r.streak} Gün',
                            style: AppTypography.sfProRounded(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF285435),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const Spacer(),

            // Marka İmzası
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF2E6342)),
                const SizedBox(width: 6),
                Text(
                  'Calenda ile Ritim Yakala',
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
