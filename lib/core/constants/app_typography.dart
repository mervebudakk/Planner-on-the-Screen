import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 🎨 Calenda Tipografi Sistemi
/// iOS   → Native SF Pro / SF Pro Rounded (sistem fontu, en yüksek kalite)
/// Android → DM Sans (Google Sans'ın en yakın açık kaynak eşdeğeri)
class AppTypography {
  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  // Fallback zinciri (sistem ve gömülü fontu garanti altına alır)
  static const List<String> sfProFallbacks = [
    'DMSans',
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

  /// Normal metinler
  /// iOS: SF Pro Text (native) — Android: DM Sans
  /// Kullanım: selamlama, açıklama, etiket, saat
  static TextStyle sfPro({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    final tracking = letterSpacing ?? _tracking(fontSize);
    final effectiveColor = color ?? AppColors.lightTextPrimary;

    if (_isIOS) {
      // iOS: doğrudan sistem SF Pro'su
      return TextStyle(
        fontFamily: '.SF Pro Text',
        fontFamilyFallback: sfProFallbacks,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: effectiveColor,
        letterSpacing: tracking,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
      );
    }

    // Android: DM Sans (Google Sans muadili)
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: effectiveColor,
      letterSpacing: tracking,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }

  /// Başlık metinleri
  /// iOS: SF Pro Rounded (native) — Android: DM Sans Bold
  /// Kullanım: isim, bölüm başlığı, CTA, büyük rakamlar
  static TextStyle sfProRounded({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    final tracking = letterSpacing ?? _tracking(fontSize);
    final effectiveColor = color ?? AppColors.lightTextPrimary;

    if (_isIOS) {
      // iOS: doğrudan sistem SF Pro Rounded'ı
      return TextStyle(
        fontFamily: '.SF Pro Rounded',
        fontFamilyFallback: sfProFallbacks,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: effectiveColor,
        letterSpacing: tracking,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
      );
    }

    // Android: DM Sans (geometrik, yuvarlak, Google Sans hissi)
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: effectiveColor,
      letterSpacing: tracking,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }

  /// Apple HIG optik tracking tablosu
  static double _tracking(double fontSize) {
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

  // ─── Semantik stiller ─────────────────────────────────────────────────────

  static TextStyle largeTitle({Color? color}) =>
      sfProRounded(fontSize: 34, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.37);

  static TextStyle title1({Color? color}) =>
      sfProRounded(fontSize: 28, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.36);

  static TextStyle title2({Color? color}) =>
      sfProRounded(fontSize: 22, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.35);

  static TextStyle title3({Color? color}) =>
      sfPro(fontSize: 20, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.38);

  static TextStyle headline({Color? color}) =>
      sfPro(fontSize: 17, fontWeight: FontWeight.w600, color: color, letterSpacing: -0.41);

  static TextStyle body({Color? color}) =>
      sfPro(fontSize: 17, fontWeight: FontWeight.w400, color: color, letterSpacing: -0.41);

  static TextStyle callout({Color? color}) =>
      sfPro(fontSize: 16, fontWeight: FontWeight.w400, color: color, letterSpacing: -0.32);

  static TextStyle subheadline({Color? color, FontWeight weight = FontWeight.w500}) =>
      sfPro(fontSize: 15, fontWeight: weight, color: color, letterSpacing: -0.24);

  static TextStyle footnote({Color? color, FontWeight weight = FontWeight.w400}) =>
      sfPro(fontSize: 13, fontWeight: weight, color: color, letterSpacing: -0.08);

  static TextStyle caption1({Color? color, FontWeight weight = FontWeight.w500}) =>
      sfPro(fontSize: 12, fontWeight: weight, color: color, letterSpacing: 0.0);

  static TextStyle caption2({Color? color, FontWeight weight = FontWeight.w600}) =>
      sfPro(fontSize: 11, fontWeight: weight, color: color, letterSpacing: 0.07);
}
