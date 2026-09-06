import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../models/club.dart';
import '../../models/club_member.dart';
import '../../providers/club_provider.dart';

/// 🏛️ Calenda — Kulüp Detay ve Canlı Çalışma Salonu (Lounge) Ekranı
class ClubDetailScreen extends StatefulWidget {
  final Club club;
  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ClubProvider>().selectClub(widget.club.id);
      }
    });
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📋 Davet kodu panoya kopyalandı: $code',
          style: AppTypography.footnote(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A1E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showStartSessionSheet(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'Birlikte Odaklanma');
    int selectedDuration = 25;
    const String selectedTag = 'Ders & Çalışma';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return Container(
              margin: EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: bottomInset > 0 ? bottomInset + 12 : 24,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFDF9),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 24,
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
                        color: const Color(0xFFD5DDD0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Birlikte Seans Başlat',
                    style: AppTypography.title3(
                      color: const Color(0xFF1E3A1E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Seansı başlattığınızda diğer kulüp üyelerine anlık bildirim gönderilecek.',
                    style: AppTypography.caption1(
                      color: const Color(0xFF6B7E68),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'SEANS BAŞLIĞI',
                    style: AppTypography.caption2(
                      color: const Color(0xFF7A8B77),
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    style: AppTypography.body(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF4F7F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'SÜRE SEÇİMİ',
                    style: AppTypography.caption2(
                      color: const Color(0xFF7A8B77),
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [25, 45, 60].map((dur) {
                      final isSel = selectedDuration == dur;
                      return Expanded(
                        child: BouncingWidget(
                          onTap: () => setSheetState(() => selectedDuration = dur),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFF1E3A1E)
                                  : const Color(0xFFF4F7F1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$dur dk',
                              style: AppTypography.caption1(
                                color: isSel ? Colors.white : const Color(0xFF2C4329),
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  BouncingWidget(
                    onTap: () async {
                      final user = context.read<PlannerProvider>().userProfile;
                      final messenger = ScaffoldMessenger.of(context);
                      final clubProv = context.read<ClubProvider>();
                      Navigator.of(sheetCtx).pop();

                      await clubProv.startFocusSession(
                            title: titleCtrl.text.trim(),
                            durationMinutes: selectedDuration,
                            focusTag: selectedTag,
                            userProfile: user,
                          );

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '🌿 Seans başlatıldı! Kulüp üyelerine bildirim gönderildi.',
                            style: AppTypography.footnote(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF1E3A1E),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E260A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Seansı Başlat & Üyeleri Çağır',
                        style: AppTypography.footnote(
                          color: Colors.white,
                          weight: FontWeight.w700,
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

  @override
  Widget build(BuildContext context) {
    final clubProvider = context.watch<ClubProvider>();
    final activeSession = clubProvider.activeSession;
    final members = clubProvider.members;
    final club = clubProvider.selectedClub ?? widget.club;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppleAmbientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── ÜST BAR ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    BouncingWidget(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8DE)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: Color(0xFF1E3A1E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club.name,
                            style: AppTypography.title3(
                              color: const Color(0xFF1E3A1E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Hedef: Günde ${club.dailyTargetMinutes} dk',
                            style: AppTypography.caption1(
                              color: const Color(0xFF6A7F66),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Davet Kodu Rozeti
                    BouncingWidget(
                      onTap: () => _copyInviteCode(club.inviteCode),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4EB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD3E0CE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              club.inviteCode,
                              style: AppTypography.caption1(
                                weight: FontWeight.w700,
                                color: const Color(0xFF1E3A1E),
                              ).copyWith(letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.copy,
                              size: 13,
                              color: Color(0xFF4C6648),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── İÇERİK LİSTESİ ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: [
                    // 1. CANLI ÇALIŞMA SALONU KARTI
                    _buildLiveLoungeCard(context, activeSession),
                    const SizedBox(height: 20),

                    // 2. KULÜP BİLGİ & KAPASİTE ÇUBUĞU
                    _buildClubCapacityBar(club, members.length),
                    const SizedBox(height: 20),

                    // 3. ÜYELER VE GÜNLÜK HEDEF TAKİBİ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Üye Hedef & Sadakat Tablosu',
                          style: AppTypography.headline(
                            color: const Color(0xFF1E3A1E),
                          ),
                        ),
                        Text(
                          'Bugünkü İlerleme',
                          style: AppTypography.caption1(
                            color: const Color(0xFF7A8B77),
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (members.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Henüz üye listesi yükleniyor...',
                          style: AppTypography.caption1(
                            color: const Color(0xFF8B9B88),
                          ),
                        ),
                      )
                    else
                      ...members.map((m) => _buildMemberTile(m, activeSession)),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CANLI ÇALIŞMA SALONU KARTI ──
  Widget _buildLiveLoungeCard(BuildContext context, dynamic activeSession) {
    final bool hasActive = activeSession != null && activeSession.isActive;

    if (hasActive) {
      final remaining = activeSession.remainingSeconds;
      final mins = (remaining ~/ 60).toString().padLeft(2, '0');
      final secs = (remaining % 60).toString().padLeft(2, '0');
      final host = activeSession.hostName;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A1E), Color(0xFF2D552C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A1E).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF66E384),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'CANLI ODAKLANMA SEANSI',
                  style: AppTypography.caption2(
                    color: const Color(0xFFBCE8C5),
                    weight: FontWeight.w700,
                  ).copyWith(letterSpacing: 1),
                ),
                const Spacer(),
                Text(
                  '$mins:$secs',
                  style: AppTypography.title2(
                    color: Colors.white,
                  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              activeSession.title,
              style: AppTypography.title3(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@$host tarafından başlatıldı • ${activeSession.focusTag}',
              style: AppTypography.caption1(
                color: const Color(0xFFD6E8D4),
              ),
            ),
            const SizedBox(height: 14),

            // İlerleme Çubuğu
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: activeSession.progressPercent,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF66E384)),
              ),
            ),
            const SizedBox(height: 16),

            BouncingWidget(
              onTap: () => Navigator.of(context).pop(), // Sayaca dön
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF1E3A1E)),
                    const SizedBox(width: 6),
                    Text(
                      'Sayacımı Bu Seansla Eşitle',
                      style: AppTypography.caption1(
                        color: const Color(0xFF1E3A1E),
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Aktif seans yoksa: Seans başlatma kartı
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🍵', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sessiz Çalışma Salonu',
                      style: AppTypography.headline(
                        color: const Color(0xFF1E3A1E),
                      ),
                    ),
                    Text(
                      'Şu an aktif bir seans yok. İlk adımı sen at!',
                      style: AppTypography.caption1(
                        color: const Color(0xFF7A8B77),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BouncingWidget(
            onTap: () => _showStartSessionSheet(context),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0E260A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Birlikte Seans Başlat',
                    style: AppTypography.caption1(
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── KULÜP KAPASİTE ÇUBUĞU (MAX 15 KİŞİ) ──
  Widget _buildClubCapacityBar(Club club, int memberCount) {
    final count = memberCount > 0 ? memberCount : club.memberCount;
    final maxM = club.maxMembers;
    final ratio = (count / maxM).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kulüp Kapasitesi (Özel Çember)',
                style: AppTypography.caption1(
                  weight: FontWeight.w600,
                  color: const Color(0xFF334B30),
                ),
              ),
              Text(
                '$count / $maxM Üye',
                style: AppTypography.caption1(
                  weight: FontWeight.w700,
                  color: const Color(0xFF1E3A1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E9DE),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF3B6837)),
            ),
          ),
        ],
      ),
    );
  }

  // ── ÜYE KARTI (HEDEF & SADAKAT TAKİBİ) ──
  Widget _buildMemberTile(ClubMember member, dynamic activeSession) {
    final isHostingNow = activeSession != null &&
        activeSession.isActive &&
        activeSession.hostUserId == member.userId;
    final isFocusing = member.isFocusingNow || isHostingNow;
    final progress = member.goalProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFocusing
              ? const Color(0xFF5AB664).withValues(alpha: 0.5)
              : const Color(0xFFE9EFE6),
          width: isFocusing ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE6),
              shape: BoxShape.circle,
              border: Border.all(
                color: isFocusing ? const Color(0xFF4CAF50) : const Color(0xFFD6DEC0),
                width: isFocusing ? 2 : 1,
              ),
            ),
            child: Text(
              member.displayName.isNotEmpty
                  ? member.displayName.characters.first.toUpperCase()
                  : 'Ü',
              style: AppTypography.title3(
                color: const Color(0xFF1E3A1E),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // İsim & Durum
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.displayName,
                        style: AppTypography.footnote(
                          weight: FontWeight.w700,
                          color: const Color(0xFF1E3A1E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.isOwner) ...[
                      const SizedBox(width: 4),
                      const Text('👑', style: TextStyle(fontSize: 11)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                if (isFocusing)
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Şu an odakta 🟢',
                        style: AppTypography.caption2(
                          color: const Color(0xFF2E7D32),
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Hedef: ${member.dailyGoalMinutes} dk',
                    style: AppTypography.caption2(
                      color: const Color(0xFF8B9B88),
                    ),
                  ),
              ],
            ),
          ),

          // İlerleme & Süre
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${member.todayFocusMinutes} / ${member.dailyGoalMinutes} dk',
                style: AppTypography.caption1(
                  weight: FontWeight.w700,
                  color: member.isGoalMet
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF1E3A1E),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 68,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE8EDE4),
                    valueColor: AlwaysStoppedAnimation(
                      member.isGoalMet
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2D5A27),
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
}
