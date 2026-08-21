import 'dart:ui';
import 'package:flutter/material.dart';

/// Apple iOS Tarzı Buzlu Cam (Frosted Glass / Glassmorphic) Kapsayıcı Bileşen
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

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 18.0,
    this.opacity = 0.70,
    this.customColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(22);

    final baseColor = customColor ??
        (isDark
            ? const Color(0xFF1E293B).withValues(alpha: opacity * 0.7)
            : Colors.white.withValues(alpha: opacity));

    final effectiveBorderColor = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.75));

    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: radius,
            border: Border.all(
              color: effectiveBorderColor,
              width: borderWidth,
            ),
          ),
          child: child,
        ),
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
                  color: (isDark ? Colors.black : Colors.black).withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
        ),
        child: content,
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    return content;
  }
}
