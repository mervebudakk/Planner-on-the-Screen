import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../models/club.dart';
import '../../models/club_focus_session.dart';
import '../../models/club_member.dart';
import '../../providers/club_provider.dart';
import 'club_focus_session_screen.dart';

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
    AestheticSnackBar.showSuccess(context, 'Davet kodu panoya kopyalandı: $code');
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
                  padding: EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    MediaQuery.of(context).padding.bottom + 24,
                  ),
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
    final session = activeSession is ClubFocusSession ? activeSession : null;
    final bool hasActiveOrWaiting = session != null &&
        (session.isActive || session.isWaiting);

    if (hasActiveOrWaiting) {
      final remaining = session.remainingSeconds;
      final mins = (remaining ~/ 60).toString().padLeft(2, '0');
      final secs = (remaining % 60).toString().padLeft(2, '0');
      final host = session.hostName;
      final isWaiting = session.isWaiting;

      return BouncingWidget(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClubFocusSessionScreen(
                club: widget.club,
                initialSession: session,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isWaiting
                  ? const [Color(0xFF223524), Color(0xFF2E462F)]
                  : const [Color(0xFF1E3A1E), Color(0xFF2D552C)],
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
                    decoration: BoxDecoration(
                      color: isWaiting ? const Color(0xFFFFD166) : const Color(0xFF66E384),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isWaiting ? 'HAZIRLIK LOBİSİ' : 'CANLI ODAKLANMA SEANSI',
                    style: AppTypography.caption2(
                      color: isWaiting ? const Color(0xFFFFEAA7) : const Color(0xFFBCE8C5),
                      weight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1),
                  ),
                  const Spacer(),
                  Text(
                    isWaiting ? '${session.durationMinutes}:00' : '$mins:$secs',
                    style: AppTypography.title2(
                      color: Colors.white,
                    ).copyWith(fontFeatures: kIsWeb ? null : const [FontFeature.tabularFigures()]),
                  ),
                  const SizedBox(width: 8),
                  // Seansı Kapat Butonu
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Text(
                            'Seansı Kapat',
                            style: AppTypography.sfProRounded(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          content: Text(
                            'Bu odaklanma seansını sonlandırmak istiyor musunuz?',
                            style: AppTypography.sfPro(fontSize: 14),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Vazgeç'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD9534F),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Evet, Kapat', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await context.read<ClubProvider>().endCurrentSession();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                session.title,
                style: AppTypography.title3(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isWaiting
                    ? '@$host tarafından açıldı • ${session.participantCount} kişi bekliyor'
                    : '@$host tarafından başlatıldı • ${session.focusTag}',
                style: AppTypography.caption1(
                  color: const Color(0xFFD6E8D4),
                ),
              ),
              const SizedBox(height: 14),

              // İlerleme Çubuğu
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: isWaiting ? 0.0 : session.progressPercent,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    isWaiting ? const Color(0xFFFFD166) : const Color(0xFF66E384),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Text(
                    isWaiting
                        ? '👉 Odaya git ve seansı başlat'
                        : '👉 Canlı seans ekranına git',
                    style: AppTypography.caption1(
                      color: const Color(0xFFBCE8C5),
                      weight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFBCE8C5), size: 12),
                ],
              ),
            ],
          ),
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
          Text(
            'Sessiz Çalışma Salonu',
            style: AppTypography.headline(
              color: const Color(0xFF1E3A1E),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Şu an aktif bir seans yok. İlk adımı sen at!',
            style: AppTypography.caption1(
              color: const Color(0xFF7A8B77),
            ),
          ),
          const SizedBox(height: 16),
          BouncingWidget(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClubFocusSessionScreen(club: widget.club),
                ),
              );
            },
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9EFE6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.group_outlined, size: 16, color: Color(0xFF334B30)),
                  const SizedBox(width: 6),
                  Text(
                    'Üye Kapasitesi',
                    style: AppTypography.footnote(
                      weight: FontWeight.w600,
                      color: const Color(0xFF334B30),
                    ),
                  ),
                ],
              ),
              Text(
                '$count / $maxM Üye',
                style: AppTypography.footnote(
                  weight: FontWeight.w700,
                  color: const Color(0xFF334B30),
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
    final session = activeSession is ClubFocusSession ? activeSession : null;
    final isSessionActive = session != null &&
        session.isActive &&
        session.remainingSeconds > 0;
    final isUserInSession = session != null &&
        (session.hostUserId == member.userId ||
         session.hostName.toLowerCase().replaceAll('@', '').trim() == member.displayName.toLowerCase().replaceAll('@', '').trim() ||
         session.participantIds.contains(member.userId) ||
         session.participantNames.any((n) => n.toLowerCase().replaceAll('@', '').trim() == member.displayName.toLowerCase().replaceAll('@', '').trim()));
    final isFocusing = isSessionActive && isUserInSession;
    final isWaitingInLobby = session != null &&
        session.isWaiting &&
        isUserInSession;
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
              : (isWaitingInLobby ? const Color(0xFFE5A93C).withValues(alpha: 0.5) : const Color(0xFFE9EFE6)),
          width: (isFocusing || isWaitingInLobby) ? 1.5 : 1.0,
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
                color: isFocusing
                    ? const Color(0xFF4CAF50)
                    : (isWaitingInLobby ? const Color(0xFFE5A93C) : const Color(0xFFD6DEC0)),
                width: (isFocusing || isWaitingInLobby) ? 2 : 1,
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
                Text(
                  member.displayName,
                  style: AppTypography.footnote(
                    weight: FontWeight.w700,
                    color: const Color(0xFF1E3A1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                else if (isWaitingInLobby)
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE5A93C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Odada bekliyor ⏳',
                        style: AppTypography.caption2(
                          color: const Color(0xFF9E7019),
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
