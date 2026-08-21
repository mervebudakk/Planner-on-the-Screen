import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../providers/planner_provider.dart';

/// Apple iOS Tarzı Buzlu Cam (Frosted Glass) Kaydırılabilir Takvim Günleri Barı
class WeeklyGridBar extends StatefulWidget {
  const WeeklyGridBar({super.key});

  @override
  State<WeeklyGridBar> createState() => _WeeklyGridBarState();
}

class _WeeklyGridBarState extends State<WeeklyGridBar> {
  late ScrollController _scrollController;
  static const double _itemWidth = 56.0;
  static const double _itemMargin = 6.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Açılışta bugünün kartını ekranın merkezine kaydır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday(animated: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToToday({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    // Bugün 15. index'tedir (-15 günden başladığı için)
    const todayIndex = 15;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = (todayIndex * (_itemWidth + _itemMargin)) - (screenWidth / 2) + (_itemWidth / 2) + 16;
    final clampedOffset =
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent).toDouble();

    if (animated) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        final days = provider.calendarDays;

        return SizedBox(
          height: 88,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = DateTimeUtils.isSameDay(provider.selectedDate, date);
              final isToday = DateTimeUtils.isToday(date);
              final dayEvents = provider.getEventsForDate(date);

              final cardColor = isSelected
                  ? (isDark
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.primary.withValues(alpha: 0.18))
                  : (isDark
                      ? const Color(0xFF1E293B).withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.65));

              final borderColor = isSelected
                  ? AppColors.primary
                  : (isToday
                      ? AppColors.todayHighlight.withValues(alpha: 0.8)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.85)));

              return Container(
                width: _itemWidth,
                margin: const EdgeInsets.only(right: _itemMargin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.15)
                          : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => provider.selectDate(date),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: borderColor,
                              width: isSelected ? 1.8 : (isToday ? 1.4 : 1),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 📍 Bugün rozeti
                              if (isToday)
                                Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.only(bottom: 2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.todayHighlight,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                const SizedBox(height: 7),

                              // Günün Kısa Adı (Pzt, Sal, Çar...)
                              Text(
                                DateTimeUtils.getShortDayName(date.weekday),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : (isToday ? FontWeight.w700 : FontWeight.w500),
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isToday
                                          ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                                          : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary)),
                                ),
                              ),
                              const SizedBox(height: 3),

                              // Gün Numarası (24, 25, 26...)
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : (isToday ? FontWeight.w800 : FontWeight.w600),
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary),
                                ),
                              ),
                              const SizedBox(height: 5),

                              // Günün Etkinlik Pastel Noktaları
                              SizedBox(
                                height: 5,
                                child: dayEvents.isEmpty
                                    ? const SizedBox.shrink()
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: dayEvents.take(3).map((event) {
                                          final dotColor = AppColors.hexToColor(event.colorHex);
                                          return Container(
                                            width: 4.5,
                                            height: 4.5,
                                            margin: const EdgeInsets.symmetric(horizontal: 1),
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
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
