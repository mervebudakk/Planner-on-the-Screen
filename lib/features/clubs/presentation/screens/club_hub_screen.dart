import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../models/club.dart';
import '../../models/club_focus_session.dart';
import '../../models/club_member.dart';
import '../../providers/club_provider.dart';

/// 🌿 Calenda — Kulüplerim Ana Hub & Canlı Kulüp Odası Ekranı
class ClubHubScreen extends StatefulWidget {
  const ClubHubScreen({super.key});

  @override
  State<ClubHubScreen> createState() => _ClubHubScreenState();
}

class _ClubHubScreenState extends State<ClubHubScreen> {
  int _activeTabIndex = 0; // 0: Kulüp Oluştur, 1: Kod ile Katıl
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String _selectedIcon = 'matcha_cup';
  bool _isSubmitting = false;
  String? _formError;

  static const List<Map<String, String>> _clubIcons = [
    {'id': 'matcha_cup', 'label': 'Matcha', 'emoji': '🍵'},
    {'id': 'book_reading', 'label': 'Kitap', 'emoji': '📖'},
    {'id': 'rabbit_focus', 'label': 'Tavşan', 'emoji': '🐰'},
    {'id': 'star_cozy', 'label': 'Yıldız', 'emoji': '✨'},
    {'id': 'plant_growth', 'label': 'Fidan', 'emoji': '🌿'},
  ];

  String _getClubEmoji(String iconName) {
    final match = _clubIcons.firstWhere(
      (item) => item['id'] == iconName,
      orElse: () => {'emoji': '🌿'},
    );
    return match['emoji'] ?? '🌿';
  }

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
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateClub() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _formError = 'Lütfen bir kulüp adı belirleyin.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    final user = context.read<PlannerProvider>().userProfile;
    final club = await context.read<ClubProvider>().createClub(
          name: name,
          description: '',
          iconName: _selectedIcon,
          dailyTargetMinutes: 60,
          userProfile: user,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (club != null) {
      _nameController.clear();
      AestheticSnackBar.showSuccess(
        context,
        '"${club.name}" kulübü kuruldu! Davet Kodu: ${club.inviteCode}',
      );
    } else {
      final err = context.read<ClubProvider>().errorMessage;
      setState(() => _formError = err ?? 'Kulüp oluşturulamadı.');
    }
  }

  Future<void> _handleJoinClub() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _formError = 'Lütfen 6 haneli davet kodunu girin.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    final user = context.read<PlannerProvider>().userProfile;
    final club = await context.read<ClubProvider>().joinClubByCode(
          inviteCode: code,
          userProfile: user,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (club != null) {
      _codeController.clear();
      AestheticSnackBar.showSuccess(
        context,
        '"${club.name}" kulübüne başarıyla katıldınız!',
      );
    } else {
      final err = context.read<ClubProvider>().errorMessage;
      setState(() => _formError = err ?? 'Kulübe katılınamadı. Kodu kontrol edin.');
    }
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

          // ── 3. Ön Plan İçeriği (Aktif Kulüp veya Boş Durum) ──
          SafeArea(
            bottom: false,
            child: isLoading && clubs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : clubs.isEmpty
                    ? _buildEmptyState(context, dockClearance, isDark)
                    : _buildActiveClubView(
                        context,
                        clubs.first,
                        clubProvider,
                        dockClearance,
                        isDark,
                      ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // 🏛️ AKTİF KULÜP EKRANI (TEK KULÜP GÖRÜNÜMÜ)
  // ═════════════════════════════════════════════════════════════════
  Widget _buildActiveClubView(
    BuildContext context,
    Club club,
    ClubProvider clubProvider,
    double dockClearance,
    bool isDark,
  ) {
    final members = clubProvider.members;
    final activeSession = clubProvider.activeSession;
    final memberCount = members.isNotEmpty ? members.length : club.memberCount;

    return Column(
      children: [
        // ── ÜST BAR: KULÜP ADI + ÜYE SAYISI + 3 NOKTA AYARLAR MENÜSÜ ──
        Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top > 0 ? 12.0 : 24.0,
            20,
            12,
          ),
          child: Row(
            children: [
              // Kulüp Simgesi
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
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
                child: Text(
                  _getClubEmoji(club.iconName),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),

              // Kulüp Başlığı & Üye Sayısı
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      club.name,
                      style: AppTypography.sfProRounded(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F2612),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$memberCount / ${club.maxMembers} Üye',
                      style: AppTypography.sfPro(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFFA8BCAE) : const Color(0xFF536A55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 3 Nokta Butonu (Kulüp Bilgileri & Ayrıl)
              BouncingWidget(
                onTap: () => _showClubOptionsSheet(context, club, memberCount, isDark),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(10),
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
                    Icons.more_horiz_rounded,
                    size: 20,
                    color: isDark ? Colors.white : const Color(0xFF1E3A1E),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── SCROLL EDİLEBİLİR GÖVDE (CANLI SEANS & ÜYELER) ──
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 6,
              bottom: dockClearance + 20,
            ),
            children: [
              // 1. CANLI ÇALIŞMA SALONU KARTI
              _buildLiveLoungeCard(context, activeSession, isDark),
              const SizedBox(height: 20),

              // 2. KULÜP ÜYELERİ BAŞLIĞI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kulüp Üyeleri',
                    style: AppTypography.sfProRounded(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F2612),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3024)
                          : Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFE2E8DE),
                      ),
                    ),
                    child: Text(
                      '$memberCount / ${club.maxMembers} Üye',
                      style: AppTypography.sfProRounded(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF90C29A) : const Color(0xFF334B30),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. ÜYE LİSTESİ
              if (members.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF14241B).withValues(alpha: 0.32)
                        : Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.6),
                    ),
                  ),
                  child: Text(
                    'Üye listesi yükleniyor...',
                    style: AppTypography.caption1(
                      color: isDark ? const Color(0xFFA8BCAE) : const Color(0xFF6B7E68),
                    ),
                  ),
                )
              else
                ...members.map((m) => _buildMemberTile(context, m, activeSession, isDark)),
            ],
          ),
        ),
      ],
    );
  }

  // ── CANLI ÇALIŞMA SALONU KARTI ──
  Widget _buildLiveLoungeCard(
    BuildContext context,
    ClubFocusSession? activeSession,
    bool isDark,
  ) {
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
            colors: [Color(0xFF162F19), Color(0xFF2A502D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF162F19).withValues(alpha: 0.35),
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
                  width: 9,
                  height: 9,
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
          ],
        ),
      );
    }

    // Aktif seans yoksa: Seans başlatma kartı
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF14241B).withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sessiz Çalışma Salonu',
            style: AppTypography.sfProRounded(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F2612),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Şu an aktif seans yok. İlk adımı sen at!',
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFA8BCAE) : const Color(0xFF6B7E68),
            ),
          ),
          const SizedBox(height: 16),
          BouncingWidget(
            onTap: () => _showStartSessionSheet(context, isDark),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0E260A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0E260A).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    'Birlikte Seans Başlat',
                    style: AppTypography.sfProRounded(
                      fontSize: 15,
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
    );
  }

  // ── ÜYE KARTI (SADECE KULLANICI & ODAK BİLGİSİ, ZORAKİ HEDEF YOK) ──
  Widget _buildMemberTile(
    BuildContext context,
    ClubMember member,
    ClubFocusSession? activeSession,
    bool isDark,
  ) {
    final isHostingNow = activeSession != null &&
        activeSession.isActive &&
        activeSession.hostUserId == member.userId;
    final isFocusing = member.isFocusingNow || isHostingNow;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF172B1E).withValues(alpha: 0.70)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFocusing
              ? const Color(0xFF5AB664).withValues(alpha: 0.7)
              : (isDark ? const Color(0xFF284834) : const Color(0xFFE4ECE0)),
          width: isFocusing ? 1.5 : 1.0,
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
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF223829) : const Color(0xFFEFF5EB),
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
              style: AppTypography.sfProRounded(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E3A1E),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // İsim & Odak Durumu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: AppTypography.sfProRounded(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E3A1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                if (isFocusing)
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Şu an odakta 🟢',
                        style: AppTypography.sfPro(
                          fontSize: 12.5,
                          color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    member.todayFocusMinutes > 0
                        ? 'Bugün aktif oldu'
                        : 'Henüz odaklanmadı',
                    style: AppTypography.sfPro(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFA8BCAE) : const Color(0xFF7A8B77),
                    ),
                  ),
              ],
            ),
          ),

          // Bugünkü Toplam Odak Süresi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: member.todayFocusMinutes > 0
                  ? (isDark ? const Color(0xFF23442C) : const Color(0xFFEFF7EE))
                  : (isDark ? const Color(0xFF1A261D) : const Color(0xFFF2F4F0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 13,
                  color: member.todayFocusMinutes > 0
                      ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
                      : (isDark ? const Color(0xFF718275) : const Color(0xFF8B9B88)),
                ),
                const SizedBox(width: 4),
                Text(
                  '${member.todayFocusMinutes} dk',
                  style: AppTypography.sfProRounded(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: member.todayFocusMinutes > 0
                        ? (isDark ? const Color(0xFFBCE8C5) : const Color(0xFF1E3A1E))
                        : (isDark ? const Color(0xFF718275) : const Color(0xFF8B9B88)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3 NOKTA AYARLAR MODALI (KULÜP BİLGİSİ, KOD KOPYALAMA, AYRILMA) ──
  void _showClubOptionsSheet(
    BuildContext context,
    Club club,
    int memberCount,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF14241B).withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Çentik
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

              // Kulüp Simgesi & Başlığı
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF223B2A) : const Color(0xFFEFF5EB),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _getClubEmoji(club.iconName),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: AppTypography.sfProRounded(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F2612),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$memberCount / ${club.maxMembers} Üye',
                          style: AppTypography.sfPro(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFFA8BCAE) : const Color(0xFF6B7E68),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Davet Kodu Kutusu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : const Color(0xFFF3F7F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2B4734) : const Color(0xFFE2EADF),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ÖZEL DAVET KODU',
                            style: AppTypography.sfPro(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF92B29A) : const Color(0xFF5D755F),
                            ).copyWith(letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            club.inviteCode,
                            style: AppTypography.sfProRounded(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F2612),
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BouncingWidget(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: club.inviteCode));
                        HapticFeedback.lightImpact();
                        Navigator.of(sheetCtx).pop();
                        AestheticSnackBar.showSuccess(
                          context,
                          'Davet kodu panoya kopyalandı: ${club.inviteCode}',
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C4A35) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF3B6247) : const Color(0xFFD4E0CE),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: isDark ? Colors.white : const Color(0xFF1E3A1E),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kopyala',
                              style: AppTypography.sfProRounded(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1E3A1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Kulüpten Ayrıl Butonu
              BouncingWidget(
                onTap: () async {
                  final confirmed = await showCupertinoDialog<bool>(
                    context: context,
                    builder: (alertCtx) => CupertinoAlertDialog(
                      title: const Text('Kulüpten Ayrıl'),
                      content: Text(
                        '"${club.name}" kulübünden ayrılmak istediğinize emin misiniz? Tekrar katılmak için davet kodunu yeniden girmeniz gerekir.',
                      ),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.of(alertCtx).pop(false),
                          child: const Text('Vazgeç'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () => Navigator.of(alertCtx).pop(true),
                          child: const Text('Ayrıl'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    Navigator.of(sheetCtx).pop(); // bottom sheet kapat
                    final user = context.read<PlannerProvider>().userProfile;
                    final success = await context.read<ClubProvider>().leaveClub(
                          clubId: club.id,
                          userProfile: user,
                        );
                    if (success && context.mounted) {
                      AestheticSnackBar.showSuccess(
                        context,
                        'Kulüpten başarıyla ayrıldınız.',
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECEE).withValues(alpha: isDark ? 0.2 : 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF5B5BC).withValues(alpha: isDark ? 0.3 : 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: Color(0xFFD32F2F),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kulüpten Ayrıl',
                        style: AppTypography.sfProRounded(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB42318),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── SEANS BAŞLATMA BOTTOM SHEET ──
  void _showStartSessionSheet(BuildContext context, bool isDark) {
    final titleCtrl = TextEditingController(text: 'Birlikte Odaklanma');
    int selectedDuration = 25;
    String selectedTag = 'Ders & Çalışma';
    bool isStarting = false;

    final tags = ['Ders & Çalışma', 'Kitap Okuma', 'Kodlama', 'Proje', 'Yazı'];

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
                left: 14,
                right: 14,
                bottom: bottomInset > 0 ? bottomInset + 12 : 24,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF14241B).withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.85),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
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
                        color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Birlikte Seans Başlat',
                    style: AppTypography.sfProRounded(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F2612),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seansı başlattığınızda kulüp üyelerine anlık bildirim gönderilecek.',
                    style: AppTypography.sfPro(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFA8BCAE) : const Color(0xFF6B7E68),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'SEANS BAŞLIĞI',
                    style: AppTypography.sfPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF92B29A) : const Color(0xFF5D755F),
                    ).copyWith(letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    style: AppTypography.sfPro(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F2612),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? Colors.black.withValues(alpha: 0.20)
                          : const Color(0xFFF2F6EF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'SÜRE SEÇİMİ',
                    style: AppTypography.caption2(
                      color: isDark ? const Color(0xFF92B29A) : const Color(0xFF5D755F),
                      weight: FontWeight.w700,
                    ).copyWith(letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [15, 25, 45, 60].map((dur) {
                      final isSel = selectedDuration == dur;
                      return Expanded(
                        child: BouncingWidget(
                          onTap: () => setSheetState(() => selectedDuration = dur),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSel
                                  ? (isDark ? const Color(0xFF284834) : const Color(0xFF0E260A))
                                  : (isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF2F6EF)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$dur dk',
                              style: AppTypography.caption1(
                                color: isSel ? Colors.white : (isDark ? const Color(0xFFA8BCAE) : const Color(0xFF536A55)),
                                weight: isSel ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'ODAK ETİKETİ',
                    style: AppTypography.caption2(
                      color: isDark ? const Color(0xFF92B29A) : const Color(0xFF5D755F),
                      weight: FontWeight.w700,
                    ).copyWith(letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: tags.map((tag) {
                        final isSel = selectedTag == tag;
                        return BouncingWidget(
                          onTap: () => setSheetState(() => selectedTag = tag),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? (isDark ? const Color(0xFF284834) : const Color(0xFF0E260A))
                                  : (isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF2F6EF)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.caption2(
                                color: isSel ? Colors.white : (isDark ? const Color(0xFFA8BCAE) : const Color(0xFF536A55)),
                                weight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  BouncingWidget(
                    onTap: isStarting
                        ? null
                        : () async {
                            setSheetState(() => isStarting = true);
                            final user = context.read<PlannerProvider>().userProfile;
                            final session = await context.read<ClubProvider>().startFocusSession(
                                  title: titleCtrl.text.trim().isEmpty
                                      ? 'Birlikte Odaklanma'
                                      : titleCtrl.text.trim(),
                                  durationMinutes: selectedDuration,
                                  focusTag: selectedTag,
                                  userProfile: user,
                                );
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                            }
                            if (session != null && context.mounted) {
                              AestheticSnackBar.showSuccess(
                                context,
                                'Canlı seans başlatıldı! Kulüp üyelerine bildirim gönderildi.',
                              );
                            }
                          },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E260A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0E260A).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: isStarting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Seansı Başlat',
                              style: AppTypography.sfProRounded(
                                fontSize: 15.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
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

  // ═════════════════════════════════════════════════════════════════
  // ── BOŞ DURUM (HİÇ KULÜBÜ YOKSA — ORTADA KULÜP OLUŞTUR / KATIL KARTI)
  // ═════════════════════════════════════════════════════════════════
  Widget _buildEmptyState(BuildContext context, double dockClearance, bool isDark) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top > 0 ? 20.0 : 36.0,
          20,
          dockClearance + (viewInsetsBottom > 0 ? viewInsetsBottom + 12 : 0),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Üst Sekme Geçişi (Kulüp Oluştur | Kod ile Katıl) ──
              Container(
                height: 42,
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.60),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_activeTabIndex != 0) {
                            setState(() {
                              _activeTabIndex = 0;
                              _formError = null;
                            });
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _activeTabIndex == 0
                                ? (isDark ? const Color(0xFF243F2D) : Colors.white.withValues(alpha: 0.92))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: _activeTabIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Kulüp Oluştur',
                            style: AppTypography.sfProRounded(
                              fontSize: 13.5,
                              fontWeight: _activeTabIndex == 0 ? FontWeight.w800 : FontWeight.w600,
                              color: _activeTabIndex == 0
                                  ? (isDark ? Colors.white : const Color(0xFF0F2612))
                                  : (isDark ? const Color(0xFFA8BCAE) : const Color(0xFF536A55)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_activeTabIndex != 1) {
                            setState(() {
                              _activeTabIndex = 1;
                              _formError = null;
                            });
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _activeTabIndex == 1
                                ? (isDark ? const Color(0xFF243F2D) : Colors.white.withValues(alpha: 0.92))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: _activeTabIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Kod ile Katıl',
                            style: AppTypography.sfProRounded(
                              fontSize: 13.5,
                              fontWeight: _activeTabIndex == 1 ? FontWeight.w800 : FontWeight.w600,
                              color: _activeTabIndex == 1
                                  ? (isDark ? Colors.white : const Color(0xFF0F2612))
                                  : (isDark ? const Color(0xFFA8BCAE) : const Color(0xFF536A55)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ── 2. Hata Uyarısı (Varsa) ──
              if (_formError != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECEE).withValues(alpha: isDark ? 0.25 : 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF5B5BC).withValues(alpha: 0.7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD32F2F)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formError!,
                          style: AppTypography.sfPro(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB42318),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── 3. Sekme İçeriği ──
              if (_activeTabIndex == 0) ...[
                // ─── KULÜP OLUŞTUR FORMU ───
                Text(
                  'KULÜP ADI',
                  style: AppTypography.sfPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFB0C4B4) : const Color(0xFF47604B),
                  ).copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  style: AppTypography.sfPro(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F2612),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? Colors.black.withValues(alpha: 0.20)
                        : Colors.white.withValues(alpha: 0.65),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.70),
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.70),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF6B9E78) : const Color(0xFF0E260A),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'KULÜP SİMGESİ',
                  style: AppTypography.sfPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFB0C4B4) : const Color(0xFF47604B),
                  ).copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _clubIcons.map((item) {
                    final isSelected = _selectedIcon == item['id'];
                    return BouncingWidget(
                      onTap: () => setState(() => _selectedIcon = item['id']!),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF284834) : const Color(0xFF0E260A))
                              : (isDark ? Colors.black.withValues(alpha: 0.20) : Colors.white.withValues(alpha: 0.60)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? const Color(0xFF6B9E78) : const Color(0xFF0E260A))
                                : Colors.white.withValues(alpha: isDark ? 0.15 : 0.70),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF0E260A).withValues(alpha: 0.20),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(item['emoji']!, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                BouncingWidget(
                  onTap: _isSubmitting ? null : _handleCreateClub,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E260A).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0E260A).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Kulübü Kur',
                            style: AppTypography.sfProRounded(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                // ─── KOD İLE KATIL FORMU ───
                Text(
                  'ÖZEL DAVET KODU',
                  style: AppTypography.sfPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFB0C4B4) : const Color(0xFF47604B),
                  ).copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: AppTypography.sfProRounded(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F2612),
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'CLD-842',
                    hintStyle: AppTypography.sfProRounded(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : const Color(0xFF96A697),
                      letterSpacing: 4,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.black.withValues(alpha: 0.20)
                        : Colors.white.withValues(alpha: 0.65),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.70),
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.70),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF6B9E78) : const Color(0xFF0E260A),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                BouncingWidget(
                  onTap: _isSubmitting ? null : _handleJoinClub,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E260A).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0E260A).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Kulübe Katıl',
                            style: AppTypography.sfProRounded(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
