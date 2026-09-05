/// 🎨 Calenda Varlık (Asset) Sabitleri
///
/// Tüm görsel, arka plan, ikon ve illüstrasyon dosya yolları
/// bu sınıf üzerinden merkezi ve tip güvenli olarak yönetilir.
class AppAssets {
  AppAssets._();

  // ── 🌟 İkonlar ──
  static const String appIcon = 'assets/icons/app_icon.png';

  // ── 🖼️ Arka Planlar ──
  static const String wallpaper = 'assets/images/backgrounds/wallpaper.jpg';
  static const String corkBoard = 'assets/images/backgrounds/cork_board.png';

  // ── ⚜️ Vintage Çerçeveler ──
  static const String vintageFrameParchment =
      'assets/images/frames/vintage_frame_parchment.png';
  static const String vintageFrameOverlay =
      'assets/images/frames/vintage_frame_overlay.png';

  // ── 📜 İllüstrasyonlar & Animasyonlar ──
  static const String welcomeIllustration =
      'assets/images/illustrations/welcome_illustration.jpg';
  static const String vintageHourglass =
      'assets/images/illustrations/vintage_hourglass.png';
  static const String vintageHourglassAnimated =
      'assets/images/illustrations/vintage_hourglass_animated.webp';

  // ── 📌 Yapışkanlı Notlar (Sticky Notes) ──
  static const String notesPath = 'assets/images/notes/';
  static const String blueNote = 'assets/images/notes/blue_note.png';
  static const String greenNote = 'assets/images/notes/green_note.png';
  static const String lilacNote = 'assets/images/notes/lilac_note.png';
  static const String orangeNote = 'assets/images/notes/orange_note.png';
  static const String pinkNote = 'assets/images/notes/pink_note.png';
  static const String purpleNote = 'assets/images/notes/purple_note.png';
  static const String yellowNote = 'assets/images/notes/yellow_note.png';

  // ── 🐾 Avatarlar & Aksesuarlar Dizin Yolları ──
  static const String avatarsPath = 'assets/avatars/';
  static const String accessoriesPath = 'assets/accessories/';

  static String avatar(String name) => 'assets/avatars/.png';
  static String accessory(String name) => 'assets/accessories/.png';
}
