import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';

/// 🌿 Calenda Masalsı Rutinler ve Alışkanlıklar Ekranı
class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final List<Map<String, dynamic>> _routines = [
    {
      'id': 'r1',
      'title': 'Sabah Suyu & Limon',
      'time': '08:00',
      'icon': Icons.water_drop_outlined,
      'color': const Color(0xFFDAEAF6),
      'accent': const Color(0xFF6A9BC3),
      'completed': true,
      'streak': 12,
    },
    {
      'id': 'r2',
      'title': '20 Sayfa Kitap Okuma',
      'time': '09:30',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFFDEBF0),
      'accent': const Color(0xFFC47B89),
      'completed': false,
      'streak': 5,
    },
    {
      'id': 'r3',
      'title': 'Günlük Plan & Öncelikler',
      'time': '10:00',
      'icon': Icons.draw_outlined,
      'color': const Color(0xFFEBF7EE),
      'accent': const Color(0xFF6B9B78),
      'completed': true,
      'streak': 8,
    },
    {
      'id': 'r4',
      'title': '15 Dk Esneme / Yürüyüş',
      'time': '17:30',
      'icon': Icons.directions_walk_rounded,
      'color': const Color(0xFFFCF4DD),
      'accent': const Color(0xFFB59A57),
      'completed': false,
      'streak': 3,
    },
    {
      'id': 'r5',
      'title': 'Akşam Günlüğü & Minnet',
      'time': '22:00',
      'icon': Icons.nightlight_round,
      'color': const Color(0xFFE8DFF5),
      'accent': const Color(0xFF8E79AB),
      'completed': false,
      'streak': 4,
    },
  ];

  void _toggleRoutine(int index) {
    setState(() {
      _routines[index]['completed'] = !(_routines[index]['completed'] as bool);
      if (_routines[index]['completed'] == true) {
        _routines[index]['streak'] = (_routines[index]['streak'] as int) + 1;
      } else {
        _routines[index]['streak'] = (_routines[index]['streak'] as int) - 1;
      }
    });
  }

  void _showAddRoutineSheet() {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '09:00');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFAF7F2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6C8BB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Yeni Rutin Ekle',
                  style: AppTypography.sfProRounded(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2B33),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleCtrl,
                  style: AppTypography.sfPro(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF4A2B33)),
                  decoration: InputDecoration(
                    hintText: 'Rutin Adı (Örn: 15 dk Meditasyon)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFEADBCE)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: timeCtrl,
                  style: AppTypography.sfPro(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF4A2B33)),
                  decoration: InputDecoration(
                    hintText: 'Saat (Örn: 09:00)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFEADBCE)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                BouncingWidget(
                  onTap: () {
                    final t = titleCtrl.text.trim();
                    if (t.isNotEmpty) {
                      setState(() {
                        _routines.add({
                          'id': 'r_',
                          'title': t,
                          'time': timeCtrl.text.trim(),
                          'icon': Icons.auto_awesome_rounded,
                          'color': const Color(0xFFFDEBF0),
                          'accent': const Color(0xFFC47B89),
                          'completed': false,
                          'streak': 1,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2B33),
                      borderRadius: BorderRadius.circular(20),
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    final completedCount = _routines.where((r) => r['completed'] == true).length;

    return AppleAmbientBackground(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rutinler & Alışkanlıklar',
                        style: AppTypography.sfProRounded(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$completedCount / ${_routines.length} Tamamlandı',
                        style: AppTypography.sfPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFC47B89),
                        ),
                      ),
                    ],
                  ),

                  // + Rutin Ekle Butonu
                  BouncingWidget(
                    onTap: _showAddRoutineSheet,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3326) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.add_rounded, size: 22, color: isDark ? Colors.white : titleColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Rutinler Listesi ──
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 110),
                  itemCount: _routines.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _routines[index];
                    final isDone = item['completed'] as bool;
                    final color = item['color'] as Color;
                    final accent = item['accent'] as Color;
                    final streak = item['streak'] as int;

                    return BouncingWidget(
                      onTap: () => _toggleRoutine(index),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? (isDone ? const Color(0xFF1B2C22) : const Color(0xFF15231B))
                              : (isDone ? Colors.white.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.7)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDone ? const Color(0xFFE6ABA7) : (isDark ? const Color(0xFF2E4D37) : const Color(0xFFEADBCE)),
                            width: isDone ? 1.5 : 1,
                          ),
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFE6ABA7).withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // İkon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E3326) : color,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                size: 22,
                                color: isDark ? Colors.white : accent,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Rutin Bilgileri
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: AppTypography.sfProRounded(
                                      fontSize: 15.5,
                                      fontWeight: isDone ? FontWeight.w800 : FontWeight.w600,
                                      color: isDark ? AppColors.darkTextPrimary : titleColor,
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                      decorationColor: const Color(0xFFC47B89),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        item['time'] as String,
                                        style: AppTypography.sfPro(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? AppColors.darkTextMuted : subtitleColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFDEBF0),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.local_fire_department_rounded, size: 12, color: Color(0xFFC47B89)),
                                            const SizedBox(width: 2),
                                            Text(
                                              '$streak gün',
                                              style: AppTypography.sfPro(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF8B5A2B),
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
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone ? const Color(0xFFE6ABA7) : Colors.transparent,
                                border: Border.all(
                                  color: isDone ? const Color(0xFFE6ABA7) : const Color(0xFFD6C8BB),
                                  width: 2,
                                ),
                              ),
                              child: isDone
                                  ? const Center(
                                      child: Icon(Icons.check_rounded, size: 15, color: Colors.white),
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
