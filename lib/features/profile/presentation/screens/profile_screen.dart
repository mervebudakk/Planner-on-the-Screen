import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../../planner/presentation/screens/welcome_screen.dart';
import '../../../planner/presentation/screens/widget_customizer_screen.dart';
import '../../../../core/widgets/vintage_framed_avatar.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../planner/providers/planner_provider.dart';

/// 👤 Calenda — Minimalist Profil, Haftalık Ritim ve Hesap Merkezi
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _textPrimary = Color(0xFF1A2B1D);
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);



  /// Kullanıcının kayıt tarihini Türkçe formatta döndürür (Örn: "Eylül 2026'dan beri üye")
  String _getMemberSinceText(DateTime? createdAt) {
    final date = createdAt ?? DateTime(2026, 9, 1);
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    final monthName = months[(date.month - 1).clamp(0, 11)];
    final year = date.year;
    final lastDigit = year % 10;
    String suffix;
    switch (lastDigit) {
      case 0: suffix = "'dan"; break;
      case 1: suffix = "'den"; break;
      case 2: suffix = "'den"; break;
      case 3: suffix = "'ten"; break;
      case 4: suffix = "'ten"; break;
      case 5: suffix = "'ten"; break;
      case 6: suffix = "'dan"; break; // 2026 -> altı'dan
      case 7: suffix = "'den"; break;
      case 8: suffix = "'den"; break;
      case 9: suffix = "'dan"; break;
      default: suffix = "'dan";
    }
    return "$monthName $year$suffix beri üye";
  }

  /// 🛡️ Gizlilik ve Destek Bilgi Sayfası (Translucent & Minimalist Apple Tarzı)
  void _showPrivacySupportSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF14241B).withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.90),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Gizlilik ve Destek',
                style: AppTypography.sfProRounded(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildPrivacyItem(
                        icon: Icons.shield_outlined,
                        title: 'Veri Güvenliği',
                        description:
                            'Tüm takvim, alışkanlık ve odaklanma verileriniz cihaz içinde ve bulutta TLS/SSL ile uçtan uca şifrelenir.',
                        isDark: isDark,
                        primaryText: primaryText,
                        mutedText: mutedText,
                      ),
                      const SizedBox(height: 10),
                      _buildPrivacyItem(
                        icon: Icons.cloud_sync_outlined,
                        title: 'Bulut Senkronizasyonu',
                        description:
                            'Hesabınız aracılığıyla tüm kayıtlarınız güvenle yedeklenir ve tüm cihazlarınız arasında anında senkronize olur.',
                        isDark: isDark,
                        primaryText: primaryText,
                        mutedText: mutedText,
                      ),
                      const SizedBox(height: 10),
                      _buildPrivacyItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Gizlilik İlkemiz',
                        description:
                            'Kişisel verileriniz asla üçüncü taraflarla paylaşılmaz, satılmaz veya reklam amaçlı işlenmez.',
                        isDark: isDark,
                        primaryText: primaryText,
                        mutedText: mutedText,
                      ),
                      const SizedBox(height: 10),
                      _buildPrivacyItem(
                        icon: Icons.mail_outline_rounded,
                        title: 'İletişim & Destek',
                        description:
                            'Her türlü soru, öneri veya destek talebiniz için doğrudan bize ulaşabilirsiniz: calenda.support@gmail.com',
                        isDark: isDark,
                        primaryText: primaryText,
                        mutedText: mutedText,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              BouncingWidget(
                onTap: () => Navigator.pop(context),
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
                      'Tamam',
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
        );
      },
    );
  }

  Widget _buildPrivacyItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    required Color primaryText,
    required Color mutedText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1B2F22).withValues(alpha: 0.60)
            : const Color(0xFFF3F7F1).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF284833) : const Color(0xFFE2EBE0),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF284833).withValues(alpha: 0.8)
                  : const Color(0xFFE2EBE0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.darkPrimary : _cta,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.sfProRounded(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppTypography.sfPro(
                    fontSize: 12.5,
                    color: mutedText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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


  /// 🚪 Hesaptan Çıkış Onay Diyaloğu
  void _showLogoutDialog(BuildContext context, PlannerProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Oturumu Kapat',
          style: AppTypography.sfProRounded(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primaryText,
          ),
        ),
        content: Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: AppTypography.sfPro(fontSize: 14, color: mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Vazgeç',
              style: AppTypography.sfProRounded(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: mutedText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
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
              'Çıkış Yap',
              style: AppTypography.sfProRounded(
                fontSize: 14.5,
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
                'Hesabı ve Verileri Sil',
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
          'Tüm planlarınız, rutinleriniz, odaklanma kayıtlarınız ve profil verileriniz hem cihazınızdan hem de buluttan kalıcı olarak silinecektir.\n\nBu işlem geri alınamaz. Emin misiniz?',
          style: AppTypography.sfPro(
            fontSize: 13.5,
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
                    'Vazgeç',
                    style: AppTypography.sfProRounded(
                      fontSize: 14.5,
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
                        AestheticSnackBar.showError(context, 'Silme işlemi sırasında bir hata oluştu.');
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
                    'Evet, Sil',
                    style: AppTypography.sfProRounded(
                      fontSize: 14.5,
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
        child: Consumer<PlannerProvider>(
          builder: (context, provider, _) {
            final user = provider.userProfile;
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
                          MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
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
                          'Profili Düzenle',
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
                        const SizedBox(height: 3),
                        Text(
                          user.username.isNotEmpty ? '@${user.username}' : '',
                          style: AppTypography.sfPro(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: mutedText,
                          ),
                        ),
                      ] else ...[
                        Text(
                          user.username.isNotEmpty
                              ? '@${user.username}'
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

                      // Kayıt Olunan Tarih (Örn: "Eylül 2026'dan beri üye")
                      Text(
                        _getMemberSinceText(user.createdAt),
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
                  provider: provider,
                  isDark: isDark,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  ctaColor: ctaColor,
                ),

                const SizedBox(height: 24),

                // ─── 4. HESAP & UYGULAMA İŞLEMLERİ ───
                // Ana Ekran Widget'ı Ekle
                _buildSettingTile(
                  title: 'Ana Ekran Widget\'ı Ekle',
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

                // Geri Bildirim
                _buildSettingTile(
                  title: 'Geri Bildirim',
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () => _showFeedbackSheet(context, user),
                ),

                const SizedBox(height: 10),

                // Gizlilik ve Destek
                _buildSettingTile(
                  title: 'Gizlilik ve Destek',
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () => _showPrivacySupportSheet(context),
                ),

                const SizedBox(height: 10),

                // Hesaptan Çıkış Yap
                _buildSettingTile(
                  title: 'Çıkış Yap',
                  titleColor: const Color(0xFFC47B89),
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () => _showLogoutDialog(context, provider),
                ),

                const SizedBox(height: 10),

                // Hesabı ve Verileri Sil (En Altta)
                _buildSettingTile(
                  title: 'Hesabı ve Verileri Sil',
                  titleColor: const Color(0xFFD9534F),
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () => _showDeleteAccountDialog(context, provider),
                ),

                const SizedBox(height: 24),

                // Versiyon Bilgisi
                Center(
                  child: Text(
                    'Calenda • Kişisel Planlayıcı',
                    style: AppTypography.sfPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: mutedText,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// ⚡ _WeeklyRhythmSection — Apple Health & Aesthetic Kart Formatında Haftalık Ritim
// ─────────────────────────────────────────────────────────────────────────────
class _WeeklyRhythmSection extends StatefulWidget {
  final PlannerProvider provider;
  final bool isDark;
  final Color primaryText;
  final Color mutedText;
  final Color ctaColor;

  const _WeeklyRhythmSection({
    required this.provider,
    required this.isDark,
    required this.primaryText,
    required this.mutedText,
    required this.ctaColor,
  });

  @override
  State<_WeeklyRhythmSection> createState() => _WeeklyRhythmSectionState();
}

class _WeeklyRhythmSectionState extends State<_WeeklyRhythmSection> {
  int? _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDayIndex = now.weekday - 1;
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return '0 dk';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '$mins dk';
    if (mins == 0) return '$hours sa';
    return '$hours sa $mins dk';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: todayIndex));
    final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    final dayMinutesList = <int>[];
    int maxMins = 0;

    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final mins = widget.provider.getFocusMinutesForDay(d);
      dayMinutesList.add(mins);
      if (mins > maxMins) maxMins = mins;
    }

    final totalWeekMinutes = dayMinutesList.fold<int>(0, (sum, m) => sum + m);

    // Çizgi doluluk oranı referans tavanı (en az 60 dk)
    final scaleMax = maxMins > 60 ? maxMins : 60;
    final activeIndex = _selectedDayIndex ?? todayIndex;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF14241B).withValues(alpha: 0.38)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: widget.isDark ? 0.20 : 0.85),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.22 : 0.04),
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
                'Haftalık Ritmin',
                style: AppTypography.sfProRounded(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: widget.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                totalWeekMinutes > 0
                    ? 'Toplam: ${_formatDuration(totalWeekMinutes)} odak'
                    : 'Bu hafta henüz odak kaydı yok',
                style: AppTypography.sfPro(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: widget.mutedText,
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
              final isSelected = index == activeIndex;
              final mins = dayMinutesList[index];
              final ratio = (mins / scaleMax).clamp(0.0, 1.0);
              const trackHeight = 78.0;
              const capsuleWidth = 16.0;
              final fillHeight = mins > 0 ? (ratio * trackHeight).clamp(10.0, trackHeight) : 0.0;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sütun Üstü Değer Göstergesi
                      SizedBox(
                        height: 20,
                        child: Center(
                          child: isSelected
                              ? AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 180),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: widget.isDark
                                          ? const Color(0xFF2C5539)
                                          : const Color(0xFF13361B),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _formatDuration(mins),
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                )
                              : (mins > 0
                                  ? Text(
                                      '$mins dk',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: widget.mutedText.withValues(alpha: 0.8),
                                        height: 1.1,
                                      ),
                                    )
                                  : const SizedBox.shrink()),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Kapsül Dikey Bar (Doluluk & Arka Plan)
                      Container(
                        width: isSelected ? capsuleWidth + 2 : capsuleWidth,
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF1C2E22)
                              : const Color(0xFFEBF1EA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? (widget.isDark
                                    ? const Color(0xFF66E384).withValues(alpha: 0.6)
                                    : const Color(0xFF2E653F).withValues(alpha: 0.5))
                                : (widget.isDark
                                    ? const Color(0xFF263D2E)
                                    : const Color(0xFFE2EBE0)),
                            width: isSelected ? 1.4 : 1.0,
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
                                    color: widget.isDark
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
                              width: isSelected ? capsuleWidth + 2 : capsuleWidth,
                              height: fillHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isSelected
                                      ? (widget.isDark
                                          ? [const Color(0xFF2E6B43), const Color(0xFF76E397)]
                                          : [const Color(0xFF0F2C14), const Color(0xFF2E6F46)])
                                      : (widget.isDark
                                          ? [const Color(0xFF224830), const Color(0xFF4C875F)]
                                          : [const Color(0xFF234B2D), const Color(0xFF4D7558)]),
                                ),
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: isSelected && mins > 0
                                    ? [
                                        BoxShadow(
                                          color: (widget.isDark
                                                  ? const Color(0xFF55C77A)
                                                  : const Color(0xFF0F2C14))
                                              .withValues(alpha: 0.35),
                                          blurRadius: 8,
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
                          fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isToday
                              ? (widget.isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                              : (isSelected ? widget.primaryText : widget.mutedText),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Bugün / Seçili Noktası
                      Container(
                        width: 4.5,
                        height: 4.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? (widget.isDark ? const Color(0xFF66E384) : const Color(0xFF2E7D32))
                              : (isSelected
                                  ? widget.mutedText.withValues(alpha: 0.45)
                                  : Colors.transparent),
                        ),
                      ),
                    ],
                  ),
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
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      AestheticSnackBar.showWarning(context, 'Lütfen bir geri bildirim mesajı yazın.');
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
        'Geri bildiriminiz iletildi. Teşekkür ederiz.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Geri Bildirim',
            style: AppTypography.sfProRounded(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: widget.primaryText,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _feedbackController,
            maxLines: 5,
            minLines: 4,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.sfPro(fontSize: 14.5, color: widget.primaryText),
            decoration: InputDecoration(
              hintText: 'Görüş, öneri veya karşılaştığınız durumları buraya yazabilirsiniz...',
              hintStyle: AppTypography.sfPro(
                fontSize: 13.5,
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
                        'Gönder',
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
    );
  }
}
