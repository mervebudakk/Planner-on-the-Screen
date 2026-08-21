import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 🍎 Apple iOS Human Interface Guidelines (HIG) SF Pro Tipografi Sistemi
class AppTypography {
  // Apple HIG Native Fallback Ailesi (iOS cihazlarda doğrudan SF Pro / SF Pro Rounded kullanır)
  static const List<String> sfProFallbacks = [
    '.SF Pro Display',
    '.SF Pro Text',
    '.SF Pro Rounded',
    'SF Pro Display',
    'SF Pro Text',
    'SF Pro',
    '-apple-system',
    'BlinkMacSystemFont',
    'Helvetica Neue',
  ];

  /// Apple HIG standartlarında SF Pro / Inter font üreticisi
  static TextStyle sfPro({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    final effectiveColor = color ?? AppColors.lightTextPrimary;

    // Apple Optical Sizing Tracking Tablosu
    final effectiveLetterSpacing = letterSpacing ?? _calculateAppleTracking(fontSize);

    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: effectiveColor,
      letterSpacing: effectiveLetterSpacing,
      height: height,
      decoration: decoration,
    ).copyWith(
      fontFamilyFallback: sfProFallbacks,
    );
  }

  /// Apple HIG Yuvarlatılmış (SF Pro Rounded) Stil
  static TextStyle sfProRounded({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    final effectiveColor = color ?? AppColors.lightTextPrimary;
    final effectiveLetterSpacing = letterSpacing ?? _calculateAppleTracking(fontSize);

    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: effectiveColor,
      letterSpacing: effectiveLetterSpacing,
      height: height,
    ).copyWith(
      fontFamilyFallback: const [
        '.SF Pro Rounded',
        'SF Pro Rounded',
        ...sfProFallbacks,
      ],
    );
  }

  /// 🍎 Apple HIG Resmi Tracking (Harf Boşluğu) Hesaplayıcısı
  static double _calculateAppleTracking(double fontSize) {
    if (fontSize >= 34) return 0.37;
    if (fontSize >= 28) return 0.36;
    if (fontSize >= 22) return 0.35;
    if (fontSize >= 20) return 0.38;
    if (fontSize >= 17) return -0.41;
    if (fontSize >= 16) return -0.32;
    if (fontSize >= 15) return -0.24;
    if (fontSize >= 13) return -0.08;
    if (fontSize >= 12) return 0.0;
    return 0.07;
  }

  // ─── 🍎 11 RESMİ APPLE HIG SEMANTİK METİN STİLİ ───

  /// Large Title (34pt, Bold)
  static TextStyle largeTitle({Color? color}) => sfProRounded(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.37,
      );

  /// Title 1 (28pt, Bold)
  static TextStyle title1({Color? color}) => sfProRounded(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.36,
      );

  /// Title 2 (22pt, Bold)
  static TextStyle title2({Color? color}) => sfProRounded(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.35,
      );

  /// Title 3 (20pt, SemiBold)
  static TextStyle title3({Color? color}) => sfPro(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.38,
      );

  /// Headline (17pt, SemiBold)
  static TextStyle headline({Color? color}) => sfPro(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.41,
      );

  /// Body (17pt, Regular)
  static TextStyle body({Color? color}) => sfPro(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: -0.41,
      );

  /// Callout (16pt, Regular)
  static TextStyle callout({Color? color}) => sfPro(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: -0.32,
      );

  /// Subheadline (15pt, Regular / Medium)
  static TextStyle subheadline({Color? color, FontWeight weight = FontWeight.w500}) => sfPro(
        fontSize: 15,
        fontWeight: weight,
        color: color,
        letterSpacing: -0.24,
      );

  /// Footnote (13pt, Regular / Medium)
  static TextStyle footnote({Color? color, FontWeight weight = FontWeight.w400}) => sfPro(
        fontSize: 13,
        fontWeight: weight,
        color: color,
        letterSpacing: -0.08,
      );

  /// Caption 1 (12pt, Medium / Regular)
  static TextStyle caption1({Color? color, FontWeight weight = FontWeight.w500}) => sfPro(
        fontSize: 12,
        fontWeight: weight,
        color: color,
        letterSpacing: 0.0,
      );

  /// Caption 2 (11pt, Regular / SemiBold)
  static TextStyle caption2({Color? color, FontWeight weight = FontWeight.w600}) => sfPro(
        fontSize: 11,
        fontWeight: weight,
        color: color,
        letterSpacing: 0.07,
      );
}
