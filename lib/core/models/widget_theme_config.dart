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

  const WidgetThemeConfig({
    this.backgroundOpacity = 0.0, // Varsayılan %100 Şeffaf
    this.backgroundColorHex = '#000000',
    this.textColorHex = '#FFFFFF',
    this.fontStyleName = 'Inter',
    this.enableTextShadow = true,
    this.showWeeklyGrid = true,
    this.showDailyTimeline = true,
    this.maxDailyItems = 5,
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
    };
  }

  factory WidgetThemeConfig.fromJson(Map<String, dynamic> json) {
    return WidgetThemeConfig(
      backgroundOpacity: (json['backgroundOpacity'] as num?)?.toDouble() ?? 0.0,
      backgroundColorHex: (json['backgroundColorHex'] as String?) ?? '#000000',
      textColorHex: (json['textColorHex'] as String?) ?? '#FFFFFF',
      fontStyleName: (json['fontStyleName'] as String?) ?? 'Inter',
      enableTextShadow: (json['enableTextShadow'] as bool?) ?? true,
      showWeeklyGrid: (json['showWeeklyGrid'] as bool?) ?? true,
      showDailyTimeline: (json['showDailyTimeline'] as bool?) ?? true,
      maxDailyItems: (json['maxDailyItems'] as int?) ?? 5,
    );
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
    );
  }
}
