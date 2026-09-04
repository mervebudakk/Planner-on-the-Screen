import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../planner/providers/planner_provider.dart';

/// ⏱️ Calenda Masalsı Odak Sayacı (Cozy Focus Timer)
class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> with SingleTickerProviderStateMixin {
  int _selectedDurationMinutes = 25;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  String _activeFocusTag = '🎓 Ders & Sınav';

  static const List<int> _presetMinutes = [15, 25, 45, 60, 90];
  static const List<String> _focusTags = [
    '🎓 Ders & Sınav',
    '💼 Proje & İş',
    '📖 Kitap & Okuma',
    '🌿 Kişisel Odak',
  ];

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

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _showCompletionDialog();
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

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(
              'Tebrikler! ✨',
              style: AppTypography.sfProRounded(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4A2B33),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_selectedDurationMinutes dakikalık "$_activeFocusTag" seansını başarıyla tamamladın.',
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
                _resetTimer();
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
                    'Harika!',
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
  }

  String _formatTime() {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
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

    final user = context.watch<PlannerProvider>().userProfile;

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // ── Header ──
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
                          _isRunning ? 'Odak seansı devam ediyor...' : 'Kişisel hedefine göre ayarlandı',
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
                  // Hedef Rozeti
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
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFC47B89)),
                        const SizedBox(width: 4),
                        Text(
                          user.weeklyGoalDays == 0 ? 'Serbest' : '${user.weeklyGoalDays} Gün/Hf',
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

              const SizedBox(height: 14),

              // ── 🏷️ ODAK KATEGORİ ETİKETLERİ (TAG SELECTOR) ──
              if (!_isRunning)
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

              // ── ⏳ BÜYÜK ESTETİK ODAK HALKASI ──
              Center(
                child: SizedBox(
                  width: 246,
                  height: 246,
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
                              ? (isDark ? const Color(0xFF2E4D37).withValues(alpha: 0.25) : buttonPink.withValues(alpha: 0.15))
                              : Colors.transparent,
                          boxShadow: _isRunning
                              ? [
                                  BoxShadow(
                                    color: (isDark ? const Color(0xFF4E9E67) : buttonPink).withValues(alpha: 0.3),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      // Arka Plan Çemberi
                      SizedBox(
                        width: 236,
                        height: 236,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 11,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFF23382B) : const Color(0xFFF0EAE1),
                          ),
                        ),
                      ),
                      // İlerleme Çemberi
                      SizedBox(
                        width: 236,
                        height: 236,
                        child: CircularProgressIndicator(
                          value: _getProgress(),
                          strokeWidth: 11,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFF4E9E67) : buttonPink,
                          ),
                        ),
                      ),
                      // Merkez Sayaç Metni
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(),
                            style: AppTypography.sfProRounded(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : titleColor,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _isRunning
                                  ? const Color(0xFFC47B89).withValues(alpha: 0.12)
                                  : (isDark ? const Color(0xFF1E3326) : const Color(0xFFF5EFEB)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _isRunning ? 'Odaklanılıyor 🌿' : 'Hazır',
                              style: AppTypography.sfPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _isRunning ? const Color(0xFFC47B89) : subtitleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ── 💊 SÜRE ÖN AYAR HAPLARI ──
              if (!_isRunning)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _presetMinutes.map((mins) {
                      final isSelected = _selectedDurationMinutes == mins;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: BouncingWidget(
                          onTap: () => _resetTimer(mins),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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

              const SizedBox(height: 22),

              // ── 🎮 KONTROL BUTONLARI (BAŞLAT / DURAKLAT / SIFIRLA) ──
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
}

