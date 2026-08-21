import 'package:flutter/material.dart';

/// Venngage Seçkin Soft Pastel Renk Paleti ve Açık/Koyu Tema Renk Sistemi
class AppColors {
  static const String defaultEventColorHex = '#60A5FA';
  static const String defaultWidgetBackgroundHex = '#000000';
  static const String defaultWidgetTextHex = '#FFFFFF';

  // ─── AÇIK TEMA (LIGHT MODE - VARSAYILAN) ───
  static const Color lightBackground = Color(0xFFF8FAFC); // Ferah Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);    // Saf Beyaz
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);     // İnce Slate 200
  static const Color lightDivider = Color(0xFFF1F5F9);

  static const Color lightTextPrimary = Color(0xFF0F172A);   // Derin Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightTextMuted = Color(0xFF94A3B8);     // Slate 400

  // ─── KOYU TEMA (DARK MODE) ───
  static const Color darkBackground = Color(0xFF0F172A);  // Derin Gece Mavisi
  static const Color darkSurface = Color(0xFF1E293B);     // Koyu Slate
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardElevated = Color(0xFF273147);
  static const Color darkBorder = Color(0xFF334155);      // Slate 700
  static const Color darkDivider = Color(0xFF1E293B);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // ─── VURGU RENKLERİ (ACCENT) ───
  static const Color primary = Color(0xFF6366F1);      // Indigo / Canlı Mavi
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color todayHighlight = Color(0xFF3B82F6); // Bugün rozeti rengi

  // ─── 🎨 VENNGAGE SOFT PASTEL RENK PALETİ ───
  // (Kaynak: https://venngage.com/blog/pastel-color-palettes/)
  static const List<Color> pastelPalette = [
    Color(0xFFDAEAF6), // Venngage Pastel Sky Blue (Bebek Mavisi)
    Color(0xFFFCE1E4), // Venngage Soft Blush Pink (Pudra Gül)
    Color(0xFFFCF4DD), // Venngage Cream Buttercup (Pastel Tereyağı)
    Color(0xFFB5EAD7), // Venngage Soft Mint (Pastel Nane)
    Color(0xFFE8DFF5), // Venngage Lavender Mist (Lavanta)
    Color(0xFFFFDAC1), // Venngage Peach Blossom (Şeftali)
    Color(0xFFCDB4DB), // Venngage Lilac Orchid (Leylak)
    Color(0xFFFFC8DD), // Venngage Cotton Candy Rose (Şeker Pembe)
    Color(0xFFBDE0FE), // Venngage Powder Blue (Pudra Mavi)
    Color(0xFFA2D2FF), // Venngage Pastel Cerulean (Gök Mavisi)
    Color(0xFFCAFFBF), // Venngage Spring Sprout (Matcha / Filiz Yeşili)
    Color(0xFFFDFFB6), // Venngage Warm Vanilla (Pastel Vanilya)
    Color(0xFF9BF6FF), // Venngage Pastel Aqua (Su Yeşili / Turkuaz)
    Color(0xFFA0C4FF), // Venngage Periwinkle Breeze (Cezayir Menekşesi)
    Color(0xFFFFC6FF), // Venngage Orchid Dream (Pastel Orkide)
    Color(0xFFF8AD9D), // Venngage Melon Coral (Somon / Mercan)
    Color(0xFFFBC4AB), // Venngage Warm Apricot (Sıcak Kayısı)
    Color(0xFFDDEDEA), // Venngage Sage Dew (Adaçayı)
  ];

  // ─── HEX DÖNÜŞTÜRÜCÜLER ───
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  static bool isValidHexColor(String hexString) {
    return RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hexString.trim());
  }

  static String normalizeHexColor(
    String? hexString, {
    String fallback = defaultEventColorHex,
  }) {
    final value = hexString?.trim();
    if (value != null && isValidHexColor(value)) {
      return value.toUpperCase();
    }
    return fallback;
  }

  static Color hexToColor(
    String hexString, {
    Color fallback = const Color(0xFFDAEAF6),
  }) {
    try {
      final normalized = normalizeHexColor(
        hexString,
        fallback: colorToHex(fallback),
      );
      final clean = normalized.replaceFirst('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } on Object {
      return fallback;
    }
    return fallback;
  }
}
