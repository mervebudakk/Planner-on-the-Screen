import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/vintage_framed_avatar.dart';
import '../../models/onboarding_state.dart';

/// 📇 Adım 8: Vintage Antika Çerçeveli Masalsı Profil & Tamamlanma
class ProfileReadyCardStep extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onFinish;

  const ProfileReadyCardStep({
    super.key,
    required this.state,
    required this.onFinish,
  });

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
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);

    final cleanAnimal = state.avatarAnimal
        .replaceAll('01_', '')
        .replaceAll('02_', '')
        .replaceAll('03_', '')
        .replaceAll('04_', '')
        .replaceAll('05_', '')
        .replaceAll('06_', '')
        .replaceAll('07_', '');

    final animalAsset = 'assets/avatars/$cleanAnimal.webp';
    final accessoryAsset = state.avatarAccessory != 'none'
        ? 'assets/accessories/${state.avatarAccessory}.webp'
        : null;

    final fullName = '${state.firstName} ${state.lastName}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : 'Sevgili Planlayıcı';
    final handle = state.username.isNotEmpty ? '@${state.username}' : '@kullanici';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // ── Başlık ──
          Text(
            'Profilin Hazır!',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Profilin oluşturuldu. Artık hedeflerini ve rutinlerini kolayca planlayabilirsin.',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
            ),
          ),

          const Spacer(flex: 1),

          // ── 🖼️ ANTİKA VİNTAGE ÇERÇEVELİ PORTRE ──
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A2B33).withValues(alpha: 0.12),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: VintageFramedAvatar(
              animalAsset: animalAsset,
              accessoryAsset: accessoryAsset,
              backgroundColor: _parseHex(state.avatarBgColor),
              height: 215,
            ),
          ),

          const SizedBox(height: 16),

          // İsim & Kullanıcı Adı
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sfProRounded(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            handle,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8B7970),
            ),
          ),

          const SizedBox(height: 18),

          // ── 📊 ZARİF & PROFESYONEL ÖZET PANELİ (Quiet Luxury 3 Sütun) ──
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 350),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFEADBCE).withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A2B33).withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryColumn(
                    label: 'Haftalık Ritim',
                    value: state.weeklyGoalDays == 0 ? 'Serbest' : '${state.weeklyGoalDays} Gün',
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: const Color(0xFFEADBCE).withValues(alpha: 0.85),
                ),
                Expanded(
                  child: _buildSummaryColumn(
                    label: 'Günlük Odak',
                    value: _getFocusText(state.dailyFocusMinutes),
                    icon: Icons.schedule_rounded,
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: const Color(0xFFEADBCE).withValues(alpha: 0.85),
                ),
                Expanded(
                  child: _buildSummaryColumn(
                    label: 'Ana Hedef',
                    value: _getGoalsText(state.coreGoals),
                    icon: Icons.track_changes_rounded,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          // ── Planlamaya Başla Butonu ──
          AestheticPlannerButton(
            text: 'Planlamaya Başla',
            icon: Icons.arrow_forward_rounded,
            height: 52,
            onPressed: onFinish,
          ),

          const SizedBox(height: 44),
        ],
      ),
    );
  }

  String _getFocusText(int minutes) {
    if (minutes == 0) return 'Serbest';
    if (minutes == 45) return '45 Dakika';
    if (minutes == 120) return '1 - 3 Saat';
    if (minutes == 210) return '3+ Saat';
    if (minutes >= 60) {
      final hrs = minutes ~/ 60;
      final rem = minutes % 60;
      return rem == 0 ? '$hrs Saat' : '$hrs sa $rem dk';
    }
    return '$minutes Dk';
  }

  String _getShortGoalTag(String g) {
    if (g.contains('Sınav') || g.contains('Ders')) return 'Sınav';
    if (g.contains('Proje') || g.contains('Çalışma')) return 'Proje';
    if (g.contains('Rutin') || g.contains('Alışkanlık')) return 'Rutin';
    if (g.contains('Planlama') || g.contains('Not')) return 'Plan';
    return g.split(' ').first;
  }

  String _getGoalsText(List<String> goals) {
    if (goals.isEmpty) return 'Genel Plan';
    if (goals.length == 1) {
      final first = goals.first;
      if (first.contains('Sınav') || first.contains('Ders')) return 'Ders & Sınav';
      if (first.contains('Proje') || first.contains('Çalışma')) return 'İş & Proje';
      if (first.contains('Rutin') || first.contains('Alışkanlık')) return 'Rutin & Yaşam';
      if (first.contains('Planlama') || first.contains('Not')) return 'Kişisel Plan';
      return first;
    }
    if (goals.length == 2) {
      final tag1 = _getShortGoalTag(goals[0]);
      final tag2 = _getShortGoalTag(goals[1]);
      return '$tag1 & $tag2';
    }
    if (goals.length == 3) {
      return 'Çok Yönlü Odak';
    }
    return 'Bütünsel Plan';
  }

  Widget _buildSummaryColumn({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: const Color(0xFF8B7970),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.sfPro(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B7970),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.sfProRounded(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4A2B33),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
