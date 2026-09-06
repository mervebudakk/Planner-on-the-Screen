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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🌿 "${club.name}" kulübü kuruldu! Davet Kodu: ${club.inviteCode}',
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF1E3A1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 "${club.name}" kulübüne başarıyla katıldınız!',
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF1E3A1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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

          // ── 3. Ön Plan İçeriği (Top Bar + Kartlar) ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── ÜST BAR (Yalnızca Kulüpler Varsa Gösterilir) ──
                if (clubs.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top > 0 ? 16.0 : 28.0,
                      20,
                      12,
                    ),
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

  // ── BOŞ DURUM (HİÇ KULÜBÜ YOKSA — ORTADA SAYDAM VE ETKİLEŞİMLİ KULÜP OLUŞTUR / KATIL KARTI) ──
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
                    hintText: 'Örn. Sessiz Kütüphane, YKS 2026',
                    hintStyle: AppTypography.sfPro(
                      fontSize: 13.5,
                      color: isDark ? Colors.white38 : const Color(0xFF7A8D7B),
                    ),
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
