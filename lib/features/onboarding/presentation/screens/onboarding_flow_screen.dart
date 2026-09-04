import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/storage_service.dart';
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
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  final OnboardingState _state = OnboardingState();
  int _currentStep = 0;

  void _nextStep() {
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
    final profile = UserProfile(
      id: existingUser.id.isNotEmpty ? existingUser.id : 'usr_',
      username: _state.username.isNotEmpty ? _state.username : 'calenda_user',
      firstName: _state.firstName.isNotEmpty ? _state.firstName : 'Kullanıcı',
      lastName: _state.lastName,
      email: existingUser.email,
      birthDate: _state.birthDate,
      avatarAnimal: cleanAnimal,
      avatarAccessory: _state.avatarAccessory,
      avatarBgColor: _state.avatarBgColor,
      weeklyGoalDays: _state.weeklyGoalDays,
      dailyFocusMinutes: _state.dailyFocusMinutes,
      coreFocusArea: _state.coreGoal,
      marketingEmailOptIn: _state.marketingEmailOptIn,
      isLoggedIn: existingUser.isLoggedIn || _state.isGoogleAuthed,
      createdAt: DateTime.now(),
    );

    await plannerProvider.updateUserProfile(profile);
    await storage.setOnboardingCompleted();

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
