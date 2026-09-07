import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../focus/presentation/widgets/focus_duration_picker_sheet.dart';
import '../../../focus/presentation/widgets/focus_tag_picker_sheet.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../../../core/services/error_logger.dart';
import '../../../../core/services/supabase_service.dart';
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
  bool _hasCreditedCompletion = false;

  static const List<int> _durations = [15, 20, 25, 30, 45, 60, 90];
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

  void _showScrollableDurationPicker(BuildContext context) {
    FocusDurationPickerSheet.show(
      context,
      isFocusMode: true,
      options: _durations,
      selectedDuration: _selectedDuration,
      onDurationSelected: (val) {
        setState(() => _selectedDuration = val);
      },
    );
  }

  void _showTagPicker(BuildContext context) {
    FocusTagPickerSheet.show(
      context,
      tags: _tags,
      activeTag: _selectedTag,
      onTagSelected: (tag) => setState(() => _selectedTag = tag),
    );
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
    final isPreLobby = session == null;
    final isWaiting = session != null && session.isWaiting;
    final isActive = session != null && session.isActive;

    if (isActive && _rabbitTimer == null) {
      _startRabbitAnimation();
    } else if (!isActive && _rabbitTimer != null) {
      _stopRabbitAnimation();
    }

    // 🌿 Doğal Süre Bitişi: Oturum tamamlandığında otomatik kredi kaydı ve tebrik mesajı
    final isCompletedNaturally = session != null &&
        (session.status == 'completed' || (session.isActive && session.remainingSeconds <= 0));
    if (isCompletedNaturally && !_hasCreditedCompletion && (isHost || isParticipant)) {
      _hasCreditedCompletion = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        final durationMinutes = session.durationMinutes;
        final planner = context.read<PlannerProvider>();
        final nav = Navigator.of(context);
        try {
          await planner.recordFocusSession(durationMinutes);
          await clubProv.recordFocusCompleted(
            minutes: durationMinutes,
            userProfile: user,
          );
          unawaited(
            SupabaseService.instance.logFocusSession(
              durationMinutes: durationMinutes,
              mode: 'club_focus',
              focusTag: session.focusTag,
            ).catchError((e, st) {
              ErrorLogger.log('ClubFocusSessionScreen.logFocusSessionAuto', e, st);
            }),
          );
        } catch (e, st) {
          ErrorLogger.log('ClubFocusSessionScreen.autoComplete', e, st);
        }

        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              '🎉 Tebrikler!',
              style: AppTypography.sfProRounded(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            content: Text(
              '$durationMinutes dakikalık "${session.focusTag}" odaklanma seansını kulübünüzle birlikte başarıyla tamamladınız! 🌿 Süreniz profilinize ve haftalık ritminize eklendi.',
              style: AppTypography.sfPro(fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  nav.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Harika!', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      });
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
                padding: const EdgeInsets.fromLTRB(16, 3, 16, 10),
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
                            isPreLobby
                                ? 'Seans Hazırlığı'
                                : (isWaiting
                                    ? 'Hazırlık Lobisi'
                                    : (session.isLocked ? '🔒 Odaklanma Seansı (Kilitli)' : 'Odaklanma Seansı')),
                            style: AppTypography.sfPro(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isActive ? const Color(0xFF2E7D32) : mutedText,
                            ),
                          ),
                        ],
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
                          color: isPreLobby
                              ? (isDark ? const Color(0xFF1E3024) : const Color(0xFFEFF5EB))
                              : (isWaiting
                                  ? (isDark ? const Color(0xFF28251C) : const Color(0xFFF9F5EC))
                                  : (isDark ? const Color(0xFF1E3524) : const Color(0xFFEDF7ED))),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPreLobby
                                ? (isDark ? const Color(0xFF2E4D37) : const Color(0xFFD5E5CF))
                                : (isWaiting
                                    ? (isDark ? const Color(0xFF453D2A) : const Color(0xFFEADFCA))
                                    : (isDark ? const Color(0xFF2D4D35) : const Color(0xFFD3E7D5))),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isPreLobby
                                    ? const Color(0xFF4A7C59)
                                    : (isWaiting
                                        ? const Color(0xFFB59A57)
                                        : const Color(0xFF3DA34F)),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPreLobby
                                  ? 'Oda Hazırlığı'
                                  : (isWaiting
                                      ? '⏳ Katılımcılar Bekleniyor'
                                      : (session.isLocked
                                          ? '🌿 Odak Modu • Sessiz Seans'
                                          : '🟢 Katılıma Açık • Kalan: ${_formatJoinRemaining(session.joinWindowRemainingSeconds)}')),
                              style: AppTypography.sfPro(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isPreLobby
                                    ? (isDark ? const Color(0xFFA5CFA9) : const Color(0xFF2E5D34))
                                    : (isWaiting
                                        ? (isDark ? const Color(0xFFE5CC8D) : const Color(0xFF7A6424))
                                        : (isDark ? const Color(0xFF7ED88B) : const Color(0xFF2D6F37))),
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
                            // Arka Plan Işıma Efekti (Matcha Glow)
                            Container(
                              width: 210,
                              height: 210,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? (isDark
                                        ? const Color(0xFF1E2D22).withValues(alpha: 0.5)
                                        : const Color(0xFFEFF5ED).withValues(alpha: 0.8))
                                    : Colors.transparent,
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: (isDark ? const Color(0xFF4E9E67) : const Color(0xFF88B38E))
                                              .withValues(alpha: 0.22),
                                          blurRadius: 32,
                                          spreadRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),

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
                                  isActive
                                      ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E4E32))
                                      : const Color(0xFF2E4E32),
                                ),
                              ),
                            ),

                            // 🐰 TAVŞAN GÖRSELİ / ANİMASYONU (Tekil kare geçişi - Çift katman çakışması önlendi)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(26),
                                child: Image.asset(
                                  (isActive && _rabbitFrame == 1)
                                      ? AppAssets.rabbitFocus2
                                      : AppAssets.rabbitFocus1,
                                  width: 135,
                                  height: 135,
                                  fit: BoxFit.contain,
                                  gaplessPlayback: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ⏱️ DAKİKA & ETİKET (Odak ekranının birebir aynısı)
                      if (isPreLobby) ...[
                        // 1. Oda Kurulumunda Süre Seçimi (Focus ekranı stili)
                        BouncingWidget(
                          onTap: () => _showScrollableDurationPicker(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$_selectedDuration:00',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.sfProRounded(
                                        fontSize: 44,
                                        fontWeight: FontWeight.w800,
                                        color: primaryText,
                                        letterSpacing: -1.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.unfold_more_rounded,
                                      size: 22,
                                      color: mutedText.withValues(alpha: 0.65),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Süreyi değiştirmek için dokun',
                                  style: AppTypography.sfPro(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 2. Oda Kurulumunda Etiket Seçimi (Focus ekranı stili)
                        BouncingWidget(
                          onTap: () => _showTagPicker(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E3326) : const Color(0xFFEDF3EB),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark ? const Color(0xFF284834) : const Color(0xFFD4E0D2),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FocusTagPickerSheet.getTagIcon(_selectedTag),
                                  size: 15,
                                  color: isDark ? Colors.white : primaryText,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  _selectedTag,
                                  style: AppTypography.sfProRounded(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: mutedText,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else if (isWaiting) ...[
                        // ⏱️ Hazırlık Lobisinde Süre ve Etiket Sabit (Değiştirilemez)
                        Column(
                          children: [
                            Text(
                              '${session.durationMinutes}:00',
                              textAlign: TextAlign.center,
                              style: AppTypography.sfProRounded(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: primaryText,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Hedef Süre',
                              style: AppTypography.sfPro(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3326) : const Color(0xFFEDF3EB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? const Color(0xFF284834) : const Color(0xFFD4E0D2),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FocusTagPickerSheet.getTagIcon(session.focusTag),
                                size: 15,
                                color: isDark ? Colors.white : primaryText,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                session.focusTag,
                                style: AppTypography.sfProRounded(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        // ⏱️ Canlı Seans (Geri Sayım Sayacı)
                        Text(
                          _formatRemainingTime(session.remainingSeconds),
                          textAlign: TextAlign.center,
                          style: AppTypography.sfProRounded(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                            letterSpacing: -1.5,
                          ).copyWith(fontFeatures: kIsWeb ? null : const [FontFeature.tabularFigures()]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Birlikte sessizce odaklanıyorsunuz 🌿',
                          style: AppTypography.sfPro(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: mutedText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3326) : const Color(0xFFEDF3EB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? const Color(0xFF284834) : const Color(0xFFD4E0D2),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FocusTagPickerSheet.getTagIcon(session.focusTag),
                                size: 15,
                                color: isDark ? Colors.white : primaryText,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                session.focusTag,
                                style: AppTypography.sfProRounded(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: primaryText,
                                ),
                              ),
                            ],
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
                            _buildParticipantsList(session, user, isDark, primaryText, mutedText, isPreLobby),
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
                  isPreLobby,
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
    bool isPreLobby,
  ) {
    final names = session?.participantNames ?? [currentUser.displayName];
    final hostId = session?.hostUserId ?? (currentUser.id.isNotEmpty ? currentUser.id : 'local_host');
    final pIds = session?.participantIds ?? [hostId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(names.length, (index) {
            final name = names[index];
            final id = index < pIds.length ? pIds[index] : '';
            final isUserHost = id == hostId;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
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
                    backgroundColor: isDark ? const Color(0xFF284834) : const Color(0xFFDDEADE),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'Ü',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E3A1E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    name,
                    style: AppTypography.sfPro(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  if (session != null && session.isActive) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  if (isUserHost) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF253B2A) : const Color(0xFFE2EFE0),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark ? const Color(0xFF385E3E) : const Color(0xFFCEE0CC),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'Kurucu',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF90E49D) : const Color(0xFF23552C),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
        if (isPreLobby) ...[
          const SizedBox(height: 10),
          Text(
            'Oda açıldıktan sonra kulüp üyeleri buraya katılabilecek.',
            style: AppTypography.sfPro(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: mutedText,
            ),
          ),
        ],
      ],
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
    bool isPreLobby,
    bool isWaiting,
    bool isActive,
  ) {
    // 1. Oda henüz oluşturulmadıysa (Oda Kurulumu / Seans Hazırlığı)
    if (isPreLobby) {
      return BouncingWidget(
        onTap: _isProcessing ? null : () => _handleCreateAndStartRoom(clubProv, user),
        child: _buildCtaContainer(
          title: 'Odayı Aç',
          icon: Icons.meeting_room_rounded,
          color: const Color(0xFF0E260A),
        ),
      );
    }

    // 2. Hazırlık Lobisi:
    if (isWaiting) {
      if (isHost) {
        return BouncingWidget(
          onTap: _isProcessing ? null : () => _handleStartActiveSession(clubProv),
          child: _buildCtaContainer(
            title: 'Odaklanmayı Başlat',
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
        return _buildCtaContainer(
          title: 'Kurucu Bekleniyor...',
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFF7A8D7D),
          disabled: true,
        );
      }
    }

    // 3. Canlı Seans:
    if (!isParticipant && !isHost) {
      if (session!.canJoin) {
        return BouncingWidget(
          onTap: _isProcessing ? null : () => _handleJoinSession(clubProv, user),
          child: _buildCtaContainer(
            title: 'Seansa Katıl',
            icon: Icons.login_rounded,
            color: const Color(0xFF0E260A),
          ),
        );
      } else {
        return _buildCtaContainer(
          title: 'Katılıma Kapalı',
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
        title: isHost ? 'Seansı Bitir' : 'Seanstan Ayrıl',
        icon: isHost ? Icons.check_circle_outline_rounded : Icons.logout_rounded,
        color: isHost ? const Color(0xFF2E4E32) : const Color(0xFF5A7260),
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
    await clubProv.createFocusSessionRoom(
      title: _titleController.text.trim().isEmpty ? 'Birlikte Odaklanma' : _titleController.text.trim(),
      durationMinutes: _selectedDuration,
      focusTag: _selectedTag,
      userProfile: user,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
  }

  Future<void> _handleStartActiveSession(
    ClubProvider clubProv,
  ) async {
    setState(() => _isProcessing = true);
    await clubProv.startActiveSession();
    if (!mounted) return;
    setState(() => _isProcessing = false);
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
    final session = clubProv.activeSession ?? widget.initialSession;
    final elapsedMinutes = session?.elapsedMinutes ?? 0;
    final bool earnsCredit = session != null && session.isActive && elapsedMinutes >= 5;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isHost ? 'Seansı Bitir' : 'Seanstan Ayrıl',
          style: AppTypography.sfProRounded(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: Text(
          earnsCredit
              ? (isHost
                  ? 'Tebrikler! Geçen $elapsedMinutes dakikalık odaklanma süresi profilinize ve kulübünüze kaydedilecektir. Seansı tüm katılımcılar için bitirmek istiyor musunuz?'
                  : 'Tebrikler! Geçen $elapsedMinutes dakikalık odaklanma süresi profilinize ve kulübünüze kaydedilecektir. Seanstan ayrılmak istiyor musunuz?')
              : (isHost
                  ? 'Canlı odaklanma seansını tüm katılımcılar için bitirmek istiyor musunuz? (5 dakikadan az olduğu için süre kaydedilmez)'
                  : 'Seans devam ediyor. Ayrılmak istediğinize emin misiniz? (5 dakikadan az olduğu için süre kaydedilmez)'),
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
              if (earnsCredit) {
                try {
                  final planner = context.read<PlannerProvider>();
                  await planner.recordFocusSession(elapsedMinutes);
                  final user = planner.userProfile;
                  await clubProv.recordFocusCompleted(
                    minutes: elapsedMinutes,
                    userProfile: user,
                  );
                  unawaited(
                    SupabaseService.instance.logFocusSession(
                      durationMinutes: elapsedMinutes,
                      mode: 'club_focus',
                      focusTag: session.focusTag,
                    ).catchError((e, st) {
                      ErrorLogger.log('ClubFocusSessionScreen.logFocusSessionEarly', e, st);
                    }),
                  );
                } catch (e, st) {
                  ErrorLogger.log('ClubFocusSessionScreen.recordCredit', e, st);
                }
              }
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
