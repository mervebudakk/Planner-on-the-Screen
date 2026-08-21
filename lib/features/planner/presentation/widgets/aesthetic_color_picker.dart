import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../providers/planner_provider.dart';

/// Timezy ve Aqua Estetiğinde Soft Pastel Renk Seçici ve `+` Özel Renk Oluşturucu
class AestheticColorPicker extends StatelessWidget {
  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;

  const AestheticColorPicker({
    super.key,
    required this.selectedColorHex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        final customColors = provider.customColors;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Renk Seçimi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                // Seçili rengin önizleme etiketi
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.hexToColor(selectedColorHex).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.hexToColor(selectedColorHex),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.hexToColor(selectedColorHex),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            selectedColorHex.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Renk Swatch Listesi
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // 1. Varsayılan Soft Pastel Renkler
                ...AppColors.pastelPalette.map((color) {
                  final hex = AppColors.colorToHex(color);
                  final isSelected = hex.toUpperCase() == selectedColorHex.toUpperCase();

                  return _ColorSwatchItem(
                    color: color,
                    isSelected: isSelected,
                    onTap: () => onColorSelected(hex),
                  );
                }),

                // 2. Kullanıcının Eklediği Özel Renkler
                ...customColors.map((hex) {
                  final color = AppColors.hexToColor(hex);
                  final isSelected = hex.toUpperCase() == selectedColorHex.toUpperCase();

                  return _ColorSwatchItem(
                    color: color,
                    isSelected: isSelected,
                    onTap: () => onColorSelected(hex),
                  );
                }),

                // 3. ➕ Özel Renk Ekle Butonu
                _buildAddCustomColorButton(context, provider, isDark),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddCustomColorButton(
    BuildContext context,
    PlannerProvider provider,
    bool isDark,
  ) {
    return BouncingWidget(
      onTap: () => _showCustomColorDialog(context, provider, isDark),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.40),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  void _showCustomColorDialog(
    BuildContext context,
    PlannerProvider provider,
    bool isDark,
  ) {
    double hue = 200.0;
    double saturation = 0.35;
    double value = 0.95;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentColor = HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();
            final hexString = AppColors.colorToHex(currentColor);

            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Özel Pastel Renk',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: currentColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black12,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: currentColor.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          hexString,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: ThemeData.estimateBrightnessForColor(currentColor) == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    _buildSlider(
                      title: 'Renk Tonu',
                      value: hue,
                      min: 0,
                      max: 360,
                      isDark: isDark,
                      activeColor: currentColor,
                      onChanged: (val) => setDialogState(() => hue = val),
                    ),

                    _buildSlider(
                      title: 'Pastel Yumuşaklığı',
                      value: saturation,
                      min: 0.1,
                      max: 0.45,
                      isDark: isDark,
                      activeColor: currentColor,
                      onChanged: (val) => setDialogState(() => saturation = val),
                    ),

                    _buildSlider(
                      title: 'Parlaklık',
                      value: value,
                      min: 0.75,
                      max: 1.0,
                      isDark: isDark,
                      activeColor: currentColor,
                      onChanged: (val) => setDialogState(() => value = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Vazgeç'),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.addCustomColor(hexString);
                    onColorSelected(hexString);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Rengi Ekle & Seç'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required bool isDark,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ColorSwatchItem extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatchItem({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.black.withValues(alpha: 0.08),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.7),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: isSelected
            ? Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 19,
                  color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF0F172A),
                ),
              )
            : null,
      ),
    );
  }
}
