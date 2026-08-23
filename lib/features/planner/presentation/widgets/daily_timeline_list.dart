import 'dart:ui';
import 'package:aesthetic_planner/core/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/bouncing_widget.dart';
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
        final dayName = DateTimeUtils.getFullDayName(provider.selectedDate.weekday);
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
                    isToday ? 'Bugün, $dayName' : dayName,
                    style: AppTypography.sfProRounded(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (events.isNotEmpty)
                    Text(
                      '${events.length} Plan',
                      style: AppTypography.sfPro(
                        fontSize: 14.5,
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF22362B)
                        : Colors.white.withValues(alpha: 0.70),
                    shape: BoxShape.circle,
                    border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 26,
                    color: isDark ? const Color(0xFFB4D8C2) : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Bugün için plan bulunmuyor',
              textAlign: TextAlign.center,
              style: AppTypography.sfProRounded(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Yeni bir plan eklemek için yukarıdaki "Ekle" butonuna dokunun.',
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

  /// ⏰ Etkinlikleri Tam Saatlere (08:00, 10:00 vb.) göre gruplayarak gösterir
  Widget _buildGroupedTimelineList(
    BuildContext context,
    PlannerProvider provider,
    List<ScheduleEvent> events,
    bool isDark,
    String key,
  ) {
    // 1. Etkinlikleri Başlangıç Saatlerine (startHour) göre grupla
    final Map<int, List<ScheduleEvent>> groupedByHour = {};
    for (final event in events) {
      groupedByHour.putIfAbsent(event.startHour, () => []).add(event);
    }

    // 2. Saatleri kronolojik sırala
    final sortedHours = groupedByHour.keys.toList()..sort();

    return ListView.builder(
      key: ValueKey('list_$key'),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 28),
      physics: const BouncingScrollPhysics(),
      itemCount: sortedHours.length,
      itemBuilder: (context, index) {
        final hour = sortedHours[index];
        final hourEvents = groupedByHour[hour]!;
        final hourStr = '${hour.toString().padLeft(2, '0')}:00';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── A. SAAT BAŞLIĞI VE SOLUK AYIRICI ÇİZGİ (REFERANS TASARIM) ──
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

              // ── B. O SAATE AİT ÇİZGİNİN ALTINDAN HİZALANAN YUVARLAK KAPSÜL KARTLAR ──
              ...hourEvents.map((event) {
                final eventColor = AppColors.hexToColor(event.colorHex);

                return Padding(
                  padding: const EdgeInsets.only(left: 56, bottom: 6),
                  child: Dismissible(
                    key: Key(event.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 22,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteConfirmation(context, event, isDark);
                    },
                    onDismissed: (_) {
                      provider.deleteEvent(event.id);
                      AestheticSnackBar.showDelete(context, '${event.title} silindi');
                    },
                    child: _TimezyEventCard(
                      event: event,
                      eventColor: eventColor,
                      isDark: isDark,
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

  Future<bool?> _showDeleteConfirmation(BuildContext context, ScheduleEvent event, bool isDark) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Planı Sil'),
        content: Text('${event.title} planını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

/// 🍎 Apple iOS SF Pro: Seçilen Renkte Zarif Kenarlıklı, Saydam Beyaz + 12px Blur Kart
class _TimezyEventCard extends StatelessWidget {
  final ScheduleEvent event;
  final Color eventColor;
  final bool isDark;

  const _TimezyEventCard({
    required this.event,
    required this.eventColor,
    required this.isDark,
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

    return BouncingWidget(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditEventScreen(event: event),
          ),
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: glassBgColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: borderColor,
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
            // 📝 1. ANA BAŞLIK: SF Pro Rounded Bold (16.5px)
            Text(
              event.title,
              style: AppTypography.sfProRounded(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),

            // 📄 2. ALT DETAY: SF Pro Medium (13.5px)
            if (event.subtitle.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                event.subtitle,
                style: AppTypography.sfPro(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
            ],

            const SizedBox(height: 8),

            // ⏰ 3. SAAT ARALIĞI VE BİLDİRİM İKONU
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: subtitleColor,
                ),
                const SizedBox(width: 5),
                Text(
                  event.formattedTimeRange,
                  style: AppTypography.sfPro(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
                if (event.isNotificationEnabled) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 13.5,
                    color: subtitleColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
