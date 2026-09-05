import 'package:flutter/material.dart';
import '../constants/app_typography.dart';
import 'bouncing_widget.dart';

class AestheticPlannerButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final double? width;
  final double height;
  final VoidCallback onPressed;
  final bool showInnerBorder;

  const AestheticPlannerButton({
    super.key,
    this.text,
    this.icon,
    this.width,
    this.height = 54.0,
    required this.onPressed,
    this.showInnerBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE8D3C7),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC78B99).withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 3,
              offset: Offset(0, -1),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7D6DC),
              Color(0xFFE8A5B2),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(showInnerBorder ? 3 : 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: showInnerBorder
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular((height - 6) / 2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.55),
                      width: 1.0,
                    ),
                  )
                : null,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: height * 0.38,
                      color: const Color(0xFF5D4037),
                    ),
                    if (text != null) const SizedBox(width: 8),
                  ],
                  if (text != null)
                    Text(
                      text!,
                      style: AppTypography.sfProRounded(
                        fontSize: height * 0.33,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5D4037),
                      ).copyWith(
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.65),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

