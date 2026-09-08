import 'dart:async';
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
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../../clubs/providers/club_provider.dart';
import '../../../planner/presentation/screens/welcome_screen.dart';
import '../../../planner/presentation/screens/widget_customizer_screen.dart';
import 'edit_profile_screen.dart';

/// ⚙️ Calenda — Uygulama ve Hesap Ayarları Ekranı
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _textPrimary = AppColors.lightTextPrimary;
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  /// 💬 Geri Bildirim Formu
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

  /// 🌐 Dil Seçim Bottom Sheet'i (Yalnızca kendi orijinal adıyla)
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
                flag: '🇹🇷',
                isSelected: currentLang == 'tr',
                isDark: isDark,
                primaryText: primaryText,
                mutedText: mutedText,
                ctaColor: ctaColor,
                onTap: () async {
                  AppHaptics.selectionClick();
                  await context.read<LocaleProvider>().setLanguage('tr');
                  if (context.mounted) {
                    final planner = context.read<PlannerProvider>();
                    final newConfig = planner.themeConfig.copyWith(
                      titleText: 'Bugünün Planı',
                      weeklyTitleText: 'Haftalık Planım',
                    );
                    unawaited(planner.updateThemeConfig(newConfig));
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 10),
              _buildLanguageOption(
                ctx: ctx,
                title: 'English',
                flag: '🇬🇧',
                isSelected: currentLang == 'en',
                isDark: isDark,
                primaryText: primaryText,
                mutedText: mutedText,
                ctaColor: ctaColor,
                onTap: () async {
                  AppHaptics.selectionClick();
                  await context.read<LocaleProvider>().setLanguage('en');
                  if (context.mounted) {
                    final planner = context.read<PlannerProvider>();
                    final newConfig = planner.themeConfig.copyWith(
                      titleText: "Today's Schedule",
                      weeklyTitleText: 'My Weekly Plan',
                    );
                    unawaited(planner.updateThemeConfig(newConfig));
                  }
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
    String? subtitle,
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.sfProRounded(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.sfPro(
                        fontSize: 12,
                        color: mutedText,
                      ),
                    ),
                  ],
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final user = context.watch<PlannerProvider>().userProfile;
    final l10n = context.l10n;

    return AppleAmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // ─── ÜST BAR: GERİ BUTONU & BAŞLIK ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    BouncingWidget(
                      onTap: () {
                        AppHaptics.lightImpact();
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: isDark
                              ? Border.all(color: AppColors.darkBorder, width: 1.0)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF142814))
                                  .withValues(alpha: isDark ? 0.20 : 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: primaryText,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          l10n.settings,
                          style: AppTypography.sfProRounded(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 42), // Dengeleme boşluğu
                  ],
                ),
              ),

              // ─── AYARLAR LİSTESİ ───
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  children: [
                    // Profili Düzenle
                    _buildSettingTile(
                      icon: Icons.person_outline_rounded,
                      title: l10n.editProfile,
                      isDark: isDark,
                      cardColor: cardColor,
                      primaryText: primaryText,
                      mutedText: mutedText,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // Dil Seçimi / Language
                    _buildSettingTile(
                      icon: Icons.language_rounded,
                      title: l10n.language,
                      trailingText: l10n.currentLanguageName,
                      isDark: isDark,
                      cardColor: cardColor,
                      primaryText: primaryText,
                      mutedText: mutedText,
                      onTap: () => _showLanguagePicker(context),
                    ),

                    const SizedBox(height: 10),

                    // Ana Ekran Widget'ı Ekle
                    _buildSettingTile(
                      icon: Icons.widgets_outlined,
                      title: l10n.addWidget,
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
                      icon: Icons.chat_bubble_outline_rounded,
                      title: l10n.helpAndFeedback,
                      isDark: isDark,
                      cardColor: cardColor,
                      primaryText: primaryText,
                      mutedText: mutedText,
                      onTap: () => _showFeedbackSheet(context, user),
                    ),

                    const SizedBox(height: 20),

                    // Hesaptan Çıkış Yap
                    _buildSettingTile(
                      icon: Icons.logout_rounded,
                      title: l10n.signOut,
                      titleColor: const Color(0xFFC47B89),
                      isDark: isDark,
                      cardColor: cardColor,
                      primaryText: primaryText,
                      mutedText: mutedText,
                      onTap: () => _showLogoutDialog(context, context.read<PlannerProvider>()),
                    ),

                    const SizedBox(height: 10),

                    // Hesabı ve Verileri Sil
                    _buildSettingTile(
                      icon: Icons.delete_outline_rounded,
                      title: l10n.deleteAccount,
                      titleColor: const Color(0xFFD9534F),
                      isDark: isDark,
                      cardColor: cardColor,
                      primaryText: primaryText,
                      mutedText: mutedText,
                      onTap: () => _showDeleteAccountDialog(context, context.read<PlannerProvider>()),
                    ),

                    const SizedBox(height: 32),

                    // Sürüm ve Yasal Bağlantılar
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Calenda • ${l10n.version} 1.0.0',
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
                                    l10n.privacyPolicy,
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
                                  style: TextStyle(
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
                                    l10n.termsOfUse,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
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
          children: [
            Icon(
              icon,
              size: 20,
              color: titleColor ?? primaryText.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTypography.sfProRounded(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? primaryText,
                ),
              ),
            ),
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
