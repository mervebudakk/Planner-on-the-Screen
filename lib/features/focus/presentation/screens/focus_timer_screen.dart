import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../clubs/presentation/screens/club_hub_screen.dart';
import '../../../clubs/providers/club_provider.dart';
import '../../../planner/providers/planner_provider.dart';

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

class _FocusTimerScreenState extends State<FocusTimerScreen> with SingleTickerProviderStateMixin {
  PomodoroMode _currentMode = PomodoroMode.focus;
  int _selectedDurationMinutes = 25;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  int _completedSessions = 0;
  String _activeFocusTag = 'Ders & Çalışma';

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
  void reassemble() {
    super.reassemble();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _handleSessionComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer([int? newMinutes]) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (newMinutes != null) {
        _selectedDurationMinutes = newMinutes;
      }
      _secondsRemaining = _selectedDurationMinutes * 60;
    });
  }

  void _handleSessionComplete() {
    if (_currentMode == PomodoroMode.focus) {
      setState(() {
        _completedSessions++;
      });
      // 🌿 Tamamlanan süreyi üye olunan kulüplere senkronize et
      try {
        final user = context.read<PlannerProvider>().userProfile;
        context.read<ClubProvider>().recordFocusCompleted(
              minutes: _selectedDurationMinutes,
              userProfile: user,
            );
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2);
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    final options = _currentPresets;
    int initialIndex = options.indexOf(_selectedDurationMinutes);
    if (initialIndex < 0) {
      initialIndex = 0;
      int minDiff = 999;
      for (int i = 0; i < options.length; i++) {
        final diff = (options[i] - _selectedDurationMinutes).abs();
        if (diff < minDiff) {
          minDiff = diff;
          initialIndex = i;
        }
      }
    }

    int tempIndex = initialIndex;
    final scrollController = FixedExtentScrollController(initialItem: initialIndex);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Üst Sürükleme Çubuğu
                Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 16),

                // Başlık & Kapatma Butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentMode == PomodoroMode.focus
                              ? 'Odak Süresi Seçimi'
                              : 'Mola Süresi Seçimi',
                          style: AppTypography.sfProRounded(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentMode == PomodoroMode.focus
                              ? '15 dakikalık aralıklarla kaydırın veya seçin'
                              : 'İstediğiniz süreyi seçin',
                          style: AppTypography.sfPro(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(modalContext),
                      icon: Icon(Icons.close_rounded, color: mutedText, size: 22),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // CupertinoPicker Tekerleği
                SizedBox(
                  height: 210,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Arka Plan Seçim Vurgu Çerçevesi (Quiet Luxury Pill)
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : ctaColor).withValues(alpha: isDark ? 0.08 : 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (isDark ? Colors.white24 : ctaColor.withValues(alpha: 0.18)),
                            width: 1.2,
                          ),
                        ),
                      ),

                      CupertinoPicker(
                        scrollController: scrollController,
                        itemExtent: 48,
                        magnification: 1.15,
                        squeeze: 1.1,
                        useMagnifier: true,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (index) {
                          tempIndex = index;
                        },
                        children: options.map((mins) {
                          final durationText = '$mins dk';

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _resetTimer(mins);
                              Navigator.pop(modalContext);
                            },
                            child: Center(
                              child: Text(
                                durationText,
                                style: AppTypography.sfProRounded(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: primaryText,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // "Süreyi Uygula" Butonu
                BouncingWidget(
                  onTap: () {
                    final chosen = options[tempIndex];
                    _resetTimer(chosen);
                    Navigator.pop(modalContext);
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: ctaColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : ctaColor).withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Süreyi Uygula',
                        style: AppTypography.sfProRounded(
                          fontSize: 16,
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
      },
    );
  }

  IconData _getTagIcon(String tag) {
    switch (tag) {
      case 'Ders & Çalışma':
        return Icons.school_outlined;
      case 'Proje & İş':
        return Icons.work_outline_rounded;
      case 'Kitap & Okuma':
        return Icons.auto_stories_outlined;
      case 'Sakin Odak':
        return Icons.spa_outlined;
      case 'Yaratıcı & Tasarım':
        return Icons.palette_outlined;
      default:
        return Icons.label_outline_rounded;
    }
  }

  void _showTagPicker(BuildContext context) {
    if (_isRunning) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2);
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sürükleme Çubuğu
                Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 16),

                // Başlık & Kapatma Butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Odak Konusu',
                          style: AppTypography.sfProRounded(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bu seansta ne üzerine çalışacaksınız?',
                          style: AppTypography.sfPro(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(modalContext),
                      icon: Icon(Icons.close_rounded, color: mutedText, size: 22),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Etiket Seçenekleri
                ..._focusTags.map((tag) {
                  final isSelected = _activeFocusTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: BouncingWidget(
                      onTap: () {
                        setState(() => _activeFocusTag = tag);
                        Navigator.pop(modalContext);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF1E3326) : const Color(0xFFEBF3EA))
                              : (isDark ? const Color(0xFF18261E) : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppColors.darkPrimary : const Color(0xFF6B9080))
                                : (isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? ctaColor.withValues(alpha: isDark ? 0.25 : 0.12)
                                    : (isDark ? Colors.white10 : const Color(0xFFF4F6F2)),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getTagIcon(tag),
                                size: 18,
                                color: isSelected ? (isDark ? AppColors.darkPrimary : ctaColor) : mutedText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tag,
                                style: AppTypography.sfProRounded(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: isDark ? AppColors.darkPrimary : ctaColor,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
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
    // Yüzen dock konumu: bottom 18 + safeArea + dock yüksekliği 66 = safeArea + 84.
    // Dock üstünde 20px estetik boşluk bırakarak net emniyet payı: safeArea + 104.
    final dockClearance = bottomPadding + 104;

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            // Ekran yüksekliğine duyarlı (responsive) oranlama
            final isCompact = availableHeight < 720;
            final isMedium = availableHeight < 820;

            final circleSize = isCompact ? 195.0 : (isMedium ? 218.0 : 246.0);
            final circleProgressSize = circleSize - 10.0;
            final glowSize = circleSize - 25.0;
            final timerFontSize = isCompact ? 42.0 : (isMedium ? 46.0 : 50.0);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 0, 20, dockClearance),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (availableHeight - dockClearance).clamp(0.0, double.infinity),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ─── HEADER (Planlayıcı Sekmesi ile Birebir Uyumlu) ───
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: isCompact ? 8 : 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Sol: Kategori & Başlık
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.hourglass_top_rounded,
                                        size: 16,
                                        color: mutedText,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _isRunning
                                            ? (isFocus ? 'Odak Seansı' : 'Mola Zamanı')
                                            : 'Zamanlayıcı & Hedef',
                                        style: AppTypography.sfPro(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: mutedText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Odak Sayacı',
                                    style: AppTypography.sfProRounded(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Sağ: Kulüplerim Butonu
                            BouncingWidget(
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) => const ClubHubScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E3326)
                                      : const Color(0xFFEFF5EC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : const Color(0xFFD6E2D2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🌿', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Kulüplerim',
                                      style: AppTypography.sfPro(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : const Color(0xFF1E3A1E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isCompact ? 4 : 6),

                      // ─── 1. POMODORO 3'LÜ MOD SEGMENT SEÇİCİ ───
                      if (!_isRunning)
                        Container(
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

                      SizedBox(height: isCompact ? 10 : 16),
                      const Spacer(flex: 1),

                      // ─── 3. BÜYÜK ESTETİK ODAK HALKASI & TAM ORTALANMIŞ SÜRE ───
                      Center(
                        child: SizedBox(
                          width: circleSize,
                          height: circleSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Arka Plan Işıma Efekti
                              Container(
                                width: glowSize,
                                height: glowSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRunning
                                      ? ringAccentColor.withValues(alpha: 0.12)
                                      : Colors.transparent,
                                  boxShadow: _isRunning
                                      ? [
                                          BoxShadow(
                                            color: ringAccentColor.withValues(alpha: 0.25),
                                            blurRadius: 36,
                                            spreadRadius: 6,
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

                              // 🎯 TAM ORTALANMIŞ İÇ METİN GRUBU (Sadece Büyük Süre Sayacı)
                              Center(
                                child: BouncingWidget(
                                  onTap: _isRunning ? null : () => _showScrollableDurationPicker(context),
                                  borderRadius: BorderRadius.circular(24),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    child: Row(
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
                                        if (!_isRunning) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.unfold_more_rounded,
                                            size: isCompact ? 18 : 22,
                                            color: mutedText.withValues(alpha: 0.65),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isCompact ? 14 : 20),

                      // 🏷️ ODAK KONUSU ROZETİ (Çemberin Tam Altında, Etkileşimli Seçici)
                      if (isFocus)
                        BouncingWidget(
                          onTap: _isRunning ? null : () => _showTagPicker(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  size: 16,
                                  color: isDark ? AppColors.darkTextPrimary : primaryText,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _activeFocusTag,
                                  style: AppTypography.sfProRounded(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                  ),
                                ),
                                if (!_isRunning) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: mutedText,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                size: 16,
                                color: mutedText,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_selectedDurationMinutes dk Dinlenme',
                                style: AppTypography.sfProRounded(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Spacer(flex: 1),

                      SizedBox(height: isCompact ? 12 : 18),

                      // ─── 5. KONTROL BUTONLARI (BAŞLAT / DURAKLAT / SIFIRLA) ───
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Sıfırla Butonu
                          BouncingWidget(
                            onTap: () => _resetTimer(),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1B2C22) : Colors.white,
                                shape: BoxShape.circle,
                                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.refresh_rounded,
                                size: 24,
                                color: primaryText,
                              ),
                            ),
                          ),

                          const SizedBox(width: 18),

                          // Başlat / Duraklat Butonu (Ana CTA)
                          BouncingWidget(
                            onTap: _isRunning ? _pauseTimer : _startTimer,
                            borderRadius: BorderRadius.circular(36),
                            child: Container(
                              width: 160,
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
                                  Icon(
                                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    size: 26,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isRunning ? 'Duraklat' : 'Başlat',
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
                        ],
                      ),
                    ],
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
        onTap: () => _switchMode(mode),
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

