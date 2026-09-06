import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'bouncing_widget.dart';

/// Apple iOS & Calenda Kenarlıksız (Borderless) Buzlu Cam ve Mikro-Yay Dokunma Kapsayıcısı
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? customColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final bool enableScaleEffect;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 18.0,
    this.opacity = 0.75,
    this.customColor,
    this.borderColor,
    this.borderWidth = 0.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.shadows,
    this.onTap,
    this.enableScaleEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(24);

    final baseColor = customColor ??
        (isDark
            ? AppColors.darkSurface.withValues(alpha: (opacity * 0.95).clamp(0.0, 1.0))
            : Colors.white.withValues(alpha: opacity));

    final containerBody = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: radius,
        border: (borderColor != null || borderWidth > 0)
            ? Border.all(
                color: borderColor ?? Colors.transparent,
                width: borderWidth,
              )
            : (isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null),
      ),
      child: child,
    );

    // WebGL CanvasKit ortamında shader çöküşlerini engellemek için doğrudan yarı saydam zemin kullanılır
    Widget content = (kIsWeb || blur <= 0)
        ? ClipRRect(
            borderRadius: radius,
            child: containerBody,
          )
        : ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: containerBody,
            ),
          );

    if (margin != null || shadows != null) {
      content = Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: shadows ??
              [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF284834)).withValues(alpha: isDark ? 0.30 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
        ),
        child: content,
      );
    }

    if (onTap != null) {
      if (enableScaleEffect) {
        return BouncingWidget(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        );
      } else {
        return GestureDetector(
          onTap: onTap,
          child: content,
        );
      }
    }

    return content;
  }
}
