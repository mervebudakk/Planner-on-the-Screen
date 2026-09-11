import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/models/schedule_event.dart';
import '../../../../../core/models/user_profile.dart';
import '../../../../../core/widgets/vintage_framed_avatar.dart';

/// 📅 "Bugünün Planı" Paylaşım Kartı (9:16 Instagram Story)
class TodayPlanCard extends StatelessWidget {
  final UserProfile profile;
  final DateTime date;
  final List<ScheduleEvent> todayEvents;

  const TodayPlanCard({
    super.key,
    required this.profile,
    required this.date,
    required this.todayEvents,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM EEEE', 'tr_TR').format(date);
    final completedCount = todayEvents.where((e) => e.isCompleted).length;
    final totalCount = todayEvents.length;

    // Gösterilecek ilk 5 plan
    final displayEvents = todayEvents.take(5).toList();

    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F9F5),
              Color(0xFFEDF4EB),
              Color(0xFFE2EBE0),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFD2DEC9), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst: Avatar & İsim
            Row(
              children: [
                SizedBox(
                  width: 52,
                  height: 62,
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
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF102E19),
                        ),
                      ),
                      Text(
                        dateStr,
                        style: AppTypography.sfPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A6B53),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF102E19),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$completedCount/$totalCount BİTTİ',
                    style: AppTypography.sfProRounded(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF8CEFA5),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'GÜNÜN HEDEFLERİ & AKIŞ',
              style: AppTypography.sfProRounded(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4A6B53),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // Plan Listesi
            if (displayEvents.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Bugün için henüz plan eklenmedi.',
                  style: AppTypography.sfPro(fontSize: 13, color: const Color(0xFF4A6B53)),
                ),
              )
            else
              Column(
                children: displayEvents.map((event) {
                  final eventColor = AppColors.hexToColor(event.colorHex);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDCE6D7), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 28,
                          decoration: BoxDecoration(
                            color: eventColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sfProRounded(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF102E19),
                                  decoration: event.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              if (event.hasSpecificTime)
                                Text(
                                  event.formattedTimeRange,
                                  style: AppTypography.sfPro(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF5A7862),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          event.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          size: 18,
                          color: event.isCompleted ? const Color(0xFF2E6342) : const Color(0xFFA5B8A8),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const Spacer(),

            // Marka İmzası
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF2E6342)),
                  const SizedBox(width: 6),
                  Text(
                    'Calenda ile Planlıyorum',
                    style: AppTypography.sfProRounded(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF102E19),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
