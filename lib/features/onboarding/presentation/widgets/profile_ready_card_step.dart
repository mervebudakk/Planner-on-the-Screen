import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../models/onboarding_state.dart';

/// 📇 Adım 8: Masalsı Mühürlü Profil Kartı & Tamamlanma
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

    final animalAsset = 'assets/avatars/$cleanAnimal.png';
    final accessoryAsset = state.avatarAccessory != 'none'
        ? 'assets/accessories/${state.avatarAccessory}.png'
        : null;

    final fullName = '${state.firstName} ${state.lastName}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : 'Sevgili Planlayıcı';
    final handle = state.username.isNotEmpty ? '@${state.username}' : '@calenda_user';

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
            'Calenda dünyan kuruldu. Artık hedeflerini huzurla planlamaya hazırsın.',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
            ),
          ),

          const Spacer(flex: 1),

          // ── 📇 POLAROID / MÜHÜRLÜ PASAPORT KARTI ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFEADBCE), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A2B33).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Kart Başlığı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC47B89),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CALENDA MEMBER',
                              style: AppTypography.sfPro(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF8B7970),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '2026',
                          style: AppTypography.sfProRounded(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFBFB2A7),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Avatar
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: _parseHex(state.avatarBgColor),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFEADBCE), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              animalAsset,
                              width: 86,
                              height: 86,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 36, color: Color(0xFF9E8D86)),
                            ),
                            if (accessoryAsset != null)
                              Image.asset(
                                accessoryAsset,
                                width: 86,
                                height: 86,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const SizedBox(),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // İsim & Handle
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sfProRounded(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      handle,
                      style: AppTypography.sfPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9E8D86),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF0EBE3)),
                    const SizedBox(height: 14),

                    // Tercihler Bento Rozetleri
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBadge(
                          icon: Icons.date_range_rounded,
                          label: state.weeklyGoalDays == 0 ? 'Serbest' : ' Gün/Hf',
                          color: const Color(0xFFFDEBF0),
                          textColor: const Color(0xFFC47B89),
                        ),
                        _buildBadge(
                          icon: Icons.timer_outlined,
                          label: state.dailyFocusMinutes == 0 ? 'Serbest' : ' dk/gün',
                          color: const Color(0xFFE8DFF5),
                          textColor: const Color(0xFF8E79AB),
                        ),
                        _buildBadge(
                          icon: Icons.star_border_rounded,
                          label: state.coreGoals.length > 1
                              ? '${state.coreGoals.length} Alan'
                              : (state.coreGoals.isNotEmpty ? state.coreGoals.first.split(' ').first : 'Planlama'),
                          color: const Color(0xFFEBF7EE),
                          textColor: const Color(0xFF6B9B78),
                        ),
                      ],
                    ),
                  ],
                ),

                // Masalsı Damga / Mühür
                Positioned(
                  right: 0,
                  bottom: 54,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFC47B89).withValues(alpha: 0.6), width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'VERIFIED ✦',
                        style: AppTypography.sfPro(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFC47B89).withValues(alpha: 0.8),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 2),

          // ── Planlamaya Başla Butonu ──
          AestheticPlannerButton(
            text: 'Planlamaya Başla',
            icon: Icons.arrow_forward_rounded,
            height: 52,
            onPressed: onFinish,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.sfPro(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
