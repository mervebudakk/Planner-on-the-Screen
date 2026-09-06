import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_typography.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';
import 'features/clubs/providers/club_provider.dart';
import 'features/planner/presentation/screens/home_screen.dart';
import 'features/planner/presentation/screens/welcome_screen.dart';
import 'features/planner/providers/planner_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatı yerelleştirmesini başlat
  await initializeDateFormatting('tr_TR', null);

  // Font titremesini / sonradan değişmesini (FOUT) önlemek için fontları hafızaya önden yükle
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.dmSans(fontWeight: FontWeight.w400),
      GoogleFonts.dmSans(fontWeight: FontWeight.w500),
      GoogleFonts.dmSans(fontWeight: FontWeight.w600),
      GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      GoogleFonts.dmSans(fontWeight: FontWeight.w800),
      GoogleFonts.dmSans(fontWeight: FontWeight.w900),
    ]);
  } catch (_) {}

  // Servisleri başlat
  final storageService = await StorageService.init();
  await SupabaseService.init();
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
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider(
          create: (_) => PlannerProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ClubProvider(),
        ),
      ],
      child: Consumer<PlannerProvider>(
        builder: (context, provider, child) {
          // Durum çubuğu stili (Daima Açık / Fransız Kırtasiye & Quiet Luxury)
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: AppColors.lightBackground,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
          );

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light, // ☀️ Daima Açık Tema (Quiet Luxury)

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

            // ─── ☀️ AÇIK TEMA (QUIET LUXURY & FRANSIZ KIRTASİYE) ───
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
              fontFamily: defaultTargetPlatform == TargetPlatform.iOS ? '.SF Pro Text' : 'DMSans',
              fontFamilyFallback: AppTypography.sfProFallbacks,
              textTheme: defaultTargetPlatform == TargetPlatform.iOS
                  ? ThemeData.light().textTheme.apply(
                      fontFamily: '.SF Pro Text',
                      bodyColor: AppColors.lightTextPrimary,
                      displayColor: AppColors.lightTextPrimary,
                    )
                  : GoogleFonts.dmSansTextTheme(
                      ThemeData.light().textTheme.apply(
                        bodyColor: AppColors.lightTextPrimary,
                        displayColor: AppColors.lightTextPrimary,
                      ),
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

            home: storageService.isOnboardingCompleted()
                ? const HomeScreen()
                : const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
