import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../../../core/widgets/vintage_framed_avatar.dart';
import '../../../planner/providers/planner_provider.dart';

/// 👤 Calenda — Minimalist Profil, Haftalık Ritim ve Hesap Merkezi
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

  /// 💬 Uygulama İçin Geri Bildirim Formu
  void _showFeedbackSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    final feedbackController = TextEditingController();
    String selectedReaction = '🌿';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
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
                        color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Geri Bildirim Paylaş',
                    style: AppTypography.sfProRounded(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Calenda\'yı geliştirmemize yardımcı ol. Tüm önerilerini dikkatle inceliyoruz.',
                    style: AppTypography.sfPro(fontSize: 13, color: mutedText),
                  ),
                  const SizedBox(height: 16),

                  // Reaksiyon seçici
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ('🌿', 'Harika'),
                      ('✨', 'İyi'),
                      ('☕', 'Fena Değil'),
                      ('💡', 'Öneri'),
                    ].map((item) {
                      final isSelected = selectedReaction == item.$1;
                      return BouncingWidget(
                        onTap: () => setSheetState(() => selectedReaction = item.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF2E5E3A) : const Color(0xFFEFF5ED))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? ctaColor : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(item.$1, style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 3),
                              Text(
                                item.$2,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? primaryText : mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Metin Giriş Alanı
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    style: AppTypography.sfPro(fontSize: 14, color: primaryText),
                    decoration: InputDecoration(
                      hintText: 'Aklına gelen fikirleri veya karşılaştığın durumları buraya yazabilirsin...',
                      hintStyle: AppTypography.sfPro(
                        fontSize: 13,
                        color: mutedText.withValues(alpha: 0.7),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF16231C) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: isDark ? const BorderSide(color: AppColors.darkBorder) : BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gönder Butonu
                  BouncingWidget(
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Geri bildirimin için çok teşekkürler! 🌿',
                            style: AppTypography.sfPro(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: ctaColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
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
          },
        );
      },
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Hesap ve tüm veriler başarıyla silindi.'
                                : 'Silme işlemi sırasında bir hata oluştu.',
                          ),
                          backgroundColor: success ? const Color(0xFF2E5E3A) : const Color(0xFFD9534F),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
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

  /// ⚡ Haftalık Ritmin Bento Kartı
  Widget _buildWeeklyRhythmCard({
    required BuildContext context,
    required PlannerProvider provider,
    required bool isDark,
    required Color cardColor,
    required Color primaryText,
    required Color mutedText,
    required Color ctaColor,
  }) {
    final now = DateTime.now();
    // Pazartesi'yi 0. gün olarak hesapla (DateTime.monday = 1)
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    int achievedCount = 0;
    final dayMinutesList = <int>[];
    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final mins = provider.getFocusMinutesForDay(d);
      dayMinutesList.add(mins);
      if (mins >= 30) achievedCount++;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF142814)).withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Haftalık Ritmin',
                style: AppTypography.sfProRounded(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3025) : const Color(0xFFEFF5ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$achievedCount / 7 Gün',
                  style: AppTypography.sfProRounded(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ctaColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 7 Gün Kutucukları (Pzt - Paz)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayDate = monday.add(Duration(days: index));
              final isToday = (dayDate.day == now.day && dayDate.month == now.month && dayDate.year == now.year);
              final isFuture = dayDate.isAfter(DateTime(now.year, now.month, now.day));
              final mins = dayMinutesList[index];
              final isCompleted = mins >= 30;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: index == 0 || index == 6 ? 0 : 3),
                  child: Column(
                    children: [
                      // Gün Adı (Pzt, Sal, Çar, Per, Cum, Cmt, Paz)
                      Text(
                        dayNames[index],
                        style: AppTypography.sfPro(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                          color: isToday ? primaryText : mutedText,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Odak Kutucuğu
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 48,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? (isDark ? const Color(0xFF2E5E3A) : const Color(0xFF1E3A24))
                              : (mins > 0
                                  ? (isDark ? const Color(0xFF1F3526) : const Color(0xFFE4EDE1))
                                  : (isDark ? const Color(0xFF18261E) : const Color(0xFFEFF5ED))),
                          borderRadius: BorderRadius.circular(14),
                          border: isToday
                              ? Border.all(
                                  color: isCompleted ? Colors.transparent : ctaColor,
                                  width: 1.5,
                                )
                              : null,
                          boxShadow: isCompleted
                              ? [
                                  BoxShadow(
                                    color: (isDark ? const Color(0xFF2E5E3A) : const Color(0xFF1E3A24))
                                        .withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      '$mins dk',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                )
                              : (mins > 0
                                  ? Text(
                                      '$mins dk',
                                      style: AppTypography.sfProRounded(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? const Color(0xFFB4D8C2) : primaryText,
                                      ),
                                    )
                                  : (isFuture
                                      ? Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: mutedText.withValues(alpha: 0.25),
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: mutedText.withValues(alpha: 0.4),
                                            shape: BoxShape.circle,
                                          ),
                                        ))),
                        ),
                      ),

                      // Bugün İndikatörü (Minik Yeşil Nokta)
                      const SizedBox(height: 5),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday ? ctaColor : Colors.transparent,
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
              padding: EdgeInsets.fromLTRB(20, 22, 20, MediaQuery.of(context).padding.bottom + 104),
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
                        backgroundColor: _parseHex(user.avatarBgColor),
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
                          user.username.isNotEmpty ? '@${user.username}' : '@calenda_user',
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
                              : (user.displayName.isNotEmpty ? user.displayName : '@calenda_user'),
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

                // ─── 3. HAFTALIK RİTMİN BENTO KARTI ───
                _buildWeeklyRhythmCard(
                  context: context,
                  provider: provider,
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  ctaColor: ctaColor,
                ),

                const SizedBox(height: 24),

                // ─── 4. HESAP & UYGULAMA İŞLEMLERİ ───
                // Geri Bildirim
                _buildSettingTile(
                  title: 'Geri Bildirim',
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () => _showFeedbackSheet(context),
                ),

                const SizedBox(height: 10),

                // Gizlilik ve Destek
                _buildSettingTile(
                  title: 'Gizlilik ve Destek',
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  mutedText: mutedText,
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Gizlilik ve Destek',
                      '1. Veri Güvenliği: Tüm takvim ve odaklanma verileriniz cihaz içi ve bulut düzeyinde TLS/SSL ile şifrelenir.\n\n2. Senkronizasyon: Apple veya Google oturumunuz aracılığıyla verileriniz güvenle yedeklenir.\n\n3. Üçüncü Taraf Paylaşımı: Kişisel verileriniz hiçbir üçüncü tarafa aktarılmaz ve ticari olarak işlenmez.\n\n4. Destek: calenda.support@gmail.com',
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Hesaptan Çıkış Yap / Giriş Yap
                if (user.isLoggedIn)
                  _buildSettingTile(
                    title: 'Çıkış Yap',
                    titleColor: const Color(0xFFC47B89),
                    isDark: isDark,
                    cardColor: cardColor,
                    primaryText: primaryText,
                    mutedText: mutedText,
                    onTap: () => _showLogoutDialog(context, provider),
                  )
                else
                  _buildSettingTile(
                    title: 'Giriş Yap / Hesap Bağla',
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
