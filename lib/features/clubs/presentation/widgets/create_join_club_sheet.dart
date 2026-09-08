import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../planner/providers/planner_provider.dart';
import '../../providers/club_provider.dart';

/// 🌿 Calenda — Kulüp Oluşturma & Davet Koduyla Katılma Modalı
class CreateJoinClubSheet extends StatefulWidget {
  final int initialTabIndex; // 0: Oluştur, 1: Katıl
  const CreateJoinClubSheet({super.key, this.initialTabIndex = 0});

  static Future<void> show(BuildContext context, {int initialTabIndex = 0}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateJoinClubSheet(initialTabIndex: initialTabIndex),
    );
  }

  @override
  State<CreateJoinClubSheet> createState() => _CreateJoinClubSheetState();
}

class _CreateJoinClubSheetState extends State<CreateJoinClubSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Kulüp Oluştur Alanları
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedIcon = 'matcha_cup';

  // Koda Katıl Alanı
  final _codeController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorText;

  static const List<Map<String, String>> _icons = [
    {'id': 'matcha_cup', 'label': 'Matcha', 'emoji': '🍵'},
    {'id': 'book_reading', 'label': 'Kütüphane', 'emoji': '📖'},
    {'id': 'rabbit_focus', 'label': 'Tavşan', 'emoji': '🐰'},
    {'id': 'star_cozy', 'label': 'Yıldız', 'emoji': '✨'},
    {'id': 'plant_growth', 'label': 'Fidan', 'emoji': '🌿'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateClub(UserProfile user) async {
    final name = _nameController.text.trim();
    final l10n = context.l10n;
    if (name.isEmpty) {
      setState(() => _errorText = l10n.enterClubNameWarning);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final club = await context.read<ClubProvider>().createClub(
          name: name,
          description: _descController.text.trim(),
          iconName: _selectedIcon,
          dailyTargetMinutes: 60,
          userProfile: user,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (club != null) {
      Navigator.of(context).pop();
      AestheticSnackBar.showSuccess(
        context,
        l10n.clubCreated(club.name, club.inviteCode),
      );
    } else {
      final err = context.read<ClubProvider>().errorMessage;
      setState(() => _errorText = err ?? l10n.clubCreateFailed);
    }
  }

  Future<void> _handleJoinClub(UserProfile user) async {
    final code = _codeController.text.trim().toUpperCase();
    final l10n = context.l10n;
    if (code.isEmpty) {
      setState(() => _errorText = l10n.enterInviteCodeWarning);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final club = await context.read<ClubProvider>().joinClubByCode(
          inviteCode: code,
          userProfile: user,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (club != null) {
      Navigator.of(context).pop();
      AestheticSnackBar.showSuccess(
        context,
        l10n.clubJoined(club.name),
      );
    } else {
      final err = context.read<ClubProvider>().errorMessage;
      setState(() => _errorText = err ?? l10n.clubJoinFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final user = context.watch<PlannerProvider>().userProfile;

    return Container(
      margin: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: bottomInset > 0 ? bottomInset + 12 : 24,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tutamaç (Handle Bar)
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

          // Üst Başlık & Sekme Geçişi
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3EB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xFF1E3A1E),
              unselectedLabelColor: const Color(0xFF7A8B77),
              labelStyle: AppTypography.caption1(
                weight: FontWeight.w700,
              ),
              tabs: [
                Tab(text: context.l10n.createClubTab),
                Tab(text: context.l10n.joinWithCodeTab),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_errorText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF5B5BC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFFB42318),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorText!,
                      style: AppTypography.caption1(
                        color: const Color(0xFFB42318),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── 1. KULÜP OLUŞTUR SEKMESİ ──
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.clubNameLabel,
                        style: AppTypography.caption2(
                          color: const Color(0xFF7A8B77),
                          weight: FontWeight.w700,
                        ).copyWith(letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        style: AppTypography.body(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF4F7F1),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // İkon Seçimi
                      Text(
                        context.l10n.clubIconLabel,
                        style: AppTypography.caption2(
                          color: const Color(0xFF7A8B77),
                          weight: FontWeight.w700,
                        ).copyWith(letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _icons.map((item) {
                          final isSelected = _selectedIcon == item['id'];
                          return BouncingWidget(
                            onTap: () => setState(() => _selectedIcon = item['id']!),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1E3A1E)
                                    : const Color(0xFFF4F7F1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1E3A1E)
                                      : const Color(0xFFE4EAE0),
                                ),
                              ),
                              child: Text(
                                item['emoji']!,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      const SizedBox(height: 20),

                      BouncingWidget(
                        onTap: _isSubmitting ? null : () => _handleCreateClub(user),
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E260A),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  context.l10n.buildClubButton,
                                  style: AppTypography.footnote(
                                    color: Colors.white,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 2. KOD İLE KATIL SEKMESİ ──
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.specialInviteCode,
                        style: AppTypography.caption2(
                          color: const Color(0xFF7A8B77),
                          weight: FontWeight.w700,
                        ).copyWith(letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        style: AppTypography.title2(
                          color: const Color(0xFF1E3A1E),
                        ).copyWith(letterSpacing: 4),
                        decoration: InputDecoration(
                          hintText: 'CLD-842',
                          hintStyle: AppTypography.title2(
                            color: const Color(0xFFC1CCC0),
                          ).copyWith(letterSpacing: 4),
                          filled: true,
                          fillColor: const Color(0xFFF4F7F1),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      BouncingWidget(
                        onTap: _isSubmitting ? null : () => _handleJoinClub(user),
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E260A),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  context.l10n.joinClubButton,
                                  style: AppTypography.footnote(
                                    color: Colors.white,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
