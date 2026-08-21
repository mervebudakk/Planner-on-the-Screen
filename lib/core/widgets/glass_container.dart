import 'dart:ui';
import 'package:flutter/material.dart';

/// Apple iOS Tarzı Buzlu Cam (Frosted Glass) ve Dokunsal Yaylanma (Spring Scale) Kapsayıcısı
class GlassContainer extends StatefulWidget {
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
    this.opacity = 0.70,
    this.customColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.shadows,
    this.onTap,
    this.enableScaleEffect = true,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = widget.borderRadius ?? BorderRadius.circular(22);

    final baseColor = widget.customColor ??
        (isDark
            ? const Color(0xFF1E293B).withValues(alpha: widget.opacity * 0.75)
            : Colors.white.withValues(alpha: widget.opacity));

    final effectiveBorderColor = widget.borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.85));

    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: radius,
            border: Border.all(
              color: effectiveBorderColor,
              width: widget.borderWidth,
            ),
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.margin != null || widget.shadows != null) {
      content = Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: widget.shadows ??
              [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF64748B)).withValues(alpha: isDark ? 0.30 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
        ),
        child: content,
      );
    }

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: widget.enableScaleEffect ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.enableScaleEffect ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: widget.enableScaleEffect ? () => setState(() => _isPressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: content,
        ),
      );
    }

    return content;
  }
}
