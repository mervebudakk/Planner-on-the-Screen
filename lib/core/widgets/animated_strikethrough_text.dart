import 'package:flutter/material.dart';

/// ✍️ Metin Üzerinde Soldan Sağa Çizilme Animasyonu Yapan Widget
///
/// Görev veya plan tamamlandığında soldan sağa akıcı bir kalem çizik efekti çizer.
class AnimatedStrikethroughText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool isCompleted;
  final Color? strikeColor;
  final double strokeWidth;
  final Duration duration;
  final int? maxLines;
  final TextOverflow overflow;

  const AnimatedStrikethroughText({
    super.key,
    required this.text,
    required this.style,
    required this.isCompleted,
    this.strikeColor,
    this.strokeWidth = 2.0,
    this.duration = const Duration(milliseconds: 320),
    this.maxLines,
    this.overflow = TextOverflow.visible,
  });

  @override
  State<AnimatedStrikethroughText> createState() => _AnimatedStrikethroughTextState();
}

class _AnimatedStrikethroughTextState extends State<AnimatedStrikethroughText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.isCompleted ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedStrikethroughText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStrikeColor = widget.strikeColor ??
        (widget.style.color?.withValues(alpha: 0.75) ?? const Color(0xFF8B948A));

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return CustomPaint(
              foregroundPainter: _MultiLineStrikePainter(
                progress: _animation.value,
                text: widget.text,
                style: widget.style,
                color: effectiveStrikeColor,
                strokeWidth: widget.strokeWidth,
                maxWidth: constraints.maxWidth,
                maxLines: widget.maxLines,
                overflow: widget.overflow,
              ),
              child: Text(
                widget.text,
                style: widget.style,
                maxLines: widget.maxLines,
                overflow: widget.overflow,
                softWrap: true,
              ),
            );
          },
        );
      },
    );
  }
}

class _MultiLineStrikePainter extends CustomPainter {
  final double progress;
  final String text;
  final TextStyle style;
  final Color color;
  final double strokeWidth;
  final double maxWidth;
  final int? maxLines;
  final TextOverflow overflow;

  _MultiLineStrikePainter({
    required this.progress,
    required this.text,
    required this.style,
    required this.color,
    required this.strokeWidth,
    required this.maxWidth,
    this.maxLines,
    this.overflow = TextOverflow.visible,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '...' : null,
    )..layout(maxWidth: maxWidth.isFinite ? maxWidth : size.width);

    final lineMetrics = textPainter.computeLineMetrics();
    if (lineMetrics.isEmpty) {
      // Fallback tek satır çizim
      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final y = size.height / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width * progress, y), paint);
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final lineCount = lineMetrics.length;
    final progressPerLine = 1.0 / lineCount;

    for (int i = 0; i < lineCount; i++) {
      final startProgress = i * progressPerLine;
      if (progress < startProgress) break;

      final currentLineProgress =
          ((progress - startProgress) / progressPerLine).clamp(0.0, 1.0);
      final lm = lineMetrics[i];

      // Y konumu: Karakterlerin tam dikey merkezinden geçer (baseline - ascent * 0.48)
      final y = lm.baseline - (lm.ascent * 0.48);
      final startX = lm.left;
      final endX = lm.left + (lm.width * currentLineProgress);

      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MultiLineStrikePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.text != text;
  }
}
