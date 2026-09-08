import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/services/widget_sync_service.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
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

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _cardBgDark = Color(0xFF14241B);
  static const Color _textPrimary = AppColors.lightTextPrimary;
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
    final savedBg = config.backgroundColorHex.toUpperCase();
    _selectedBackground = (savedBg == '#121E16' || savedBg == '#14241B') ? 1 : 0;
    _textColorHex = (savedHex == '#102E19' || savedHex.isEmpty) 
        ? (_selectedBackground == 1 ? '#FFFBEB' : '#0F172A') 
        : savedHex;
  }

  void _saveConfig({bool showSnackBar = true}) {
    final provider = context.read<PlannerProvider>();
    final isApple = defaultTargetPlatform == TargetPlatform.iOS;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fillOpacity = isApple ? 0.0 : (1.0 - _transparency).clamp(0.0, 1.0).toDouble();
    final bgHex = isApple
        ? (isDark ? '#121E16' : '#F7FAF4')
        : (_selectedBackground == 1 ? '#121E16' : '#F7FAF4');
    final txtHex = isApple
        ? (isDark ? '#FFFFFF' : '#0F172A')
        : _textColorHex;

    final newConfig = provider.themeConfig.copyWith(
      backgroundOpacity: fillOpacity,
      backgroundColorHex: bgHex,
      textColorHex: txtHex,
      titleText: 'Bugünün Planı',
    );
    provider.updateThemeConfig(newConfig);

    if (showSnackBar) {
      AestheticSnackBar.showSuccess(context, 'Widget ayarları güncellendi.');
    }
  }

  Future<void> _pinSelectedWidget() async {
    _saveConfig(showSnackBar: false);
    final isWeekly = _selectedWidgetType == 1;
    final widgetName = isWeekly ? 'Haftalık Program' : 'Günlük Program';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (mounted) {
        AestheticSnackBar.showSuccess(context, '$widgetName ayarları kaydedildi.');
        _showIosWidgetInstructions(context);
      }
      return;
    }

    final success = await WidgetSyncService.requestPinWidget(isWeekly: isWeekly);

    if (mounted) {
      if (success) {
        AestheticSnackBar.showSuccess(context, '$widgetName widget\'ı ana ekrana ekleniyor...');
      } else {
        AestheticSnackBar.showInfo(context, '$widgetName ayarları kaydedildi.');
      }
    }
  }

  void _showIosWidgetInstructions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24, 18, 24, MediaQuery.of(ctx).padding.bottom + 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14241B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF23442E) : const Color(0xFFE6EFE4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.widgets_rounded,
                size: 24,
                color: isDark ? const Color(0xFF8CE4A4) : const Color(0xFF1E4025),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'iPhone Ana Ekranına Widget Ekleme',
              textAlign: TextAlign.center,
              style: AppTypography.sfProRounded(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF14241B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Apple güvenlik kuralları gereği widget\'lar doğrudan iPhone ana ekranından eklenir:',
              textAlign: TextAlign.center,
              style: AppTypography.sfPro(
                fontSize: 13,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF5A7060),
              ),
            ),
            const SizedBox(height: 20),
            _buildInstructionRow(
              stepNumber: '1',
              title: 'Ana Ekrana Basılı Tutun',
              desc: 'Boş bir alana uygulamalar titreyene kadar basılı tutun.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildInstructionRow(
              stepNumber: '2',
              title: 'Sol Üstteki (+) İkonuna Dokunun',
              desc: 'Apple widget galerisini açın.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildInstructionRow(
              stepNumber: '3',
              title: 'Calenda\'yı Seçip Ekleyin',
              desc: 'Calenda widget\'ını seçip "Widget Ekle" butonuna basın.',
              isDark: isDark,
            ),
            const SizedBox(height: 22),
            BouncingWidget(
              onTap: () => Navigator.pop(ctx),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF264832) : const Color(0xFF1B3822),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Tamamdır, Anladım',
                    style: AppTypography.sfProRounded(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionRow({
    required String stepNumber,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A4A33) : const Color(0xFFE2EEE1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: AppTypography.sfProRounded(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFF90E8A8) : const Color(0xFF1F4326),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.sfPro(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTypography.sfPro(
                  fontSize: 12.5,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7F70),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Color get _currentTextColor {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return isDark ? Colors.white : const Color(0xFF0F172A);
    }
    return AppColors.hexToColor(_textColorHex);
  }

  bool get _isDarkText {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return !isDark;
    }
    return _textColorHex == '#0F172A' || _textColorHex == '#000000';
  }

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
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                        ),
                      ),
                      // Açık / Koyu Arka Plan Seçici (Yalnızca Android için, Apple'da sistem temasına bağlı)
                      if (defaultTargetPlatform != TargetPlatform.iOS)
                        Row(
                          children: [
                            _buildBgChoiceChip(
                              label: 'Açık Zemin',
                              isSelected: _selectedBackground == 0,
                              cardColor: cardColor,
                              isDark: isDark,
                              onTap: () => setState(() {
                                _selectedBackground = 0;
                                if (_textColorHex == '#FFFFFF' || _textColorHex == '#FFFBEB') {
                                  _textColorHex = '#0F172A';
                                }
                              }),
                            ),
                            const SizedBox(width: 8),
                            _buildBgChoiceChip(
                              label: 'Koyu Zemin',
                              isSelected: _selectedBackground == 1,
                              cardColor: cardColor,
                              isDark: isDark,
                              onTap: () => setState(() {
                                _selectedBackground = 1;
                                if (_textColorHex == '#0F172A' || _textColorHex == '#000000') {
                                  _textColorHex = '#FFFBEB';
                                }
                              }),
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
                        color: isDark ? AppColors.darkPrimary : const Color(0xFF1B3822),
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
                            defaultTargetPlatform == TargetPlatform.iOS
                                ? (_selectedWidgetType == 0
                                    ? 'Günlük Widget Ayarlarını Kaydet'
                                    : 'Haftalık Widget Ayarlarını Kaydet')
                                : (_selectedWidgetType == 0
                                    ? 'Günlük Widget Ekle'
                                    : 'Haftalık Widget Ekle'),
                            style: AppTypography.sfProRounded(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ─── 5. YAZI RENGİ SEÇİM KARTI (Yalnızca Android için, Apple'da sistem temasına dinamik uyarlanır) ───
                  if (defaultTargetPlatform != TargetPlatform.iOS) ...[
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
                  ],

                  // ─── 6. SAMSUNG KİLİT EKRANI REHBER KARTI (Yalnızca Android için) ───
                  if (defaultTargetPlatform == TargetPlatform.android) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isDark ? AppColors.darkPrimary : _cta).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.screen_lock_portrait_rounded,
                                  size: 20,
                                  color: isDark ? AppColors.darkPrimary : _cta,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Samsung Kilit Ekranı Rehberi',
                                  style: AppTypography.sfProRounded(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Samsung One UI, kilit ekranında doğrudan yalnızca kendi sistem uygulamalarını listeler. Calenda widget\'ını kilit ekranına eklemek için:',
                            style: AppTypography.sfPro(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: mutedText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildStepRow('1', 'Galaxy Store\'dan Good Lock uygulamasını indirin.', primaryText, isDark),
                          const SizedBox(height: 6),
                          _buildStepRow('2', 'Good Lock içinden LockStar eklentisini kurun.', primaryText, isDark),
                          const SizedBox(height: 6),
                          _buildStepRow('3', 'LockStar\'ı açıp kilit ekranına dokunun, "+" butonundan Calenda widget\'ını ekleyin.', primaryText, isDark),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepRow(String number, String text, Color textColor, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkPrimary : _cta).withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: AppTypography.sfPro(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkPrimary : _cta,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.sfPro(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ],
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

    final isApple = defaultTargetPlatform == TargetPlatform.iOS;
    final showDarkPreview = isApple ? isDark : (_selectedBackground == 1);

    // Koyu Arka Plan Önizlemesi
    if (showDarkPreview) {
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
    const displayTitle = 'Bugünün Planı';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
          child: Text(
            displayTitle,
            style: AppTypography.sfProRounded(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: txtColor,
            ),
          ),
        ),
        if (todayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
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
          )
        else
          ...todayEvents.take(4).map((event) {
            return _buildEventItemCard(event);
          }),
      ],
    );
  }

  /// 🗓️ Haftalık Program Önizlemesi (Üstte 7 Günün Tamamı + Genişletilmiş Hücreler)
  Widget _buildWeeklyPreviewContent(PlannerProvider provider) {
    final days = DateTimeUtils.getDaysOfWeek(0);
    final activeDate = days[_previewSelectedDay - 1];
    final activeDayEvents = provider.getEventsForDate(activeDate);
    final txtColor = _currentTextColor;

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

            final isApple = defaultTargetPlatform == TargetPlatform.iOS;
            final isDarkBg = isApple
                ? (Theme.of(context).brightness == Brightness.dark)
                : (_selectedBackground == 1 || !_isDarkText);
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
                        ).copyWith(
                          shadows: isDarkBg
                              ? [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.50),
                                    offset: const Offset(0, 0.8),
                                    blurRadius: 2.0,
                                  ),
                                ]
                              : null,
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
                        ).copyWith(
                          shadows: isDarkBg
                              ? [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.50),
                                    offset: const Offset(0, 0.8),
                                    blurRadius: 2.0,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 3.5),

                      // O güne ait alt alta dizilen açık saydam renkli, sağa doğru yatay uzun mini plan hücreleri
                      if (dayEvents.isEmpty)
                        const SizedBox.shrink()
                      else
                        ...dayEvents.take(4).map((e) {
                          final eventColor = AppColors.hexToColor(e.colorHex);
                          // 🌿 Seçenek 1: Yumuşak açık pastel dolgu + Canlı renkli kenarlık
                          final cellBg = Color.alphaBlend(
                            eventColor.withValues(alpha: 0.38),
                            Colors.white.withValues(alpha: 0.92),
                          );
                          final cellBorderColor = eventColor.withValues(alpha: 0.85);

                          return Container(
                            height: 24.5,
                            margin: const EdgeInsets.only(bottom: 1.8),
                            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
                            decoration: BoxDecoration(
                              color: cellBg,
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: cellBorderColor,
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ⏰ Başlangıç - Bitiş Saati (Koyu gri, net)
                                Text(
                                  e.hasNoEndTime
                                      ? '${e.startHour.toString().padLeft(2, '0')}:${e.startMinute.toString().padLeft(2, '0')}'
                                      : '${e.startHour.toString().padLeft(2, '0')}:${e.startMinute.toString().padLeft(2, '0')}-${e.endHour.toString().padLeft(2, '0')}:${e.endMinute.toString().padLeft(2, '0')}',
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                    fontSize: 5.2,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                    letterSpacing: -0.2,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 0.3),
                                // 📝 Başlık (Koyu siyah/lacivert, jilet gibi net)
                                Text(
                                  e.title,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 6.4,
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

        const SizedBox(height: 10),

        // ── 2. SEÇİLİ GÜNÜN DETAYLI AKIŞ KARTLARI ──
        if (activeDayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Bu güne ait plan bulunmuyor',
                style: AppTypography.sfPro(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: txtColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          )
        else
          Column(
            children: activeDayEvents.take(4).map((event) {
              return _buildEventItemCard(event);
            }).toList(),
          ),
      ],
    );
  }

  /// 📇 Alt Plan Öğesi: Sol Zarif Parlak Çubuk + Ortada Başlık & Açıklama + Sağda Saat
  Widget _buildEventItemCard(ScheduleEvent event) {
    final eventColor = AppColors.hexToColor(event.colorHex);
    final titleColor = _isDarkText ? const Color(0xFF0F172A) : _currentTextColor;
    final subtitleColor = _isDarkText ? const Color(0xFF475569) : _currentTextColor.withValues(alpha: 0.85);
    final timeColor = _isDarkText ? const Color(0xFF475569) : _currentTextColor.withValues(alpha: 0.75);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5, horizontal: 2),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. SOL DİKEY PARLAK RENK ÇUBUĞU (Yazının tam boyuna uyumlu) ──
            Container(
              width: 2.8,
              decoration: BoxDecoration(
                color: eventColor,
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: [
                  BoxShadow(
                    color: eventColor.withValues(alpha: 0.75),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.5),

            // ── 2. ORTADA BAŞLIK VE ALT METİN ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Başlık
                  Text(
                    event.title,
                    style: AppTypography.sfProRounded(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),

                  // Alt Başlık (varsa)
                  if (event.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 1.2),
                    Text(
                      event.subtitle,
                      style: AppTypography.sfPro(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ── 3. SAĞDA SAAT VE BİLDİRİM SİMGESİ ──
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.formattedTimeRange,
                    style: AppTypography.sfPro(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: timeColor,
                    ),
                  ),
                  if (event.isNotificationEnabled) ...[
                    const SizedBox(width: 3.5),
                    Icon(
                      Icons.notifications_active_outlined,
                      size: 11.0,
                      color: timeColor,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
