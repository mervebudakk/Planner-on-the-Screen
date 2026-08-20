import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Aesthetic pastel ve canlı renk seçim çipleri
class AestheticColorPicker extends StatelessWidget {
  final String selectedColorHex;
  final Function(String) onColorChanged;

  const AestheticColorPicker({
    super.key,
    required this.selectedColorHex,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppColors.eventPalette.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final color = AppColors.eventPalette[index];
          final hex = AppColors.colorToHex(color);
          final isSelected = hex.toLowerCase() == selectedColorHex.toLowerCase();

          return GestureDetector(
            onTap: () => onColorChanged(hex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 42 : 36,
              height: isSelected ? 42 : 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
