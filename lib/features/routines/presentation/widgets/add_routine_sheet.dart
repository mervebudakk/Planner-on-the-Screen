import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/models/routine_model.dart';

/// 🌿 Calenda — Yarı Saydam (Frosted Glass) Yeni Rutin / Alışkanlık Ekleme Modal Kartı
class AddRoutineSheet extends StatefulWidget {
  final ValueChanged<RoutineModel> onRoutineAdded;

  const AddRoutineSheet({
    super.key,
    required this.onRoutineAdded,
  });

  static void show(
    BuildContext context, {
    required ValueChanged<RoutineModel> onRoutineAdded,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => AddRoutineSheet(onRoutineAdded: onRoutineAdded),
    );
  }

  @override
  State<AddRoutineSheet> createState() => _AddRoutineSheetState();
}

class _AddRoutineSheetState extends State<AddRoutineSheet> {
  late final TextEditingController _titleCtrl;
  IconData _chosenIcon = Icons.auto_awesome_rounded;

  static const Color _textPrimary = AppColors.lightTextPrimary;
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  static const List<Map<String, dynamic>> _iconsList = [
    {'icon': Icons.menu_book_rounded, 'name': 'Kitap'},
    {'icon': Icons.water_drop_outlined, 'name': 'Su'},
    {'icon': Icons.self_improvement_rounded, 'name': 'Meditasyon'},
    {'icon': Icons.directions_walk_rounded, 'name': 'Yürüyüş'},
    {'icon': Icons.fitness_center_rounded, 'name': 'Spor'},
    {'icon': Icons.edit_note_rounded, 'name': 'Günlük'},
    {'icon': Icons.spa_outlined, 'name': 'Bakım'},
    {'icon': Icons.local_cafe_outlined, 'name': 'Mola'},
    {'icon': Icons.nightlight_round, 'name': 'Uyku'},
    {'icon': Icons.brush_rounded, 'name': 'Sanat'},
    {'icon': Icons.code_rounded, 'name': 'Kod'},
    {'icon': Icons.music_note_rounded, 'name': 'Müzik'},
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _titleCtrl.text.trim();
    if (t.isNotEmpty) {
      final sanitizedTitle = t.length > 65 ? t.substring(0, 65).trim() : t;
      final newRoutine = RoutineModel(
        id: 'r_${DateTime.now().millisecondsSinceEpoch}',
        title: sanitizedTitle,
        iconCodePoint: _chosenIcon.codePoint,
        colorValue: 0xFFEFF5ED,
        accentValue: 0xFF4A7C59,
        isCompleted: false,
        streak: 0,
      );
      widget.onRoutineAdded(newRoutine);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    final routineContent = Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
                  const SizedBox(height: 14),

                  // 2. Başlık Çubuğu: Sol Başlık + Sağ Kapat Butonu
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.newRoutine,
                              style: AppTypography.sfProRounded(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: primaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.isTurkish
                                  ? 'Günlük ritmini ve hedeflerini belirle'
                                  : 'Set your daily rhythm and goals',
                              style: AppTypography.sfPro(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFA1C4AA) : const Color(0xFF386644),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white12 : const Color(0xFFEFF4ED),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7A6E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3. Rutin Adı Bento Kartı (EditEventSheet ile Birebir Aynı Estetik)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A2F23).withValues(alpha: 0.65)
                          : const Color(0xFFF4F7F2).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E4D37).withValues(alpha: 0.6)
                            : const Color(0xFFE2EBE0),
                        width: 1.1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _titleCtrl,
                      autofocus: true,
                      maxLength: 65,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      textCapitalization: TextCapitalization.sentences,
                      style: AppTypography.sfProRounded(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.isTurkish
                            ? 'Rutin adı (Örn: 20 Sayfa Kitap Okuma)'
                            : 'Routine name (e.g. Read 20 Pages)',
                        hintStyle: AppTypography.sfProRounded(
                          color: mutedText.withValues(alpha: 0.75),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4. İkon Seçim Bölümü
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      context.l10n.isTurkish ? 'İKON SEÇ' : 'CHOOSE ICON',
                      style: AppTypography.sfPro(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w800,
                        color: mutedText,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _iconsList.map((item) {
                          final ic = item['icon'] as IconData;
                          final isSel = _chosenIcon == ic;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: BouncingWidget(
                              onTap: () => setState(() => _chosenIcon = ic),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? ctaColor
                                      : (isDark
                                          ? const Color(0xFF1A2F23).withValues(alpha: 0.65)
                                          : const Color(0xFFF4F7F2).withValues(alpha: 0.85)),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSel
                                        ? Colors.transparent
                                        : (isDark
                                            ? const Color(0xFF2E4D37).withValues(alpha: 0.6)
                                            : const Color(0xFFE2EBE0)),
                                    width: 1.1,
                                  ),
                                  boxShadow: isSel
                                      ? [
                                          BoxShadow(
                                            color: ctaColor.withValues(alpha: 0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  ic,
                                  size: 22,
                                  color: isSel ? Colors.white : primaryText,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. Kaydet Butonu
                  BouncingWidget(
                    onTap: _submit,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: ctaColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: ctaColor.withValues(alpha: 0.30),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          context.l10n.isTurkish ? 'Rutini Kaydet' : 'Save Routine',
                          style: AppTypography.sfProRounded(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF14241B) : Colors.white)
              .withValues(alpha: isDark ? 0.94 : 0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.85),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.10),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: kIsWeb
              ? routineContent
              : BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: routineContent,
                ),
        ),
      ),
    );
  }
}
