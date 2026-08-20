import 'package:flutter/material.dart';

/// Aesthetic renk paletleri ve tema renkleri
class AppColors {
  // Arka Plan ve Koyu Tema Renkleri
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D26);
  static const Color darkCard = Color(0xFF222736);
  static const Color darkBorder = Color(0xFF2F3548);

  // Metin Renkleri
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF6B7280);

  // Vurgu Rengi
  static const Color accent = Color(0xFF6366F1); // Indigo
  static const Color accentLight = Color(0xFF818CF8);

  // Aesthetic Etkinlik/Ders Renk Paleti (Referans ekran görüntülerindeki renkler)
  static const List<Color> eventPalette = [
    Color(0xFF60A5FA), // Soft Mavi (Business Class)
    Color(0xFFF472B6), // Pastel Pembe (Part-time shift)
    Color(0xFFFBBF24), // Sıcak Amber / Turuncu (Quick workout)
    Color(0xFF34D399), // Nane Yeşili (Project meeting)
    Color(0xFFA78BFA), // Lavanta Moru (Economics)
    Color(0xFFF87171), // Mercan Kırmızı (Statistics)
    Color(0xFF38BDF8), // Gökyüzü Mavisi (Psychology)
    Color(0xFFE2E8F0), // Minimalist Beyaz / Gri (Trader Joe's)
  ];

  // Hex Helper
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
