import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/models/routine_model.dart';

/// 🌿 Calenda — Yeni Rutin / Alışkanlık Ekleme Alt Sayfası
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
      builder: (ctx) => AddRoutineSheet(onRoutineAdded: onRoutineAdded),
    );
  }

  @override
  State<AddRoutineSheet> createState() => _AddRoutineSheetState();
}

class _AddRoutineSheetState extends State<AddRoutineSheet> {
  late final TextEditingController _titleCtrl;
  IconData _chosenIcon = Icons.auto_awesome_rounded;

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _textPrimary = Color(0xFF1A2B1D);
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
      final newRoutine = RoutineModel(
        id: 'r_${DateTime.now().millisecondsSinceEpoch}',
        title: t,
        iconCodePoint: _chosenIcon.codePoint,
        colorValue: 0xFFEFF5ED,
        accentValue: 0xFF4A7C59,
        isCompleted: false,
        streak: 1,
      );
      widget.onRoutineAdded(newRoutine);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 18),
            Text(
              'Yeni Alışkanlık Ekle',
              style: AppTypography.sfProRounded(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Her gün saatten bağımsız olarak kendine ayırmak istediğin bir rutin.',
              style: AppTypography.sfPro(fontSize: 13, color: mutedText),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              style: AppTypography.sfPro(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              decoration: InputDecoration(
                hintText: 'Alışkanlık Adı (Örn: 20 Sayfa Kitap Okuma)',
                hintStyle: TextStyle(color: mutedText, fontSize: 14),
                filled: true,
                fillColor: isDark ? const Color(0xFF1B2C22) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: ctaColor, width: 1.5),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            Text(
              'İkon Seç',
              style: AppTypography.sfPro(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: mutedText,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 46,
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
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isSel
                                ? ctaColor
                                : (isDark ? const Color(0xFF1B2C22) : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel
                                  ? Colors.transparent
                                  : (isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                            ),
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
            const SizedBox(height: 22),
            BouncingWidget(
              onTap: _submit,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: ctaColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    'Alışkanlığı Kaydet',
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
      ),
    );
  }
}
