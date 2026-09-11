import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import 'achievement_detail_sheet.dart';
import 'modern_achievement_badge.dart';
import 'share_cards/share_card_picker_sheet.dart';

/// 🪴 The Cozy Room & Başarılar Bölümü (Profil Ekranı Bento Kartı)
class CozyDeskSection extends StatelessWidget {
  const CozyDeskSection({super.key});

  static const List<Map<String, dynamic>> _themeOptions = [
    {
      'key': 'pink',
      'labelTr': 'Pembe',
      'labelEn': 'Blush',
      'color': Color(0xFFFFC8DD),
    },
    {
      'key': 'purple',
      'labelTr': 'Mor',
      'labelEn': 'Lilac',
      'color': Color(0xFFCDB4DB),
    },
    {
      'key': 'blue',
      'labelTr': 'Mavi',
      'labelEn': 'Mavi',
      'color': Color(0xFFA2D2FF),
    },
    {
      'key': 'green',
      'labelTr': 'Yeşil',
      'labelEn': 'Matcha',
      'color': Color(0xFFA8D5BA),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final isEn = lang == 'en';

    return ListenableBuilder(
      listenable: AchievementService.instance,
      builder: (context, _) {
        final achievements = AchievementService.instance.achievements;
        final unlockedCount = AchievementService.instance.unlockedCount;
        final totalCount = AchievementService.instance.totalCount;
        final selectedTheme = AchievementService.instance.roomThemeColor;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF16231A).withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2C3E32).withValues(alpha: 0.8)
                  : const Color(0xFFDBE8D3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF102E19))
                    .withValues(alpha: isDark ? 0.35 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Başlık, Paylaş ve Sayaç ──
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF263D2E) : const Color(0xFFE5EEE2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cottage_rounded,
                      size: 19,
                      color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'The Cozy Room' : 'Odam',
                          style: AppTypography.sfProRounded(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          isEn ? 'Personalize & upgrade as you focus' : 'Odaklandıkça odan güzelleşir',
                          style: AppTypography.sfPro(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Paylaş Butonu
                  BouncingWidget(
                    onTap: () {
                      AppHaptics.lightImpact();
                      ShareCardPickerSheet.show(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF223528) : const Color(0xFFEAF2E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334F3D) : const Color(0xFFCFDFC9),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.ios_share_rounded,
                            size: 14,
                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isEn ? 'Share' : 'Paylaş',
                            style: AppTypography.sfProRounded(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sayaç Rozeti
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2C21) : const Color(0xFFE2EEE0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unlockedCount/$totalCount',
                      style: AppTypography.sfProRounded(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF255233),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── 2. Renk Teması Seçici Kapsüller ──
              Row(
                children: [
                  Text(
                    isEn ? 'THEME:' : 'TEMA:',
                    style: AppTypography.sfProRounded(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: _themeOptions.map((opt) {
                        final key = opt['key'] as String;
                        final isSelected = selectedTheme == key;
                        final color = opt['color'] as Color;
                        final label = isEn ? opt['labelEn'] as String : opt['labelTr'] as String;

                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: BouncingWidget(
                            onTap: () {
                              AppHaptics.selectionClick();
                              AchievementService.instance.setRoomThemeColor(key);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSelected ? 10 : 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: isDark ? 0.35 : 0.45)
                                    : (isDark
                                        ? const Color(0xFF1F2E23)
                                        : const Color(0xFFF0F4EC)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? Colors.white70 : const Color(0xFF102E19))
                                      : Colors.transparent,
                                  width: isSelected ? 1.4 : 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 5),
                                    Text(
                                      label,
                                      style: AppTypography.sfProRounded(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : const Color(0xFF102E19),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── 3. 2.5D İzometrik Oda Tuvali (The Cozy Room Canvas) ──
              Container(
                width: double.infinity,
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
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? const Color(0xFF283A2E) : const Color(0xFFD6E3D0),
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Katmanlı Oda Görünümü (800:600 Oranında)
                      AspectRatio(
                        aspectRatio: 800 / 600,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 1. Boş Oda Kabuğu (Zemin, Duvarlar, Diorama Kaidesi, Güneş Işığı)
                            Image.asset(
                              'assets/images/room/room_base.png',
                              fit: BoxFit.contain,
                            ),

                            // 2. Sabah Penceresi
                            Image.asset(
                              'assets/images/room/window_lv1.png',
                              fit: BoxFit.contain,
                            ),

                            // 3. Duvar Tablosu
                            Image.asset(
                              'assets/images/room/wall_decor_lv1.png',
                              fit: BoxFit.contain,
                            ),

                            // 4. Renk Temalı Eşyalar (Yumuşak AnimatedSwitcher ile Geçiş)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Image.asset(
                                'assets/images/room/rug_lv1_$selectedTheme.png',
                                key: ValueKey('rug_$selectedTheme'),
                                fit: BoxFit.contain,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Image.asset(
                                'assets/images/room/bed_lv1_$selectedTheme.png',
                                key: ValueKey('bed_$selectedTheme'),
                                fit: BoxFit.contain,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Image.asset(
                                'assets/images/room/desk_lv1_$selectedTheme.png',
                                key: ValueKey('desk_$selectedTheme'),
                                fit: BoxFit.contain,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Image.asset(
                                'assets/images/room/decor_lv1_$selectedTheme.png',
                                key: ValueKey('decor_$selectedTheme'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Oda Seviye & Bilgi Kapsülü (Alt Ortada Zarif Rozet)
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFF142017) : Colors.white)
                                .withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2A3D2F)
                                  : const Color(0xFFD3E0CD),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.eco_rounded,
                                size: 13,
                                color: Color(0xFF38553F),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isEn ? 'Level 1: Starter Room' : 'Seviye 1: Başlangıç Odası',
                                style: AppTypography.sfProRounded(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
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

              const SizedBox(height: 18),

              // ── 4. Başarı Rozetleri Şeridi ──
              Text(
                isEn ? 'ACHIEVEMENTS' : 'BAŞARI MADALYONLARI',
                style: AppTypography.sfProRounded(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF38553F),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: achievements.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final achv = achievements[index];
                    return ModernAchievementBadge(
                      achievement: achv,
                      size: 64,
                      showLabel: true,
                      onTap: () {
                        AppHaptics.lightImpact();
                        AchievementDetailSheet.show(context, achv);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
