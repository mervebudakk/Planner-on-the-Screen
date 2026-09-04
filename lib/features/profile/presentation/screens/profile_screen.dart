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

/// 👤 Calenda — Masalsı Profil, Hedefler ve Ayarlar Merkezi
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFFFAF7F2);
    }
  }

  List<Map<String, dynamic>> _parseGoalChips(String goalsText) {
    final chips = <Map<String, dynamic>>[];
    if (goalsText.isEmpty) {
      return [
        {'icon': Icons.edit_note_rounded, 'label': 'Kişisel Planlama', 'color': const Color(0xFFEBF7EE), 'textColor': const Color(0xFF52875E)},
      ];
    }

    final lower = goalsText.toLowerCase();
    if (lower.contains('sınav') || lower.contains('ders')) {
      chips.add({'icon': Icons.school_rounded, 'label': 'Sınav & Ders', 'color': const Color(0xFFFDEBF0), 'textColor': const Color(0xFFC47B89)});
    }
    if (lower.contains('proje') || lower.contains('çalışma') || lower.contains('iş')) {
      chips.add({'icon': Icons.work_outline_rounded, 'label': 'Proje & Kariyer', 'color': const Color(0xFFDAEAF6), 'textColor': const Color(0xFF5A8DB5)});
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFFFAF7F2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6C8BB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: AppTypography.sfProRounded(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2B33),
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
                      color: const Color(0xFF7A5861),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              BouncingWidget(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A2B33),
                    borderRadius: BorderRadius.circular(20),
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
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);

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

            final animalAsset = 'assets/avatars/$cleanAnimal.png';
            final accessoryAsset = user.avatarAccessory != 'none'
                ? 'assets/accessories/${user.avatarAccessory}.png'
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                // ── 🏷️ ÜST BAŞLIK & DÜZENLE BUTONU ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil & Ayarlar',
                          style: AppTypography.sfProRounded(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : titleColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kişisel hedeflerin ve uygulama tercihlerin',
                          style: AppTypography.sfPro(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextMuted : subtitleColor,
                          ),
                        ),
                      ],
                    ),
                    BouncingWidget(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3326) : const Color(0xFFFDEBF0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_fix_high_rounded, size: 14, color: Color(0xFFC47B89)),
                            const SizedBox(width: 5),
                            Text(
                              'Düzenle',
                              style: AppTypography.sfPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── 📇 1. MASALSI PASAPORT BENTO KARTI (HERO PROFILE) ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF15231B) : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Canlı Pul / Çerçeveli Avatar
                          Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              color: _parseHex(user.avatarBgColor),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    animalAsset,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.pets, size: 32, color: Color(0xFF9E8D86)),
                                  ),
                                  if (accessoryAsset != null)
                                    Image.asset(
                                      accessoryAsset,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // İsim, Handle ve Üyelik Rozeti
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.sfProRounded(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.darkTextPrimary : titleColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.username.isNotEmpty ? '@${user.username}' : '@calenda_user',
                                  style: AppTypography.sfPro(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF9E8D86),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC47B89).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFC47B89).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '✦ CALENDA ÜYESİ',
                                    style: AppTypography.sfPro(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFC47B89),
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
                      const Divider(height: 1, color: Color(0xFFF0EBE3)),
                      const SizedBox(height: 12),

                      // Estetik Odak Alanları Çipleri (Chips)
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

                const SizedBox(height: 16),

                // ── 📊 2. 3'LÜ MİNİ BENTO İSTATİSTİK GRUBU ──
                Row(
                  children: [
                    // 1. Haftalık Hedef
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF15231B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.date_range_rounded, size: 16, color: Color(0xFFC47B89)),
                                SizedBox(width: 6),
                                Text(
                                  'Haftalık',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9E8D86)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.weeklyGoalDays == 0 ? 'Serbest' : '${user.weeklyGoalDays} Gün/Hf',
                              style: AppTypography.sfProRounded(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : titleColor,
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
                          color: isDark ? const Color(0xFF15231B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.timer_outlined, size: 16, color: Color(0xFF8E79AB)),
                                SizedBox(width: 6),
                                Text(
                                  'Odak',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9E8D86)),
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
                                color: isDark ? AppColors.darkTextPrimary : titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 3. Hesap / Senkronizasyon
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF15231B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  user.isLoggedIn ? Icons.cloud_done_rounded : Icons.phone_android_rounded,
                                  size: 16,
                                  color: user.isLoggedIn ? const Color(0xFF52875E) : const Color(0xFFB59A57),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Depolama',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9E8D86)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.isLoggedIn ? 'Bulut' : 'Yerel Cihaz',
                              style: AppTypography.sfProRounded(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── 🎨 3. GÖRÜNÜM TEMASI (3'LÜ ESTETİK SEGMENT SEÇİCİ) ──
                _buildSectionHeader('GÖRÜNÜM & TEMA', isDark ? AppColors.darkTextMuted : subtitleColor),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF15231B) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildThemeSegment(
                        title: 'Sistem',
                        icon: Icons.brightness_auto_rounded,
                        isSelected: provider.themeMode == ThemeMode.system,
                        isDark: isDark,
                        onTap: () => provider.setThemeMode(ThemeMode.system),
                      ),
                      _buildThemeSegment(
                        title: 'Açık',
                        icon: Icons.wb_sunny_rounded,
                        isSelected: provider.themeMode == ThemeMode.light,
                        isDark: isDark,
                        onTap: () => provider.setThemeMode(ThemeMode.light),
                      ),
                      _buildThemeSegment(
                        title: 'Koyu',
                        icon: Icons.nightlight_round,
                        isSelected: provider.themeMode == ThemeMode.dark,
                        isDark: isDark,
                        onTap: () => provider.setThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── 📱 4. ARAÇLAR VE WIDGET ÖZELLEŞTİRİCİ ──
                _buildSectionHeader('ARAÇLAR & KİŞİSELLEŞTİRME', isDark ? AppColors.darkTextMuted : subtitleColor),
                const SizedBox(height: 8),

                _buildSettingTile(
                  icon: Icons.widgets_outlined,
                  iconColor: const Color(0xFF8E79AB),
                  iconBg: isDark ? const Color(0xFF241E2F) : const Color(0xFFE8DFF5),
                  title: 'Ana Ekran Widget Özelleştirici',
                  subtitle: 'Android 4x4, 4x3 & 2x2 widget temaları',
                  isDark: isDark,
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
                  iconColor: const Color(0xFFB59A57),
                  iconBg: isDark ? const Color(0xFF2A2E1A) : const Color(0xFFFCF4DD),
                  title: 'Hedef & Avatar Sihirbazını Yeniden Başlat',
                  subtitle: 'Karakterini, aksesuarlarını ve çalışma saatlerini güncelle',
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ── 🔐 5. HESAP VE GÜVENLİK ──
                _buildSectionHeader('HESAP & VERİLER', isDark ? AppColors.darkTextMuted : subtitleColor),
                const SizedBox(height: 8),

                if (!user.isLoggedIn)
                  _buildSettingTile(
                    icon: Icons.login_rounded,
                    iconColor: const Color(0xFF52875E),
                    iconBg: isDark ? const Color(0xFF1C2C20) : const Color(0xFFEBF7EE),
                    title: 'Google ile Giriş Yap',
                    subtitle: 'Verilerini bulutta güvenle yedekle',
                    isDark: isDark,
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
                    onTap: () async {
                      await provider.logoutUser();
                    },
                  ),

                const SizedBox(height: 10),

                _buildSettingTile(
                  icon: Icons.security_rounded,
                  iconColor: const Color(0xFF7A5861),
                  iconBg: isDark ? const Color(0xFF1E2822) : const Color(0xFFF5EFEB),
                  title: 'Gizlilik ve Güvenlik',
                  subtitle: 'Kullanım koşulları ve kişisel veri güvencesi',
                  isDark: isDark,
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Gizlilik ve Koşullar',
                      '1. Yerel Öncelikli Güvenlik: Tüm plan, rutin ve odak verileriniz öncelikli olarak cihazınızda şifreli saklanır.\n\n2. Hesap Senkronizasyonu: Google ile giriş yaptığınızda profiliniz güvenle buluta aktarılır.\n\n3. Veri Paylaşımı: Kişisel verileriniz hiçbir üçüncü taraf ile paylaşılmaz.',
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Versiyon ve Logo ──
                Center(
                  child: Text(
                    'Calenda • Masalsı Haftalık Planlayıcı ✦',
                    style: AppTypography.sfPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF5A7566) : const Color(0xFFBDB2A7),
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

  Widget _buildThemeSegment({
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: BouncingWidget(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF2E4D37) : const Color(0xFF4A2B33))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextMuted : const Color(0xFF8B7970)),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTypography.sfProRounded(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextMuted : const Color(0xFF8B7970)),
                ),
              ),
            ],
          ),
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
          letterSpacing: 1.0,
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
    required VoidCallback onTap,
  }) {
    return BouncingWidget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF15231B) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF4A2B33),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.sfPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF7A5861),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? const Color(0xFF5A7566) : const Color(0xFFBFB2A7),
            ),
          ],
        ),
      ),
    );
  }
}
