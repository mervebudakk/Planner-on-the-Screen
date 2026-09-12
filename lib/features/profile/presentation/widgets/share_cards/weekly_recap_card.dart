import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/models/user_profile.dart';
import '../../../../../core/widgets/vintage_framed_avatar.dart';

/// 📊 "Bu Haftam" Paylaşım Kartı (9:16 Instagram Story Formatı)
class WeeklyRecapCard extends StatelessWidget {
  final UserProfile profile;
  final int totalWeeklyMinutes;
  final Map<int, int> dailyMinutes;
  final int completedPlansCount;

  const WeeklyRecapCard({
    super.key,
    required this.profile,
    required this.totalWeeklyMinutes,
    required this.dailyMinutes,
    required this.completedPlansCount,
  });

  @override
  Widget build(BuildContext context) {
    final hours = totalWeeklyMinutes ~/ 60;
    final minutes = totalWeeklyMinutes % 60;
    final timeStr = hours > 0 ? '${hours}sa ${minutes}dk' : '${minutes}dk';

    // 7 Günlük isimler
    const dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    int maxMin = 1;
    for (final v in dailyMinutes.values) {
      if (v > maxMin) maxMin = v;
    }

    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          // Doğal adaçayı & fildişi gradyanı (Quiet Luxury Studygram)
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4F7F2),
              Color(0xFFE8EFE5),
              Color(0xFFDFE9DC),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFD2DEC9), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
        child: Column(
          children: [
            // ── Üst: Avatar & İsim ──
            Row(
              children: [
                SizedBox(
                  width: 58,
                  height: 68,
                  child: VintageFramedAvatar(
                    animalAsset: profile.animalAssetPath,
                    accessoryAsset: profile.accessoryAssetPath,
                    backgroundColor: AppColors.hexToColor(profile.avatarBgColor),
                    height: 68,
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
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF102E19),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${profile.username.isNotEmpty ? profile.username : 'calenda.user'}',
                        style: AppTypography.sfPro(
                          fontSize: 12.5,
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
                    color: const Color(0xFF102E19),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'HAFTALIK ÖZET',
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

            // ── Orta: Büyük Odak Süresi Kartı ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDBE7D4), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF102E19).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'BU HAFTA ODAKLANILAN SÜRE',
                    style: AppTypography.sfProRounded(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4A6B53),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeStr,
                    style: AppTypography.sfProRounded(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF102E19),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 7 Günlük Mini Çubuk Grafik
                  SizedBox(
                    height: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        final mins = dailyMinutes[i] ?? 0;
                        final ratio = (mins / maxMin).clamp(0.08, 1.0);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 16,
                              height: 65 * ratio,
                              decoration: BoxDecoration(
                                color: mins > 0 ? const Color(0xFF285435) : const Color(0xFFD6E2D0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dayLabels[i],
                              style: AppTypography.sfProRounded(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4A6B53),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tamamlanan Planlar Rozeti
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFDCE6D7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF2E6342), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tamamlanan Planlar',
                      style: AppTypography.sfProRounded(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF102E19),
                      ),
                    ),
                  ),
                  Text(
                    '$completedPlansCount Plan',
                    style: AppTypography.sfProRounded(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF285435),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Alt: Marka İmzası (Viral Büyüme) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF2E6342)),
                const SizedBox(width: 6),
                Text(
                  'Calenda ile Çalışıyorum',
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
