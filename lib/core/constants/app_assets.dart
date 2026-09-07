/// 🎨 Calenda Varlık (Asset) Sabitleri
///
/// Tüm görsel, arka plan, ikon ve illüstrasyon dosya yolları
/// bu sınıf üzerinden merkezi ve tip güvenli olarak yönetilir.
class AppAssets {
  AppAssets._();

  // ── 🌟 İkonlar ──
  static const String appIcon = 'assets/icons/app_icon.png';

  // ── 🖼️ Arka Planlar ──
  static const String wallpaper = 'assets/images/backgrounds/wallpaper.webp';
  static const String clubStudyBg = 'assets/images/backgrounds/club_study_bg.jpg';
  static const String corkBoard = 'assets/images/backgrounds/cork_board.webp';

  // ── ⚜️ Vintage Çerçeveler ──
  static const String vintageFrameParchment =
      'assets/images/frames/vintage_frame_parchment.webp';
  static const String vintageFrameOverlay =
      'assets/images/frames/vintage_frame_overlay.webp';

  // ── 📜 İllüstrasyonlar & Görseller ──
  static const String welcomeIllustration =
      'assets/images/illustrations/welcome_illustration.webp';
  static const String vintageHourglass =
      'assets/images/illustrations/vintage_hourglass.webp';
  static const String kawaiiHourglass1 =
      'assets/images/illustrations/kawaii_hourglass_1.webp';
  static const String kawaiiHourglass2 =
      'assets/images/illustrations/kawaii_hourglass_2.webp';
  static const String kawaiiHourglass3 =
      'assets/images/illustrations/kawaii_hourglass_3.webp';
  static const String kawaiiHourglass4 =
      'assets/images/illustrations/kawaii_hourglass_4.webp';
  static const List<String> kawaiiHourglassFrames = [
    kawaiiHourglass1,
    kawaiiHourglass2,
    kawaiiHourglass3,
    kawaiiHourglass4,
  ];
  static const String rabbitFocus1 =
      'assets/images/illustrations/rabbit_focus_1.png';
  static const String rabbitFocus2 =
      'assets/images/illustrations/rabbit_focus_2.png';

  // ── 📌 Yapışkanlı Notlar (Sticky Notes) ──
  static const String notesPath = 'assets/images/notes/';
  static const String blueNote = 'assets/images/notes/blue_note.webp';
  static const String greenNote = 'assets/images/notes/green_note.webp';
  static const String lilacNote = 'assets/images/notes/lilac_note.webp';
  static const String orangeNote = 'assets/images/notes/orange_note.webp';
  static const String pinkNote = 'assets/images/notes/pink_note.webp';
  static const String purpleNote = 'assets/images/notes/purple_note.webp';
  static const String yellowNote = 'assets/images/notes/yellow_note.webp';

  // ── 🐾 Avatarlar & Aksesuarlar Dizin Yolları ──
  static const String avatarsPath = 'assets/avatars/';
  static const String accessoriesPath = 'assets/accessories/';

  static String avatar(String name) => 'assets/avatars/$name.webp';
  static String accessory(String name) => 'assets/accessories/$name.webp';
}
