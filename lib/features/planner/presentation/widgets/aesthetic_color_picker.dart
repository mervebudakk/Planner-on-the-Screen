import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
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
                  style: AppTypography.sfProRounded(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                // Seçili rengin önizleme etiketi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: AppColors.hexToColor(selectedColorHex).withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.hexToColor(selectedColorHex).withValues(alpha: 0.60),
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
                        style: AppTypography.sfPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 🎨 6 Sütunlu Kusursuz Simetrik Grid (Sağdaki Boşluğu Yok Eder)
            Builder(
              builder: (context) {
                final List<Widget> items = [
                  // 1. Varsayılan Renkler (18 Renk = 3 Tam Satır)
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
                      onLongPress: () => _showDeleteCustomColorDialog(context, provider, hex, isDark),
                    );
                  }),

                  // 3. ➕ Özel Renk Ekle Butonu
                  _buildAddCustomColorButton(context, provider, isDark),
                ];

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.16,
                  ),
                  itemBuilder: (context, index) {
                    return Center(child: items[index]);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCustomColorDialog(
    BuildContext context,
    PlannerProvider provider,
    String hex,
    bool isDark,
  ) {
    final color = AppColors.hexToColor(hex);
    final dialogBg = isDark ? const Color(0xFF14241B) : const Color(0xFFF8FAF5);
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Özel Rengi Kaldır',
          style: AppTypography.sfProRounded(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primaryText,
          ),
        ),
        content: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                '$hex özel rengini paletinizden kaldırmak istiyor musunuz?',
                style: AppTypography.sfPro(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primaryText,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Vazgeç',
              style: AppTypography.sfPro(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: mutedText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removeCustomColor(hex);
              if (selectedColorHex.toUpperCase() == hex.toUpperCase()) {
                onColorSelected(AppColors.colorToHex(AppColors.pastelPalette.first));
              }
              Navigator.pop(ctx);
              AestheticSnackBar.showDelete(context, '$hex rengi paletten kaldırıldı');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Kaldır'),
          ),
        ],
      ),
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
          color: isDark ? const Color(0xFF1E3526) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF0E260A).withValues(alpha: 0.35),
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
            size: 22,
            color: Color(0xFF0E260A),
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
    double saturation = 0.40;
    double value = 0.95;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentColor = HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();
            final hexString = AppColors.colorToHex(currentColor);
            final dialogBg = isDark ? const Color(0xFF14241B) : const Color(0xFFF8FAF5);
            final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
            final mutedText = isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A);

            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              titlePadding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              actionsPadding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              title: Text(
                'Özel Renk Oluştur',
                style: AppTypography.sfProRounded(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Canlı Renk Önizleme Kapsülü
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: currentColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.08),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: currentColor.withValues(alpha: 0.40),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          hexString,
                          style: AppTypography.sfProRounded(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: ThemeData.estimateBrightnessForColor(currentColor) == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Renk Tonu (Hue)
                    _buildSlider(
                      title: 'Renk Tonu',
                      valueStr: '${hue.toInt()}°',
                      value: hue,
                      min: 0,
                      max: 360,
                      isDark: isDark,
                      activeColor: currentColor,
                      primaryText: primaryText,
                      mutedText: mutedText,
                      onChanged: (val) => setDialogState(() => hue = val),
                    ),

                    const SizedBox(height: 12),

                    // 2. Doygunluk (Saturation)
                    _buildSlider(
                      title: 'Doygunluk',
                      valueStr: '%${(saturation * 100).toInt()}',
                      value: saturation,
                      min: 0.05,
                      max: 1.0,
                      isDark: isDark,
                      activeColor: currentColor,
                      primaryText: primaryText,
                      mutedText: mutedText,
                      onChanged: (val) => setDialogState(() => saturation = val),
                    ),

                    const SizedBox(height: 12),

                    // 3. Parlaklık (Brightness)
                    _buildSlider(
                      title: 'Parlaklık',
                      valueStr: '%${(value * 100).toInt()}',
                      value: value,
                      min: 0.40,
                      max: 1.0,
                      isDark: isDark,
                      activeColor: currentColor,
                      primaryText: primaryText,
                      mutedText: mutedText,
                      onChanged: (val) => setDialogState(() => value = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Vazgeç',
                    style: AppTypography.sfPro(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: mutedText,
                    ),
                  ),
                ),
                BouncingWidget(
                  onTap: () {
                    provider.addCustomColor(hexString);
                    onColorSelected(hexString);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E260A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Rengi Kaydet',
                      style: AppTypography.sfPro(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
    required String valueStr,
    required double value,
    required double min,
    required double max,
    required bool isDark,
    required Color activeColor,
    required Color primaryText,
    required Color mutedText,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.sfPro(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            Text(
              valueStr,
              style: AppTypography.sfPro(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: mutedText,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: isDark ? Colors.white12 : const Color(0xFFE2EBE0),
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.15),
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
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
  final VoidCallback? onLongPress;

  const _ColorSwatchItem({
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      onTap: onTap,
      onLongPress: onLongPress,
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
