/// 🛋️ 3D Diorama Odası Eşya Modeli
class DioramaItem {
  final String id;
  final String nameTr;
  final String nameEn;
  final String icon;
  final int requiredXP;
  final List<int> meshIndices;
  final List<int> nodeIndices;

  const DioramaItem({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.icon,
    required this.requiredXP,
    required this.meshIndices,
    required this.nodeIndices,
  });

  String localizedName(bool isEn) => isEn ? nameEn : nameTr;

  /// 1. Kat (Cozy Bedroom) eşya kataloğu
  /// room_level_1.glb (63 parça / node) ile birebir eşleştirilmiştir.
  static const List<DioramaItem> floor1Items = [
    DioramaItem(
      id: 'bed',
      nameTr: 'Yatak',
      nameEn: 'Cozy Bed',
      icon: '🛏️',
      requiredXP: 50,
      meshIndices: [1],             // bed.001
      nodeIndices: [1],
    ),
    DioramaItem(
      id: 'rug',
      nameTr: 'Pastel Halı',
      nameEn: 'Pastel Rug',
      icon: '🧶',
      requiredXP: 100,
      meshIndices: [54],            // rug.001
      nodeIndices: [54],
    ),
    DioramaItem(
      id: 'desk',
      nameTr: 'Çalışma Masası',
      nameEn: 'Study Desk',
      icon: '🪵',
      requiredXP: 180,
      meshIndices: [32, 34, 35, 36, 37, 38], // desk.001, desk_drawer_01..05
      nodeIndices: [32, 34, 35, 36, 37, 38],
    ),
    DioramaItem(
      id: 'chair',
      nameTr: 'Çalışma Taburesi',
      nameEn: 'Desk Stool',
      icon: '🪑',
      requiredXP: 260,
      meshIndices: [33],            // desk_chair.001
      nodeIndices: [33],
    ),
    DioramaItem(
      id: 'laptop',
      nameTr: 'Çift Monitör & PC Seti',
      nameEn: 'Dual Monitor PC Setup',
      icon: '💻',
      requiredXP: 360,
      meshIndices: [24, 25, 26, 27, 28], // keyboard, monitor_01, monitor_02, mouse, mousepad
      nodeIndices: [24, 25, 26, 27, 28],
    ),
    DioramaItem(
      id: 'armchair',
      nameTr: 'Berjer Koltuk',
      nameEn: 'Lounge Armchair',
      icon: '🛋️',
      requiredXP: 480,
      meshIndices: [23],            // chair.001
      nodeIndices: [23],
    ),
    DioramaItem(
      id: 'nightstand',
      nameTr: 'Sehpa & Fincan',
      nameEn: 'Coffee Table & Mug',
      icon: '☕',
      requiredXP: 580,
      meshIndices: [56, 30],        // table, cup
      nodeIndices: [56, 30],
    ),
    DioramaItem(
      id: 'lamp',
      nameTr: 'Masa Lambası',
      nameEn: 'Desk Lamp',
      icon: '💡',
      requiredXP: 680,
      meshIndices: [46],            // lamp
      nodeIndices: [46],
    ),
    DioramaItem(
      id: 'curtain',
      nameTr: 'Tül Perdeler',
      nameEn: 'Window Curtains',
      icon: '🪟',
      requiredXP: 780,
      meshIndices: [31],            // curtain.001
      nodeIndices: [31],
    ),
    DioramaItem(
      id: 'shelf',
      nameTr: 'Kitaplık & Konsol',
      nameEn: 'Bookshelf & Console',
      icon: '🪜',
      requiredXP: 900,
      meshIndices: [21, 22, 29],    // cabinet_01.001, cabinet_01.002, console
      nodeIndices: [21, 22, 29],
    ),
    DioramaItem(
      id: 'books',
      nameTr: 'Kitaplar',
      nameEn: 'Books Collection',
      icon: '📚',
      requiredXP: 1020,
      meshIndices: [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], // book, book013..book029
      nodeIndices: [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
    ),
    DioramaItem(
      id: 'plants',
      nameTr: 'Bitkiler & Sarmaşıklar',
      nameEn: 'Plants & Ivy',
      icon: '🌿',
      requiredXP: 1150,
      meshIndices: [47, 48, 49, 50, 51, 52, 53], // plants_00.001..plants_03.002
      nodeIndices: [47, 48, 49, 50, 51, 52, 53],
    ),
    DioramaItem(
      id: 'wardrobe',
      nameTr: 'Duvar Tabloları',
      nameEn: 'Wall Art Frames',
      icon: '🖼️',
      requiredXP: 1280,
      meshIndices: [41, 42, 43, 44, 45], // frame.001..frame.005
      nodeIndices: [41, 42, 43, 44, 45],
    ),
    DioramaItem(
      id: 'slippers',
      nameTr: 'Çanta & Terlikler',
      nameEn: 'Backpack & Slippers',
      icon: '🎒',
      requiredXP: 1400,
      meshIndices: [0, 55],         // bag, slipper
      nodeIndices: [0, 55],
    ),
  ];
}
