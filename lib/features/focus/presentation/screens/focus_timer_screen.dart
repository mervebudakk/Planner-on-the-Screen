import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
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

  static const List<int> _focusPresets = [15, 25, 45, 60, 90];
  static const List<int> _shortBreakPresets = [3, 5, 10, 15];
  static const List<int> _longBreakPresets = [15, 20, 30, 45];

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

  void _adjustMinutes(int delta) {
    if (_isRunning) return;
    final newMins = (_selectedDurationMinutes + delta).clamp(1, 180);
    setState(() {
      _selectedDurationMinutes = newMins;
      _secondsRemaining = newMins * 60;
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

  void _showCustomDurationPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    int tempMins = _selectedDurationMinutes;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Özel Süre Belirle',
                    style: AppTypography.sfProRounded(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kendine en uygun odak veya mola süresini seç',
                    style: AppTypography.sfPro(
                      fontSize: 13,
                      color: mutedText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BouncingWidget(
                        onTap: () {
                          if (tempMins > 5) {
                            setModalState(() => tempMins -= 5);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1B2C22) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.remove_rounded, color: primaryText, size: 22),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '$tempMins',
                        style: AppTypography.sfProRounded(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'dakika',
                        style: AppTypography.sfPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: mutedText,
                        ),
                      ),
                      const SizedBox(width: 24),
                      BouncingWidget(
                        onTap: () {
                          if (tempMins < 180) {
                            setModalState(() => tempMins += 5);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1B2C22) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.add_rounded, color: primaryText, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BouncingWidget(
                    onTap: () {
                      _resetTimer(tempMins);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: ctaColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(
                          'Uygula',
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
            );
          },
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

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── HEADER (Planlayıcı Sekmesi ile Birebir Uyumlu) ───
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
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

                    // Sağ: Seans Takip Rozeti (Eylül Rozeti Standardında)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : const Color(0xFF142814))
                                .withValues(alpha: isDark ? 0.25 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 16,
                            color: _completedSessions > 0 ? const Color(0xFFE27D60) : mutedText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_completedSessions % 4}/4 Seans',
                            style: AppTypography.sfProRounded(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

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

              const SizedBox(height: 10),

              // ─── 2. ODAK KONUSU ETİKETLERİ (TAG SELECTOR) ───
              if (!_isRunning && isFocus)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _focusTags.map((tag) {
                      final isSelected = _activeFocusTag == tag;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: BouncingWidget(
                          onTap: () => setState(() => _activeFocusTag = tag),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ctaColor
                                  : (isDark ? const Color(0xFF15231B) : Colors.white),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.sfPro(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.darkTextPrimary : primaryText),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const Spacer(flex: 1),

              // ─── 3. BÜYÜK ESTETİK ODAK HALKASI & TAM ORTALANMIŞ SÜRE ───
              Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Arka Plan Işıma Efekti
                      Container(
                        width: 220,
                        height: 220,
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
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 9,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFF23382B) : const Color(0xFFEAEFE7),
                          ),
                        ),
                      ),

                      // İlerleme Çemberi
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: _getProgress(),
                          strokeWidth: 9,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(ringAccentColor),
                        ),
                      ),

                      // 🎯 TAM ORTALANMIŞ İÇ METİN GRUBU
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Üst Durum Rozeti
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: _isRunning
                                    ? ringAccentColor.withValues(alpha: 0.10)
                                    : (isDark ? const Color(0xFF1E3326) : const Color(0xFFEFF5ED)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _isRunning
                                    ? (isFocus ? 'Odaklanılıyor' : 'Mola')
                                    : 'Hazır',
                                style: AppTypography.sfPro(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _isRunning ? ringAccentColor : mutedText,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // ⏰ TAM MERKEZDEKİ BÜYÜK DEV SAYAÇ
                            Text(
                              _formatTime(),
                              textAlign: TextAlign.center,
                              style: AppTypography.sfProRounded(
                                fontSize: 50,
                                fontWeight: FontWeight.w800,
                                color: primaryText,
                                letterSpacing: -1.5,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Alt Odak Konusu veya Hedef Özeti
                            Text(
                              isFocus ? _activeFocusTag : '$_selectedDurationMinutes dk Dinlenme',
                              textAlign: TextAlign.center,
                              style: AppTypography.sfPro(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ⚡ Hızlı Stepper Butonları (-5 dk / +5 dk)
                      if (!_isRunning) ...[
                        Positioned(
                          left: 12,
                          child: BouncingWidget(
                            onTap: () => _adjustMinutes(-5),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1B2C22) : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.remove_rounded, size: 16, color: primaryText),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          child: BouncingWidget(
                            onTap: () => _adjustMinutes(5),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1B2C22) : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.add_rounded, size: 16, color: primaryText),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ─── 4. SÜRE ÖN AYAR HAPLARI & ÖZEL SÜRE BUTONU (Planlayıcı Gün Hapları Standardında) ───
              if (!_isRunning)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ..._currentPresets.map((mins) {
                        final isSelected = _selectedDurationMinutes == mins;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: BouncingWidget(
                            onTap: () => _resetTimer(mins),
                            borderRadius: BorderRadius.circular(18),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? ctaColor
                                    : (isDark ? const Color(0xFF1B2C22) : Colors.white),
                                borderRadius: BorderRadius.circular(18),
                                border: isDark && !isSelected
                                    ? Border.all(color: AppColors.darkBorder)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : const Color(0xFF142814))
                                        .withValues(alpha: isSelected ? 0.15 : 0.04),
                                    blurRadius: isSelected ? 8 : 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '$mins dk',
                                style: AppTypography.sfProRounded(
                                  fontSize: 13.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.darkTextPrimary : primaryText),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      // Özel Süre Butonu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: BouncingWidget(
                          onTap: () => _showCustomDurationPicker(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B2C22) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? Colors.black : const Color(0xFF142814))
                                      .withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.tune_rounded, size: 15, color: mutedText),
                                const SizedBox(width: 5),
                                Text(
                                  'Özel',
                                  style: AppTypography.sfPro(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

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

              const SizedBox(height: 110), // Dock emniyet payı
            ],
          ),
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

