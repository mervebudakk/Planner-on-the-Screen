import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../providers/planner_provider.dart';
import 'widget_customizer_screen.dart';
import 'welcome_screen.dart';

/// 🍎 Calenda — Apple Bento & HIG Standartlarında Araçlar ve Ayarlar Ekranı
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _cardBgDark = Color(0xFF14241B);
  static const Color _textPrimary = Color(0xFF1A2B1D);
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  static List<BoxShadow> _cardShadow(bool isDark, {bool strong = false}) {
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF142814))
            .withValues(alpha: isDark ? (strong ? 0.30 : 0.22) : (strong ? 0.08 : 0.05)),
        blurRadius: strong ? 20 : 14,
        offset: const Offset(0, 5),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? _cardBgDark : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE8EFE5);

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        final user = provider.userProfile;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: primaryText,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Araçlar & Ayarlar',
              style: AppTypography.sfProRounded(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryText,
              ),
            ),
          ),
          body: AppleAmbientBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ─── 1. BÖLÜM: HESAP & PROFİL (EN ÜSTTE) ───
                  _buildSectionHeader('HESAP', mutedText),
                  const SizedBox(height: 8),

                  // 👤 1.1 Hesap Bento Kartı
                  _buildProfileCard(context, provider, user, isDark, cardColor, primaryText, mutedText, dividerColor),

                  const SizedBox(height: 22),

                  // ─── 2. BÖLÜM: ARAÇLAR ───
                  _buildSectionHeader('ARAÇLAR', mutedText),
                  const SizedBox(height: 8),

                  // 📱 2.1 Widget Özelleştirici Bento Kartı
                  BouncingWidget(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WidgetCustomizerScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(28),
                        border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                        boxShadow: _cardShadow(isDark),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkPrimary : _cta,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.widgets_rounded,
                              color: Colors.white,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ana Ekran Widget\'ı',
                                  style: AppTypography.sfProRounded(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Günlük & Haftalık widget, saydamlık ve renkler',
                                  style: AppTypography.sfPro(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: mutedText,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ─── 3. BÖLÜM: AYARLAR & BİLGİ ───
                  _buildSectionHeader('BİLGİ & SÜRÜM', mutedText),
                  const SizedBox(height: 8),

                  // ℹ️ 3.1 Bilgi & Sürüm Bento Kartı
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                      boxShadow: _cardShadow(isDark),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF22342A) : const Color(0xFFEAF2E8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.history_toggle_off_rounded,
                                  color: isDark ? const Color(0xFFB4D8C2) : const Color(0xFF102E19),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Geçmiş Veri Saklama',
                                  style: AppTypography.sfPro(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                              Text(
                                '1 Hafta',
                                style: AppTypography.sfPro(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFFB4D8C2) : _cta,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 18,
                          indent: 50,
                          color: dividerColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF22342A) : const Color(0xFFEAF2E8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.verified_outlined,
                                  color: isDark ? const Color(0xFFB4D8C2) : const Color(0xFF102E19),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Sürüm',
                                  style: AppTypography.sfPro(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                              Text(
                                AppConstants.appVersion,
                                style: AppTypography.sfPro(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        title,
        style: AppTypography.sfPro(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 👤 Kullanıcı Profil Kartı
  Widget _buildProfileCard(
    BuildContext context,
    PlannerProvider provider,
    UserProfile user,
    bool isDark,
    Color cardColor,
    Color primaryText,
    Color mutedText,
    Color dividerColor,
  ) {
    if (user.isLoggedIn) {
      final words = user.name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final String initials;
      if (words.length >= 2) {
        initials = '${words.first[0]}${words.last[0]}'.toUpperCase();
      } else if (words.isNotEmpty && words.first.isNotEmpty) {
        initials = words.first[0].toUpperCase();
      } else {
        initials = 'MB';
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
          boxShadow: _cardShadow(isDark),
        ),
        child: Row(
          children: [
            // 🌿 Koyu Matcha Yeşili Baş Harf (İsim & Soyisim) Avatarı
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimary : const Color(0xFF102E19),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.darkPrimary : const Color(0xFF102E19)).withValues(alpha: isDark ? 0.35 : 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppTypography.sfProRounded(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.trim(),
                    style: AppTypography.sfProRounded(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email.isNotEmpty
                        ? user.email
                        : (user.isLoggedIn ? 'Kişisel Profil' : 'Misafir Kullanıcı'),
                    style: AppTypography.sfPro(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
                // 🔴 Kırmızı Çıkış Butonu (Sade ve Zarif İkon Buton)
                BouncingWidget(
                  onTap: () => _showLogoutConfirmDialog(context, provider),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.18 : 0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.35 : 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🗑️ Hesabımı ve Verilerimi Sil Butonu (Apple Kural 5.1.1(v) Uyumlu)
          BouncingWidget(
            onTap: () => _showDeleteAccountConfirmDialog(context, provider),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.28 : 0.16),
                  width: 1.1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.20 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFFEF4444),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hesabımı ve Verilerimi Sil',
                          style: AppTypography.sfPro(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        Text(
                          'Buluttaki tüm planları ve hesabı kalıcı sil',
                          style: AppTypography.sfPro(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFFE57373) : const Color(0xFFB91C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: const Color(0xFFEF4444).withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
          boxShadow: _cardShadow(isDark),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isDark ? const Color(0xFF22342A) : Colors.black.withValues(alpha: 0.05),
              child: Icon(
                Icons.person_outline_rounded,
                size: 22,
                color: isDark ? const Color(0xFFB4D8C2) : mutedText,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Misafir Kullanıcı',
                    style: AppTypography.sfProRounded(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Veriler yerel cihazınızda saklanır',
                    style: AppTypography.sfPro(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
            BouncingWidget(
              onTap: () => _showLoginBottomSheet(context, provider, isDark, primaryText),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimary : _cta,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Giriş Yap',
                  style: AppTypography.sfPro(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showLoginBottomSheet(
    BuildContext context,
    PlannerProvider provider,
    bool isDark,
    Color primaryText,
  ) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final navBarPadding = MediaQuery.of(ctx).viewPadding.bottom;

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: isDark ? const Color(0xFF14241B).withValues(alpha: 0.98) : const Color(0xFFF8FAF5).withValues(alpha: 0.98),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: bottomInset > 0 ? bottomInset + 16 : navBarPadding + 24,
              ),
              child: SafeArea(
                top: false,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 38,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                    // Başlık ve Açıklama
                    Text(
                      'Giriş Yap',
                      style: AppTypography.sfProRounded(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Planlarınızı ve tercihlerinizi anında kişiselleştirin',
                      style: AppTypography.sfPro(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFFA1C4AA) : const Color(0xFF5A7A62),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── 1. APPLE İLE GİRİŞ KARTI ──
                    BouncingWidget(
                      onTap: () async {
                        try {
                          final success = await provider.signInWithApple();
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            if (success) {
                              _showWelcomeSnackBar(context, provider.userProfile.name, isDark);
                            }
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            AestheticSnackBar.showWarning(context, 'Apple servisine bağlanırken bir hata oluştu.');
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D1D1F),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                color: Colors.white12,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.apple, size: 26, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Apple ile Devam Et',
                                    style: AppTypography.sfProRounded(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Gizli ve tek tıkla profilini bağla',
                                    style: AppTypography.sfPro(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFD1D1D6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── 2. GOOGLE İLE YENİLİKÇİ VE TEMATİK BENTO KARTI ──
                    BouncingWidget(
                      onTap: () async {
                        try {
                          final success = await provider.signInWithGoogle();
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            if (success) {
                              _showWelcomeSnackBar(context, provider.userProfile.name, isDark);
                            }
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            AestheticSnackBar.showWarning(context, 'Google servisine bağlanmak için uygulamayı yeniden başlatın (q → flutter run) 🌿');
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [const Color(0xFF1E3928), const Color(0xFF14261B)]
                                : [const Color(0xFFEAF3E7), const Color(0xFFF6FAF3)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? const Color(0xFF33583D) : const Color(0xFFD4E6D1),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF0E260A))
                                  .withValues(alpha: isDark ? 0.28 : 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 🌟 Google Logosu için Zarif Yuvarlak Kapsül
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF122419) : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: _GoogleLogo(size: 23),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // İki Satırlı Zengin Metin Bloğu
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Google ile Devam Et',
                                    style: AppTypography.sfProRounded(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      color: primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Hızlı profil oluştur & takvimi bağla',
                                    style: AppTypography.sfPro(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFFA1C4AA) : const Color(0xFF5A7A62),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Sağ Ok Kapsülü
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white12 : const Color(0xFF0E260A).withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: isDark ? Colors.white : _cta,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── VEYA AYIRACI ──
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? Colors.white12 : const Color(0xFFDCE8DA), thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'VEYA SADECE İSİMLE',
                            style: AppTypography.sfPro(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF7A9981) : const Color(0xFF6E8573),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? Colors.white12 : const Color(0xFFDCE8DA), thickness: 1)),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── 2. ŞİFRESİZ & FORMSUZ İSİM ALANI (Sadece "Adınız Soyadınız") ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3526).withValues(alpha: 0.7) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFDCE8DA),
                          width: 1.3,
                        ),
                      ),
                      child: TextFormField(
                        controller: nameController,
                        style: AppTypography.sfPro(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Adınız Soyadınız',
                          hintStyle: AppTypography.sfPro(
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                          icon: Icon(
                            Icons.person_outline_rounded,
                            size: 22,
                            color: isDark ? const Color(0xFFA1C4AA) : const Color(0xFF5A7A62),
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Lütfen adınızı girin' : null,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Giriş Yap Butonu
                    BouncingWidget(
                      onTap: () {
                        if (!formKey.currentState!.validate()) return;
                        final name = nameController.text.trim();
                        provider.loginUser(
                          name: name,
                          email: '',
                        );
                        Navigator.pop(ctx);
                        _showWelcomeSnackBar(context, name, isDark);
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkPrimary : _cta,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Center(
                          child: Text(
                            'Giriş Yap',
                            style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  },
);
}

  void _showWelcomeSnackBar(BuildContext context, String name, bool isDark) {
    AestheticSnackBar.showSuccess(context, 'Hoş geldiniz, $name! 🌿');
  }

  void _showLogoutConfirmDialog(BuildContext context, PlannerProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF14241B) : const Color(0xFFF9FAF7);
    final primaryText = isDark ? AppColors.darkTextPrimary : const Color(0xFF102E19);
    final subtitleText = isDark ? const Color(0xFFA1C4AA) : const Color(0xFF38553F);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            color: dialogBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFDCE8DA),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔴 Şık Kırmızı Çıkış İkon Rozeti
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),

              // 📝 Başlık
              Text(
                'Çıkış Yap',
                style: AppTypography.sfProRounded(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 8),

              // 📄 Açıklama
              Text(
                'Hesabınızdan çıkış yapmak istediğinize emin misiniz? Planlarınız cihazınızda güvenle saklanır.',
                textAlign: TextAlign.center,
                style: AppTypography.sfPro(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: subtitleText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 🔘 Butonlar: Vazgeç ve Çıkış Yap
              Row(
                children: [
                  Expanded(
                    child: BouncingWidget(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3526) : const Color(0xFFE8F0E5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFD0E1CD),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Vazgeç',
                            style: AppTypography.sfPro(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BouncingWidget(
                      onTap: () {
                        provider.logoutUser();
                        Navigator.pop(ctx);
                        AestheticSnackBar.showInfo(context, 'Oturum kapatıldı.');
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Çıkış Yap',
                            style: AppTypography.sfPro(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
  }

  void _showDeleteAccountConfirmDialog(BuildContext context, PlannerProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF14241B) : Colors.white;
    final primaryText = isDark ? AppColors.darkTextPrimary : const Color(0xFF1B2E20);
    final subtitleText = isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280);

    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: dialogBg,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔴 Kırmızı Çöp Kutusu İkon Rozeti
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: Color(0xFFEF4444),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 📝 Başlık
                    Text(
                      'Hesabı ve Verileri Sil',
                      style: AppTypography.sfProRounded(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Açıklama
                    Text(
                      'Hesabınızı ve hesabınıza bağlı tüm takvim, rutin ve profil verilerini kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz derhal imha edilir.',
                      textAlign: TextAlign.center,
                      style: AppTypography.sfPro(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: subtitleText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔘 Butonlar: Vazgeç ve Kalıcı Olarak Sil
                    Row(
                      children: [
                        Expanded(
                          child: BouncingWidget(
                            onTap: isDeleting ? () {} : () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E3526) : const Color(0xFFE8F0E5),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFD0E1CD),
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Vazgeç',
                                  style: AppTypography.sfPro(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BouncingWidget(
                            onTap: isDeleting
                                ? () {}
                                : () async {
                                    setDialogState(() => isDeleting = true);
                                    final success = await provider.deleteAccountAndAllData();
                                    if (!ctx.mounted) return;
                                    Navigator.pop(ctx);

                                    if (context.mounted) {
                                      if (success) {
                                        Navigator.of(context).pushAndRemoveUntil(
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(milliseconds: 400),
                                            pageBuilder: (context, a1, a2) => const WelcomeScreen(),
                                            transitionsBuilder: (context, a1, a2, child) =>
                                                FadeTransition(opacity: a1, child: child),
                                          ),
                                          (route) => false,
                                        );
                                      } else {
                                        AestheticSnackBar.showWarning(
                                          context,
                                          'Hesap silinirken bir sorun oluştu. Lütfen tekrar deneyin.',
                                        );
                                      }
                                    }
                                  },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: isDeleting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Kalıcı Sil',
                                        style: AppTypography.sfPro(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 🎨 Resmi Google 4 Renkli Vektörel Logo Çizici
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = w / 2;
    final center = Offset(r, h / 2);
    final rect = Rect.fromCircle(center: center, radius: r * 0.76);
    final strokeW = w * 0.22;

    // Kırmızı (Üst)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, -3.14 * 0.75, 3.14 * 0.50, false, redPaint);

    // Sarı (Sol)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 3.14 * 0.75, 3.14 * 0.50, false, yellowPaint);

    // Yeşil (Alt)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 3.14 * 0.25, 3.14 * 0.50, false, greenPaint);

    // Mavi (Sağ kavis)
    final blueArcPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, -3.14 * 0.25, 3.14 * 0.50, false, blueArcPaint);

    // Mavi Yatay Çubuk
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.44, h * 0.40, w * 0.44, h * 0.20),
      const Radius.circular(2),
    );
    canvas.drawRRect(barRect, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
