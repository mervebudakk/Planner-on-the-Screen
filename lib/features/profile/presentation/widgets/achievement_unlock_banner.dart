import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/achievement.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import 'achievement_detail_sheet.dart';

/// 🎊 Başarı Kazanım Bildirim Kartı (Non-Intrusive Floating Banner)
class AchievementUnlockBanner {
  static void show(BuildContext context, Achievement achievement) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    AppHaptics.mediumImpact();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final isEn = lang == 'en';

    final screenWidth = MediaQuery.maybeSizeOf(context)?.width ?? 400.0;
    final horizontalMargin = screenWidth > 480
        ? (screenWidth - 420) / 2
        : (screenWidth < 360 ? 12.0 : 16.0);

    final bottomInset = MediaQuery.maybePaddingOf(context)?.bottom ?? 0.0;
    final viewInsetsBottom = MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0.0;
    final dockTop = (bottomInset > 0 ? (bottomInset * 0.45) : 8.0) + 60.0;
    final baseBottomMargin = dockTop + 14.0;
    final bottomMargin = viewInsetsBottom > 0 ? (viewInsetsBottom + 12.0) : baseBottomMargin;

    final accentColor = isDark ? const Color(0xFF7FE29E) : const Color(0xFF266736);
    final iconBgColor = accentColor.withValues(alpha: isDark ? 0.22 : 0.12);
    final bgColor = isDark
        ? const Color(0xFF1B261F).withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.96);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFDFE8DF).withValues(alpha: 0.90);
    final primaryTextColor = isDark ? const Color(0xFFF0F5F1) : const Color(0xFF1B281E);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, bottomMargin),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF14241B))
                    .withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    achievement.icon,
                    size: 18,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? '🎉 Achievement Unlocked!' : '🎉 Yeni Başarı Açıldı!',
                      style: AppTypography.sfProRounded(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      achievement.getTitle(lang),
                      style: AppTypography.sfProRounded(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BouncingWidget(
                onTap: () {
                  messenger.hideCurrentSnackBar();
                  AchievementDetailSheet.show(context, achievement);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.24 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentColor.withValues(alpha: isDark ? 0.45 : 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEn ? 'View' : 'İncele',
                        style: AppTypography.sfProRounded(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
