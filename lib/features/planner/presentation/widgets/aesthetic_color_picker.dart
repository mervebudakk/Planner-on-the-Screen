import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/planner_provider.dart';

/// Soft Pastel Renk Seçici ve `+` ile Özel Renk Oluşturma Bileşeni
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.hexToColor(selectedColorHex).withValues(alpha: 0.2),
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
              ],
            ),
            const SizedBox(height: 12),

            // Renk Swatch Listesi
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // 1. Varsayılan 14 Soft Pastel Renk
                ...AppColors.pastelPalette.map((color) {
                  final hex = AppColors.colorToHex(color);
                  final isSelected = hex.toUpperCase() == selectedColorHex.toUpperCase();

                  return _buildColorCircle(
                    color: color,
                    isSelected: isSelected,
                    onTap: () => onColorSelected(hex),
                  );
                }),

                // 2. Kullanıcının Eklediği Özel Renkler
                ...customColors.map((hex) {
                  final color = AppColors.hexToColor(hex);
                  final isSelected = hex.toUpperCase() == selectedColorHex.toUpperCase();

                  return _buildColorCircle(
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

  Widget _buildColorCircle({
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
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
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: isSelected
            ? const Center(
                child: Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildAddCustomColorButton(
    BuildContext context,
    PlannerProvider provider,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => _showCustomColorDialog(context, provider),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Icon(
          Icons.add,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  /// 🎨 Özel Renk Oluşturma Diyaloğu
  void _showCustomColorDialog(BuildContext context, PlannerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _CustomColorPickerDialog(
        initialHex: selectedColorHex,
        onColorCreated: (hex) {
          provider.addCustomColor(hex);
          onColorSelected(hex);
        },
      ),
    );
  }
}

/// Renk Çarkı / Ton Kaydırıcı ve Hex Girişi ile Özel Renk Diyaloğu
class _CustomColorPickerDialog extends StatefulWidget {
  final String initialHex;
  final ValueChanged<String> onColorCreated;

  const _CustomColorPickerDialog({
    required this.initialHex,
    required this.onColorCreated,
  });

  @override
  State<_CustomColorPickerDialog> createState() => _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<_CustomColorPickerDialog> {
  late double _hue;
  late double _saturation;
  late double _value;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    final initialColor = AppColors.hexToColor(widget.initialHex);
    final hsv = HSVColor.fromColor(initialColor);
    _hue = hsv.hue;
    _saturation =
        (hsv.saturation * 0.7).clamp(0.2, 0.7).toDouble(); // Pastel ton koruması
    _value = hsv.value.clamp(0.7, 1.0).toDouble();
    _hexController = TextEditingController(text: widget.initialHex);
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor {
    return HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
  }

  void _updateFromHSV() {
    final hex = AppColors.colorToHex(_currentColor);
    _hexController.text = hex;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.palette_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Özel Renk Oluştur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Canlı Renk Önizleme Kutusu
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _currentColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppColors.colorToHex(_currentColor),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Renk Tonu (Hue)
            Text(
              'Renk Tonu',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Slider(
              value: _hue,
              min: 0,
              max: 360,
              activeColor: _currentColor,
              onChanged: (val) {
                _hue = val;
                _updateFromHSV();
              },
            ),

            // Pastel Yumuşaklığı (Saturation)
            Text(
              'Pastel Yumuşaklığı',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Slider(
              value: _saturation,
              min: 0.1,
              max: 1.0,
              activeColor: _currentColor,
              onChanged: (val) {
                _saturation = val;
                _updateFromHSV();
              },
            ),

            // Parlaklık (Value)
            Text(
              'Açıklık / Parlaklık',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Slider(
              value: _value,
              min: 0.5,
              max: 1.0,
              activeColor: _currentColor,
              onChanged: (val) {
                _value = val;
                _updateFromHSV();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'İptal',
            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final hex = AppColors.colorToHex(_currentColor);
            widget.onColorCreated(hex);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Rengi Kullan'),
        ),
      ],
    );
  }
}
