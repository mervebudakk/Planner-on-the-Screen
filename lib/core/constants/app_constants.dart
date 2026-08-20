/// Uygulama genelinde kullanılan sabitler
class AppConstants {
  static const String appName = 'Aesthetic Planner';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyEvents = 'key_schedule_events';
  static const String keyWidgetTheme = 'key_widget_theme_config';
  static const String keySettings = 'key_user_settings';
  static const String keyFirstLaunch = 'key_first_launch_date';

  // Widget Bridge Constants (home_widget)
  static const String appGroupId = 'group.com.aesthetic.planner';
  static const String androidWidgetName = 'AestheticPlannerWidget';
  static const String iosWidgetKind = 'AestheticPlannerWidget';

  // Default Values
  static const double defaultWidgetOpacity = 0.0; // %100 Şeffaf
  static const int defaultReminderMinutes = 15; // 15 dk önce
}
