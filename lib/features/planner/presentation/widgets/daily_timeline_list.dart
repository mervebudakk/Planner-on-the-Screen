import 'package:aesthetic_planner/core/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/animated_strikethrough_text.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/widgets/swipe_to_delete_tile.dart';
import '../../providers/planner_provider.dart';
import '../screens/edit_event_screen.dart';

/// 🍎 Apple iOS SF Pro Standartlarında Zarif Kenarlıklı ve Saydam Cam Kapsüllü Günlük Akış
class DailyTimelineList extends StatelessWidget {
  const DailyTimelineList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        final events = provider.currentDayEvents;
        final selectedDateKey = provider.selectedDate.toIso8601String();
        final dayName = DateTimeUtils.getFullDayName(
          provider.selectedDate.weekday,
          locale: context.l10n.locale.languageCode,
        );
        final isToday = provider.isSelectedDateToday;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 🌟 KART ÜST BAŞLIĞI: GÜN ADI (CUMARTESİ / WEDNESDAY) & PLAN SAYISI ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isToday ? context.l10n.todayWithDay(dayName) : dayName,
                    style: AppTypography.sfProRounded(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (events.isNotEmpty)
                    Text(
                      context.l10n.planCount(events.length),
                      style: AppTypography.sfPro(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMuted : const Color(0xFF7A9981),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: events.isEmpty
                    ? _buildEmptyState(context, isDark, selectedDateKey)
                    : _buildGroupedTimelineList(context, provider, events, isDark, selectedDateKey),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, String key) {
    return Center(
      key: ValueKey('empty_$key'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.noPlansThisDay,
              textAlign: TextAlign.center,
              style: AppTypography.sfProRounded(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.emptyTimelineHint,
              textAlign: TextAlign.center,
              style: AppTypography.sfPro(
                fontSize: 13,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ⏰ Etkinlikleri Tam Saatlere (08:00, 10:00 vb.) göre gruplayarak, saatsiz olanları en altta gösterir
  Widget _buildGroupedTimelineList(
    BuildContext context,
    PlannerProvider provider,
    List<ScheduleEvent> events,
    bool isDark,
    String key,
  ) {
    final groupedByHour = provider.currentDayGroupedByHour;
    final sortedHours = provider.currentDaySortedHours;
    final untimedEvents = provider.currentDayUntimedEvents;
    final totalSections = sortedHours.length + (untimedEvents.isNotEmpty ? 1 : 0);

    return ListView.builder(
      key: ValueKey('list_$key'),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: totalSections,
      itemBuilder: (context, index) {
        if (index < sortedHours.length) {
          final hour = sortedHours[index];
          final hourEvents = groupedByHour[hour]!;
          final hourStr = '${hour.toString().padLeft(2, '0')}:00';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── A. SAAT BAŞLIĞI VE SOLUK AYIRICI ÇİZGİ ──
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        hourStr,
                        style: AppTypography.sfProRounded(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          height: 1.2,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBorder
                                : const Color(0xFFDFE9DC),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),

                // ── B. O SAATE AİT KAPSÜL KARTLAR ──
                ...hourEvents.map((event) {
                  final eventColor = AppColors.hexToColor(event.colorHex);

                  return Padding(
                    padding: const EdgeInsets.only(left: 56, bottom: 6),
                    child: SwipeToDeleteTile(
                      key: ValueKey(event.id),
                      borderRadius: 30,
                      onEdit: () {
                        EditEventSheet.show(context, event: event);
                      },
                      onDelete: () {
                        provider.deleteEvent(event.id);
                        AestheticSnackBar.showDelete(context, context.l10n.planDeleted(event.title));
                      },
                      child: _TimezyEventCard(
                        event: event,
                        eventColor: eventColor,
                        isDark: isDark,
                        onToggle: () {
                          provider.toggleEventCompletion(event.id);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }

        // ── C. SAATSİZ PLANLAR (EN ALTTA LİSTELENİR) ──
        final untimedLabel = context.l10n.isTurkish ? 'Saatsiz' : 'Anytime';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      untimedLabel,
                      style: AppTypography.sfProRounded(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        height: 1.2,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFDFE9DC),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              ...untimedEvents.map((event) {
                final eventColor = AppColors.hexToColor(event.colorHex);

                return Padding(
                  padding: const EdgeInsets.only(left: 56, bottom: 6),
                  child: SwipeToDeleteTile(
                    key: ValueKey(event.id),
                    borderRadius: 30,
                    onEdit: () {
                      EditEventSheet.show(context, event: event);
                    },
                    onDelete: () {
                      provider.deleteEvent(event.id);
                      AestheticSnackBar.showDelete(context, context.l10n.planDeleted(event.title));
                    },
                    child: _TimezyEventCard(
                      event: event,
                      eventColor: eventColor,
                      isDark: isDark,
                      onToggle: () {
                        provider.toggleEventCompletion(event.id);
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// 🍎 Apple iOS SF Pro: Seçilen Renkte Zarif Kenarlıklı, Saydam Beyaz + 12px Blur Kart
class _TimezyEventCard extends StatelessWidget {
  final ScheduleEvent event;
  final Color eventColor;
  final bool isDark;
  final VoidCallback onToggle;

  const _TimezyEventCard({
    required this.event,
    required this.eventColor,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // 💧 Saydam Beyaz (%72) + Yumuşak Pastel Sızıntısı (%14) / Koyu Zümrüt Cam (%94)
    final glassBgColor = isDark
        ? Color.alphaBlend(
            eventColor.withValues(alpha: 0.16),
            const Color(0xFF1E2D24).withValues(alpha: 0.94),
          )
        : Color.alphaBlend(
            eventColor.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.72),
          );

    // 🎨 SEÇİLEN RENKTE ZARİF KENARLIK
    final borderColor = isDark
        ? eventColor.withValues(alpha: 0.65)
        : eventColor.withValues(alpha: 0.55);

    // 🌲 Tipografi Renkleri
    final titleColor = isDark ? Colors.white : AppColors.lightTextPrimary; // #102E19 (Koyu & Net)
    final subtitleColor = isDark
        ? const Color(0xFFB4D8C2)
        : const Color(0xFF5A7B62); // Açık füme / adaçayı

    final isCompleted = event.isCompleted;

    return BouncingWidget(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isCompleted ? 0.60 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: glassBgColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isCompleted
                  ? (isDark ? Colors.white12 : const Color(0xFFD4DFD3))
                  : borderColor,
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : eventColor).withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 📝 1. ANA BAŞLIK: SF Pro Rounded Bold (16px) + Soldan Sağa Çizilme Efekti
              AnimatedStrikethroughText(
                text: event.title,
                isCompleted: isCompleted,
                maxLines: null,
                overflow: TextOverflow.visible,
                style: AppTypography.sfProRounded(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: isCompleted
                      ? (isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A))
                      : titleColor,
                ),
                strikeColor: isDark ? const Color(0xFF81A088) : const Color(0xFF4A6B53),
                strokeWidth: 2.2,
              ),

              // 📄 2. ALT DETAY: SF Pro Medium (13px)
              if (event.subtitle.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  event.subtitle,
                  style: AppTypography.sfPro(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: isCompleted
                        ? (isDark ? AppColors.darkTextMuted.withValues(alpha: 0.6) : const Color(0xFFA1ACA0))
                        : subtitleColor,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // ⏰ 3. SAAT ARALIĞI VEYA SAATSİZ BİLGİSİ
              Row(
                children: [
                  Icon(
                    event.hasSpecificTime
                        ? Icons.access_time_rounded
                        : Icons.schedule_rounded,
                    size: 14,
                    color: isCompleted
                        ? (isDark ? AppColors.darkTextMuted.withValues(alpha: 0.6) : const Color(0xFFA1ACA0))
                        : subtitleColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    event.hasSpecificTime
                        ? event.formattedTimeRange
                        : (context.l10n.isTurkish ? 'Saatsiz' : 'Anytime'),
                    style: AppTypography.sfPro(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? (isDark ? AppColors.darkTextMuted.withValues(alpha: 0.6) : const Color(0xFFA1ACA0))
                          : subtitleColor,
                    ),
                  ),
                  if (event.hasSpecificTime && event.isNotificationEnabled) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.notifications_active_outlined,
                      size: 14.0,
                      color: isCompleted
                          ? (isDark ? AppColors.darkTextMuted.withValues(alpha: 0.6) : const Color(0xFFA1ACA0))
                          : subtitleColor,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
