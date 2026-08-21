import '../constants/app_colors.dart';

/// Widget görünüm ve şeffaflık ayarlarını tutan model
class WidgetThemeConfig {
  final double backgroundOpacity; // 0.0 (Tam Şeffaf) ... 1.0 (Mat)
  final String backgroundColorHex;
  final String textColorHex;
  final String fontStyleName; // 'Inter', 'Playfair', 'Serif', 'Mono'
  final bool enableTextShadow; // Açık arka planlarda okunabilirlik koruması
  final bool showWeeklyGrid;
  final bool showDailyTimeline;
  final int maxDailyItems;
  final String titleText; // Widget başlığı (Örn: 'Bugünün Planı')

  const WidgetThemeConfig({
    this.backgroundOpacity = 0.0, // Varsayılan %100 Şeffaf
    this.backgroundColorHex = '#000000',
    this.textColorHex = '#FFFFFF',
    this.fontStyleName = 'Inter',
    this.enableTextShadow = true,
    this.showWeeklyGrid = true,
    this.showDailyTimeline = true,
    this.maxDailyItems = 5,
    this.titleText = 'Bugünün Planı',
  });

  Map<String, dynamic> toJson() {
    return {
      'backgroundOpacity': backgroundOpacity,
      'backgroundColorHex': backgroundColorHex,
      'textColorHex': textColorHex,
      'fontStyleName': fontStyleName,
      'enableTextShadow': enableTextShadow,
      'showWeeklyGrid': showWeeklyGrid,
      'showDailyTimeline': showDailyTimeline,
      'maxDailyItems': maxDailyItems,
      'titleText': titleText,
    };
  }

  factory WidgetThemeConfig.fromJson(Map<String, dynamic> json) {
    final opacity = json['backgroundOpacity'];
    final maxItems = json['maxDailyItems'];
    final title = json['titleText'];

    return WidgetThemeConfig(
      backgroundOpacity:
          opacity is num ? opacity.toDouble().clamp(0.0, 1.0).toDouble() : 0.0,
      backgroundColorHex: AppColors.normalizeHexColor(
        json['backgroundColorHex'] is String
            ? json['backgroundColorHex'] as String
            : null,
        fallback: AppColors.defaultWidgetBackgroundHex,
      ),
      textColorHex: AppColors.normalizeHexColor(
        json['textColorHex'] is String ? json['textColorHex'] as String : null,
        fallback: AppColors.defaultWidgetTextHex,
      ),
      fontStyleName: _safeString(
        json['fontStyleName'],
        fallback: 'Inter',
        maxLength: 32,
      ),
      enableTextShadow: _safeBool(json['enableTextShadow'], fallback: true),
      showWeeklyGrid: _safeBool(json['showWeeklyGrid'], fallback: true),
      showDailyTimeline: _safeBool(json['showDailyTimeline'], fallback: true),
      maxDailyItems: maxItems is int ? maxItems.clamp(1, 10).toInt() : 5,
      titleText: _safeString(
        title,
        fallback: 'Bugünün Planı',
        maxLength: 40,
        allowEmpty: false,
      ),
    );
  }

  static String _safeString(
    Object? value, {
    required String fallback,
    required int maxLength,
    bool allowEmpty = true,
  }) {
    if (value is! String) return fallback;
    final trimmed = value.trim();
    if (!allowEmpty && trimmed.isEmpty) return fallback;
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  static bool _safeBool(Object? value, {required bool fallback}) {
    return value is bool ? value : fallback;
  }

  WidgetThemeConfig copyWith({
    double? backgroundOpacity,
    String? backgroundColorHex,
    String? textColorHex,
    String? fontStyleName,
    bool? enableTextShadow,
    bool? showWeeklyGrid,
    bool? showDailyTimeline,
    int? maxDailyItems,
    String? titleText,
  }) {
    return WidgetThemeConfig(
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      textColorHex: textColorHex ?? this.textColorHex,
      fontStyleName: fontStyleName ?? this.fontStyleName,
      enableTextShadow: enableTextShadow ?? this.enableTextShadow,
      showWeeklyGrid: showWeeklyGrid ?? this.showWeeklyGrid,
      showDailyTimeline: showDailyTimeline ?? this.showDailyTimeline,
      maxDailyItems: maxDailyItems ?? this.maxDailyItems,
      titleText: titleText ?? this.titleText,
    );
  }
}
