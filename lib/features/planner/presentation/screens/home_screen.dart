import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../providers/planner_provider.dart';
import '../widgets/daily_timeline_list.dart';
import '../widgets/weekly_grid_bar.dart';
import 'edit_event_screen.dart';
import 'settings_screen.dart';
import 'widget_customizer_screen.dart';

/// Ana Planlayıcı Ekranı (Haftalık Grid + Günlük Zaman Akışı)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAddEvent(BuildContext context, PlannerProvider planner) async {
    final newEvent = await Navigator.push<ScheduleEvent>(
      context,
      MaterialPageRoute(
        builder: (_) => EditEventScreen(defaultDay: planner.selectedDay),
      ),
    );

    if (newEvent != null) {
      planner.addEvent(newEvent);
    }
  }

  void _openEditEvent(BuildContext context, PlannerProvider planner, ScheduleEvent event) async {
    final updatedEvent = await Navigator.push<ScheduleEvent>(
      context,
      MaterialPageRoute(
        builder: (_) => EditEventScreen(
          initialEvent: event,
          defaultDay: planner.selectedDay,
        ),
      ),
    );

    if (updatedEvent != null) {
      planner.updateEvent(updatedEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final todayFormatted = DateFormat('EEEE, d MMMM', 'tr_TR').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aesthetic Planner',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              todayFormatted,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Widget Görünüm Özelleştirici Butonu
          IconButton(
            icon: const Icon(Icons.widgets_outlined, color: Colors.white),
            tooltip: 'Widget Görünümü & Şeffaflık',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WidgetCustomizerScreen()),
              );
            },
          ),
          // Ayarlar Butonu
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: planner.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentLight))
          : RefreshIndicator(
              onRefresh: () async {
                // Yenileme işlemi
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // 1. HAFTALIK MİNİ ÇİZELGE BAR (7 GÜN)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: WeeklyGridBar(
                        selectedDay: planner.selectedDay,
                        onDaySelected: planner.selectDay,
                        getEventsForDay: planner.getEventsForDay,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. GÜNLÜK DETAYLI ZAMAN AKIŞI BAŞLIĞI
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateTimeUtils.getFullDayName(planner.selectedDay),
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${planner.currentDayEvents.length} plan kayıtlı',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          // Hızlı Ekle Butonu
                          TextButton.icon(
                            onPressed: () => _openAddEvent(context, planner),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              'Plan Ekle',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.accentLight,
                              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 3. GÜNLÜK ZAMAN AKIŞI LİSTESİ (TIMELINE)
                    DailyTimelineList(
                      events: planner.currentDayEvents,
                      onEditEvent: (event) => _openEditEvent(context, planner, event),
                      onDeleteEvent: (id) => planner.deleteEvent(id),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEvent(context, planner),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Ders / Plan Ekle',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
