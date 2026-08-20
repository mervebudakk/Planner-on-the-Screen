import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/utils/date_time_utils.dart';

/// 7 günlük mini haftalık çizelge kutucukları (Referans ekran görüntüsündeki Weekly Grid)
class WeeklyGridBar extends StatelessWidget {
  final int selectedDay;
  final Function(int) onDaySelected;
  final List<ScheduleEvent> Function(int) getEventsForDay;
  final bool isTransparentMode;

  const WeeklyGridBar({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.getEventsForDay,
    this.isTransparentMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final weekDayNumbers = DateTimeUtils.getCurrentWeekDayNumbers();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(7, (index) {
          final dayOfWeek = index + 1;
          final isSelected = dayOfWeek == selectedDay;
          final dayNumber = weekDayNumbers[dayOfWeek] ?? (17 + index);
          final dayEvents = getEventsForDay(dayOfWeek);

          return Expanded(
            child: GestureDetector(
              onTap: () => onDaySelected(dayOfWeek),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.28)
                      : (isTransparentMode
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gün Kısa Adı (Mon, Tue ...)
                    Text(
                      DateTimeUtils.getShortDayName(dayOfWeek),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Gün Numarası (17, 18 ...)
                    Text(
                      '$dayNumber',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Mini Etkinlik Çipleri (Maksimum 4 adet gösterim)
                    ...dayEvents.take(4).map((event) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 2),
                        decoration: BoxDecoration(
                          color: event.color.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w600,
                            color: _getTextColorForBackground(event.color),
                          ),
                        ),
                      );
                    }),
                    if (dayEvents.isEmpty)
                      Container(
                        height: 20,
                        alignment: Alignment.center,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Çip üzerindeki yazının okunabilirliği için kontrast rengi
  Color _getTextColorForBackground(Color bg) {
    if (bg == const Color(0xFFE2E8F0) || bg == Colors.white) {
      return const Color(0xFF1E293B);
    }
    return Colors.black87;
  }
}
