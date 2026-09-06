import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/bouncing_widget.dart';

/// ⏱️ Calenda — Odak & Mola Süresi Seçici Alt Sayfası (Wheel Picker Sheet)
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
    final cardColor = isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2);
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Sürükleme Çubuğu
            Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),

            // Başlık & Kapatma Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isFocusMode ? 'Odak Süresi Seçimi' : 'Mola Süresi Seçimi',
                      style: AppTypography.sfProRounded(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isFocusMode
                          ? '15 dakikalık aralıklarla kaydırın veya seçin'
                          : 'İstediğiniz süreyi seçin',
                      style: AppTypography.sfPro(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: mutedText, size: 22),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // CupertinoPicker Tekerleği
            SizedBox(
              height: 210,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Arka Plan Seçim Vurgu Çerçevesi (Quiet Luxury Pill)
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : ctaColor).withValues(alpha: isDark ? 0.08 : 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isDark ? Colors.white24 : ctaColor.withValues(alpha: 0.18)),
                        width: 1.2,
                      ),
                    ),
                  ),

                  CupertinoPicker(
                    scrollController: _scrollController,
                    itemExtent: 48,
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
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: ctaColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : ctaColor).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Süreyi Uygula',
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
