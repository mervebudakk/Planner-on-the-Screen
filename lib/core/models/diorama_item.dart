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
  static const List<DioramaItem> floor1Items = [
    DioramaItem(
      id: 'bed',
      nameTr: 'Yatak',
      nameEn: 'Cozy Bed',
      icon: '🛏️',
      requiredXP: 50,
      meshIndices: [0],
      nodeIndices: [0],
    ),
    DioramaItem(
      id: 'rug',
      nameTr: 'Oval Halı',
      nameEn: 'Oval Rug',
      icon: '🧶',
      requiredXP: 120,
      meshIndices: [14],
      nodeIndices: [14],
    ),
    DioramaItem(
      id: 'desk',
      nameTr: 'Çalışma Masası',
      nameEn: 'Study Desk',
      icon: '🪵',
      requiredXP: 200,
      meshIndices: [9, 8],
      nodeIndices: [9, 8],
    ),
    DioramaItem(
      id: 'chair',
      nameTr: 'Çalışma Sandalyesi',
      nameEn: 'Desk Chair',
      icon: '🪑',
      requiredXP: 300,
      meshIndices: [6, 5],
      nodeIndices: [6, 5],
    ),
    DioramaItem(
      id: 'laptop',
      nameTr: 'Laptop',
      nameEn: 'Laptop',
      icon: '💻',
      requiredXP: 420,
      meshIndices: [11],
      nodeIndices: [11],
    ),
    DioramaItem(
      id: 'nightstand',
      nameTr: 'Komodin',
      nameEn: 'Nightstand',
      icon: '🪞',
      requiredXP: 550,
      meshIndices: [16],
      nodeIndices: [16],
    ),
    DioramaItem(
      id: 'lamp',
      nameTr: 'Abajur',
      nameEn: 'Bedside Lamp',
      icon: '💡',
      requiredXP: 680,
      meshIndices: [10],
      nodeIndices: [10],
    ),
    DioramaItem(
      id: 'slippers',
      nameTr: 'Terlikler',
      nameEn: 'Slippers',
      icon: '🩴',
      requiredXP: 800,
      meshIndices: [12],
      nodeIndices: [12],
    ),
    DioramaItem(
      id: 'shelf',
      nameTr: 'Duvar Rafı',
      nameEn: 'Wall Shelf',
      icon: '🪜',
      requiredXP: 920,
      meshIndices: [15],
      nodeIndices: [15],
    ),
    DioramaItem(
      id: 'books',
      nameTr: 'Kitaplar',
      nameEn: 'Books',
      icon: '📚',
      requiredXP: 1050,
      meshIndices: [1],
      nodeIndices: [1],
    ),
    DioramaItem(
      id: 'wardrobe',
      nameTr: 'Gardırop',
      nameEn: 'Wardrobe',
      icon: '🚪',
      requiredXP: 1200,
      meshIndices: [4, 2, 3],
      nodeIndices: [4, 2, 3],
    ),
  ];
}
