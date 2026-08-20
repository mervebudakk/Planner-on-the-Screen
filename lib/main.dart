import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Durum çubuğu ve navigasyon barını şeffaf/aesthetic yap
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlannerProvider(storageService),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.darkBackground,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            secondary: AppColors.accentLight,
            surface: AppColors.darkSurface,
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            scrolledUnderElevation: 0,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
