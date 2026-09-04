import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../planner/providers/planner_provider.dart';

/// ⏱️ Calenda Masalsı Pomodoro & Odak Sayacı (Cozy Pomodoro Focus Companion)
enum PomodoroMode {
  focus,      // 🌿 Odaklanma (25 dk)
  shortBreak, // ☕ Kısa Mola (5 dk)
  longBreak,  // 🌴 Uzun Mola (15 dk)
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
  int _completedSessions = 0; // Tamamlanan Pomodoro seansları (4 seanslık döngü)
  String _activeFocusTag = '🎓 Sınav & Ders';

  static const List<String> _focusTags = [
    '🎓 Sınav & Ders',
    '💼 Proje & İş',
    '📖 Kitap & Okuma',
    '🌿 Sakin Odak',
    '🎨 Yaratıcı & Çizim',
  ];

  static const List<int> _focusPresets = [15, 25, 45, 60, 90];
  static const List<int> _shortBreakPresets = [3, 5, 10, 15];
  static const List<int> _longBreakPresets = [15, 20, 30, 45];

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
        title: 'Harika Odaklandın! 🌟',
        message: '$_selectedDurationMinutes dakikalık "$_activeFocusTag" seansını tamamladın.',
        nextMode: (_completedSessions % 4 == 0) ? PomodoroMode.longBreak : PomodoroMode.shortBreak,
      );
    } else {
      _showCompletionDialog(
        title: 'Mola Tamamlandı! ☕',
        message: 'Zihnini dinlendirdin. Şimdi yeni bir odak seansına hazır mısın?',
        nextMode: PomodoroMode.focus,
      );
    }
  }

  void _showCompletionDialog({
    required String title,
    required String message,
    required PomodoroMode nextMode,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentMode == PomodoroMode.focus ? '🎉' : '🌿',
              style: const TextStyle(fontSize: 44),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.sfProRounded(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4A2B33),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.sfPro(
                fontSize: 14,
                color: const Color(0xFF7A5861),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            BouncingWidget(
              onTap: () {
                Navigator.pop(context);
                _switchMode(nextMode);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A2B33),
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
    int tempMins = _selectedDurationMinutes;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAF7F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6C8BB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Özel Süre Belirle',
                    style: AppTypography.sfProRounded(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4A2B33),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kendine en uygun odak veya mola süresini seç',
                    style: AppTypography.sfPro(
                      fontSize: 13,
                      color: const Color(0xFF7A5861),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEADBCE)),
                          ),
                          child: const Icon(Icons.remove_rounded, color: Color(0xFF4A2B33), size: 22),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '$tempMins',
                        style: AppTypography.sfProRounded(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A2B33),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'dakika',
                        style: AppTypography.sfPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7A5861),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEADBCE)),
                          ),
                          child: const Icon(Icons.add_rounded, color: Color(0xFF4A2B33), size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AestheticPlannerButton(
                    text: 'Uygula',
                    height: 50,
                    onPressed: () {
                      _resetTimer(tempMins);
                      Navigator.pop(context);
                    },
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
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    const buttonPink = Color(0xFFE6ABA7);
    const buttonPinkDarker = Color(0xFFDF9E99);

    // Mod renkleri
    final isFocus = _currentMode == PomodoroMode.focus;
    final isShortBreak = _currentMode == PomodoroMode.shortBreak;

    final ringAccentColor = isFocus
        ? (isDark ? const Color(0xFF4E9E67) : buttonPink)
        : (isShortBreak ? const Color(0xFF5A8DB5) : const Color(0xFF8E79AB));

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // ── 🏷️ ÜST BAŞLIK & POMODORO SEANS SAYACI ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Odak Sayacı',
                          style: AppTypography.sfProRounded(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : titleColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isRunning
                              ? (isFocus ? 'Odak seansı devam ediyor...' : 'Mola zamanı, dinlen...')
                              : 'Kişisel hedefine göre ayarlandı',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sfPro(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextMuted : subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Seans Takip Rozeti
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3326) : const Color(0xFFFDEBF0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: _completedSessions > 0 ? const Color(0xFFC47B89) : const Color(0xFFBDB2A7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_completedSessions % 4}/4 Seans',
                          style: AppTypography.sfPro(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── 🍅 1. POMODORO 3'LÜ MOD SEGMENT SEÇİCİ (POPÜLER POMODORO STANDARDİ) ──
              if (!_isRunning)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF15231B) : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildModeSegment(
                        title: '🌿 Odak',
                        mode: PomodoroMode.focus,
                        isDark: isDark,
                        activeBg: isDark ? const Color(0xFF2E4D37) : const Color(0xFF4A2B33),
                      ),
                      _buildModeSegment(
                        title: '☕ Kısa Mola',
                        mode: PomodoroMode.shortBreak,
                        isDark: isDark,
                        activeBg: isDark ? const Color(0xFF1B3B4B) : const Color(0xFF5A8DB5),
                      ),
                      _buildModeSegment(
                        title: '🌴 Uzun Mola',
                        mode: PomodoroMode.longBreak,
                        isDark: isDark,
                        activeBg: isDark ? const Color(0xFF382A4A) : const Color(0xFF8E79AB),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // ── 🏷️ 2. ODAK KONUSU ETİKETLERİ (TAG SELECTOR) ──
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
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF2E4D37) : const Color(0xFF4A2B33))
                                  : (isDark ? const Color(0xFF15231B) : Colors.white.withValues(alpha: 0.8)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE)),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.sfPro(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.darkTextPrimary : titleColor),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const Spacer(flex: 1),

              // ── ⏳ 3. BÜYÜK ESTETİK ODAK HALKASI & TAM ORTALANMIŞ SÜRE ──
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
                              ? ringAccentColor.withValues(alpha: 0.18)
                              : Colors.transparent,
                          boxShadow: _isRunning
                              ? [
                                  BoxShadow(
                                    color: ringAccentColor.withValues(alpha: 0.35),
                                    blurRadius: 44,
                                    spreadRadius: 8,
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
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFF23382B) : const Color(0xFFF0EAE1),
                          ),
                        ),
                      ),

                      // İlerleme Çemberi
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: _getProgress(),
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(ringAccentColor),
                        ),
                      ),

                      // 🎯 TAM ORTALANMIŞ İÇ METİN GRUBU (DEAD CENTERED DIGITS)
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
                                    ? ringAccentColor.withValues(alpha: 0.12)
                                    : (isDark ? const Color(0xFF1E3326) : const Color(0xFFF5EFEB)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _isRunning
                                    ? (isFocus ? 'Odaklanılıyor 🌿' : 'Mola Zamanı ☕')
                                    : '✦ Hazır',
                                style: AppTypography.sfPro(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _isRunning ? ringAccentColor : subtitleColor,
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
                                color: isDark ? AppColors.darkTextPrimary : titleColor,
                                letterSpacing: -1.5,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Alt Odak Konusu veya Hedef Özeti
                            Text(
                              isFocus ? _activeFocusTag : '$_selectedDurationMinutes dk Dinlenme',
                              textAlign: TextAlign.center,
                              style: AppTypography.sfPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextMuted : const Color(0xFF9E8D86),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ⚡ Hızlı Stepper Butonları (-5 dk / +5 dk: Forest & Flora Tarzı)
                      if (!_isRunning) ...[
                        Positioned(
                          left: 12,
                          child: BouncingWidget(
                            onTap: () => _adjustMinutes(-5),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFEADBCE)),
                              ),
                              child: const Icon(Icons.remove_rounded, size: 16, color: titleColor),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          child: BouncingWidget(
                            onTap: () => _adjustMinutes(5),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFEADBCE)),
                              ),
                              child: const Icon(Icons.add_rounded, size: 16, color: titleColor),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ── 💊 4. POPÜLER SÜRE ÖN AYAR HAPLARI & ÖZEL SÜRE BUTONU ──
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
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF387A51) : titleColor)
                                    : (isDark ? const Color(0xFF1B2C22) : Colors.white.withValues(alpha: 0.85)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE)),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                '$mins dk',
                                style: AppTypography.sfPro(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.darkTextPrimary : titleColor),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      // ⚙️ Özel Süre Butonu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: BouncingWidget(
                          onTap: () => _showCustomDurationPicker(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B2C22) : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.tune_rounded, size: 14, color: Color(0xFF8B7970)),
                                const SizedBox(width: 4),
                                Text(
                                  'Özel',
                                  style: AppTypography.sfPro(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8B7970),
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

              // ── 🎮 5. KONTROL BUTONLARI (BAŞLAT / DURAKLAT / SIFIRLA) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sıfırla
                  BouncingWidget(
                    onTap: () => _resetTimer(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B2C22) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 24,
                        color: isDark ? Colors.white : titleColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  // Başlat / Duraklat
                  BouncingWidget(
                    onTap: _isRunning ? _pauseTimer : _startTimer,
                    borderRadius: BorderRadius.circular(36),
                    child: Container(
                      width: 154,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isRunning
                              ? [const Color(0xFF8B7970), const Color(0xFF7A5861)]
                              : [buttonPink, buttonPinkDarker],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRunning ? const Color(0xFF7A5861) : buttonPink)
                                .withValues(alpha: 0.4),
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
    required PomodoroMode mode,
    required bool isDark,
    required Color activeBg,
  }) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: BouncingWidget(
        onTap: () => _switchMode(mode),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
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
          child: Center(
            child: Text(
              title,
              style: AppTypography.sfProRounded(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextMuted : const Color(0xFF8B7970)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

