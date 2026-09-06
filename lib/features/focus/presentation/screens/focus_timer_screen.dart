import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../clubs/providers/club_provider.dart';
import '../../../planner/providers/planner_provider.dart';
import '../widgets/focus_duration_picker_sheet.dart';
import '../widgets/focus_tag_picker_sheet.dart';

/// ⏱️ Calenda — Odak Sayacı (Pomodoro Focus Companion)
enum PomodoroMode {
  focus,      // Odaklanma (25 dk)
  shortBreak, // Kısa Mola (5 dk)
  longBreak,  // Uzun Mola (15 dk)
}

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  PomodoroMode _currentMode = PomodoroMode.focus;
  int _selectedDurationMinutes = 25;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  int _completedSessions = 0;
  String _activeFocusTag = 'Ders & Çalışma';
  int _rabbitFrame = 0;
  Timer? _rabbitTimer;

  static const List<String> _focusTags = [
    'Ders & Çalışma',
    'Proje & İş',
    'Kitap & Okuma',
    'Sakin Odak',
    'Yaratıcı & Tasarım',
  ];

  static const List<int> _focusPresets = [
    15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180, 210, 240
  ];
  static const List<int> _shortBreakPresets = [3, 5, 10, 15, 20, 25, 30];
  static const List<int> _longBreakPresets = [10, 15, 20, 25, 30, 45, 60];

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _textPrimary = Color(0xFF1A2B1D);
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  List<int> get _currentPresets {
    switch (_currentMode) {
      case PomodoroMode.focus:
        return _focusPresets;
      case PomodoroMode.shortBreak:
        return _shortBreakPresets;
      case PomodoroMode.longBreak:
        return _longBreakPresets;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<PlannerProvider>().userProfile;
      if (user.dailyFocusMinutes > 0) {
        setState(() {
          _selectedDurationMinutes = user.dailyFocusMinutes;
          _secondsRemaining = _selectedDurationMinutes * 60;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.rabbitFocus1), context);
    precacheImage(const AssetImage(AppAssets.rabbitFocus2), context);
  }


  @override
  void dispose() {
    _timer?.cancel();
    _rabbitTimer?.cancel();
    super.dispose();
  }

  void _startRabbitAnimation() {
    _rabbitTimer?.cancel();
    _rabbitTimer = Timer.periodic(const Duration(milliseconds: 550), (_) {
      if (mounted && _isRunning) {
        setState(() {
          _rabbitFrame = (_rabbitFrame == 0) ? 1 : 0;
        });
      }
    });
  }

  void _stopRabbitAnimation() {
    _rabbitTimer?.cancel();
    _rabbitTimer = null;
    if (mounted) {
      setState(() {
        _rabbitFrame = 0;
      });
    }
  }

  void _switchMode(PomodoroMode mode) {
    if (_isRunning) _pauseTimer();
    setState(() {
      _currentMode = mode;
      switch (mode) {
        case PomodoroMode.focus:
          final user = context.read<PlannerProvider>().userProfile;
          _selectedDurationMinutes = user.dailyFocusMinutes > 0 ? user.dailyFocusMinutes : 25;
          break;
        case PomodoroMode.shortBreak:
          _selectedDurationMinutes = 5;
          break;
        case PomodoroMode.longBreak:
          _selectedDurationMinutes = 15;
          break;
      }
      _secondsRemaining = _selectedDurationMinutes * 60;
    });
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _startRabbitAnimation();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _stopRabbitAnimation();
        setState(() => _isRunning = false);
        _handleSessionComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _stopRabbitAnimation();
    setState(() => _isRunning = false);
  }

  void _resetTimer([int? newMinutes]) {
    _timer?.cancel();
    _stopRabbitAnimation();
    setState(() {
      _isRunning = false;
      if (newMinutes != null) {
        _selectedDurationMinutes = newMinutes;
      }
      _secondsRemaining = _selectedDurationMinutes * 60;
    });
  }



  void _showCancelConfirmDialog() {
    final totalSeconds = _selectedDurationMinutes * 60;
    final elapsed = totalSeconds - _secondsRemaining;
    if (elapsed < 30) {
      _resetTimer();
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Seansı İptal Et?',
          style: AppTypography.sfProRounded(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primaryText,
          ),
        ),
        content: Text(
          'Şu ana kadar geçen süre kaydedilmeyecektir. Seansı iptal etmek istediğinden emin misin?',
          style: AppTypography.sfPro(
            fontSize: 14,
            color: mutedText,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Devam Et',
              style: AppTypography.sfPro(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: mutedText,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetTimer();
            },
            child: Text(
              'İptal Et',
              style: AppTypography.sfPro(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSessionComplete() {
    if (_currentMode == PomodoroMode.focus) {
      setState(() {
        _completedSessions++;
      });
      // 🌿 Tamamlanan süreyi yerel odaklanma geçmişine ve üye olunan kulüplere senkronize et
      try {
        final planner = context.read<PlannerProvider>();
        planner.recordFocusSession(_selectedDurationMinutes);
        final user = planner.userProfile;
        context.read<ClubProvider>().recordFocusCompleted(
              minutes: _selectedDurationMinutes,
              userProfile: user,
            );
        unawaited(SupabaseService.instance.logFocusSession(
              durationMinutes: _selectedDurationMinutes,
              mode: _currentMode.name,
              focusTag: _activeFocusTag,
            ));
      } catch (_) {}

      _showCompletionDialog(
        title: 'Odak Seansı Tamamlandı',
        message: '$_selectedDurationMinutes dakikalık "$_activeFocusTag" seansını başarıyla tamamladın.',
        nextMode: (_completedSessions % 4 == 0) ? PomodoroMode.longBreak : PomodoroMode.shortBreak,
      );
    } else {
      _showCompletionDialog(
        title: 'Mola Tamamlandı',
        message: 'Zihnini dinlendirdin. Yeni bir odak seansına başlamaya hazır mısın?',
        nextMode: PomodoroMode.focus,
      );
    }
  }

  void _showCompletionDialog({
    required String title,
    required String message,
    required PomodoroMode nextMode,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ctaColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _currentMode == PomodoroMode.focus ? Icons.check_circle_outline_rounded : Icons.coffee_outlined,
                size: 28,
                color: ctaColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.sfProRounded(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.sfPro(
                fontSize: 14,
                color: mutedText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            BouncingWidget(
              onTap: () {
                Navigator.pop(context);
                _switchMode(nextMode);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: ctaColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    nextMode == PomodoroMode.focus ? 'Odak Seansına Başla' : 'Molaya Geç',
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

  void _showScrollableDurationPicker(BuildContext context) {
    if (_isRunning) return;
    FocusDurationPickerSheet.show(
      context,
      isFocusMode: _currentMode == PomodoroMode.focus,
      options: _currentPresets,
      selectedDuration: _selectedDurationMinutes,
      onDurationSelected: _resetTimer,
    );
  }

  IconData _getTagIcon(String tag) => FocusTagPickerSheet.getTagIcon(tag);

  void _showTagPicker(BuildContext context) {
    if (_isRunning) return;
    FocusTagPickerSheet.show(
      context,
      tags: _focusTags,
      activeTag: _activeFocusTag,
      onTagSelected: (tag) => setState(() => _activeFocusTag = tag),
    );
  }

  String _formatTime() {
    final safeSecs = _secondsRemaining < 0 ? 0 : _secondsRemaining;
    final mins = safeSecs ~/ 60;
    final secs = safeSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    final totalSeconds = _selectedDurationMinutes * 60;
    if (totalSeconds <= 0) return 0.0;
    final progress = 1.0 - (_secondsRemaining / totalSeconds);
    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    final isFocus = _currentMode == PomodoroMode.focus;
    final ringAccentColor = isFocus
        ? (isDark ? const Color(0xFF4E9E67) : _cta)
        : (_currentMode == PomodoroMode.shortBreak
            ? const Color(0xFF4A7C59)
            : const Color(0xFF6B8E73));

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Yüzen dock konumu: bottom 18 + bottomPadding + dock 66 = bottomPadding + 84.
    // Dock üstünde 20px estetik boşluk bırakarak net emniyet payı: bottomPadding + 104.
    final dockClearance = bottomPadding + 104.0;

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final usableHeight = (availableHeight - dockClearance).clamp(380.0, double.infinity);

            // Ekran yüksekliğine duyarlı (responsive) oranlama
            final isCompact = usableHeight < 560;
            final isMedium = usableHeight < 680;

            final circleSize = isCompact ? 180.0 : (isMedium ? 205.0 : 230.0);
            final circleProgressSize = circleSize - 10.0;
            final glowSize = circleSize - 25.0;
            final timerFontSize = isCompact ? 38.0 : (isMedium ? 44.0 : 48.0);

            final topInset = MediaQuery.of(context).padding.top;
            final effectiveTopPadding = topInset > 0 ? 20.0 : 36.0;

            return Padding(
              padding: EdgeInsets.only(bottom: dockClearance),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, effectiveTopPadding, 20, 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (usableHeight - effectiveTopPadding - 16).clamp(0.0, double.infinity),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ─── 1. POMODORO 3'LÜ MOD SEGMENT SEÇİCİ ───
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(22),
                              border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? Colors.black : const Color(0xFF142814))
                                      .withValues(alpha: isDark ? 0.20 : 0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                              _buildModeSegment(
                                title: 'Odak',
                                icon: Icons.spa_outlined,
                                mode: PomodoroMode.focus,
                                isDark: isDark,
                                ctaColor: ctaColor,
                                primaryText: primaryText,
                                mutedText: mutedText,
                              ),
                              _buildModeSegment(
                                title: 'Kısa Mola',
                                icon: Icons.coffee_outlined,
                                mode: PomodoroMode.shortBreak,
                                isDark: isDark,
                                ctaColor: ctaColor,
                                primaryText: primaryText,
                                mutedText: mutedText,
                              ),
                              _buildModeSegment(
                                title: 'Uzun Mola',
                                icon: Icons.park_outlined,
                                mode: PomodoroMode.longBreak,
                                isDark: isDark,
                                ctaColor: ctaColor,
                                primaryText: primaryText,
                                mutedText: mutedText,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isCompact ? 10 : 16),
                      const Spacer(flex: 1),

                      // ─── 3. BÜYÜK ESTETİK ODAK HALKASI & BEKLEYEN TAVŞAN ANİMASYONU ───
                      Center(
                        child: SizedBox(
                          width: circleSize,
                          height: circleSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Arka Plan Işıma Efekti (Yumuşak Pastel Matcha Glow - Asla kararma yapmaz)
                              Container(
                                width: glowSize,
                                height: glowSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRunning
                                      ? (isDark
                                          ? const Color(0xFF1E2D22).withValues(alpha: 0.5)
                                          : const Color(0xFFEFF5ED).withValues(alpha: 0.8))
                                      : Colors.transparent,
                                  boxShadow: _isRunning
                                      ? [
                                          BoxShadow(
                                            color: (isDark ? const Color(0xFF4E9E67) : const Color(0xFF88B38E))
                                                .withValues(alpha: 0.22),
                                            blurRadius: 32,
                                            spreadRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),

                              // Arka Plan Çemberi
                              SizedBox(
                                width: circleProgressSize,
                                height: circleProgressSize,
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: isCompact ? 8 : 9,
                                  strokeCap: StrokeCap.round,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? const Color(0xFF23382B) : const Color(0xFFEAEFE7),
                                  ),
                                ),
                              ),

                              // İlerleme Çemberi
                              SizedBox(
                                width: circleProgressSize,
                                height: circleProgressSize,
                                child: CircularProgressIndicator(
                                  value: _getProgress(),
                                  strokeWidth: isCompact ? 8 : 9,
                                  strokeCap: StrokeCap.round,
                                  valueColor: AlwaysStoppedAnimation<Color>(ringAccentColor),
                                ),
                              ),

                              // 🐰 BEKLEYEN TAVŞAN ANİMASYONU (Çemberin Tam Ortasında - Yumuşak ve Kesintisiz Çift Katman)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        AppAssets.rabbitFocus1,
                                        width: circleSize * 0.74,
                                        height: circleSize * 0.74,
                                        fit: BoxFit.contain,
                                        gaplessPlayback: true,
                                      ),
                                      AnimatedOpacity(
                                        opacity: (_isRunning && _rabbitFrame == 1) ? 1.0 : 0.0,
                                        duration: const Duration(milliseconds: 180),
                                        curve: Curves.easeInOut,
                                        child: Image.asset(
                                          AppAssets.rabbitFocus2,
                                          width: circleSize * 0.74,
                                          height: circleSize * 0.74,
                                          fit: BoxFit.contain,
                                          gaplessPlayback: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isCompact ? 14 : 20),

                      // ⏱️ SÜRE SAYACI & İLERLEME AÇIKLAMASI
                      BouncingWidget(
                        onTap: _isRunning ? null : () => _showScrollableDurationPicker(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatTime(),
                                    textAlign: TextAlign.center,
                                    style: AppTypography.sfProRounded(
                                      fontSize: timerFontSize,
                                      fontWeight: FontWeight.w800,
                                      color: primaryText,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Opacity(
                                    opacity: _isRunning ? 0.0 : 1.0,
                                    child: Icon(
                                      Icons.unfold_more_rounded,
                                      size: isCompact ? 18 : 22,
                                      color: mutedText.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Visibility(
                                visible: !_isRunning && _secondsRemaining == _selectedDurationMinutes * 60,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: Text(
                                  'Süreyi değiştirmek için dokun',
                                  style: AppTypography.sfPro(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: mutedText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isCompact ? 8 : 12),

                      // 🏷️ ODAK KONUSU ROZETİ (Çemberin ve Sürenin Tam Altında)
                      if (isFocus)
                        BouncingWidget(
                          onTap: _isRunning ? null : () => _showTagPicker(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E3326) : const Color(0xFFEDF3EB),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : const Color(0xFFD4E0D2),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getTagIcon(_activeFocusTag),
                                  size: 15,
                                  color: isDark ? AppColors.darkTextPrimary : primaryText,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  _activeFocusTag,
                                  style: AppTypography.sfProRounded(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Opacity(
                                  opacity: _isRunning ? 0.0 : 1.0,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3326) : const Color(0xFFEDF3EB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : const Color(0xFFD4E0D2),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.coffee_outlined,
                                size: 15,
                                color: mutedText,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                '$_selectedDurationMinutes dk Dinlenme',
                                style: AppTypography.sfProRounded(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Spacer(flex: 1),

                      SizedBox(height: isCompact ? 12 : 18),

                      // ─── 5. KONTROL BUTONLARI (BAŞLAT / DURAKLAT / İPTAL ET) ───
                      SizedBox(
                        height: 56,
                        child: Center(
                          child: (_isRunning || _secondsRemaining < _selectedDurationMinutes * 60)
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // İptal Et Butonu
                                    BouncingWidget(
                                      onTap: _showCancelConfirmDialog,
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        height: 52,
                                        padding: const EdgeInsets.symmetric(horizontal: 22),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF2C1E20) : const Color(0xFFFDECEE),
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: isDark ? const Color(0xFF5A2A30) : const Color(0xFFF5C6CB),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.close_rounded,
                                              size: 18,
                                              color: Color(0xFFD32F2F),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'İptal Et',
                                              style: AppTypography.sfProRounded(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFFD32F2F),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    // Duraklat / Devam Et (Ana CTA)
                                    BouncingWidget(
                                      onTap: _isRunning ? _pauseTimer : _startTimer,
                                      borderRadius: BorderRadius.circular(26),
                                      child: Container(
                                        height: 52,
                                        padding: const EdgeInsets.symmetric(horizontal: 26),
                                        decoration: BoxDecoration(
                                          color: ctaColor,
                                          borderRadius: BorderRadius.circular(26),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isDark ? Colors.black : ctaColor)
                                                  .withValues(alpha: isDark ? 0.35 : 0.22),
                                              blurRadius: 14,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                              size: 22,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _isRunning ? 'Duraklat' : 'Devam Et',
                                              style: AppTypography.sfProRounded(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : BouncingWidget(
                                  onTap: _startTimer,
                                  borderRadius: BorderRadius.circular(36),
                                  child: Container(
                                    width: 230,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: ctaColor,
                                      borderRadius: BorderRadius.circular(36),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDark ? Colors.black : ctaColor)
                                              .withValues(alpha: isDark ? 0.4 : 0.25),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.play_arrow_rounded,
                                          size: 26,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Odaklanmaya Başla',
                                          style: AppTypography.sfProRounded(
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          },
        ),
      ),
    );
  }

  Widget _buildModeSegment({
    required String title,
    required IconData icon,
    required PomodoroMode mode,
    required bool isDark,
    required Color ctaColor,
    required Color primaryText,
    required Color mutedText,
  }) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: BouncingWidget(
        onTap: _isRunning ? null : () => _switchMode(mode),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? ctaColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : mutedText,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: AppTypography.sfProRounded(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

