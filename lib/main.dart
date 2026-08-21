import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'features/planner/presentation/screens/home_screen.dart';
import 'features/planner/providers/planner_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatı yerelleştirmesini başlat
  await initializeDateFormatting('tr_TR', null);

  // Servisleri başlat
  final storageService = await StorageService.init();
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(AestheticPlannerApp(storageService: storageService));
}

class AestheticPlannerApp extends StatelessWidget {
  final StorageService storageService;

  const AestheticPlannerApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlannerProvider(storageService),
      child: Consumer<PlannerProvider>(
        builder: (context, provider, child) {
          final isDark = provider.themeMode == ThemeMode.dark ||
              (provider.themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          // Durum çubuğu stilini temaya göre ayarla
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: provider.themeMode, // ☀️ Varsayılan: ThemeMode.light

            // 🇹🇷 %100 Türkçe Yerelleştirme Desteği
            locale: const Locale('tr', 'TR'),
            supportedLocales: const [
              Locale('tr', 'TR'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // ─── ☀️ AÇIK TEMA (VARSAYILAN) ───
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColors.lightBackground,
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                secondary: AppColors.primaryLight,
                surface: AppColors.lightSurface,
                error: Color(0xFFEF4444),
              ),
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.light().textTheme,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                scrolledUnderElevation: 0,
                iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
              ),
              cardTheme: CardThemeData(
                color: AppColors.lightCard,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.lightBorder, width: 1),
                ),
              ),
              dividerColor: AppColors.lightDivider,
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            // ─── 🌙 KOYU TEMA ───
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.darkBackground,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.primaryLight,
                surface: AppColors.darkSurface,
                error: Color(0xFFEF4444),
              ),
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.dark().textTheme,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                scrolledUnderElevation: 0,
                iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
              ),
              cardTheme: CardThemeData(
                color: AppColors.darkCard,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.darkBorder, width: 1),
                ),
              ),
              dividerColor: AppColors.darkDivider,
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
