import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/services/widget_sync_service.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../providers/planner_provider.dart';

/// Timezy & Aqua Estetiğinde Widget Özelleştirici ve Canlı Önizleme Ekranı
class WidgetCustomizerScreen extends StatefulWidget {
  const WidgetCustomizerScreen({super.key});

  @override
  State<WidgetCustomizerScreen> createState() => _WidgetCustomizerScreenState();
}

class _WidgetCustomizerScreenState extends State<WidgetCustomizerScreen> {
  int _selectedWidgetType = 0; // 0: Günlük, 1: Haftalık
  int _previewSelectedDay = DateTime.now().weekday; // 1: Pzt ... 7: Paz
  late double _transparency; // 1.0: %100 Tam Saydam, 0.0: Tam Dolgulu
  late String _textColorHex;
  late String _titleText;
  late TextEditingController _titleController;
  final ImagePicker _imagePicker = ImagePicker();

  static const List<Map<String, String>> _availableTextColors = [
    {'name': 'Beyaz', 'hex': '#FFFFFF'},
    {'name': 'Derin Yeşil', 'hex': '#102E19'},
    {'name': 'Krem', 'hex': '#FFFBEB'},
    {'name': 'Pembe', 'hex': '#F472B6'},
    {'name': 'Mavi', 'hex': '#93C5FD'},
  ];

  @override
  void initState() {
    super.initState();
    final config = context.read<PlannerProvider>().themeConfig;
    _transparency = (1.0 - config.backgroundOpacity).clamp(0.0, 1.0).toDouble();
    _textColorHex = config.textColorHex.toUpperCase();
    _titleText = config.titleText.isEmpty ? 'Bugünün Planı' : config.titleText;
    _titleController = TextEditingController(text: _titleText);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickWallpaper() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final provider = context.read<PlannerProvider>();
        await provider.setCustomWallpaperPath(image.path);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Fotoğraf seçilemedi.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _saveConfig() {
    final provider = context.read<PlannerProvider>();
    final title = _limitText(_titleController.text, 40);
    final fillOpacity = (1.0 - _transparency).clamp(0.0, 1.0).toDouble();
    final newConfig = provider.themeConfig.copyWith(
      backgroundOpacity: fillOpacity,
      textColorHex: _textColorHex,
      titleText: title.isEmpty ? 'Bugünün Planı' : title,
    );
    provider.updateThemeConfig(newConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Widget ayarları güncellendi.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pinSelectedWidget() async {
    _saveConfig();
    final isWeekly = _selectedWidgetType == 1;
    final success = await WidgetSyncService.requestPinWidget(isWeekly: isWeekly);

    if (mounted) {
      final widgetName = isWeekly ? 'Haftalık Program' : 'Günlük Program';
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$widgetName widget\'ı ana ekrana ekleniyor...'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$widgetName widget\'ı güncellendi.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  String _limitText(String value, int maxLength) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  Color get _currentTextColor => AppColors.hexToColor(_textColorHex);
  bool get _isDarkText => _textColorHex == '#0F172A';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        final hasCustomWallpaper = provider.customWallpaperPath != null &&
            File(provider.customWallpaperPath!).existsSync();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Widget Görünümü',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _saveConfig,
                child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: AppleAmbientBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ─── 1. SEGMENT SEÇİCİ ───
                  GlassContainer(
                    blur: 16,
                    opacity: isDark ? 0.40 : 0.70,
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentButton(
                            title: 'Günlük Program',
                            isSelected: _selectedWidgetType == 0,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedWidgetType = 0),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildSegmentButton(
                            title: 'Haftalık Program',
                            isSelected: _selectedWidgetType == 1,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedWidgetType = 1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ─── 2. DUVAR KÂĞIDI EKLE / DEĞİŞTİR ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Önizleme',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          BouncingWidget(
                            onTap: _pickWallpaper,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    hasCustomWallpaper
                                        ? Icons.photo_library_outlined
                                        : Icons.add_photo_alternate_outlined,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    hasCustomWallpaper
                                        ? 'Duvar Kâğıdını Değiştir'
                                        : 'Duvar Kâğıdı Ekle',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (hasCustomWallpaper) ...[
                            const SizedBox(width: 8),
                            BouncingWidget(
                              onTap: () => provider.setCustomWallpaperPath(null),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  'Kaldır',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ─── 3. CANLI ÖNİZLEME ───
                  _buildLivePreviewCard(provider, isDark, hasCustomWallpaper),

                  const SizedBox(height: 16),

                  // ─── 4. WİDGET EKLE BUTONU ───
                  BouncingWidget(
                    onTap: _pinSelectedWidget,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _selectedWidgetType == 0
                              ? 'Günlük Widget Ekle'
                              : 'Haftalık Widget Ekle',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── 5. YAZI RENGİ SEÇİMİ ───
                  GlassContainer(
                    blur: 16,
                    opacity: isDark ? 0.40 : 0.70,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yazı Rengi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _availableTextColors.map((item) {
                            final hex = item['hex']!;
                            final name = item['name']!;
                            final isSelected = _textColorHex.toUpperCase() == hex.toUpperCase();
                            final color = AppColors.hexToColor(hex);

                            return BouncingWidget(
                              onTap: () => setState(() => _textColorHex = hex),
                              child: Column(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (hex == '#FFFFFF'
                                                ? (isDark ? Colors.white24 : Colors.black12)
                                                : Colors.transparent),
                                        width: isSelected ? 2.5 : 1.0,
                                      ),
                                      boxShadow: [
                                        if (isSelected)
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                      ],
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check_rounded,
                                            size: 22,
                                            color: hex == '#FFFFFF' || hex == '#FFFBEB'
                                                ? Colors.black
                                                : Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── 6. SAYDAMLIK AYARI ───
                  GlassContainer(
                    blur: 16,
                    opacity: isDark ? 0.40 : 0.70,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Saydamlık',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              _transparency == 1.0
                                  ? 'Tam Saydam (%100)'
                                  : (_transparency == 0.0
                                      ? 'Tam Dolgulu (%0)'
                                      : '%${(_transparency * 100).toInt()}'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primary.withValues(alpha: 0.2),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _transparency,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            onChanged: (val) {
                              setState(() => _transparency = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return BouncingWidget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard(
    PlannerProvider provider,
    bool isDark,
    bool hasCustomWallpaper,
  ) {
    final content = Container(
      constraints: BoxConstraints(
        minHeight: _selectedWidgetType == 1 ? 340 : 170,
      ),
      child: _selectedWidgetType == 0
          ? _buildDailyPreviewContent(provider)
          : _buildWeeklyHybridPreviewContent(provider),
    );

    if (hasCustomWallpaper) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          image: DecorationImage(
            image: FileImage(File(provider.customWallpaperPath!)),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(14),
            color: Colors.transparent,
            child: content,
          ),
        ),
      );
    }

    return GlassContainer(
      blur: 20,
      opacity: isDark ? 0.35 : 0.65,
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(14),
      child: content,
    );
  }

  /// Günlük Program Önizlemesi
  Widget _buildDailyPreviewContent(PlannerProvider provider) {
    final todayEvents = provider.currentDayEvents;
    final txtColor = _currentTextColor;
    final shadowColor = _isDarkText ? Colors.white70 : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (todayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Plan bulunmuyor',
                style: TextStyle(
                  color: txtColor.withValues(alpha: 0.7),
                  fontSize: 12,
                  shadows: [Shadow(color: shadowColor, blurRadius: 3)],
                ),
              ),
            ),
          )
        else
          Column(
            children: todayEvents.take(4).map((event) {
              return _buildItemRow(event);
            }).toList(),
          ),
      ],
    );
  }

  /// Haftalık Program Önizlemesi
  Widget _buildWeeklyHybridPreviewContent(PlannerProvider provider) {
    final days = DateTimeUtils.getDaysOfWeek(0);
    final activeDate = days[_previewSelectedDay - 1];
    final activeDayEvents = provider.getEventsForDate(activeDate);
    final txtColor = _currentTextColor;
    final shadowColor = _isDarkText ? Colors.white70 : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Üst 7 Günlük Matris
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(7, (i) {
            final date = days[i];
            final isSelected = _previewSelectedDay == (i + 1);
            final dayEvents = provider.getEventsForDate(date);

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _previewSelectedDay = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── A. SABİT HİZALI GÜN & TARİH BAŞLIĞI ──
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (_isDarkText ? Colors.black.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.35))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: _isDarkText ? const Color(0xFF0F172A) : Colors.white,
                                  width: 1.2,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateTimeUtils.getShortDayName(date.weekday),
                              style: TextStyle(
                                fontSize: 9.0,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: txtColor,
                                shadows: [Shadow(color: shadowColor, blurRadius: 3)],
                              ),
                            ),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                color: txtColor,
                                shadows: [Shadow(color: shadowColor, blurRadius: 3)],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ── B. AŞAĞI DOĞRU UZAYAN MİNİ DERS KARTLARI ──
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: dayEvents.take(4).map((e) {
                          final color = AppColors.hexToColor(e.colorHex);
                          final timeStr = '${e.startHour.toString().padLeft(2, '0')}:${e.startMinute.toString().padLeft(2, '0')}';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 2.0),
                            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(3.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 1.5,
                                  offset: const Offset(0, 0.5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeStr,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                    fontSize: 5.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF475569),
                                    letterSpacing: -0.2,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  e.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 6.8,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                    height: 1.05,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),
        Divider(
          height: 1,
          color: _isDarkText ? Colors.black12 : Colors.white.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 8),

        // 2. Seçili Günün Akışı
        Text(
          '${DateTimeUtils.getFullDayName(_previewSelectedDay)}, ${activeDate.day} ${DateTimeUtils.formatMonthYear(activeDate).split(' ').first}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: txtColor,
            shadows: [Shadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 1))],
          ),
        ),
        const SizedBox(height: 6),

        if (activeDayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Plan bulunmuyor',
                style: TextStyle(
                  color: txtColor.withValues(alpha: 0.7),
                  fontSize: 12,
                  shadows: [Shadow(color: shadowColor, blurRadius: 3)],
                ),
              ),
            ),
          )
        else
          Column(
            children: activeDayEvents.take(4).map((event) {
              return _buildItemRow(event);
            }).toList(),
          ),
      ],
    );
  }

  /// Tekil Ders Satırı
  Widget _buildItemRow(ScheduleEvent event) {
    final eventColor = AppColors.hexToColor(event.colorHex);
    final txtColor = _currentTextColor;
    final shadowColor = _isDarkText ? Colors.white70 : Colors.black87;

    final fillAlpha = (1.0 - _transparency);

    final cellBgColor = _transparency == 1.0
        ? Colors.transparent
        : eventColor.withValues(alpha: fillAlpha * 0.85);

    final borderColor = _transparency == 1.0
        ? Colors.transparent
        : (_isDarkText ? Colors.black12 : Colors.white.withValues(alpha: fillAlpha * 0.35));

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cellBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 24,
            decoration: BoxDecoration(
              color: eventColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: eventColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: fillAlpha > 0.6 ? const Color(0xFF0F172A) : txtColor,
                    shadows: fillAlpha > 0.6
                        ? null
                        : [Shadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                ),
                if (event.subtitle.isNotEmpty)
                  Text(
                    event.subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: fillAlpha > 0.6 ? const Color(0xFF334155) : txtColor.withValues(alpha: 0.75),
                      shadows: fillAlpha > 0.6
                          ? null
                          : [Shadow(color: shadowColor, blurRadius: 3, offset: const Offset(0, 1))],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            event.formattedTimeRange,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fillAlpha > 0.6 ? const Color(0xFF1E293B) : txtColor.withValues(alpha: 0.75),
              shadows: fillAlpha > 0.6
                  ? null
                  : [Shadow(color: shadowColor, blurRadius: 3, offset: const Offset(0, 1))],
            ),
          ),
        ],
      ),
    );
  }
}
