import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/schedule_event.dart';

/// Günlük detaylı ajanda zaman akışı listesi (Referans ekran görüntüsündeki Daily Agenda)
class DailyTimelineList extends StatelessWidget {
  final List<ScheduleEvent> events;
  final Function(ScheduleEvent) onEditEvent;
  final Function(String) onDeleteEvent;
  final bool enableShadow;

  const DailyTimelineList({
    super.key,
    required this.events,
    required this.onEditEvent,
    required this.onDeleteEvent,
    this.enableShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 44,
                color: Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 12),
              Text(
                'Bu gün için henüz bir plan yok',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildTimelineItem(context, event);
      },
    );
  }

  Widget _buildTimelineItem(BuildContext context, ScheduleEvent event) {
    final textShadows = enableShadow
        ? [
            Shadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 1),
              blurRadius: 3,
            )
          ]
        : null;

    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDeleteEvent(event.id),
      child: InkWell(
        onTap: () => onEditEvent(event),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol Renkli Dikey Gösterge Çizgisi (Referanstaki gibi dikey çubuk)
              Container(
                width: 3.5,
                height: 48,
                margin: const EdgeInsets.only(top: 2, right: 14),
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: event.color.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),

              // İçerik (Başlık, Alt Başlık ve Saat)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      event.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: textShadows,
                        letterSpacing: -0.2,
                      ),
                    ),

                    // Alt Başlık (varsa)
                    if (event.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        event.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.75),
                          shadows: textShadows,
                        ),
                      ),
                    ],

                    const SizedBox(height: 4),

                    // Saat ve Bildirim İkonu
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          event.formattedTimeRange,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.75),
                            shadows: textShadows,
                          ),
                        ),
                        if (event.isNotificationEnabled) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 13,
                            color: event.color.withValues(alpha: 0.9),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
