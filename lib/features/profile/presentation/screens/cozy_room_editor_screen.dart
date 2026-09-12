import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../widgets/parallax_room_canvas.dart';

/// 🪴 The Cozy Room - Odam Önizleme & Dinlenme Alanı
/// Sade, estetik ve dingin 2.5D izometrik oda deneyimi.
/// Yeni eşya ve kat modelleri hazırlanırken odayı saf ve temiz bir diorama olarak sergiler.
class CozyRoomEditorScreen extends StatelessWidget {
  const CozyRoomEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final isEn = lang == 'en';

    return ListenableBuilder(
      listenable: AchievementService.instance,
      builder: (context, _) {
        final service = AchievementService.instance;
        final roomState = service.roomState;
        final isFloor2 = roomState.activeFloor == 1;
        final focusXP = service.focusXP;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F1712) : const Color(0xFFFAFBF8),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              onPressed: () {
                AppHaptics.lightImpact();
                Navigator.of(context).pop();
              },
            ),
            centerTitle: true,
            title: Text(
              isEn ? 'The Cozy Room' : 'Odam',
              style: AppTypography.sfProRounded(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            actions: [
              // Sağ Üst: Toplam Odak Puanı
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF223528) : const Color(0xFFEBF3E8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF35523E) : const Color(0xFFD3E2CF),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          '$focusXP XP',
                          style: AppTypography.sfProRounded(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── 1. Kat Değiştirme Segmenti (1. Kat & 2. Kat Loft) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162319) : const Color(0xFFEDF3E9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF283D2D) : const Color(0xFFD6E4D1),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 1. Kat Butonu
                        Expanded(
                          child: BouncingWidget(
                            onTap: () {
                              AppHaptics.selectionClick();
                              service.setActiveRoomFloor(0);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !isFloor2
                                    ? (isDark ? const Color(0xFF243B2A) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: !isFloor2
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🏠', style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 6),
                                    Text(
                                      isEn ? '1st Floor' : '1. Kat',
                                      style: AppTypography.sfProRounded(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: !isFloor2
                                            ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                                            : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 2. Kat Butonu
                        Expanded(
                          child: BouncingWidget(
                            onTap: () {
                              AppHaptics.selectionClick();
                              service.setActiveRoomFloor(1);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isFloor2
                                    ? (isDark ? const Color(0xFF243B2A) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: isFloor2
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(roomState.isFloor2Unlocked ? '📚' : '🔒', style: const TextStyle(fontSize: 13)),
                                    const SizedBox(width: 6),
                                    Text(
                                      isEn ? '2nd Floor Loft' : '2. Kat Loft',
                                      style: AppTypography.sfProRounded(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: isFloor2
                                            ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                                            : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
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

                const SizedBox(height: 8),

                // ── 2. Canlı 3D İzometrik Parallax Tuvali ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isDark
                                ? [
                                    const Color(0xFF141F17),
                                    const Color(0xFF1A281E),
                                    const Color(0xFF152219),
                                  ]
                                : [
                                    const Color(0xFFFAFBF8),
                                    const Color(0xFFF4F7F1),
                                    const Color(0xFFE9F0E6),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: isDark ? const Color(0xFF283A2E) : const Color(0xFFD6E3D0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF102E19))
                                  .withValues(alpha: isDark ? 0.35 : 0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: ParallaxRoomCanvas(
                            roomState: roomState,
                            isInteractive: false,
                            enableParallax: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── 3. Alt Durum Bilgi Kartı ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF162319) : Colors.white).withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2B4030) : const Color(0xFFDCE7D6),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF285435).withValues(alpha: isDark ? 0.35 : 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('🎨', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isFloor2
                                    ? (isEn ? '2nd Floor: Study Loft' : '2. Kat: Çalışma Loftu')
                                    : (isEn ? '1st Floor: Cozy Room' : '1. Kat: Cozy Odam'),
                                style: AppTypography.sfProRounded(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isFloor2
                                    ? (isEn ? 'Unlocks after completing 1st floor items' : '1. kattaki eşyalar tamamlandığında açılır')
                                    : (isEn ? 'Focus to collect and place cozy items' : 'Odaklandıkça yeni eşyalar toplayıp yerleştireceksin'),
                                style: AppTypography.sfPro(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
