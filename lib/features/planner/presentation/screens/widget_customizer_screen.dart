import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/planner_provider.dart';
import '../widgets/daily_timeline_list.dart';
import '../widgets/weekly_grid_bar.dart';

/// Widget Şeffaflık, Görünüm ve Canlı Önizleme Ayarları Ekranı
class WidgetCustomizerScreen extends StatefulWidget {
  const WidgetCustomizerScreen({super.key});

  @override
  State<WidgetCustomizerScreen> createState() => _WidgetCustomizerScreenState();
}

class _WidgetCustomizerScreenState extends State<WidgetCustomizerScreen> {
  // Canlı önizleme için duvar kağıdı simülasyon gradyanları
  final List<List<Color>> _mockWallpaperGradients = [
    [const Color(0xFF1E3A5F), const Color(0xFF0F172A)], // Derin Mavi / Starry Night
    [const Color(0xFF4A154B), const Color(0xFF111827)], // Mor Gece
    [const Color(0xFF2C3E50), const Color(0xFF3498DB)], // Okyanus
    [const Color(0xFF1F2937), const Color(0xFF111827)], // Minimalist Koyu
    [const Color(0xFFD97706), const Color(0xFF7C2D12)], // Sunset Amber
  ];

  int _selectedMockBgIndex = 0;

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final theme = planner.themeConfig;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Widget Görünümü & Şeffaflık',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Canlı Duvar Kağıdı Üzerinde Widget Önizleme Alanı (Phone Mockup)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: AspectRatio(
                aspectRatio: 9 / 14,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 3,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _mockWallpaperGradients[_selectedMockBgIndex],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Üst Saat ve Tarih (Kilit Ekranı Hissi)
                      Positioned(
                        top: 24,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Text(
                              'Tue, Aug 18',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '09:38',
                              style: GoogleFonts.inter(
                                fontSize: 52,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                letterSpacing: -1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Şeffaf Widget Katmanı
                      Positioned(
                        top: 130,
                        left: 12,
                        right: 12,
                        bottom: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: theme.backgroundOpacity),
                            borderRadius: BorderRadius.circular(16),
                            border: theme.backgroundOpacity > 0.05
                                ? Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  )
                                : null,
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 7 Günlük Mini Grid
                                if (theme.showWeeklyGrid)
                                  WeeklyGridBar(
                                    selectedDay: planner.selectedDay,
                                    onDaySelected: planner.selectDay,
                                    getEventsForDay: planner.getEventsForDay,
                                    isTransparentMode: theme.backgroundOpacity == 0.0,
                                  ),

                                const SizedBox(height: 8),

                                // Günlük Zaman Çizelgesi
                                if (theme.showDailyTimeline)
                                  DailyTimelineList(
                                    events: planner.currentDayEvents,
                                    onEditEvent: (_) {},
                                    onDeleteEvent: (_) {},
                                    enableShadow: theme.enableTextShadow,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Önizleme Arka Planı Değiştirme Çipleri
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Önizleme Duvar Kağıdı Rengi',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mockWallpaperGradients.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, idx) {
                        final isSelected = idx == _selectedMockBgIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMockBgIndex = idx),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _mockWallpaperGradients[idx],
                              ),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Kontrol Paneli (Opaklık Kaydırıcısı & Ayarlar)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arka Plan Opaklığı (0.0 -> Tam Şeffaf)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Widget Arka Plan Şeffaflığı',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        theme.backgroundOpacity == 0.0
                            ? '%100 Şeffaf'
                            : '%${(theme.backgroundOpacity * 100).toInt()}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: theme.backgroundOpacity,
                    min: 0.0,
                    max: 0.8,
                    divisions: 8,
                    activeColor: AppColors.accentLight,
                    inactiveColor: AppColors.darkCard,
                    onChanged: (val) {
                      planner.updateThemeConfig(
                        theme.copyWith(backgroundOpacity: val),
                      );
                    },
                  ),

                  const Divider(height: 24, color: AppColors.darkBorder),

                  // Metin Gölgesi (Okunabilirlik Koruması)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Metin Gölgesi (Okunabilirlik)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Açık ve karışık duvar kağıtlarında yazıların net görünmesini sağlar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    value: theme.enableTextShadow,
                    activeTrackColor: AppColors.accentLight,
                    onChanged: (val) {
                      planner.updateThemeConfig(
                        theme.copyWith(enableTextShadow: val),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Widget Ekleme Rehberi Butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.accentLight,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ana ekranınıza veya kilit ekranınıza widget eklemek için ana ekranda boş bir yere basılı tutun ve "Aesthetic Planner" widget\'ını seçin.',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
