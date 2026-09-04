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

/// 👤 Calenda Masalsı Profil ve Ayarlar Ekranı (Toolbox Sağ Sekmesi)
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    const buttonPink = Color(0xFFE6ABA7);

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

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              children: [
                // ── Header ──
                Text(
                  'Profil & Ayarlar',
                  style: AppTypography.sfProRounded(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : titleColor,
                  ),
                ),

                const SizedBox(height: 16),

                // ── 👤 1. BÜYÜK AVATAR & KULLANICI BENTO KARTI ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF15231B) : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Canlı Avatar
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: _parseHex(user.avatarBgColor),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
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
                                width: 68,
                                height: 68,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 30, color: Color(0xFF9E8D86)),
                              ),
                              if (accessoryAsset != null)
                                Image.asset(
                                  accessoryAsset,
                                  width: 68,
                                  height: 68,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // İsim & Handle & Durum
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sfProRounded(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : titleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.username.isNotEmpty ? '@' : 'Misafir Kullanıcı',
                              style: AppTypography.sfPro(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.darkTextMuted : subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E3326) : const Color(0xFFFDEBF0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.coreFocusArea,
                                style: AppTypography.sfPro(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF8B5A2B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── 🎯 2. HAFTALIK HEDEF VE RİTİM KARTI ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF15231B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Haftalık Hedef Durumu',
                            style: AppTypography.sfProRounded(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : titleColor,
                            ),
                          ),
                          Text(
                            user.weeklyGoalDays == 0 ? 'Serbest Mod' : '0 /  Gün',
                            style: AppTypography.sfProRounded(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFC47B89),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: user.weeklyGoalDays == 0 ? 1.0 : 0.0,
                          minHeight: 8,
                          backgroundColor: isDark ? const Color(0xFF23382B) : const Color(0xFFF0EAE1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFF4E9E67) : buttonPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── 📱 3. ARAÇLAR VE WIDGET ÖZELLEŞTİRİCİ ──
                _buildSectionHeader('ARAÇLAR', isDark ? AppColors.darkTextMuted : subtitleColor),
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

                const SizedBox(height: 20),

                // ── ⚙️ 4. TERCİHLER VE TEMA ──
                _buildSectionHeader('TERCİHLER', isDark ? AppColors.darkTextMuted : subtitleColor),
                const SizedBox(height: 8),

                // Tema Seçici
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF15231B) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2E1A) : const Color(0xFFFCF4DD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.palette_outlined, size: 20, color: Color(0xFFB59A57)),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Görünüm Teması',
                            style: AppTypography.sfPro(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : titleColor,
                            ),
                          ),
                        ],
                      ),
                      DropdownButton<ThemeMode>(
                        value: provider.themeMode,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? const Color(0xFF15231B) : Colors.white,
                        style: AppTypography.sfPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : titleColor,
                        ),
                        items: const [
                          DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
                          DropdownMenuItem(value: ThemeMode.light, child: Text('Açık')),
                          DropdownMenuItem(value: ThemeMode.dark, child: Text('Koyu')),
                        ],
                        onChanged: (mode) {
                          if (mode != null) provider.setThemeMode(mode);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── 🔐 5. HESAP & OTURUM ──
                _buildSectionHeader('HESAP', isDark ? AppColors.darkTextMuted : subtitleColor),
                const SizedBox(height: 8),

                if (!user.isLoggedIn)
                  _buildSettingTile(
                    icon: Icons.login_rounded,
                    iconColor: const Color(0xFF6B9B78),
                    iconBg: isDark ? const Color(0xFF1C2C20) : const Color(0xFFEBF7EE),
                    title: 'Google ile Giriş Yap',
                    subtitle: 'Verilerini bulutta senkronize et',
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

                // Onboarding'i Tekrar Başlat
                _buildSettingTile(
                  icon: Icons.refresh_rounded,
                  iconColor: const Color(0xFF8B7970),
                  iconBg: isDark ? const Color(0xFF1E2822) : const Color(0xFFF5EFEB),
                  title: 'Hedef & Avatar Sihirbazını Yeniden Başlat',
                  subtitle: 'Hedeflerini veya avatarını tekrar düzenle',
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                    );
                  },
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
