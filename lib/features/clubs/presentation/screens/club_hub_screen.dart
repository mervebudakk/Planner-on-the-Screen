import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppleAmbientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── ÜST BAR ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (Navigator.of(context).canPop())
                      BouncingWidget(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8DE)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Color(0xFF1E3A1E),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const Spacer(),
                    // Ekle / Katıl Butonu
                    BouncingWidget(
                      onTap: () => CreateJoinClubSheet.show(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E260A),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0E260A).withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Yeni',
                              style: AppTypography.sfProRounded(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 10,
                              bottom: MediaQuery.of(context).padding.bottom + 96,
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
      ),
    );
  }

  // ── BOŞ DURUM (HİÇ KULÜBÜ YOKSA) ──
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE4ECE0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF5EB),
                  shape: BoxShape.circle,
                ),
                child: const Text('🍵', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz Bir Kulübün Yok',
                style: AppTypography.title3(
                  color: const Color(0xFF1E3A1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Arkadaşlarınızla özel bir çalışma çemberi kurabilir ya da size verilen davet koduyla bir kulübe katılabilirsiniz.',
                textAlign: TextAlign.center,
                style: AppTypography.footnote(
                  color: const Color(0xFF7A8B77),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: BouncingWidget(
                      onTap: () => CreateJoinClubSheet.show(context, initialTabIndex: 0),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E260A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Kulüp Oluştur',
                          style: AppTypography.footnote(
                            color: Colors.white,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BouncingWidget(
                      onTap: () => CreateJoinClubSheet.show(context, initialTabIndex: 1),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4EB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4E0D0)),
                        ),
                        child: Text(
                          'Kod ile Katıl',
                          style: AppTypography.footnote(
                            color: const Color(0xFF1E3A1E),
                            weight: FontWeight.w700,
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
