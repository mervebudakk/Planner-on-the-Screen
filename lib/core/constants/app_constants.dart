/// Uygulama genelinde kullanılan sabitler ve anahtarlar
class AppConstants {
  static const String appName = 'Calenda';
  static const String appVersion = '1.0.0';

  // Yerel Depolama Anahtarları (SharedPreferences)
  static const String storageKeyEvents = 'user_schedule_events_v1';
  static const String storageKeyWidgetTheme = 'widget_theme_config_v1';
  static const String storageKeyThemeMode = 'app_theme_mode_v1'; // 'light', 'dark', 'system'
  static const String storageKeyCustomColors = 'user_custom_colors_v1';
  static const String storageKeyCustomWallpaper = 'user_custom_wallpaper_path_v1';
  static const String storageKeyWelcomeSeen = 'user_has_seen_welcome_v1';

  // Android ve iOS Native Widget Sabitleri
  static const String appGroupId = 'group.com.calenda.app';
  static const String androidWidgetName = 'AestheticPlannerWidget';
  static const String androidWeeklyWidgetName = 'AestheticWeeklyWidget';
  static const String iosWidgetKind = 'AestheticPlannerWidget';
  static const String iosWeeklyWidgetKind = 'AestheticWeeklyWidget';

  // Varsayılan Ayarlar
  static const int defaultReminderMinutes = 15;
  static const double defaultWidgetOpacity = 0.0; // %100 Şeffaf
}
