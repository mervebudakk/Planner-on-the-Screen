import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../providers/planner_provider.dart';

/// 🍎 Apple iOS SF Pro Standartlarında Kaydırılabilir (Haftalık Sayfalı) 7 Günlük Takvim Barı
/// - 1 hafta öncesi (saklanan geçmiş veriler)
/// - İçinde bulunulan hafta (Pzt - Paz)
/// - Gelecek haftalar (Pzt - Paz)
class WeeklyGridBar extends StatefulWidget {
  const WeeklyGridBar({super.key});

  @override
  State<WeeklyGridBar> createState() => _WeeklyGridBarState();
}

class _WeeklyGridBarState extends State<WeeklyGridBar> {
  static const int _pastWeeks = 1; // Sadece 1 hafta öncesi saklanır
  static const int _futureWeeks = 52; // Geleceğe 52 hafta
  static const int _totalPages = _pastWeeks + 1 + _futureWeeks; // Toplam 54 hafta
  static const int _initialPage = _pastWeeks; // 1 = İçinde bulunulan hafta

  late final PageController _pageController;
  int _currentPage = _initialPage;
  bool _isUserScrolling = false;
  PlannerProvider? _provider;
  DateTime? _lastObservedDate;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newProvider = context.read<PlannerProvider>();
    if (_provider != newProvider) {
      _provider?.removeListener(_onProviderChanged);
      _provider = newProvider;
      _provider?.addListener(_onProviderChanged);
    }
  }

  void _onProviderChanged() {
    if (!mounted || _isUserScrolling || !_pageController.hasClients) return;
    final selectedDate = _provider?.selectedDate;
    if (selectedDate == null || selectedDate == _lastObservedDate) return;
    _lastObservedDate = selectedDate;

    final targetPage = _getPageIndexForDate(selectedDate);
    if (_currentPage != targetPage) {
      _currentPage = targetPage;
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    _pageController.dispose();
    super.dispose();
  }

  /// Verilen sayfa indeksi için haftanın Pazartesi gününü hesaplar
  DateTime _getMondayForPageIndex(int pageIndex) {
    final today = DateTimeUtils.today;
    final thisMonday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    final weekOffset = pageIndex - _pastWeeks;
    return thisMonday.add(Duration(days: weekOffset * 7));
  }

  /// Verilen tarihin hangi hafta sayfa indeksine denk geldiğini bulur
  int _getPageIndexForDate(DateTime date) {
    final today = DateTimeUtils.today;
    final thisMonday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    final targetMonday = DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
    final diffDays = targetMonday.difference(thisMonday).inDays;
    final weekOffset = (diffDays / 7).round();
    final page = weekOffset + _pastWeeks;
    return page.clamp(0, _totalPages - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        final selectedDate = provider.selectedDate;
        return SizedBox(
          height: 94,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _isUserScrolling = true;
              } else if (notification is ScrollEndNotification) {
                _isUserScrolling = false;
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalPages,
              onPageChanged: (newPage) {
                _currentPage = newPage;
                final newMonday = _getMondayForPageIndex(newPage);
                
                // İçinde bulunulan haftaya dönüldüyse Bugünü, başka haftaya geçildiyse Pazartesi'yi seç
                final DateTime newSelectedDate;
                if (newPage == _initialPage) {
                  newSelectedDate = DateTimeUtils.today;
                } else {
                  newSelectedDate = newMonday; // Her zaman haftanın başı (Pazartesi)
                }

                _lastObservedDate = newSelectedDate;
                if (!DateTimeUtils.isSameDay(provider.selectedDate, newSelectedDate)) {
                  provider.selectDate(newSelectedDate);
                }
              },
              itemBuilder: (context, pageIndex) {
                final monday = _getMondayForPageIndex(pageIndex);
                final weekDays = List.generate(
                  7,
                  (i) => DateTime(monday.year, monday.month, monday.day + i),
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weekDays.map((date) {
                      final isSelected = DateTimeUtils.isSameDay(selectedDate, date);
                      final isToday = DateTimeUtils.isToday(date);
                      final dayEvents = provider.getEventsForDate(date);

                      final dayTextColor = isSelected
                          ? (isDark ? AppColors.darkTextPrimary : const Color(0xFF102E19))
                          : (isDark ? AppColors.darkTextMuted : const Color(0xFF526D57));

                      final circleColor = isSelected
                          ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                          : (isDark
                              ? AppColors.darkSurface
                              : (isToday ? const Color(0xFFE8F1E5) : Colors.white));

                      final circleBorder = isDark && !isSelected
                          ? Border.all(
                              color: isToday ? const Color(0xFF385845) : AppColors.darkBorder,
                              width: 1.0,
                            )
                          : null;

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
                                  DateTimeUtils.getShortDayName(
                                    date.weekday,
                                    locale: context.l10n.locale.languageCode,
                                  ),
                                  style: AppTypography.sfPro(
                                    fontSize: 13.0,
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
                                    color: circleColor,
                                    shape: BoxShape.circle,
                                    border: circleBorder,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${date.day}',
                                      style: AppTypography.sfProRounded(
                                        fontSize: 16.0,
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
                                                ? (isDark ? const Color(0xFFB4D8C2) : AppColors.primary)
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
            ),
          ),
        );
      },
    );
  }
}
