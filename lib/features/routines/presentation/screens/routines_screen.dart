import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';

/// 🌿 Alışkanlık & Rutin Veri Modeli
class RoutineItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final Color accent;
  bool completed;
  int streak;

  RoutineItem({
    required this.id,
    required this.title,
    required this.icon,
    this.color = const Color(0xFFEFF5ED),
    this.accent = const Color(0xFF4A7C59),
    this.completed = false,
    this.streak = 1,
  });
}

/// 🌿 Calenda — Rutinler ve Alışkanlıklar Ekranı
class RoutinesScreen extends StatefulWidget {
  final bool isEmbedded;
  const RoutinesScreen({super.key, this.isEmbedded = false});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
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
          title: 'Günde 2 Litre Su',
          icon: Icons.water_drop_outlined,
          color: const Color(0xFFDAEAF6),
          accent: const Color(0xFF4A7C59),
          completed: true,
          streak: 12,
        ),
        RoutineItem(
          id: 'r2',
          title: '20 Sayfa Kitap Okuma',
          icon: Icons.menu_book_rounded,
          color: const Color(0xFFFDEBF0),
          accent: const Color(0xFFC47B89),
          completed: false,
          streak: 5,
        ),
        RoutineItem(
          id: 'r3',
          title: 'Günlük Öncelikler & Planlama',
          icon: Icons.edit_note_rounded,
          color: const Color(0xFFEBF7EE),
          accent: const Color(0xFF4A7C59),
          completed: true,
          streak: 8,
        ),
        RoutineItem(
          id: 'r4',
          title: '15 Dk Yürüyüş / Temiz Hava',
          icon: Icons.directions_walk_rounded,
          color: const Color(0xFFFCF4DD),
          accent: const Color(0xFFB59A57),
          completed: false,
          streak: 3,
        ),
        RoutineItem(
          id: 'r5',
          title: 'Akşam Günlüğü & Farkındalık',
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

  void _deleteRoutine(int index) {
    if (index < 0 || index >= _routines.length) return;
    setState(() {
      _routines.removeAt(index);
    });
  }

  void _showAddRoutineSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : _cardBg;
    final primaryText = isDark ? AppColors.darkTextPrimary : _textPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : _textMuted;
    final ctaColor = isDark ? AppColors.darkPrimary : _cta;

    final titleCtrl = TextEditingController();
    IconData chosenIcon = Icons.auto_awesome_rounded;

    final iconsList = [
      {'icon': Icons.menu_book_rounded, 'name': 'Kitap'},
      {'icon': Icons.water_drop_outlined, 'name': 'Su'},
      {'icon': Icons.self_improvement_rounded, 'name': 'Meditasyon'},
      {'icon': Icons.directions_walk_rounded, 'name': 'Yürüyüş'},
      {'icon': Icons.fitness_center_rounded, 'name': 'Spor'},
      {'icon': Icons.edit_note_rounded, 'name': 'Günlük'},
      {'icon': Icons.spa_outlined, 'name': 'Bakım'},
      {'icon': Icons.local_cafe_outlined, 'name': 'Mola'},
      {'icon': Icons.nightlight_round, 'name': 'Uyku'},
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
                      'Yeni Alışkanlık Ekle',
                      style: AppTypography.sfProRounded(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Her gün saatten bağımsız olarak kendine ayırmak istediğin bir rutin.',
                      style: AppTypography.sfPro(fontSize: 13, color: mutedText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      autofocus: true,
                      style: AppTypography.sfPro(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Alışkanlık Adı (Örn: 20 Sayfa Kitap Okuma)',
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
                    const SizedBox(height: 16),
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
                      height: 46,
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
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? ctaColor
                                        : (isDark ? const Color(0xFF1B2C22) : Colors.white),
                                    borderRadius: BorderRadius.circular(14),
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
                            'Alışkanlığı Kaydet',
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

    final content = Padding(
      padding: EdgeInsets.fromLTRB(20, widget.isEmbedded ? 8 : 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── BAŞLIK, DURUM & YENİ EKLE BUTONU ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günlük Rutinler',
                      style: AppTypography.sfProRounded(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      totalCount == 0
                          ? 'Alışkanlıklarını takip etmeye başla'
                          : (completedCount == totalCount
                              ? 'Tüm rutinler tamamlandı ✨'
                              : '$completedCount tamamlandı • ${totalCount - completedCount} kaldı'),
                      style: AppTypography.sfPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: completedCount == totalCount && totalCount > 0
                            ? (isDark ? const Color(0xFF68D391) : const Color(0xFF2E7D32))
                            : mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              BouncingWidget(
                onTap: _showAddRoutineSheet,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: ctaColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : ctaColor).withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Yeni Ekle',
                        style: AppTypography.sfProRounded(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ─── MİNİMALİST ÇİZGİSEL İLERLEME (PEBBLE PROGRESS) ───
          if (totalCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(totalCount, (index) {
                final isFilled = index < completedCount;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 4.5,
                    margin: EdgeInsets.only(right: index == totalCount - 1 ? 0 : 5),
                    decoration: BoxDecoration(
                      color: isFilled
                          ? (isDark ? const Color(0xFF48BB78) : ctaColor)
                          : (isDark ? const Color(0xFF233528) : const Color(0xFFE2ECE0)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ],

          const SizedBox(height: 14),

          // ─── RUTİNLER LİSTESİ ───
          Expanded(
            child: _routines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.spa_outlined,
                          size: 48,
                          color: mutedText.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Henüz bir rutin eklenmedi',
                          style: AppTypography.sfProRounded(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sağ üstteki "Yeni Ekle" ile günlük bir alışkanlık başlatabilirsin.',
                          textAlign: TextAlign.center,
                          style: AppTypography.sfPro(
                            fontSize: 13,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + (widget.isEmbedded ? 104 : 32),
                    ),
                    itemCount: _routines.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _routines[index];
                      final isDone = item.completed;
                      final streak = item.streak;

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteRoutine(index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        child: BouncingWidget(
                          onTap: () => _toggleRoutine(index),
                          borderRadius: BorderRadius.circular(22),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? (isDark ? const Color(0xFF132018) : const Color(0xFFF3F7F2))
                                  : cardColor,
                              borderRadius: BorderRadius.circular(22),
                              border: isDark
                                  ? Border.all(
                                      color: isDone
                                          ? const Color(0xFF2A4B35)
                                          : AppColors.darkBorder,
                                      width: 1.0,
                                    )
                                  : Border.all(
                                      color: isDone
                                          ? const Color(0xFFD7E6D5)
                                          : Colors.transparent,
                                      width: 1.0,
                                    ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? Colors.black : const Color(0xFF142814))
                                      .withValues(alpha: isDone ? 0.02 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
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
                                        ? ctaColor.withValues(alpha: 0.1)
                                        : (isDark ? const Color(0xFF1E3025) : item.color),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    size: 22,
                                    color: isDone
                                        ? ctaColor
                                        : (isDark ? AppColors.darkTextPrimary : item.accent),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Başlık & Seri Bilgisi
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: AppTypography.sfProRounded(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDone
                                              ? mutedText
                                              : primaryText,
                                          decoration: isDone ? TextDecoration.lineThrough : null,
                                          decorationColor: mutedText,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
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
                                                  '$streak gün seride',
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
                                      color: isDone
                                          ? ctaColor
                                          : (isDark ? AppColors.darkBorder : const Color(0xFFD4DFD3)),
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return content;
    }

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: content,
      ),
    );
  }
}
