import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../../planner/presentation/screens/widget_customizer_screen.dart';
import '../../../planner/providers/planner_provider.dart';

/// 👤 Calenda — Profil, Hedefler ve Ayarlar Merkezi
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _textPrimary = Color(0xFF1A2B1D);
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFFEFF5ED);
    }
  }

  List<Map<String, dynamic>> _parseGoalChips(String goalsText) {
    final chips = <Map<String, dynamic>>[];
    if (goalsText.isEmpty) {
      return [
        {'icon': Icons.edit_note_rounded, 'label': 'Kişisel Planlama', 'color': const Color(0xFFEFF5ED), 'textColor': _textPrimary},
      ];
    }

    final lower = goalsText.toLowerCase();
    if (lower.contains('sınav') || lower.contains('ders')) {
      chips.add({'icon': Icons.school_rounded, 'label': 'Sınav & Ders', 'color': const Color(0xFFFDEBF0), 'textColor': const Color(0xFFC47B89)});
    }
    if (lower.contains('proje') || lower.contains('çalışma') || lower.contains('iş')) {
      chips.add({'icon': Icons.work_outline_rounded, 'label': 'Proje & Kariyer', 'color': const Color(0xFFDAEAF6), 'textColor': const Color(0xFF4A7C59)});
    }
    if (lower.contains('rutin') || lower.contains('alışkanlık')) {
      chips.add({'icon': Icons.self_improvement_rounded, 'label': 'Rutin & Sağlık', 'color': const Color(0xFFE8DFF5), 'textColor': const Color(0xFF8E79AB)});
    }
    if (lower.contains('not') || lower.contains('planlama') || chips.isEmpty) {
      chips.add({'icon': Icons.auto_awesome_rounded, 'label': 'Planlama & Notlar', 'color': const Color(0xFFFCF4DD), 'textColor': const Color(0xFFB59A57)});
    }
    return chips;
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                title,
                style: AppTypography.sfProRounded(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    content,
                    style: AppTypography.sfPro(
                      fontSize: 14,
                      color: mutedText,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              BouncingWidget(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ctaColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      'Anladım',
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
        );
      },
    );
  }

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

            final goalChips = _parseGoalChips(user.coreFocusArea);

            final focusTimeText = () {
              if (user.dailyFocusMinutes == 0) return 'Serbest';
              if (user.dailyFocusMinutes == 45) return '< 1 Saat';
              if (user.dailyFocusMinutes == 120) return '1 - 3 Saat';
              if (user.dailyFocusMinutes == 210) return '3+ Saat';
              if (user.dailyFocusMinutes >= 60) {
                final hrs = user.dailyFocusMinutes ~/ 60;
                final rem = user.dailyFocusMinutes % 60;
                return rem == 0 ? '$hrs Saat' : '$hrs sa $rem dk';
              }
              return '${user.dailyFocusMinutes} dk/gün';
            }();

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 104),
              children: [
                // ─── HEADER (Planlayıcı Sekmesi ile Birebir Uyumlu) ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Sol: Kategori & Başlık
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 16,
                              color: mutedText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Hesap & Tercihler',
                              style: AppTypography.sfPro(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Profil',
                          style: AppTypography.sfProRounded(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),

                    // Sağ: Düzenle Butonu (Eylül Rozeti Standardında)
                    BouncingWidget(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF142814))
                                  .withValues(alpha: isDark ? 0.25 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune_rounded, size: 15, color: ctaColor),
                            const SizedBox(width: 5),
                            Text(
                              'Düzenle',
                              style: AppTypography.sfProRounded(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── 1. PROFİL KARTI (HERO BENTO) ───
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(26),
                    border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : const Color(0xFF142814))
                            .withValues(alpha: isDark ? 0.25 : 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar Çerçevesi
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: _parseHex(user.avatarBgColor),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    animalAsset,
                                    width: 66,
                                    height: 66,
                                    fit: BoxFit.contain,
                                    cacheWidth: 160,
                                    cacheHeight: 160,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.pets, size: 30, color: mutedText),
                                  ),
                                  if (accessoryAsset != null)
                                    Image.asset(
                                      accessoryAsset,
                                      width: 66,
                                      height: 66,
                                      fit: BoxFit.contain,
                                      cacheWidth: 160,
                                      cacheHeight: 160,
                                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // İsim & Handle & Durum Rozeti
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.sfProRounded(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: primaryText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.username.isNotEmpty ? '@${user.username}' : '@calenda_user',
                                  style: AppTypography.sfPro(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: mutedText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E3025)
                                        : const Color(0xFFEFF5ED),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user.isLoggedIn ? 'HESAP BAĞLI' : 'YEREL HESAP',
                                    style: AppTypography.sfPro(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: ctaColor,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      Divider(height: 1, color: isDark ? AppColors.darkBorder : const Color(0xFFEAEFE7)),
                      const SizedBox(height: 12),

                      // Odak Alanı Çipleri (Chips)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: goalChips.map((chip) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E3326) : chip['color'] as Color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(chip['icon'] as IconData, size: 13, color: chip['textColor'] as Color),
                                  const SizedBox(width: 5),
                                  Text(
                                    chip['label'] as String,
                                    style: AppTypography.sfPro(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: chip['textColor'] as Color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ─── 2. 3'LÜ MİNİ BENTO İSTATİSTİK GRUBU ───
                Row(
                  children: [
                    // 1. Haftalık Hedef
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF142814))
                                  .withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.date_range_rounded, size: 15, color: ctaColor),
                                const SizedBox(width: 5),
                                Text(
                                  'Haftalık',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: mutedText),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.weeklyGoalDays == 0 ? 'Serbest' : '${user.weeklyGoalDays} Gün/Hf',
                              style: AppTypography.sfProRounded(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 2. Günlük Odak
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF142814))
                                  .withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.hourglass_bottom_rounded, size: 15, color: ctaColor),
                                const SizedBox(width: 5),
                                Text(
                                  'Odak',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: mutedText),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              focusTimeText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sfProRounded(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 3. Depolama Durumu
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF142814))
                                  .withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  user.isLoggedIn ? Icons.cloud_done_rounded : Icons.phone_android_rounded,
                                  size: 15,
                                  color: user.isLoggedIn ? ctaColor : mutedText,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Kayıt',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: mutedText),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.isLoggedIn ? 'Bulut' : 'Cihaz',
                              style: AppTypography.sfProRounded(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ─── 3. ARAÇLAR VE WIDGET ÖZELLEŞTİRİCİ ───
                _buildSectionHeader('ARAÇLAR & KİŞİSELLEŞTİRME', mutedText),
                const SizedBox(height: 8),

                _buildSettingTile(
                  icon: Icons.widgets_outlined,
                  iconColor: ctaColor,
                  iconBg: isDark ? const Color(0xFF1E3025) : const Color(0xFFEFF5ED),
                  title: 'Ana Ekran Widget Özelleştirici',
                  subtitle: 'Android 4x4, 4x3 & 2x2 widget temaları',
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WidgetCustomizerScreen()),
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildSettingTile(
                  icon: Icons.palette_outlined,
                  iconColor: ctaColor,
                  iconBg: isDark ? const Color(0xFF1E3025) : const Color(0xFFEFF5ED),
                  title: 'Hedef & Avatar Sihirbazı',
                  subtitle: 'Karakterini, aksesuarlarını ve çalışma saatlerini güncelle',
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ─── 5. HESAP VE GÜVENLİK ───
                _buildSectionHeader('HESAP & VERİLER', mutedText),
                const SizedBox(height: 8),

                if (!user.isLoggedIn)
                  _buildSettingTile(
                    icon: Icons.login_rounded,
                    iconColor: ctaColor,
                    iconBg: isDark ? const Color(0xFF1E3025) : const Color(0xFFEFF5ED),
                    title: 'Google ile Giriş Yap',
                    subtitle: 'Verilerini bulutta güvenle yedekle',
                    isDark: isDark,
                    cardColor: cardColor,
                    primaryText: primaryText,
                    mutedText: mutedText,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  )
                else
                  _buildSettingTile(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFC45A65),
                    iconBg: const Color(0xFFFDEBF0),
                    title: 'Oturumu Kapat',
                    subtitle: user.email.isNotEmpty ? user.email : 'Hesaptan güvenle çıkış yap',
                    isDark: isDark,
                    cardColor: cardColor,
                    primaryText: primaryText,
                    mutedText: mutedText,
                    onTap: () async {
                      await provider.logoutUser();
                    },
                  ),

                const SizedBox(height: 10),

                _buildSettingTile(
                  icon: Icons.security_rounded,
                  iconColor: mutedText,
                  iconBg: isDark ? const Color(0xFF1E2822) : const Color(0xFFF5EFEB),
                  title: 'Gizlilik ve Güvenlik',
                  subtitle: 'Kullanım koşulları ve kişisel veri güvencesi',
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Gizlilik ve Koşullar',
                      '1. Veri Güvenliği: Tüm takvim ve odaklanma verileriniz cihaz içi ve bulut düzeyinde TLS/SSL ile şifrelenir.\n\n2. Senkronizasyon: Apple veya Google oturumunuz aracılığıyla verileriniz güvenle yedeklenir.\n\n3. Üçüncü Taraf Paylaşımı: Kişisel verileriniz hiçbir üçüncü tarafa aktarılmaz ve ticari olarak işlenmez.\n\n4. Destek: calenda.support@gmail.com',
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildSettingTile(
                  icon: Icons.mail_outline_rounded,
                  iconColor: mutedText,
                  iconBg: isDark ? const Color(0xFF1E2822) : const Color(0xFFF5EFEB),
                  title: 'Müşteri Desteği ve İletişim',
                  subtitle: 'calenda.support@gmail.com',
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Müşteri Desteği',
                      'Teknik destek talepleri, hesap işlemleri ve ürün geri bildirimleri için resmi iletişim adresi:\n\ncalenda.support@gmail.com',
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ─── Versiyon Bilgisi ───
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

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTypography.sfPro(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color cardColor,
    required Color primaryText,
    required Color mutedText,
    required VoidCallback onTap,
  }) {
    return BouncingWidget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF142814))
                  .withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 14),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.sfPro(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: mutedText,
            ),
          ],
        ),
      ),
    );
  }
}
