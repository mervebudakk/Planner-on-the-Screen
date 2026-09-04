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

  static const List<int> _presetMinutes = [15, 25, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
            const Text('🎉', style: TextStyle(fontSize: 40)),
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
              ' dakikalık odaklanma seansını başarıyla tamamladın.',
              textAlign: TextAlign.center,
              style: AppTypography.sfPro(
                fontSize: 14,
                color: const Color(0xFF7A5861),
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
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (_secondsRemaining / totalSeconds);
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Odak Sayacı',
                        style: AppTypography.sfProRounded(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.coreFocusArea,
                        style: AppTypography.sfPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextMuted : subtitleColor,
                        ),
                      ),
                    ],
                  ),
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
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFC47B89)),
                        const SizedBox(width: 4),
                        Text(
                          user.weeklyGoalDays == 0 ? 'Serbest' : 'Hedef:  Gün/Hf',
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

              const Spacer(flex: 1),

              // ── ⏳ BÜYÜK ESTETİK ODAK HALKASI ──
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Arka Plan Çemberi
                      SizedBox(
                        width: 230,
                        height: 230,
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
                        width: 230,
                        height: 230,
                        child: CircularProgressIndicator(
                          value: _getProgress(),
                          strokeWidth: 10,
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
                              fontSize: 46,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : titleColor,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isRunning ? 'Odaklanılıyor...' : 'Hazır',
                            style: AppTypography.sfPro(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isRunning ? const Color(0xFFC47B89) : subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ── Süre Ön Ayar Hapları ──
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF387A51) : titleColor)
                                  : (isDark ? const Color(0xFF1B2C22) : Colors.white.withValues(alpha: 0.8)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE)),
                              ),
                            ),
                            child: Text(
                              ' dk',
                              style: AppTypography.sfPro(
                                fontSize: 13,
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

              const SizedBox(height: 24),

              // ── Kontrol Butonları (Başlat / Duraklat / Sıfırla) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sıfırla
                  BouncingWidget(
                    onTap: () => _resetTimer(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 52,
                      height: 52,
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
                        size: 22,
                        color: isDark ? Colors.white : titleColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Başlat / Duraklat
                  BouncingWidget(
                    onTap: _isRunning ? _pauseTimer : _startTimer,
                    borderRadius: BorderRadius.circular(36),
                    child: Container(
                      width: 140,
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
                        boxShadow: [
                          BoxShadow(
                            color: (_isRunning ? const Color(0xFF7A5861) : buttonPink)
                                .withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRunning ? 'Duraklat' : 'Başlat',
                            style: AppTypography.sfProRounded(
                              fontSize: 16,
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

              const SizedBox(height: 100), // Dock payı
            ],
          ),
        ),
      ),
    );
  }
}
