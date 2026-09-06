import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/bouncing_widget.dart';

/// ⏱️ Calenda — Odak & Mola Süresi Seçici Alt Sayfası (Translucent & Minimalist)
class FocusDurationPickerSheet extends StatefulWidget {
  final bool isFocusMode;
  final List<int> options;
  final int selectedDuration;
  final ValueChanged<int> onDurationSelected;

  const FocusDurationPickerSheet({
    super.key,
    required this.isFocusMode,
    required this.options,
    required this.selectedDuration,
    required this.onDurationSelected,
  });

  static void show(
    BuildContext context, {
    required bool isFocusMode,
    required List<int> options,
    required int selectedDuration,
    required ValueChanged<int> onDurationSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => FocusDurationPickerSheet(
        isFocusMode: isFocusMode,
        options: options,
        selectedDuration: selectedDuration,
        onDurationSelected: onDurationSelected,
      ),
    );
  }

  @override
  State<FocusDurationPickerSheet> createState() => _FocusDurationPickerSheetState();
}

class _FocusDurationPickerSheetState extends State<FocusDurationPickerSheet> {
  late int _tempIndex;
  late FixedExtentScrollController _scrollController;

  static const Color _textPrimary = Color(0xFF1A2B1D);
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  @override
  void initState() {
    super.initState();
    int initialIndex = widget.options.indexOf(widget.selectedDuration);
    if (initialIndex < 0) {
      initialIndex = 0;
      int minDiff = 999;
      for (int i = 0; i < widget.options.length; i++) {
        final diff = (widget.options[i] - widget.selectedDuration).abs();
        if (diff < minDiff) {
          minDiff = diff;
          initialIndex = i;
        }
      }
    }
    _tempIndex = initialIndex;
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF14241B).withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Sürükleme Çubuğu (Drag Handle)
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

            // Sade ve Profesyonel Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isFocusMode ? 'Odak Süresi' : 'Mola Süresi',
                  style: AppTypography.sfProRounded(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primaryText,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, color: mutedText, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // CupertinoPicker Tekerleği
            SizedBox(
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Seçim Vurgu Çerçevesi (Yarı Saydam Quiet Luxury Pill)
                  Container(
                    height: 46,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : ctaColor).withValues(alpha: isDark ? 0.08 : 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.8),
                        width: 1.0,
                      ),
                    ),
                  ),

                  CupertinoPicker(
                    scrollController: _scrollController,
                    itemExtent: 46,
                    magnification: 1.15,
                    squeeze: 1.1,
                    useMagnifier: true,
                    selectionOverlay: const SizedBox.shrink(),
                    onSelectedItemChanged: (index) {
                      _tempIndex = index;
                    },
                    children: widget.options.map((mins) {
                      final durationText = '$mins dk';

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.onDurationSelected(mins);
                          Navigator.pop(context);
                        },
                        child: Center(
                          child: Text(
                            durationText,
                            style: AppTypography.sfProRounded(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // "Süreyi Uygula" Butonu
            BouncingWidget(
              onTap: () {
                final chosen = widget.options[_tempIndex];
                widget.onDurationSelected(chosen);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: ctaColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : ctaColor).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Süreyi Uygula',
                    style: AppTypography.sfProRounded(
                      fontSize: 15.5,
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
