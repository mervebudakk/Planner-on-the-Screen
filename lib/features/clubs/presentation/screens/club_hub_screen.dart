import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../models/club.dart';
import '../../providers/club_provider.dart';
import '../widgets/create_join_club_sheet.dart';
import 'club_detail_screen.dart';

/// 🌿 Calenda — Kulüplerim Ana Hub Ekranı
class ClubHubScreen extends StatefulWidget {
  const ClubHubScreen({super.key});

  @override
  State<ClubHubScreen> createState() => _ClubHubScreenState();
}

class _ClubHubScreenState extends State<ClubHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final user = context.read<PlannerProvider>().userProfile;
        context.read<ClubProvider>().loadUserClubs(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubProvider = context.watch<ClubProvider>();
    final clubs = clubProvider.myClubs;
    final isLoading = clubProvider.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Yüzen alt toolbox konumu: bottom 18 + bottomPadding + dock 66 = bottomPadding + 84.
    // Net emniyet boşluğu payı: bottomPadding + 104.
    final dockClearance = bottomPadding + 104.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── 1. Masalsı Suluboya Pastel Zemin ──
          const AppleAmbientBackground(child: SizedBox.expand()),

          // ── 2. Masada Çalışan Kawaii Hayvanlar (Kulüp Temalı Soft Çizim) ──
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.45 : 0.95,
              child: Image.asset(
                AppAssets.clubStudyBg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                gaplessPlayback: true,
              ),
            ),
          ),

          // ── 3. Ön Plan İçeriği (Top Bar + Kartlar) ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── ÜST BAR (Yalnızca Kulüpler Varsa Gösterilir) ──
                if (clubs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BouncingWidget(
                          onTap: () => CreateJoinClubSheet.show(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E3024) : Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFE2E8DE),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: isDark ? Colors.white : const Color(0xFF1E3A1E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── İÇERİK ──
                Expanded(
                  child: isLoading && clubs.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : clubs.isEmpty
                          ? _buildEmptyState(context, dockClearance, isDark)
                          : ListView.builder(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 10,
                                bottom: dockClearance + 16,
                              ),
                              itemCount: clubs.length,
                              itemBuilder: (ctx, index) {
                                final club = clubs[index];
                                return _buildClubCard(context, club);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BOŞ DURUM (HİÇ KULÜBÜ YOKSA - EKRANDA OPTİK OLARAK TAM ORTALI) ──
  Widget _buildEmptyState(BuildContext context, double dockClearance, bool isDark) {
    return Padding(
      // Alt yüzen dock payını düşerek kartı gerçek görünür alanın tam ortasına yerleştirir
      padding: EdgeInsets.only(bottom: dockClearance),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF14241B).withValues(alpha: 0.32)
                  : Colors.white.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.30 : 0.85),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Henüz Bir Kulübün Yok',
                  style: AppTypography.sfProRounded(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F2612),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Arkadaşlarınızla özel bir çalışma çemberi kurabilir ya da size verilen davet koduyla bir kulübe katılabilirsiniz.',
                  textAlign: TextAlign.center,
                  style: AppTypography.sfPro(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCAD8CD) : const Color(0xFF243B27),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: BouncingWidget(
                        onTap: () => CreateJoinClubSheet.show(context, initialTabIndex: 0),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E260A).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0E260A).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'Kulüp Oluştur',
                            style: AppTypography.sfProRounded(
                              fontSize: 14.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BouncingWidget(
                        onTap: () => CreateJoinClubSheet.show(context, initialTabIndex: 1),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1B2E20).withValues(alpha: 0.65)
                                : Colors.white.withValues(alpha: 0.70),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2E4D37)
                                  : const Color(0xFF0E260A).withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            'Kod ile Katıl',
                            style: AppTypography.sfProRounded(
                              fontSize: 14.5,
                              color: isDark ? Colors.white : const Color(0xFF0E260A),
                              fontWeight: FontWeight.w700,
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
      ),
    );
  }

  // ── KULÜP KARTI ──
  Widget _buildClubCard(BuildContext context, Club club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: BouncingWidget(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => ClubDetailScreen(club: club),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE4ECE0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🌿', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: AppTypography.headline(
                            color: const Color(0xFF1E3A1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hedef: Günde ${club.dailyTargetMinutes} dk',
                          style: AppTypography.caption1(
                            color: const Color(0xFF7A8B77),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFFB5C4B2),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Alt Bilgiler: Kapasite ve Davet Kodu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F6EF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          size: 14,
                          color: Color(0xFF4C6648),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${club.memberCount} / ${club.maxMembers} Üye',
                          style: AppTypography.caption2(
                            color: const Color(0xFF4C6648),
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Kod: ${club.inviteCode}',
                    style: AppTypography.caption2(
                      color: const Color(0xFF8B9B88),
                      weight: FontWeight.w600,
                    ).copyWith(letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
