import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Uygulama Ayarları, Yedekleme ve Bilgi Ekranı
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ayarlar',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Bulut Yedekleme & Giriş Kartı (Guest First Modeli)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_outlined,
                        color: AppColors.accentLight, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Bulut Yedekleme & Senkronizasyon',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Planlarınız şu anda güvenle cihazınızda saklanıyor. Telefonunuzu değiştirdiğinizde kaybolmaması için Google hesabınızla yedekleyin.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bulut senkronizasyonu yakında aktif edilecek!'),
                        backgroundColor: AppColors.accent,
                      ),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(
                    'Google ile Giriş Yap & Yedekle',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Genel Tercihler Bölümü
          _buildSectionHeader('GENEL TERCİHLER'),
          const SizedBox(height: 8),
          _buildSettingsGroup([
            _buildListTile(
              icon: Icons.access_time,
              title: '24 Saat Formatı',
              subtitle: '14:30 yerine 02:30 PM kullanımı',
              trailing: Switch.adaptive(
                value: true,
                activeTrackColor: AppColors.accentLight,
                onChanged: (_) {},
              ),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.calendar_today_outlined,
              title: 'Haftanın İlk Günü',
              subtitle: 'Pazartesi',
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 24),

          // Hukuki & Güvenlik Bölümü (Google Play ve App Store Gereksinimi)
          _buildSectionHeader('BİLGİ & GİZLİLİK'),
          const SizedBox(height: 8),
          _buildSettingsGroup([
            _buildListTile(
              icon: Icons.shield_outlined,
              title: 'Gizlilik Politikası',
              subtitle: 'Kişisel verileriniz ve güvenlik şartları',
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () {},
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.description_outlined,
              title: 'Kullanım Koşulları (EULA)',
              subtitle: 'Hizmet ve kullanım şartları',
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () {},
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.info_outline,
              title: 'Uygulama Sürümü',
              subtitle: 'v${AppConstants.appVersion} (Build 1)',
              trailing: null,
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }

  static Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  static Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.accentLight, size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.white54,
        ),
      ),
      trailing: trailing,
    );
  }

  static Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.darkBorder, indent: 56);
  }
}
