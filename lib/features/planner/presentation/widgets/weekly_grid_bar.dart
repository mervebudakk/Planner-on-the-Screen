import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../providers/planner_provider.dart';

/// 🍎 Apple iOS SF Pro Standartlarında 7 Günlük (Pzt - Paz) Haftalık Takvim Barı
class WeeklyGridBar extends StatelessWidget {
  const WeeklyGridBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        final selectedDate = provider.selectedDate;

        // Seçili tarihin içinde bulunduğu haftanın Pazartesi gününü bul
        final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
        final weekDays = List.generate(
          7,
          (i) => DateTime(monday.year, monday.month, monday.day + i),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((date) {
              final isSelected = DateTimeUtils.isSameDay(selectedDate, date);
              final isToday = DateTimeUtils.isToday(date);
              final dayEvents = provider.getEventsForDate(date);

              final dayTextColor = isSelected
                  ? (isDark ? AppColors.darkTextPrimary : const Color(0xFF102E19))
                  : (isDark ? const Color(0xFF7A9981) : const Color(0xFF526D57));

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: BouncingWidget(
                    onTap: () => provider.selectDate(date),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔤 1. Gün Kısaltması (Pzt, Sal, Çar, Per, Cum, Cmt, Paz)
                        Text(
                          DateTimeUtils.getShortDayName(date.weekday),
                          style: AppTypography.sfPro(
                            fontSize: 13.8,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: dayTextColor,
                          ),
                        ),

                        const SizedBox(height: 7),

                        // 🔘 2. Dairesel Gün Numarası (44px x 44px)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? const Color(0xFF14241B)
                                    : (isToday ? const Color(0xFFE8F1E5) : Colors.white)),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: AppTypography.sfProRounded(
                                fontSize: 16.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // 📍 3. Etkinlik Noktaları
                        SizedBox(
                          height: 4,
                          child: dayEvents.isEmpty
                              ? const SizedBox.shrink()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: dayEvents.take(3).map((event) {
                                    final dotColor = isSelected
                                        ? AppColors.primary
                                        : AppColors.hexToColor(event.colorHex);
                                    return Container(
                                      width: 3.5,
                                      height: 3.5,
                                      margin: const EdgeInsets.symmetric(horizontal: 0.8),
                                      decoration: BoxDecoration(
                                        color: dotColor,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
