import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/widgets/legal_policy_sheet.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/utils/date_time_utils.dart';
import 'edit_profile_screen.dart';
import '../../../planner/presentation/screens/welcome_screen.dart';
import '../../../planner/presentation/screens/widget_customizer_screen.dart';
import '../../../../core/widgets/vintage_framed_avatar.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../../clubs/providers/club_provider.dart';

/// 👤 Calenda — Minimalist Profil, Haftalık Ritim ve Hesap Merkezi
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _textPrimary = AppColors.lightTextPrimary;
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  /// Kullanıcının kayıt tarihini seçili dil formatında döndürür
  String _getMemberSinceText(BuildContext context, DateTime? createdAt) {
    final date = createdAt ?? DateTime(2026, 9, 1);
    final l10n = context.l10n;
    final monthName = DateTimeUtils.getMonthName(date, locale: l10n.locale.languageCode);
    return l10n.memberSince(monthName, date.year);
  }

  /// 💬 Uygulama İçin Geri Bildirim Formu (Minimalist, Translucent, Emojisiz & Supabase Entegreli)
  void _showFeedbackSheet(BuildContext context, UserProfile user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FeedbackBottomSheet(
        user: user,
        isDark: isDark,
        primaryText: primaryText,
        mutedText: mutedText,
        ctaColor: ctaColor,
      ),
    );
  }


  /// 🌐 Dil Seçim Bottom Sheet'i (Türkçe & English)
  void _showLanguagePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;
    final currentLang = context.read<LocaleProvider>().locale.languageCode;
    final l10n = context.l10n;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedText.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.chooseLanguage,
                style: AppTypography.sfProRounded(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                ctx: ctx,
                title: 'Türkçe',
                subtitle: 'Turkish',
                flag: '🇹🇷',
                isSelected: currentLang == 'tr',
                isDark: isDark,
                primaryText: primaryText,
                mutedText: mutedText,
                ctaColor: ctaColor,
                onTap: () async {
                  AppHaptics.selectionClick();
                  await context.read<LocaleProvider>().setLanguage('tr');
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 10),
              _buildLanguageOption(
                ctx: ctx,
                title: 'English',
                subtitle: 'İngilizce',
                flag: '🇬🇧',
                isSelected: currentLang == 'en',
                isDark: isDark,
                primaryText: primaryText,
                mutedText: mutedText,
                ctaColor: ctaColor,
                onTap: () async {
                  AppHaptics.selectionClick();
                  await context.read<LocaleProvider>().setLanguage('en');
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext ctx,
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    required bool isDark,
    required Color primaryText,
    required Color mutedText,
    required Color ctaColor,
    required VoidCallback onTap,
  }) {
    return BouncingWidget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF284834) : const Color(0xFFE8F1E6))
              : (isDark ? const Color(0xFF1B2F23) : const Color(0xFFF1F5EE)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ctaColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.sfProRounded(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.sfPro(
                      fontSize: 12,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: ctaColor, size: 20),
          ],
        ),
      ),
    );
  }

  /// 🚪 Hesaptan Çıkış Onay Diyaloğu
  void _showLogoutDialog(BuildContext context, PlannerProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.signOut,
          style: AppTypography.sfProRounded(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primaryText,
          ),
        ),
        content: Text(
          l10n.signOutConfirm,
          style: AppTypography.sfPro(fontSize: 14, color: mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: AppTypography.sfProRounded(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: mutedText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                context.read<ClubProvider>().clear();
              } catch (_) {}
              await provider.logoutUser();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 350),
                    pageBuilder: (context, a1, a2) => const WelcomeScreen(),
                    transitionsBuilder: (context, a1, a2, child) =>
                        FadeTransition(opacity: a1, child: child),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ctaColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              l10n.signOut,
              style: AppTypography.sfProRounded(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🗑️ Hesabı ve Tüm Verileri Sil Onay Diyaloğu
  void _showDeleteAccountDialog(BuildContext context, PlannerProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD9534F), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.deleteAccount,
                style: AppTypography.sfProRounded(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteAccountConfirm,
          style: AppTypography.sfPro(
            fontSize: 13.0,
            color: mutedText,
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: AppTypography.sfProRounded(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: mutedText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final success = await provider.deleteAccountAndAllData();
                    if (context.mounted) {
                      if (success) {
                        Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 350),
                            pageBuilder: (context, a1, a2) => const WelcomeScreen(),
                            transitionsBuilder: (context, a1, a2, child) =>
                                FadeTransition(opacity: a1, child: child),
                          ),
                          (route) => false,
                        );
                      } else {
                        AestheticSnackBar.showError(
                          context,
                          l10n.isTurkish
                              ? 'Silme işlemi sırasında bir hata oluştu.'
                              : 'An error occurred while deleting account.',
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9534F),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    l10n.delete,
                    style: AppTypography.sfProRounded(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // (Haftalık Ritim kartı aşağıda _WeeklyRhythmSection olarak ayrıldı)

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: Selector<PlannerProvider, UserProfile>(
          selector: (_, p) => p.userProfile,
          builder: (context, user, _) {
            final cleanAnimal = user.avatarAnimal
                .replaceAll('01_', '')
                .replaceAll('02_', '')
                .replaceAll('03_', '')
                .replaceAll('04_', '')
                .replaceAll('05_', '')
                .replaceAll('06_', '')
                .replaceAll('07_', '');

            final animalAsset = 'assets/avatars/$cleanAnimal.webp';
            final accessoryAsset = user.avatarAccessory != 'none'
                ? 'assets/accessories/${user.avatarAccessory}.webp'
                : null;

            final hasValidUsername = user.username.isNotEmpty &&
                user.username != 'calenda_user' &&
                user.username != 'apple_user' &&
                user.username != 'misafir';
            final displayUsername = hasValidUsername ? '@${user.username}' : '';

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top > 0 ? 3.0 : 8.0,
                20,
                MediaQuery.of(context).padding.bottom + 84,
              ),
              children: [
                // ─── 1. ÜST AKSİYON: PROFİLİ DÜZENLE (İKONSUZ, SADECE METİN) ───
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: BouncingWidget(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF142814))
                                  .withValues(alpha: isDark ? 0.20 : 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          context.l10n.editProfile,
                          style: AppTypography.sfProRounded(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ─── 2. PROFİL RESMİ (ÜST ORTA, ÇERÇEVELİ, ARKA KARTSIZ) ───
                Center(
                  child: Column(
                    children: [
                      // Antika Vintage Çerçeveli Avatar
                      VintageFramedAvatar(
                        animalAsset: animalAsset,
                        accessoryAsset: accessoryAsset,
                        backgroundColor: AppColors.hexToColor(user.avatarBgColor),
                        height: 135,
                      ),
                      const SizedBox(height: 14),

                      // İsim Soyisim (varsa) ve Kullanıcı Adı
                      if (user.firstName.trim().isNotEmpty) ...[
                        Text(
                          '${user.firstName} ${user.lastName}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sfProRounded(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                        if (displayUsername.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            displayUsername,
                            style: AppTypography.sfPro(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: mutedText,
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          displayUsername.isNotEmpty
                              ? displayUsername
                              : (user.displayName.isNotEmpty ? user.displayName : ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sfProRounded(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                      ],

                      const SizedBox(height: 5),

                      // Kayıt Olunan Tarih
                      Text(
                        _getMemberSinceText(context, user.createdAt),
                        style: AppTypography.sfPro(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ─── 3. HAFTALIK RİTİM (KARTSIZ, DOĞRUDAN PROFİLE ENTEGRE ÇİZGİ TABLOSU) ───
                _WeeklyRhythmSection(
                  isDark: isDark,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  ctaColor: ctaColor,
                ),

                const SizedBox(height: 24),

                // ─── 4. HESAP & UYGULAMA İŞLEMLERİ ───
                // Ana Ekran Widget'ı Ekle
                _buildSettingTile(
                  title: context.l10n.addWidget,
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WidgetCustomizerScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Yardım & Geri Bildirim
                _buildSettingTile(
                  title: context.l10n.helpAndFeedback,
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () => _showFeedbackSheet(context, user),
                ),

                const SizedBox(height: 10),

                // Dil Seçimi / Language
                _buildSettingTile(
                  title: context.l10n.language,
                  trailingText: context.l10n.currentLanguageName,
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () => _showLanguagePicker(context),
                ),

                const SizedBox(height: 10),

                // Hesaptan Çıkış Yap
                _buildSettingTile(
                  title: context.l10n.signOut,
                  titleColor: const Color(0xFFC47B89),
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () => _showLogoutDialog(context, context.read<PlannerProvider>()),
                ),

                const SizedBox(height: 10),

                // Hesabı ve Verileri Sil (En Altta)
                _buildSettingTile(
                  title: context.l10n.deleteAccount,
                  titleColor: const Color(0xFFD9534F),
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () => _showDeleteAccountDialog(context, context.read<PlannerProvider>()),
                ),

                const SizedBox(height: 28),

                // Sürüm ve Yasal Bağlantılar (Apple Guideline 5.1.1(i) & 1.5 uyumlu minimalist footer)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Calenda • ${context.l10n.version} 1.0.0',
                        style: AppTypography.sfPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: mutedText.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => LegalPolicySheet.show(context, initialTab: LegalTab.privacy),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                              child: Text(
                                context.l10n.privacyPolicy,
                                style: AppTypography.sfPro(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: mutedText.withValues(alpha: 0.85),
                                  decoration: TextDecoration.underline,
                                  decorationColor: mutedText.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '•',
                              style: AppTypography.sfPro(
                                fontSize: 11,
                                color: mutedText.withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => LegalPolicySheet.show(context, initialTab: LegalTab.terms),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                              child: Text(
                                context.l10n.termsOfUse,
                                style: AppTypography.sfPro(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: mutedText.withValues(alpha: 0.85),
                                  decoration: TextDecoration.underline,
                                  decorationColor: mutedText.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    String? trailingText,
    Color? titleColor,
    required bool isDark,
    required Color cardColor,
    required Color primaryText,
    required Color mutedText,
    required VoidCallback onTap,
  }) {
    return BouncingWidget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF142814))
                  .withValues(alpha: isDark ? 0.18 : 0.035),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.sfProRounded(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: titleColor ?? primaryText,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null) ...[
                  Text(
                    trailingText,
                    style: AppTypography.sfPro(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: mutedText,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: mutedText.withValues(alpha: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// ⚡ _WeeklyRhythmSection — Apple Health & Aesthetic Kart Formatında Haftalık Ritim
// ─────────────────────────────────────────────────────────────────────────────
// ⚡ _WeeklyRhythmSection — Apple Health & Aesthetic Kart Formatında Haftalık Ritim
// ─────────────────────────────────────────────────────────────────────────────
class _WeeklyRhythmSection extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  final Color mutedText;
  final Color ctaColor;

  const _WeeklyRhythmSection({
    required this.isDark,
    required this.primaryText,
    required this.mutedText,
    required this.ctaColor,
  });

  String _formatDuration(BuildContext context, int minutes) {
    final l10n = context.l10n;
    if (minutes <= 0) return '0 ${l10n.minutesShort}';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '$mins ${l10n.minutesShort}';
    if (mins == 0) return '$hours ${l10n.hoursShort}';
    return '$hours ${l10n.hoursShort} $mins ${l10n.minutesShort}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlannerProvider>();
    final l10n = context.l10n;
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: todayIndex));
    final dayNames = List.generate(
      7,
      (i) => DateTimeUtils.getShortDayName(i + 1, locale: l10n.locale.languageCode),
    );

    final dayMinutesList = <int>[];
    int maxMins = 0;

    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final mins = provider.getFocusMinutesForDay(d);
      dayMinutesList.add(mins);
      if (mins > maxMins) maxMins = mins;
    }

    final totalWeekMinutes = dayMinutesList.fold<int>(0, (sum, m) => sum + m);

    // Çizgi doluluk oranı referans tavanı (en az 60 dk)
    final scaleMax = maxMins > 60 ? maxMins : 60;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF14241B).withValues(alpha: 0.38)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.85),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 1. BAŞLIK ───
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.weeklyRhythm,
                style: AppTypography.sfProRounded(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                totalWeekMinutes > 0
                    ? (l10n.isTurkish
                        ? 'Toplam: ${_formatDuration(context, totalWeekMinutes)} odak'
                        : 'Total: ${_formatDuration(context, totalWeekMinutes)} focused')
                    : (l10n.isTurkish
                        ? 'Bu hafta henüz odak kaydı yok'
                        : 'No focus recorded this week'),
                style: AppTypography.sfPro(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: mutedText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ─── 2. 7 GÜN KAPSÜL GRAFİK TABLOSU (PZT - PAZ) ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final isToday = index == todayIndex;
              final mins = dayMinutesList[index];
              final ratio = (mins / scaleMax).clamp(0.0, 1.0);
              const trackHeight = 78.0;
              const capsuleWidth = 16.0;
              final fillHeight = mins > 0 ? (ratio * trackHeight).clamp(10.0, trackHeight) : 0.0;

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sütun Üstü Değer Göstergesi (Tüm günlerin odaklanma süresi)
                    SizedBox(
                      height: 20,
                      child: Center(
                        child: Text(
                          _formatDuration(context, mins),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: isToday
                                ? FontWeight.w800
                                : (mins > 0 ? FontWeight.w700 : FontWeight.w500),
                            color: isToday
                                ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                                : (mins > 0
                                    ? (isDark ? const Color(0xFF66E384) : const Color(0xFF2E653F))
                                    : mutedText.withValues(alpha: 0.55)),
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Kapsül Dikey Bar (Doluluk & Arka Plan)
                    Container(
                      width: capsuleWidth,
                      height: trackHeight,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C2E22)
                            : const Color(0xFFEBF1EA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF263D2E)
                              : const Color(0xFFE2EBE0),
                          width: 1.0,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // 0 dk için zarif alt taban çizgisi
                          if (mins == 0)
                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 6,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : const Color(0xFFCCD8CA),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                          // Dolu Odak Süresi Kapsülü
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            width: capsuleWidth,
                            height: fillHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isDark
                                    ? [const Color(0xFF224830), const Color(0xFF4C875F)]
                                    : [const Color(0xFF234B2D), const Color(0xFF4D7558)],
                              ),
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: mins > 0
                                  ? [
                                      BoxShadow(
                                        color: (isDark
                                                ? const Color(0xFF55C77A)
                                                : const Color(0xFF0F2C14))
                                            .withValues(alpha: 0.20),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Gün İsmi (Pzt, Sal, ...)
                    Text(
                      dayNames[index],
                      style: AppTypography.sfPro(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isToday
                            ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                            : mutedText,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Bugün Noktası
                    Container(
                      width: 4.5,
                      height: 4.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday
                            ? (isDark ? const Color(0xFF66E384) : const Color(0xFF2E7D32))
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBottomSheet extends StatefulWidget {
  final UserProfile user;
  final bool isDark;
  final Color primaryText;
  final Color mutedText;
  final Color ctaColor;

  const _FeedbackBottomSheet({
    required this.user,
    required this.isDark,
    required this.primaryText,
    required this.mutedText,
    required this.ctaColor,
  });

  @override
  State<_FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<_FeedbackBottomSheet> {
  late final TextEditingController _feedbackController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      AestheticSnackBar.showWarning(
        context,
        l10n.isTurkish
            ? 'Lütfen bir geri bildirim mesajı yazın.'
            : 'Please write a feedback message.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final senderName = widget.user.username.isNotEmpty
        ? widget.user.username
        : (widget.user.displayName.isNotEmpty ? widget.user.displayName : null);

    await SupabaseService.instance.submitFeedback(
      content: text,
      username: senderName,
      userEmail: widget.user.email.isNotEmpty ? widget.user.email : null,
    );

    if (mounted) {
      Navigator.pop(context);
      AestheticSnackBar.showSuccess(
        context,
        l10n.feedbackReceived,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF14241B).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: widget.isDark ? 0.20 : 0.85),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.helpAndFeedback,
            style: AppTypography.sfProRounded(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: widget.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.isTurkish
                ? 'Sorularınız veya doğrudan destek için: calenda.support@gmail.com'
                : 'For questions or direct support: calenda.support@gmail.com',
            style: AppTypography.sfPro(
              fontSize: 12.0,
              color: widget.mutedText.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _feedbackController,
            maxLines: 5,
            minLines: 4,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.sfPro(fontSize: 14.0, color: widget.primaryText),
            decoration: InputDecoration(
              hintText: l10n.feedbackHint,
              hintStyle: AppTypography.sfPro(
                fontSize: 13.0,
                color: widget.mutedText.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: widget.isDark
                  ? const Color(0xFF1A2F23).withValues(alpha: 0.70)
                  : const Color(0xFFF4F7F2).withValues(alpha: 0.80),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: widget.isDark ? const Color(0xFF2E4D37) : const Color(0xFFD8E4D5),
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: widget.isDark ? const Color(0xFF2E4D37) : const Color(0xFFD8E4D5),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: widget.ctaColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 18),
          BouncingWidget(
            onTap: _isSubmitting ? null : _submit,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: widget.ctaColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        l10n.submit,
                        style: AppTypography.sfProRounded(
                          fontSize: 16.0,
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
  }
}
