import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../models/club.dart';
import '../../models/club_focus_session.dart';
import '../../providers/club_provider.dart';

/// ⏱️ Calenda — Kulüp Canlı Birlikte Odaklanma Odası ve Sayacı
class ClubFocusSessionScreen extends StatefulWidget {
  final Club club;
  final ClubFocusSession? initialSession;

  const ClubFocusSessionScreen({
    super.key,
    required this.club,
    this.initialSession,
  });

  @override
  State<ClubFocusSessionScreen> createState() => _ClubFocusSessionScreenState();
}

class _ClubFocusSessionScreenState extends State<ClubFocusSessionScreen> {
  int _selectedDuration = 25;
  String _selectedTag = 'Ders & Çalışma';
  final _titleController = TextEditingController(text: 'Birlikte Odaklanma');

  int _rabbitFrame = 0;
  Timer? _rabbitTimer;
  bool _isProcessing = false;

  static const List<int> _durations = [15, 25, 30, 45, 60];
  static const List<String> _tags = [
    'Ders & Çalışma',
    'Proje & İş',
    'Kitap & Okuma',
    'Sakin Odak',
    'Yaratıcı & Tasarım',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSession != null) {
      _selectedDuration = widget.initialSession!.durationMinutes;
      _selectedTag = widget.initialSession!.focusTag;
      _titleController.text = widget.initialSession!.title;
      if (widget.initialSession!.isActive) {
        _startRabbitAnimation();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.rabbitFocus1), context);
    precacheImage(const AssetImage(AppAssets.rabbitFocus2), context);
  }

  @override
  void dispose() {
    _rabbitTimer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  void _startRabbitAnimation() {
    _rabbitTimer?.cancel();
    _rabbitTimer = Timer.periodic(const Duration(milliseconds: 550), (_) {
      if (mounted) {
        setState(() {
          _rabbitFrame = (_rabbitFrame == 0) ? 1 : 0;
        });
      }
    });
  }

  void _stopRabbitAnimation() {
    _rabbitTimer?.cancel();
    _rabbitTimer = null;
    if (mounted) {
      setState(() => _rabbitFrame = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clubProv = context.watch<ClubProvider>();
    final user = context.watch<PlannerProvider>().userProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Aktif oturum: Provider'daki güncel oturum veya widget başlangıç oturumu
    final session = (clubProv.activeSession != null && clubProv.activeSession!.clubId == widget.club.id)
        ? clubProv.activeSession
        : widget.initialSession;

    final isHost = session == null ||
        (session.hostUserId == (user.id.isNotEmpty ? user.id : 'local_host')) ||
        (session.hostName.toLowerCase().replaceAll('@', '').trim() ==
            user.displayName.toLowerCase().replaceAll('@', '').trim());
    final isParticipant = session != null &&
        (session.participantIds.contains(user.id) ||
         session.participantNames.any((n) =>
             n.toLowerCase().replaceAll('@', '').trim() ==
             user.displayName.toLowerCase().replaceAll('@', '').trim()));
    final isWaiting = session == null || session.isWaiting;
    final isActive = session != null && session.isActive;

    if (isActive && _rabbitTimer == null) {
      _startRabbitAnimation();
    } else if (!isActive && _rabbitTimer != null) {
      _stopRabbitAnimation();
    }

    final cardBg = isDark ? const Color(0xFF16271D) : Colors.white.withValues(alpha: 0.92);
    final primaryText = isDark ? Colors.white : const Color(0xFF142918);
    final mutedText = isDark ? const Color(0xFFA5B8AB) : const Color(0xFF6B7F6F);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppleAmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── 1. ÜST BAR: GERİ TUŞU + KULÜP ADI + DURUM ROZETİ ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    BouncingWidget(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF284834) : const Color(0xFFE4EDE1),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.club.name,
                            style: AppTypography.sfProRounded(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isWaiting
                                ? 'Hazırlık Lobisi'
                                : (session.isLocked ? '🔒 Canlı Seans (Kilitli)' : 'Canlı Seans • Katılımlar Açık'),
                            style: AppTypography.sfPro(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isActive ? const Color(0xFF2E7D32) : mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (session != null)
                      BouncingWidget(
                        onTap: () => _confirmEndOrLeave(context, clubProv, isHost),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isHost ? 'Bitir' : 'Ayrıl',
                            style: AppTypography.sfProRounded(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD9534F),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── 2. KAYDIRILABİLİR İÇERİK: TAVŞANLI SAYAÇ & KATILIMCILAR ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // Durum Rozeti
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isWaiting
                              ? (isDark ? const Color(0xFF2B3A26) : const Color(0xFFEFF5EB))
                              : (isDark ? const Color(0xFF1D3B23) : const Color(0xFFE3F5E6)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isWaiting
                                ? (isDark ? const Color(0xFF3F5538) : const Color(0xFFD5E5CF))
                                : const Color(0xFF66E384).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isWaiting ? const Color(0xFFB59A57) : const Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isWaiting
                                  ? '⏳ Katılımcılar Bekleniyor'
                                  : (session.isLocked
                                      ? '🔒 Seans Kilitlendi (İlk 5 Dk Doldu)'
                                      : '🟢 Katılıma Açık • Kalan: ${_formatJoinRemaining(session.joinWindowRemainingSeconds)}'),
                              style: AppTypography.sfPro(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isWaiting
                                    ? (isDark ? const Color(0xFFE2C98A) : const Color(0xFF665319))
                                    : (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF1E5B29)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ─── TAVŞANLI BÜYÜK SAYAÇ HALKASI ───
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Arka Plan Çemberi
                            SizedBox(
                              width: 210,
                              height: 210,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 9,
                                strokeCap: StrokeCap.round,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? const Color(0xFF23382B) : const Color(0xFFEAEFE7),
                                ),
                              ),
                            ),

                            // İlerleme Çemberi
                            SizedBox(
                              width: 210,
                              height: 210,
                              child: CircularProgressIndicator(
                                value: isActive ? session.progressPercent : 0.0,
                                strokeWidth: 9,
                                strokeCap: StrokeCap.round,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isActive ? const Color(0xFF4CAF50) : const Color(0xFF0E260A),
                                ),
                              ),
                            ),

                            // 🐰 ÇİFT KATMANLI TAVŞAN GÖRSELİ / ANİMASYONU
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(26),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      AppAssets.rabbitFocus1,
                                      width: 135,
                                      height: 135,
                                      fit: BoxFit.contain,
                                      gaplessPlayback: true,
                                    ),
                                    AnimatedOpacity(
                                      opacity: (isActive && _rabbitFrame == 1) ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 180),
                                      curve: Curves.easeInOut,
                                      child: Image.asset(
                                        AppAssets.rabbitFocus2,
                                        width: 135,
                                        height: 135,
                                        fit: BoxFit.contain,
                                        gaplessPlayback: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ⏱️ DAKİKA / GERİ SAYIM SAYACI
                      Text(
                        isWaiting ? '$_selectedDuration:00' : _formatRemainingTime(session.remainingSeconds),
                        style: AppTypography.sfProRounded(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                          letterSpacing: -1.0,
                        ),
                      ),

                      Text(
                        isWaiting ? 'Odak Süresi' : session.title,
                        style: AppTypography.sfPro(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: mutedText,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ─── BEKLEMEDEYKEN SÜRE SEÇİM BUTONLARI (SADECE LOBİDE) ───
                      if (isWaiting && isHost) ...[
                        Text(
                          'Süre Seçin (Dakika)',
                          style: AppTypography.sfPro(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: mutedText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _durations.map((dur) {
                            final isSel = _selectedDuration == dur;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: BouncingWidget(
                                onTap: () => setState(() => _selectedDuration = dur),
                                child: Container(
                                  width: 48,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? const Color(0xFF0E260A)
                                        : (isDark ? const Color(0xFF1E3024) : Colors.white),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSel
                                          ? const Color(0xFF0E260A)
                                          : (isDark ? const Color(0xFF2E4D37) : const Color(0xFFE2E8DE)),
                                    ),
                                    boxShadow: isSel
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF0E260A).withValues(alpha: 0.25),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    '$dur',
                                    style: AppTypography.sfProRounded(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isSel ? Colors.white : primaryText,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Etiket Seçici
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _tags.map((tag) {
                              final isSel = _selectedTag == tag;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: BouncingWidget(
                                  onTap: () => setState(() => _selectedTag = tag),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? (isDark ? const Color(0xFF284834) : const Color(0xFF0E260A))
                                          : (isDark ? const Color(0xFF16251C) : Colors.white),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSel
                                            ? const Color(0xFF0E260A)
                                            : (isDark ? const Color(0xFF2B4433) : const Color(0xFFE4EDE1)),
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: AppTypography.sfPro(
                                        fontSize: 12.5,
                                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                        color: isSel ? Colors.white : mutedText,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ─── 3. KATILIMCILAR LİSTESİ ───
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark ? const Color(0xFF284834) : const Color(0xFFE4EDE1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
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
                                  'Katılımcılar (${session?.participantCount ?? 1}/${widget.club.maxMembers})',
                                  style: AppTypography.sfProRounded(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                  ),
                                ),
                                if (session != null && !session.canJoin)
                                  Text(
                                    '🔒 Katılıma kapandı',
                                    style: AppTypography.sfPro(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFD9534F),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Katılımcı avatarları listesi
                            _buildParticipantsList(session, user, isDark, primaryText, mutedText),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 4. AKSİYON BUTONU (BAŞLAT / KATIL / BİTİR) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: _buildActionButton(
                  context,
                  clubProv,
                  session,
                  user,
                  isHost,
                  isParticipant,
                  isWaiting,
                  isActive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Katılımcı Avatarları
  Widget _buildParticipantsList(
    ClubFocusSession? session,
    UserProfile currentUser,
    bool isDark,
    Color primaryText,
    Color mutedText,
  ) {
    final names = session?.participantNames ?? [currentUser.displayName];
    final hostId = session?.hostUserId ?? (currentUser.id.isNotEmpty ? currentUser.id : 'local_host');
    final pIds = session?.participantIds ?? [hostId];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(names.length, (index) {
        final name = names[index];
        final id = index < pIds.length ? pIds[index] : '';
        final isUserHost = id == hostId;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E3224) : const Color(0xFFF3F8F0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFD9E7D4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF0E260A),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: AppTypography.sfPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              if (isUserHost) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEFE0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Kurucu',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1E4D27)),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  // Alt Aksiyon Butonu
  Widget _buildActionButton(
    BuildContext context,
    ClubProvider clubProv,
    ClubFocusSession? session,
    UserProfile user,
    bool isHost,
    bool isParticipant,
    bool isWaiting,
    bool isActive,
  ) {
    // 1. Oda henüz oluşturulmadıysa (Doğrudan ekrandan açılmışsa)
    if (session == null) {
      return BouncingWidget(
        onTap: _isProcessing ? null : () => _handleCreateAndStartRoom(clubProv, user),
        child: _buildCtaContainer(
          title: 'Odayı Aç & Katılımcıları Bekle',
          icon: Icons.meeting_room_rounded,
          color: const Color(0xFF0E260A),
        ),
      );
    }

    // 2. Lobi Durumu:
    if (isWaiting) {
      if (isHost) {
        return BouncingWidget(
          onTap: _isProcessing ? null : () => _handleStartActiveSession(clubProv),
          child: _buildCtaContainer(
            title: 'Birlikte Odaklanmayı Başlat',
            icon: Icons.play_arrow_rounded,
            color: const Color(0xFF0E260A),
          ),
        );
      } else if (!isParticipant) {
        return BouncingWidget(
          onTap: _isProcessing ? null : () => _handleJoinSession(clubProv, user),
          child: _buildCtaContainer(
            title: 'Odaya Katıl',
            icon: Icons.login_rounded,
            color: const Color(0xFF0E260A),
          ),
        );
      } else {
        // Katılımcı lobide bekliyor
        return _buildCtaContainer(
          title: 'Oda Sahibi Bekleniyor...',
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFF7A8D7D),
          disabled: true,
        );
      }
    }

    // 3. Aktif Seans:
    if (!isParticipant && !isHost) {
      if (session.canJoin) {
        return BouncingWidget(
          onTap: _isProcessing ? null : () => _handleJoinSession(clubProv, user),
          child: _buildCtaContainer(
            title: 'Seansa Katıl (Kalan: ${_formatJoinRemaining(session.joinWindowRemainingSeconds)})',
            icon: Icons.login_rounded,
            color: const Color(0xFF0E260A),
          ),
        );
      } else {
        return _buildCtaContainer(
          title: '🔒 Seans Kilitlendi (İlk 5 Dk Doldu)',
          icon: Icons.lock_outline_rounded,
          color: const Color(0xFF7A8D7D),
          disabled: true,
        );
      }
    }

    // Katılımcı veya host: Bitir / Ayrıl
    return BouncingWidget(
      onTap: () => _confirmEndOrLeave(context, clubProv, isHost),
      child: _buildCtaContainer(
        title: isHost ? 'Seansı Tamamla & Bitir' : 'Seanstan Ayrıl',
        icon: isHost ? Icons.check_circle_outline_rounded : Icons.exit_to_app_rounded,
        color: const Color(0xFF2E4E32),
      ),
    );
  }

  Widget _buildCtaContainer({
    required String title,
    required IconData icon,
    required Color color,
    bool disabled = false,
  }) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: disabled ? color.withValues(alpha: 0.6) : color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: _isProcessing
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTypography.sfProRounded(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _handleCreateAndStartRoom(
    ClubProvider clubProv,
    UserProfile user,
  ) async {
    setState(() => _isProcessing = true);
    final session = await clubProv.createFocusSessionRoom(
      title: _titleController.text.trim().isEmpty ? 'Birlikte Odaklanma' : _titleController.text.trim(),
      durationMinutes: _selectedDuration,
      focusTag: _selectedTag,
      userProfile: user,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (session != null) {
      AestheticSnackBar.showSuccess(context, 'Odaklanma odası açıldı! Katılımcılar katılabilir.');
    }
  }

  Future<void> _handleStartActiveSession(
    ClubProvider clubProv,
  ) async {
    setState(() => _isProcessing = true);
    final started = await clubProv.startActiveSession();
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (started != null) {
      AestheticSnackBar.showSuccess(context, 'Odaklanma başladı! Sayacınız devrede.');
    }
  }

  Future<void> _handleJoinSession(
    ClubProvider clubProv,
    UserProfile user,
  ) async {
    setState(() => _isProcessing = true);
    final success = await clubProv.joinActiveSession(user);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (success) {
      AestheticSnackBar.showSuccess(context, 'Seansa başarıyla katıldınız!');
    } else {
      AestheticSnackBar.showError(context, 'Seansa katılınamadı veya katılım süresi doldu.');
    }
  }

  void _confirmEndOrLeave(BuildContext context, ClubProvider clubProv, bool isHost) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isHost ? 'Seansı Bitir' : 'Seanstan Ayrıl',
          style: AppTypography.sfProRounded(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: Text(
          isHost
              ? 'Canlı odaklanma seansını tüm katılımcılar için bitirmek istiyor musunuz?'
              : 'Seans devam ediyor. Ayrılmak istediğinize emin misiniz?',
          style: AppTypography.sfPro(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              Navigator.pop(ctx);
              await clubProv.endCurrentSession();
              nav.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9534F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isHost ? 'Evet, Bitir' : 'Ayrıl', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatRemainingTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _formatJoinRemaining(int seconds) {
    final mins = seconds ~/ 60;
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
