import 'package:flutter/material.dart';

enum RoomCategory {
  bed,
  desk,
  rug,
  window,
  decor,
  wallDecor;

  String getTitle(String lang) {
    switch (this) {
      case RoomCategory.bed:
        return lang == 'en' ? 'Bed' : 'Yatak';
      case RoomCategory.desk:
        return lang == 'en' ? 'Study Desk' : 'Çalışma Masası';
      case RoomCategory.rug:
        return lang == 'en' ? 'Floor Rug' : 'Zemin Halısı';
      case RoomCategory.window:
        return lang == 'en' ? 'Window' : 'Pencere';
      case RoomCategory.decor:
        return lang == 'en' ? 'Desk Decor' : 'Masa Dekoru';
      case RoomCategory.wallDecor:
        return lang == 'en' ? 'Wall Art' : 'Duvar Tablosu';
    }
  }

  String get iconEmoji {
    switch (this) {
      case RoomCategory.bed:
        return '🛏️';
      case RoomCategory.desk:
        return '🪑';
      case RoomCategory.rug:
        return '🧶';
      case RoomCategory.window:
        return '🪟';
      case RoomCategory.decor:
        return '🪴';
      case RoomCategory.wallDecor:
        return '🖼️';
    }
  }

  IconData get iconData {
    switch (this) {
      case RoomCategory.bed:
        return Icons.bed_rounded;
      case RoomCategory.desk:
        return Icons.desk_rounded;
      case RoomCategory.rug:
        return Icons.texture_rounded;
      case RoomCategory.window:
        return Icons.window_rounded;
      case RoomCategory.decor:
        return Icons.local_florist_rounded;
      case RoomCategory.wallDecor:
        return Icons.image_rounded;
    }
  }
}

class RoomFurnitureItem {
  final String id;
  final RoomCategory category;
  final int level;
  final String nameTr;
  final String nameEn;
  final String descriptionTr;
  final String descriptionEn;
  final String unlockRequirementTr;
  final String unlockRequirementEn;
  final bool isUnlocked;
  final bool isThemeable;
  final String? thumbnailPath;

  const RoomFurnitureItem({
    required this.id,
    required this.category,
    required this.level,
    required this.nameTr,
    required this.nameEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.unlockRequirementTr,
    required this.unlockRequirementEn,
    this.isUnlocked = false,
    this.isThemeable = false,
    this.thumbnailPath,
  });

  String getName(String lang) => lang == 'en' ? nameEn : nameTr;
  String getDescription(String lang) => lang == 'en' ? descriptionEn : descriptionTr;
  String getUnlockRequirement(String lang) => lang == 'en' ? unlockRequirementEn : unlockRequirementTr;

  String getThumbnailAsset(String theme) {
    if (thumbnailPath == null) return '';
    if (isThemeable) {
      return '${thumbnailPath}_$theme.png';
    }
    return '$thumbnailPath.png';
  }

  static List<RoomFurnitureItem> get catalog => [
    // ── 1. Yataklar ──
    const RoomFurnitureItem(
      id: 'bed_lv1',
      category: RoomCategory.bed,
      level: 1,
      nameTr: 'Sade Ahşap Karyola',
      nameEn: 'Minimalist Oak Bed',
      descriptionTr: 'Doğal İskandinav meşesi, keten şilte ve pastel kapitone yorgan.',
      descriptionEn: 'Natural light oak frame, linen mattress and pastel quilt.',
      unlockRequirementTr: 'Varsayılan Başlangıç Eşyası',
      unlockRequirementEn: 'Default Starter Item',
      isUnlocked: true,
      isThemeable: true,
      thumbnailPath: 'assets/images/room/thumb_bed_lv1',
    ),
    const RoomFurnitureItem(
      id: 'bed_lv2',
      category: RoomCategory.bed,
      level: 2,
      nameTr: 'Masif Meşe Çekmeceli Karyola',
      nameEn: 'Solid Oak Storage Bed',
      descriptionTr: 'Depolama çekmeceli masif ahşap gövde ve pelüş keten yastıklar.',
      descriptionEn: 'Solid wood bed with under-bed storage drawers and plush pillows.',
      unlockRequirementTr: '25 Saat Odaklanınca Açılır',
      unlockRequirementEn: 'Unlocks after 25 Hours Focus',
      isUnlocked: false,
      isThemeable: true,
      thumbnailPath: 'assets/images/room/thumb_bed_lv1',
    ),
    const RoomFurnitureItem(
      id: 'bed_lv3',
      category: RoomCategory.bed,
      level: 3,
      nameTr: 'Bohem Cibinlikli Karyola',
      nameEn: 'Boho Canopy Daybed',
      descriptionTr: 'Uçuşan tül perdeler, masal gibi peri ışıkları ve keten şilte.',
      descriptionEn: 'Flowing sheer drapes, fairy lights and plush linen bedding.',
      unlockRequirementTr: '100 Saat Odaklanınca Açılır',
      unlockRequirementEn: 'Unlocks after 100 Hours Focus',
      isUnlocked: false,
      isThemeable: true,
      thumbnailPath: 'assets/images/room/thumb_bed_lv1',
    ),

    // ── 2. Çalışma Masaları ──
    const RoomFurnitureItem(
      id: 'desk_lv1',
      category: RoomCategory.desk,
      level: 1,
      nameTr: 'İskandinav Çalışma Masası',
      nameEn: 'Scandinavian Study Desk',
      descriptionTr: 'Pirinç kulplu kırtasiye çekmecesi ve minderli ahşap tabure.',
      descriptionEn: 'Oak desk with stationery drawer and matching cushioned stool.',
      unlockRequirementTr: 'Varsayılan Başlangıç Eşyası',
      unlockRequirementEn: 'Default Starter Item',
      isUnlocked: true,
      isThemeable: true,
      thumbnailPath: 'assets/images/room/thumb_desk_lv1',
    ),
    const RoomFurnitureItem(
      id: 'desk_lv2',
      category: RoomCategory.desk,
      level: 2,
      nameTr: 'Raflı Kütüphaneli Masa',
      nameEn: 'Bookshelf Study Desk',
      descriptionTr: 'Üst raflarında kitap dizilebilen geniş çalışma masası ve ergonomik koltuk.',
      descriptionEn: 'Spacious desk with upper bookshelf hutch and ergonomic armchair.',
      unlockRequirementTr: '50 Saat Odaklanınca Açılır',
      unlockRequirementEn: 'Unlocks after 50 Hours Focus',
      isUnlocked: false,
      isThemeable: true,
      thumbnailPath: 'assets/images/room/thumb_desk_lv1',
    ),

    // ── 3. Halı / Paspas ──
    const RoomFurnitureItem(
      id: 'rug_lv1',
      category: RoomCategory.rug,
      level: 1,
      nameTr: 'Örgü Jüt Paspas',
      nameEn: 'Braided Jute Rug',
      descriptionTr: 'Eşmerkezli dairesel örgü deseni ve pastel vurgulu doğal zemin örtüsü.',
      descriptionEn: 'Concentric braided circles with pastel accent ring.',
      unlockRequirementTr: 'Varsayılan Başlangıç Eşyası',
      unlockRequirementEn: 'Default Starter Item',
      isUnlocked: true,
      isThemeable: false,
      thumbnailPath: 'assets/images/room/thumb_rug_lv1',
    ),
    const RoomFurnitureItem(
      id: 'rug_lv2',
      category: RoomCategory.rug,
      level: 2,
      nameTr: 'Bohem Dokuma Geometrik Kilim',
      nameEn: 'Boho Woven Kilim',
      descriptionTr: 'Yumuşak pastel geometrik desenler ve püsküllü kenarlar.',
      descriptionEn: 'Soft pastel geometric motifs and hand-tied fringes.',
      unlockRequirementTr: '7 Gün Kesintisiz Rutin ile Açılır',
      unlockRequirementEn: 'Unlocks with 7-Day Routine Streak',
      isUnlocked: false,
      isThemeable: false,
      thumbnailPath: 'assets/images/room/thumb_rug_lv1',
    ),

    // ── 4. Pencereler ──
    const RoomFurnitureItem(
      id: 'window_lv1',
      category: RoomCategory.window,
      level: 1,
      nameTr: 'Sabah Pencereli Ahşap Pervaz',
      nameEn: 'Morning Sunlight Window',
      descriptionTr: 'Dışarıda hafif bulutlar ve sabah güneşi süzülen 4 camlı pencere.',
      descriptionEn: '4-pane wooden window casting warm morning sunbeams.',
      unlockRequirementTr: 'Varsayılan Başlangıç Eşyası',
      unlockRequirementEn: 'Default Starter Item',
      isUnlocked: true,
      isThemeable: false,
      thumbnailPath: 'assets/images/room/thumb_window_lv1',
    ),
    const RoomFurnitureItem(
      id: 'window_lv2',
      category: RoomCategory.window,
      level: 2,
      nameTr: 'Keten Tül Perdeli Fransız Penceresi',
      nameEn: 'Linen Sheer French Window',
      descriptionTr: 'Yumuşak keten tülleri rüzgarla dans eden geniş çift kanatlı pencere.',
      descriptionEn: 'Tall French window with breezy linen curtains.',
      unlockRequirementTr: '50 Tamamlanan Plan ile Açılır',
      unlockRequirementEn: 'Unlocks after 50 Completed Plans',
      isUnlocked: false,
      isThemeable: false,
      thumbnailPath: 'assets/images/room/thumb_window_lv1',
    ),

    // ── 5. Masa Dekoru ──
    const RoomFurnitureItem(
      id: 'decor_lv1',
      category: RoomCategory.decor,
      level: 1,
      nameTr: 'Sukulent & Kalemlik & Ajanda',
      nameEn: 'Succulent & Stationery Set',
      descriptionTr: 'Terracotta saksıda sukulent, seramik kalemlik ve açık ipek ayraçlı ajanda.',
      descriptionEn: 'Terracotta succulent, ceramic pencil holder and open journal.',
      unlockRequirementTr: 'Varsayılan Başlangıç Eşyası',
      unlockRequirementEn: 'Default Starter Item',
      isUnlocked: true,
      isThemeable: false,
      thumbnailPath: 'assets/images/room/thumb_decor_lv1',
    ),
    const RoomFurnitureItem(
      id: 'decor_lv2',
      category: RoomCategory.decor,
      level: 2,
      nameTr: 'Retro Pirinç Gece Lambası & Kupa',
      nameEn: 'Retro Brass Lamp & Warm Mug',
      descriptionTr: 'Masanın köşesini sıcak sarı ışıkla aydınlatan lamba ve buharı tüten kupa.',
      descriptionEn: 'Warm vintage brass lamp and cozy steaming mug.',
      unlockRequirementTr: '15 Saat Odaklanınca Açılır',
      unlockRequirementEn: 'Unlocks after 15 Hours Focus',
      isUnlocked: false,
      isThemeable: false,
      thumbnailPath: 'assets/images/room/thumb_decor_lv1',
    ),

    // ── 6. Duvar Tablosu ──
    const RoomFurnitureItem(
      id: 'wall_lv1',
      category: RoomCategory.wallDecor,
      level: 1,
      nameTr: 'Adaçayı Botanik Çerçeve',
      nameEn: 'Sage Botanical Art Frame',
      descriptionTr: 'Pirinç askılı ahşap çerçeve ve suluboya okaliptüs illüstrasyonu.',
      descriptionEn: 'Wooden picture frame with watercolor botanical leaf print.',
      unlockRequirementTr: 'Varsayılan Başlangıç Eşyası',
      unlockRequirementEn: 'Default Starter Item',
      isUnlocked: true,
      isThemeable: false,
      thumbnailPath: 'assets/images/room/thumb_wall_decor_lv1',
    ),
    const RoomFurnitureItem(
      id: 'wall_lv2',
      category: RoomCategory.wallDecor,
      level: 2,
      nameTr: 'Vintage Ahşap Duvar Saati',
      nameEn: 'Vintage Wood Wall Clock',
      descriptionTr: 'Tık tık zamanı sayan minimalist İskandinav duvar saati.',
      descriptionEn: 'Minimalist Scandinavian wooden wall clock.',
      unlockRequirementTr: '30 Gün Rutin ile Açılır',
      unlockRequirementEn: 'Unlocks with 30-Day Routine',
      isUnlocked: false,
      isThemeable: false,
      thumbnailPath: 'assets/images/room/thumb_wall_decor_lv1',
    ),
  ];
}
