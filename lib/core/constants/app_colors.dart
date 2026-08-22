import 'package:flutter/material.dart';

/// Calenda & Apple HIG Standartlarında Huzurlu Matcha / Adaçayı Yeşili ve Mat Pastel Renk Sistemi
class AppColors {
  static const String defaultEventColorHex = '#ABC4DF';
  static const String defaultWidgetBackgroundHex = '#FFFFFF';
  static const String defaultWidgetTextHex = '#0F172A';

  // ─── AÇIK TEMA (LIGHT MODE - HUZURLU PASTEL MATCHA YEŞİLİ) ───
  static const Color lightBackground = Color(0xFFEEF5E4); // Yumuşak Açık Pastel Adaçayı Yeşili
  static const Color lightSurface = Color(0xFFF6FAF2);    // Süt Beyazı / Matcha Cam
  static const Color lightCard = Color(0xFFFFFFFF);       // Saf Beyaz Kapsül Kart
  static const Color lightCardElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFDBE8D3);     // İnce Soft Matcha Sınırı
  static const Color lightDivider = Color(0xFFE4EFE0);

  // 🌿 TAM SİYAH YERİNE ÇOK ÇOK KOYU DOĞAL ORMAN / MATCHA YEŞİLİ METİNLER
  static const Color lightTextPrimary = Color(0xFF102E19);   // Çok Çok Koyu Orman Yeşili (Başlıklar & Ana Metinler)
  static const Color lightTextSecondary = Color(0xFF38553F); // Koyu Adaçayı Yeşili (Alt Başlıklar & Saatler)
  static const Color lightTextMuted = Color(0xFF63836A);     // Yumuşak Pastel Adaçayı Yeşili

  // ─── KOYU TEMA (DARK MODE - FOREST OBSIDIAN) ───
  static const Color darkBackground = Color(0xFF0C1610);  // Derin Orman Gece Yeşili
  static const Color darkSurface = Color(0xFF14241B);     // Koyu Obsidian Matcha Cam
  static const Color darkCard = Color(0xFF16281E);
  static const Color darkCardElevated = Color(0xFF1D3327);
  static const Color darkBorder = Color(0xFF274232);      // Koyu Orman Sınır
  static const Color darkDivider = Color(0xFF1A3024);

  static const Color darkTextPrimary = Color(0xFFEDF7EE);
  static const Color darkTextSecondary = Color(0xFFA1C4A9);
  static const Color darkTextMuted = Color(0xFF6B8E73);

  // ─── VURGU RENKLERİ (ACCENT - DERİN ORMAN YEŞİLİ) ───
  static const Color primary = Color(0xFF102E19);          // Derin Huzurlu Matcha Yeşili
  static const Color primaryLight = Color(0xFF234B2D);     // Orta Matcha Ormanı
  static const Color primarySage = Color(0xFF4D7558);      // Soft Adaçayı
  static const Color todayHighlight = Color(0xFF102E19);   // Seçili Gün Dolgusu
  static const Color forestAccent = Color(0xFF102E19);

  // ─── 🎨 APPLE HIG UYUMLU MAT & PARLAMAYAN MİNERAL PASTEL RENKLERİ ───
  static const List<Color> pastelPalette = [
    Color(0xFFE8B4B8), // Muted Linen Rose (Mat Gül Pembesi)
    Color(0xFFE2C9A5), // Warm Oat / Cream (Sıcak Yulaf Kreması)
    Color(0xFFA8D5BA), // Sage Mist (Adaçayı Nanesi)
    Color(0xFFABC4DF), // Soft Slate Blue (Dumanlı Bebek Mavisi)
    Color(0xFFC7B8E3), // Dusty Lavender (Puslu Lavanta)
    Color(0xFFE5B99F), // Terracotta Blush (Toprak Şeftali)
    Color(0xFFB8C0D9), // Periwinkle Fog (Sisli Menekşe)
    Color(0xFFB5CFA8), // Soft Celadon (Huzurlu Seladon Yeşili)
    Color(0xFFDEC3B3), // Warm Sand (Sıcak Doğal Kum)
    Color(0xFFC5DACB), // Pale Eucalyptus (Okaliptüs Yeşili)
    Color(0xFFD4C2D9), // Heather Mist (Yumuşak Funda)
    Color(0xFFD9D5C5), // Olive Linen (Zeytin Keten)
  ];

  // ─── HEX DÖNÜŞTÜRÜCÜLER ───
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Hex renk dizesini standartlaştırır ve güvenli kılar (Örn: "DAEAF6" -> "#DAEAF6", "#daeaf6" -> "#DAEAF6")
  static String normalizeHexColor(String? hexString, {String fallback = defaultEventColorHex}) {
    if (hexString == null) return fallback;
    var cleaned = hexString.trim().toUpperCase();
    if (cleaned.isEmpty) return fallback;
    if (!cleaned.startsWith('#')) {
      cleaned = '#$cleaned';
    }
    final hexRegExp = RegExp(r'^#([A-F0-9]{6}|[A-F0-9]{8})$');
    if (!hexRegExp.hasMatch(cleaned)) {
      return fallback;
    }
    return cleaned;
  }

  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    final normalized = normalizeHexColor(hexString);
    if (normalized.length == 7) buffer.write('ff');
    buffer.write(normalized.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFFABC4DF);
    }
  }

  // ─── ÖZEL RENK PALETİ LİSTESİ DÖNÜŞTÜRÜCÜLERİ ───
  static List<Color> getFullPalette(List<String> customHexColors) {
    final customColors = customHexColors.map((hex) => hexToColor(hex)).toList();
    return [...pastelPalette, ...customColors];
  }
}
