import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/services/widget_sync_service.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../providers/planner_provider.dart';

/// 🍎 Calenda Widget Özelleştirici ve Canlı Önizleme Ekranı
class WidgetCustomizerScreen extends StatefulWidget {
  const WidgetCustomizerScreen({super.key});

  @override
  State<WidgetCustomizerScreen> createState() => _WidgetCustomizerScreenState();
}

class _WidgetCustomizerScreenState extends State<WidgetCustomizerScreen> {
  int _selectedWidgetType = 0; // 0: Günlük, 1: Haftalık
  int _previewSelectedDay = DateTime.now().weekday; // 1: Pzt ... 7: Paz
  int _selectedBackground = 0; // 0: Açık Arka Plan (Varsayılan), 1: Koyu Arka Plan
  late double _transparency; // 1.0: %100 Tam Saydam, 0.0: Tam Dolgulu
  late String _textColorHex;
  late String _titleText;
  late TextEditingController _titleController;

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _cardBgDark = Color(0xFF14241B);
  static const Color _textPrimary = Color(0xFF1A2B1D);
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  static const List<Map<String, String>> _availableTextColors = [
    {'name': 'Siyah', 'hex': '#0F172A'},
    {'name': 'Beyaz', 'hex': '#FFFFFF'},
    {'name': 'Krem', 'hex': '#FFFBEB'},
    {'name': 'Pembe', 'hex': '#F472B6'},
    {'name': 'Mavi', 'hex': '#93C5FD'},
  ];

  @override
  void initState() {
    super.initState();
    final config = context.read<PlannerProvider>().themeConfig;
    _transparency = (1.0 - config.backgroundOpacity).clamp(0.0, 1.0).toDouble();
    // Varsayılan olarak siyah yazı rengi (#0F172A)
    final savedHex = config.textColorHex.toUpperCase();
    _textColorHex = (savedHex == '#102E19' || savedHex == '#FFFFFF' || savedHex.isEmpty) ? '#0F172A' : savedHex;
    _selectedBackground = 0; // Varsayılan: Açık Zemin
    _titleText = config.titleText.isEmpty ? 'Bugünün Planı' : config.titleText;
    _titleController = TextEditingController(text: _titleText);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$widgetName widget\'ı güncellendi.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
  bool get _isDarkText => _textColorHex == '#0F172A' || _textColorHex == '#000000';

  static List<BoxShadow> _cardShadow(bool isDark, {bool strong = false}) {
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF142814))
            .withValues(alpha: isDark ? (strong ? 0.30 : 0.22) : (strong ? 0.08 : 0.05)),
        blurRadius: strong ? 20 : 14,
        offset: const Offset(0, 5),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? _cardBgDark : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: primaryText,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Widget Görünümü',
              style: AppTypography.sfProRounded(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryText,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton(
                  onPressed: _saveConfig,
                  child: Text(
                    'Kaydet',
                    style: AppTypography.sfProRounded(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFB4D8C2) : _cta,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: AppleAmbientBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ─── 1. SEGMENT SEÇİCİ (GÜNLÜK / HAFTALIK) ───
                  Container(
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                      boxShadow: _cardShadow(isDark),
                    ),
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

                  const SizedBox(height: 18),

                  // ─── 2. ÖNİZLEME BAŞLIĞI VE BASİT ARKA PLAN SEÇİCİ ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Önizleme',
                        style: AppTypography.sfProRounded(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                        ),
                      ),
                      // Açık / Koyu Arka Plan Seçici
                      Row(
                        children: [
                          _buildBgChoiceChip(
                            label: 'Açık Zemin',
                            isSelected: _selectedBackground == 0,
                            cardColor: cardColor,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedBackground = 0),
                          ),
                          const SizedBox(width: 8),
                          _buildBgChoiceChip(
                            label: 'Koyu Zemin',
                            isSelected: _selectedBackground == 1,
                            cardColor: cardColor,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedBackground = 1),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ─── 3. CANLI ÖNİZLEME KARTI ───
                  _buildLivePreviewContainer(provider, isDark, cardColor),

                  const SizedBox(height: 18),

                  // ─── 4. WİDGET EKLE CTA BUTONU ───
                  BouncingWidget(
                    onTap: _pinSelectedWidget,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkPrimary : _cta,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: _cardShadow(isDark, strong: true),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.widgets_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedWidgetType == 0
                                ? 'Günlük Widget Ekle'
                                : 'Haftalık Widget Ekle',
                            style: AppTypography.sfProRounded(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ─── 5. YAZI RENGİ SEÇİM KARTI ───
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                      boxShadow: _cardShadow(isDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yazı Rengi',
                          style: AppTypography.sfProRounded(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _availableTextColors.map((item) {
                            final hex = item['hex']!;
                            final name = item['name']!;
                            final isSelected = _textColorHex.toUpperCase() == hex.toUpperCase();
                            final color = AppColors.hexToColor(hex);
                            final accent = isDark ? AppColors.darkPrimary : _cta;

                            return BouncingWidget(
                              onTap: () => setState(() => _textColorHex = hex),
                              child: Column(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? accent
                                            : (hex == '#FFFFFF' || hex == '#FFFBEB'
                                                ? (isDark ? Colors.white24 : Colors.black12)
                                                : Colors.transparent),
                                        width: isSelected ? 3.0 : 1.0,
                                      ),
                                      boxShadow: [
                                        if (isSelected)
                                          BoxShadow(
                                            color: accent.withValues(alpha: 0.35),
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
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    style: AppTypography.sfPro(
                                      fontSize: 13.5,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? primaryText : mutedText,
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

                  const SizedBox(height: 14),

                  // ─── 6. SAYDAMLIK AYARI KARTI ───
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                      boxShadow: _cardShadow(isDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Saydamlık',
                              style: AppTypography.sfProRounded(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: primaryText,
                              ),
                            ),
                            Text(
                              '%${(_transparency * 100).toInt()}',
                              style: AppTypography.sfPro(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(0xFFB4D8C2) : _cta,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: isDark ? AppColors.darkPrimary : _cta,
                            inactiveTrackColor: isDark ? const Color(0xFF283D30) : const Color(0xFFD4E2D1),
                            thumbColor: isDark ? const Color(0xFFB4D8C2) : _cta,
                            overlayColor: (isDark ? AppColors.darkPrimary : _cta).withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBgChoiceChip({
    required String label,
    required bool isSelected,
    required Color cardColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark ? AppColors.darkPrimary : _cta;
    return BouncingWidget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: isDark && !isSelected ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.15 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.sfPro(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark ? AppColors.darkPrimary : _cta;
    return BouncingWidget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTypography.sfProRounded(
              fontSize: 14.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreviewContainer(
    PlannerProvider provider,
    bool isDark,
    Color cardColor,
  ) {
    final content = _selectedWidgetType == 0
        ? _buildDailyPreviewContent(provider)
        : _buildWeeklyPreviewContent(provider);

    // Koyu Arka Plan Önizlemesi
    if (_selectedBackground == 1) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF121E16),
          boxShadow: _cardShadow(isDark, strong: true),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
            child: content,
          ),
        ),
      );
    }

    // Açık Arka Plan Önizlemesi (Varsayılan)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF4),
        borderRadius: BorderRadius.circular(24),
        boxShadow: _cardShadow(isDark),
      ),
      child: content,
    );
  }

  /// 📅 Günlük Program Önizlemesi
  /// 📅 Günlük Program Önizlemesi (Sadece Planlar)
  Widget _buildDailyPreviewContent(PlannerProvider provider) {
    final todayEvents = provider.currentDayEvents;
    final txtColor = _currentTextColor;

    if (todayEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Bugün için plan bulunmuyor',
            style: AppTypography.sfPro(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: txtColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: todayEvents.take(4).map((event) {
        return _buildEventItemCard(event);
      }).toList(),
    );
  }

  /// 🗓️ Haftalık Program Önizlemesi (Üstte 7 Günün Tamamı + Genişletilmiş Hücreler)
  Widget _buildWeeklyPreviewContent(PlannerProvider provider) {
    final days = DateTimeUtils.getDaysOfWeek(0);
    final activeDate = days[_previewSelectedDay - 1];
    final activeDayEvents = provider.getEventsForDate(activeDate);
    final txtColor = _currentTextColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 1. ÜSTTE HAFTANIN TAMAMINI GÖSTEREN 7 GÜNLÜK MİNİ DERS PROGRAMI MATRİSİ ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(7, (i) {
            final date = days[i];
            final isSelected = _previewSelectedDay == (i + 1);
            final dayEvents = provider.getEventsForDate(date);

            final isDarkBg = _selectedBackground == 1 || !_isDarkText;
            final selectedHeaderColor = isDarkBg ? txtColor : _cta;
            
            // 🌿 Sadece seçili olan güne zarif saydam dolgu verilir, diğer günler tamamen saydamdır
            final selectedFill = isDarkBg
                ? Colors.white.withValues(alpha: 0.18)
                : const Color(0xFF0E260A).withValues(alpha: 0.12);

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _previewSelectedDay = i + 1),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 1.2),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Gün Başlığı (Pzt)
                      Text(
                        DateTimeUtils.getShortDayName(date.weekday),
                        textAlign: TextAlign.center,
                        style: AppTypography.sfPro(
                          fontSize: 12.0,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: isSelected ? selectedHeaderColor : txtColor,
                        ),
                      ),
                      const SizedBox(height: 0.5),
                      // Gün Numarası (17)
                      Text(
                        '${date.day}',
                        textAlign: TextAlign.center,
                        style: AppTypography.sfProRounded(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: isSelected ? selectedHeaderColor : txtColor,
                        ),
                      ),
                      const SizedBox(height: 3.5),

                      // O güne ait alt alta dizilen açık saydam renkli, sağa doğru yatay uzun mini plan hücreleri
                      if (dayEvents.isEmpty)
                        const SizedBox.shrink()
                      else
                        ...dayEvents.take(4).map((e) {
                          final eventColor = AppColors.hexToColor(e.colorHex);
                          final cellBg = isDark
                              ? Color.alphaBlend(
                                  eventColor.withValues(alpha: 0.16),
                                  const Color(0xFF16281E).withValues(alpha: 0.82),
                                )
                              : Color.alphaBlend(
                                  eventColor.withValues(alpha: 0.22),
                                  Colors.white.withValues(alpha: 0.88),
                                );
                          final cellBorderColor = eventColor.withValues(alpha: isDark ? 0.60 : 0.70);

                          return Container(
                            height: 29.0,
                            margin: const EdgeInsets.only(bottom: 3.0),
                            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: cellBg,
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                color: cellBorderColor,
                                width: 0.9,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ⏰ Başlangıç - Bitiş Saati (Örn: 08:30-10:00 veya 08:30)
                                Text(
                                  e.hasNoEndTime
                                      ? '${e.startHour.toString().padLeft(2, '0')}:${e.startMinute.toString().padLeft(2, '0')}'
                                      : '${e.startHour.toString().padLeft(2, '0')}:${e.startMinute.toString().padLeft(2, '0')}-${e.endHour.toString().padLeft(2, '0')}:${e.endMinute.toString().padLeft(2, '0')}',
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                    fontSize: 5.6,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF475569),
                                    letterSpacing: -0.2,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 0.5),
                                // 📝 Başlık (Sıkı ve ortalanmış)
                                Text(
                                  e.title,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 6.8,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    height: 1.02,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        // ── 2. SEÇİLİ GÜNÜN DETAYLI AKIŞ KARTLARI ──
        if (activeDayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Bu güne ait plan bulunmuyor',
                style: AppTypography.sfPro(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: txtColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          )
        else
          Column(
            children: activeDayEvents.take(3).map((event) {
              return _buildEventItemCard(event);
            }).toList(),
          ),
      ],
    );
  }

  /// 📇 Alt Plan Öğesi: Sol Renk Çubuğu + Altta Saat ve Bildirim
  Widget _buildEventItemCard(ScheduleEvent event) {
    final eventColor = AppColors.hexToColor(event.colorHex);
    final titleColor = _isDarkText ? const Color(0xFF0F172A) : _currentTextColor;
    final subtitleColor = _isDarkText ? const Color(0xFF475569) : _currentTextColor.withValues(alpha: 0.85);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.5, horizontal: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. SOL DİKEY RENK ÇUBUĞU (Kartın tüm boyunu ve alttaki zamanı kapsar) ──
            Container(
              width: 3.5,
              decoration: BoxDecoration(
                color: eventColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: eventColor.withValues(alpha: 0.35),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── 2. BAŞLIK, ALT METİN VE ALTTTAKİ ZAMAN / BİLDİRİM ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Başlık
                  Text(
                    event.title,
                    style: AppTypography.sfProRounded(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),

                  // Alt Başlık (varsa)
                  if (event.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 1.5),
                    Text(
                      event.subtitle,
                      style: AppTypography.sfPro(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],

                  const SizedBox(height: 3.5),

                  // Alttaki Zaman Satırı (Daha küçük ve daha saydam)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11.5,
                        color: subtitleColor.withValues(alpha: 0.60),
                      ),
                      const SizedBox(width: 3.5),
                      Text(
                        event.formattedTimeRange,
                        style: AppTypography.sfPro(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor.withValues(alpha: 0.60),
                        ),
                      ),
                      if (event.isNotificationEnabled) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.notifications_active_outlined,
                          size: 11.5,
                          color: subtitleColor.withValues(alpha: 0.60),
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
    );
  }
}
