import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/error_logger.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../planner/presentation/screens/home_screen.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../models/onboarding_state.dart';
import '../widgets/account_create_step.dart';
import '../widgets/avatar_studio_step.dart';
import '../widgets/core_goal_step.dart';
import '../widgets/focus_wheel_step.dart';
import '../widgets/impact_celebration_step.dart';
import '../widgets/onboarding_step_bar.dart';
import '../widgets/profile_info_step.dart';
import '../widgets/profile_ready_card_step.dart';
import '../widgets/washi_tape_frequency_step.dart';

/// 🌿 Calenda Masalsı Onboarding Akışı (8 Adımlı Doğrusal Yolculuk)
class OnboardingFlowScreen extends StatefulWidget {
  final OnboardingState? initialState;
  final int initialStep;

  const OnboardingFlowScreen({
    super.key,
    this.initialState,
    this.initialStep = 0,
  });

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late final PageController _pageController;
  late final OnboardingState _state;
  late int _currentStep;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _pageController = PageController(initialPage: widget.initialStep);
    _state = widget.initialState ?? OnboardingState();

    if (widget.initialState == null) {
      // Fix #11: Önceden kaydedilmiş ilerleme varsa geri yükle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final saved = context.read<StorageService>().getOnboardingProgress();
        if (saved != null) {
          final restored = OnboardingState.fromJson(saved);
          setState(() {
            _state.weeklyGoalDays = restored.weeklyGoalDays;
            _state.dailyFocusMinutes = restored.dailyFocusMinutes;
            _state.coreGoals = restored.coreGoals;
            _state.customGoalText = restored.customGoalText;
            _state.username = restored.username;
            _state.firstName = restored.firstName;
            _state.lastName = restored.lastName;
            _state.birthDay = restored.birthDay;
            _state.birthMonth = restored.birthMonth;
            _state.birthYear = restored.birthYear;
            _state.avatarAnimal = restored.avatarAnimal;
            _state.avatarAccessory = restored.avatarAccessory;
            _state.avatarBgColor = restored.avatarBgColor;
            _state.marketingEmailOptIn = restored.marketingEmailOptIn;
            _state.isGoogleAuthed = restored.isGoogleAuthed;
            _state.userId = restored.userId;
            _state.email = restored.email;
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      // 🚀 1. ÖNCELİK: İlk adımın (Mantar Pano & Notlar) anında, sıfır gecikmeyle açılması için önbelleğe al
      precacheImage(const AssetImage(AppAssets.corkBoard), context);
      const notes = [
        'yellow_note.webp',
        'pink_note.webp',
        'green_note.webp',
        'blue_note.webp',
        'purple_note.webp',
        'orange_note.webp',
        'lilac_note.webp',
      ];
      for (final n in notes) {
        precacheImage(AssetImage('${AppAssets.notesPath}$n'), context);
      }

      // 🚀 2. ÖNCELİK: Adım 7'deki avatar ve aksesuarlar ilk adımın açılışını geciktirmemesi için arka planda ertelenerek yüklenir
      Future.delayed(const Duration(milliseconds: 750), () {
        if (!mounted) return;
        const animals = ['bear', 'cat', 'deer', 'fox', 'puppy', 'rabbit', 'seal'];
        for (final a in animals) {
          precacheImage(AssetImage(AppAssets.avatar(a)), context);
        }
        const accessories = [
          'flower_crown',
          'gold_crown',
          'sleep_mask',
          'sprout_clip',
          'strawberry_beret',
          'teacup_hat',
          'velvet_bowtie',
        ];
        for (final acc in accessories) {
          precacheImage(AssetImage(AppAssets.accessory(acc)), context);
        }
      });
    }
  }

  void _nextStep() {
    // 🔕 Klavyeyi kapat (doğum tarihi ve diğer giriş ekranlarından geçişte)
    FocusScope.of(context).unfocus();
    // Adım geçişinde otomatik kaydet (Fix #11)
    context.read<StorageService>().saveOnboardingProgress(_state.toJson());
    if (_currentStep < 7) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _completeOnboarding() async {
    final plannerProvider = context.read<PlannerProvider>();
    final storage = context.read<StorageService>();

    final cleanAnimal = _state.avatarAnimal
        .replaceAll('01_', '')
        .replaceAll('02_', '')
        .replaceAll('03_', '')
        .replaceAll('04_', '')
        .replaceAll('05_', '')
        .replaceAll('06_', '')
        .replaceAll('07_', '');

    final existingUser = plannerProvider.userProfile;
    final finalUserId = _state.userId.isNotEmpty
        ? _state.userId
        : (existingUser.id.isNotEmpty && existingUser.id != 'guest'
            ? existingUser.id
            : (SupabaseService.instance.currentUserId ?? 'usr_${DateTime.now().millisecondsSinceEpoch}'));

    final finalEmail = _state.email.isNotEmpty
        ? _state.email
        : (existingUser.email.isNotEmpty
            ? existingUser.email
            : (SupabaseService.instance.currentUser?.email ?? ''));

    final profile = UserProfile(
      id: finalUserId,
      username: _state.username.trim(),
      firstName: _state.firstName.trim(),
      lastName: _state.lastName.trim(),
      email: finalEmail,
      birthDate: _state.birthDate,
      avatarAnimal: cleanAnimal,
      avatarAccessory: _state.avatarAccessory,
      avatarBgColor: _state.avatarBgColor,
      weeklyGoalDays: _state.weeklyGoalDays,
      dailyFocusMinutes: _state.dailyFocusMinutes,
      coreFocusArea: _state.coreGoal,
      marketingEmailOptIn: _state.marketingEmailOptIn,
      isLoggedIn: true,
      createdAt: DateTime.now(),
    );

    try {
      await plannerProvider.updateUserProfile(profile);
      await storage.setOnboardingCompleted();
      await storage.clearOnboardingProgress(); // Fix #11: Tamamlanınca temizle

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e, st) {
      ErrorLogger.log('OnboardingFlowScreen._completeOnboarding', e, st);
      if (mounted) {
        AestheticSnackBar.showError(
          context,
          'Profil kaydedilirken bir hata oluştu: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AppleAmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Üst İlerleme Çubuğu & Geri Butonu ──
              OnboardingStepBar(
                currentStep: _currentStep,
                totalSteps: 8,
                onBack: _prevStep,
              ),

              // ── Sayfa İçeriği ──
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Adım butonları ile kontrollü geçiş
                  onPageChanged: (index) => setState(() => _currentStep = index),
                  children: [
                    WashiTapeFrequencyStep(state: _state, onNext: _nextStep),
                    FocusWheelStep(state: _state, onNext: _nextStep),
                    CoreGoalStep(state: _state, onNext: _nextStep),
                    ImpactCelebrationStep(state: _state, onNext: _nextStep),
                    AccountCreateStep(state: _state, onNext: _nextStep),
                    ProfileInfoStep(state: _state, onNext: _nextStep),
                    AvatarStudioStep(state: _state, onNext: _nextStep),
                    ProfileReadyCardStep(state: _state, onFinish: _completeOnboarding),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
