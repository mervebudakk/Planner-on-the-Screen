import 'package:flutter/material.dart';

/// Calenda & Apple HIG Standartlarında Huzurlu Matcha / Adaçayı Yeşili ve Mat Pastel Renk Sistemi
class AppColors {
  static const String defaultEventColorHex = '#ABC4DF';
  static const String defaultWidgetBackgroundHex = '#FFFFFF';
  static const String defaultWidgetTextHex = '#102E19';

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

  // ─── KOYU TEMA (DARK MODE - LUXURY OBSIDIAN & EMERALD MATCHA) ───
  static const Color darkBackground = Color(0xFF0E1511);      // Lüks Gece Obsidyeni
  static const Color darkBackgroundEnd = Color(0xFF141E18);   // Yumuşak Zümrüt Geçişi
  static const Color darkSurface = Color(0xFF18241D);         // Koyu Bento Yüzey
  static const Color darkCard = Color(0xFF18241D);            // Koyu Bento Kartı
  static const Color darkCardElevated = Color(0xFF203027);
  static const Color darkBorder = Color(0xFF283D30);          // Zarif Koyu Kenarlık
  static const Color darkDivider = Color(0xFF223529);

  static const Color darkTextPrimary = Color(0xFFF2F8F4);     // Net Kristal Nane Beyazı
  static const Color darkTextSecondary = Color(0xFFB4D8C2);   // Canlı Adaçayı Nanesi
  static const Color darkTextMuted = Color(0xFF769E85);       // Yumuşak Mat Adaçayı

  // ─── VURGU RENKLERİ (ACCENT) ───
  static const Color primary = Color(0xFF102E19);             // Açık Tema: Derin Huzurlu Matcha Yeşili
  static const Color darkPrimary = Color(0xFF2C6843);         // Koyu Tema: Canlı Zümrüt Matcha Vurgusu
  static const Color primaryLight = Color(0xFF234B2D);
  static const Color primarySage = Color(0xFF4D7558);
  static const Color todayHighlight = Color(0xFF102E19);
  static const Color forestAccent = Color(0xFF102E19);

  // ─── 🏷️ EYLEM VE AKSİYON RENKLERİ (AESTHETIC ACTION TONES) ───
  static const Color actionDelete = Color(0xFFC75A5A); // Yumuşak Mat Terrakotta / Vintage Gül (Soft Terracotta Rose)
  static const Color actionEdit = Color(0xFF4F708C);   // Dingin Mat Dumanlı Çelik Mavisi (Dusty Slate Blue)
  static const Color actionDefer = Color(0xFFC98A3C);  // Sıcak Bal Amberi / Yarına Aktarma (Warm Golden Honey)

  // ─── 🎨 APPLE HIG & VENNGAGE UYUMLU 18'Lİ ZENGİN PASTEL RENK PALETİ ───
  static const List<Color> pastelPalette = [
    Color(0xFFFFC8DD), // 1. Cotton Candy Rose (Pamuk Şeker Pembesi)
    Color(0xFFFFAFCC), // 2. Blush Pink (Gül Pembesi)
    Color(0xFFFCE1E4), // 3. Soft Powder Pink (Pudra Pembesi)
    Color(0xFFFFDAC1), // 4. Peach Blossom (Şeftali Çiçeği)
    Color(0xFFFFDFBA), // 5. Warm Apricot (Sıcak Kayısı)
    Color(0xFFFCF4DD), // 6. Cream Buttercup (Krem & Tereyağı)
    Color(0xFFB5EAD7), // 7. Soft Mint (Taze Nane Yeşili)
    Color(0xFFA8D5BA), // 8. Sage Mist (Adaçayı Nanesi)
    Color(0xFFB5CFA8), // 9. Soft Celadon (Huzurlu Seladon Yeşili)
    Color(0xFFC5DACB), // 10. Pale Eucalyptus (Okaliptüs Yeşili)
    Color(0xFFDAEAF6), // 11. Pastel Sky Blue (Gökyüzü Mavisi)
    Color(0xFFA2D2FF), // 12. Pastel Cerulean (Bebek Mavisi)
    Color(0xFFABC4DF), // 13. Soft Slate Blue (Dumanlı Çelik Mavisi)
    Color(0xFFB8C0D9), // 14. Periwinkle Fog (Sisli Menekşe)
    Color(0xFFE8DFF5), // 15. Lavender Mist (Lavanta Esintisi)
    Color(0xFFCDB4DB), // 16. Lilac Orchid (Leylak Orkide)
    Color(0xFFE8B4B8), // 17. Muted Linen Rose (Mat Keten Gülü)
    Color(0xFFDEC3B3), // 18. Warm Sand / Latte (Sıcak Doğal Kum)
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
