import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';

/// 🌿 Rutin Veri Modeli
class RoutineItem {
  final String id;
  final String title;
  final String time;
  final String category;
  final IconData icon;
  final Color color;
  final Color accent;
  bool completed;
  int streak;

  RoutineItem({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.icon,
    required this.color,
    required this.accent,
    this.completed = false,
    this.streak = 1,
  });
}

/// 🌿 Calenda — Rutinler ve Alışkanlıklar Ekranı
class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  String _selectedCategory = 'Tümü';

  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _textPrimary = Color(0xFF1A2B1D);
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  List<RoutineItem> _routines = [];

  @override
  void initState() {
    super.initState();
    _initRoutines();
  }

  @override
  void reassemble() {
    super.reassemble();
    _initRoutines();
  }

  void _initRoutines() {
    if (_routines.isEmpty) {
      _routines = [
        RoutineItem(
          id: 'r1',
          title: 'Sabah Suyu & Limon',
          time: '08:00',
          category: 'Sabah',
          icon: Icons.water_drop_outlined,
          color: const Color(0xFFDAEAF6),
          accent: const Color(0xFF4A7C59),
          completed: true,
          streak: 12,
        ),
        RoutineItem(
          id: 'r2',
          title: '20 Sayfa Kitap Okuma',
          time: '09:30',
          category: 'Sabah',
          icon: Icons.menu_book_rounded,
          color: const Color(0xFFFDEBF0),
          accent: const Color(0xFFC47B89),
          completed: false,
          streak: 5,
        ),
        RoutineItem(
          id: 'r3',
          title: 'Günlük Plan & Öncelikler',
          time: '10:00',
          category: 'Sabah',
          icon: Icons.edit_note_rounded,
          color: const Color(0xFFEBF7EE),
          accent: const Color(0xFF4A7C59),
          completed: true,
          streak: 8,
        ),
        RoutineItem(
          id: 'r4',
          title: '15 Dk Yürüyüş / Esneme',
          time: '17:30',
          category: 'Akşam',
          icon: Icons.directions_walk_rounded,
          color: const Color(0xFFFCF4DD),
          accent: const Color(0xFFB59A57),
          completed: false,
          streak: 3,
        ),
        RoutineItem(
          id: 'r5',
          title: 'Akşam Günlüğü & Değerlendirme',
          time: '22:00',
          category: 'Akşam',
          icon: Icons.nightlight_round,
          color: const Color(0xFFE8DFF5),
          accent: const Color(0xFF8E79AB),
          completed: false,
          streak: 4,
        ),
      ];
    }
  }

  void _toggleRoutine(int index) {
    if (index < 0 || index >= _routines.length) return;
    setState(() {
      final item = _routines[index];
      item.completed = !item.completed;
      if (item.completed) {
        item.streak += 1;
      } else {
        item.streak = (item.streak - 1).clamp(0, 999);
      }
    });
  }

  void _showAddRoutineSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '08:30');
    String chosenCat = 'Sabah';
    IconData chosenIcon = Icons.check_circle_outline_rounded;

    final iconsList = [
      {'icon': Icons.water_drop_outlined, 'name': 'Su'},
      {'icon': Icons.menu_book_rounded, 'name': 'Kitap'},
      {'icon': Icons.edit_note_rounded, 'name': 'Plan'},
      {'icon': Icons.directions_walk_rounded, 'name': 'Yürüyüş'},
      {'icon': Icons.self_improvement_rounded, 'name': 'Meditasyon'},
      {'icon': Icons.nightlight_round, 'name': 'Uyku'},
      {'icon': Icons.fitness_center_rounded, 'name': 'Spor'},
      {'icon': Icons.brush_rounded, 'name': 'Sanat'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Yeni Rutin Ekle',
                      style: AppTypography.sfProRounded(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtrl,
                      style: AppTypography.sfPro(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rutin Adı (Örn: 10 Dk Meditasyon)',
                        hintStyle: TextStyle(color: mutedText, fontSize: 14),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1B2C22) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: ctaColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: timeCtrl,
                            style: AppTypography.sfPro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Saat (Örn: 08:30)',
                              hintStyle: TextStyle(color: mutedText, fontSize: 14),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2C22) : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Kategori Seçici
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1B2C22) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: chosenCat,
                              dropdownColor: cardColor,
                              items: ['Sabah', 'Akşam', 'Gün İçi'].map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: AppTypography.sfPro(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: primaryText,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setModalState(() => chosenCat = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'İkon Seç',
                      style: AppTypography.sfPro(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: mutedText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: iconsList.map((item) {
                            final ic = item['icon'] as IconData;
                            final isSel = chosenIcon == ic;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: BouncingWidget(
                                onTap: () => setModalState(() => chosenIcon = ic),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? ctaColor
                                        : (isDark ? const Color(0xFF1B2C22) : Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel
                                          ? Colors.transparent
                                          : (isDark ? AppColors.darkBorder : const Color(0xFFE2ECE0)),
                                    ),
                                  ),
                                  child: Icon(
                                    ic,
                                    size: 22,
                                    color: isSel ? Colors.white : primaryText,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    BouncingWidget(
                      onTap: () {
                        final t = titleCtrl.text.trim();
                        if (t.isNotEmpty) {
                          setState(() {
                            _routines.add(
                              RoutineItem(
                                id: 'r_${DateTime.now().millisecondsSinceEpoch}',
                                title: t,
                                time: timeCtrl.text.trim().isNotEmpty ? timeCtrl.text.trim() : '08:00',
                                category: chosenCat,
                                icon: chosenIcon,
                                color: const Color(0xFFEFF5ED),
                                accent: const Color(0xFF4A7C59),
                                completed: false,
                                streak: 1,
                              ),
                            );
                          });
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: ctaColor,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            'Rutini Kaydet',
                            style: AppTypography.sfProRounded(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;
    final completedCount = _routines.where((r) => r.completed == true).length;
    final totalCount = _routines.length;
    final progress = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    final filteredRoutines = _selectedCategory == 'Tümü'
        ? _routines
        : _routines.where((r) => r.category == _selectedCategory).toList();

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── HEADER (Planlayıcı Sekmesi ile Birebir Uyumlu) ───
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Sol: Kategori & Başlık
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              size: 16,
                              color: mutedText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Günün Alışkanlıkları',
                              style: AppTypography.sfPro(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rutinler',
                          style: AppTypography.sfProRounded(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),

                    // Sağ: + Yeni Ekle Butonu (Eylül Rozeti Standardında)
                    BouncingWidget(
                      onTap: _showAddRoutineSheet,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF142814))
                                  .withValues(alpha: isDark ? 0.25 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: ctaColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Yeni Ekle',
                              style: AppTypography.sfProRounded(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // ─── GÜNLÜK BAŞARI & İLERLEME BENTO KARTI ───
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : const Color(0xFF142814))
                          .withValues(alpha: isDark ? 0.22 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: ctaColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              completedCount == totalCount && totalCount > 0
                                  ? 'Tüm Rutinler Tamamlandı'
                                  : 'Bugün $completedCount / $totalCount Rutin Tamamlandı',
                              style: AppTypography.sfProRounded(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '%$percentage',
                          style: AppTypography.sfProRounded(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: ctaColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: isDark ? const Color(0xFF23382B) : const Color(0xFFEAF0E7),
                        valueColor: AlwaysStoppedAnimation<Color>(ctaColor),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ─── KATEGORİ FİLTRE HAPLARI ───
              Row(
                children: ['Tümü', 'Sabah', 'Akşam'].map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: BouncingWidget(
                      onTap: () => setState(() => _selectedCategory = cat),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? ctaColor
                              : (isDark ? const Color(0xFF15231B) : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: isDark && !isSel
                              ? Border.all(color: AppColors.darkBorder)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF142814))
                                  .withValues(alpha: isSel ? 0.15 : 0.04),
                              blurRadius: isSel ? 8 : 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          cat,
                          style: AppTypography.sfProRounded(
                            fontSize: 13,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                            color: isSel
                                ? Colors.white
                                : (isDark ? AppColors.darkTextPrimary : primaryText),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // ─── RUTİNLER LİSTESİ ───
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 104),
                  itemCount: filteredRoutines.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filteredRoutines[index];
                    final realIndex = _routines.indexOf(item);
                    final isDone = item.completed;
                    final streak = item.streak;

                    return BouncingWidget(
                      onTap: () => _toggleRoutine(realIndex),
                      borderRadius: BorderRadius.circular(22),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(22),
                          border: isDark
                              ? Border.all(
                                  color: isDone ? ctaColor : AppColors.darkBorder,
                                  width: isDone ? 1.5 : 1.0,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF142814))
                                  .withValues(alpha: isDone ? 0.08 : 0.04),
                              blurRadius: isDone ? 12 : 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // İkon Kutusu
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? ctaColor.withValues(alpha: 0.12)
                                    : (isDark ? const Color(0xFF1E3025) : const Color(0xFFEFF5ED)),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                item.icon,
                                size: 22,
                                color: isDone ? ctaColor : primaryText,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Başlık & Saat & Seri Bilgisi
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppTypography.sfProRounded(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: primaryText,
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                      decorationColor: mutedText,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 13,
                                        color: mutedText,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.time,
                                        style: AppTypography.sfPro(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: mutedText,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF28201B)
                                              : const Color(0xFFFFF1EB),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.local_fire_department_rounded,
                                              size: 12,
                                              color: Color(0xFFE27D60),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              '$streak gün',
                                              style: AppTypography.sfPro(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFFE27D60),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Checkbox
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone ? ctaColor : Colors.transparent,
                                border: Border.all(
                                  color: isDone ? ctaColor : (isDark ? AppColors.darkBorder : const Color(0xFFD4DFD3)),
                                  width: 2,
                                ),
                              ),
                              child: isDone
                                  ? const Center(
                                      child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
