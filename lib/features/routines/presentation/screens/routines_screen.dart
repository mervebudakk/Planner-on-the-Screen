import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/routine_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/error_logger.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/widgets/swipe_to_delete_tile.dart';
import '../widgets/add_routine_sheet.dart';

/// Calenda — Rutinler ve Alışkanlıklar Ekranı
class RoutinesScreen extends StatefulWidget {
  final bool isEmbedded;
  const RoutinesScreen({super.key, this.isEmbedded = false});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  static const Color _cardBg = Color(0xFFF8FAF5);
  static const Color _textPrimary = AppColors.lightTextPrimary;
  static const Color _textMuted = Color(0xFF8B948A);
  static const Color _cta = Color(0xFF0E260A);

  List<RoutineModel> _routines = [];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadRoutines();
      _isInitialized = true;
    }
  }

  void _loadRoutines() {
    final storage = context.read<StorageService>();
    final loaded = storage.getRoutines();
    setState(() {
      _routines = List.from(loaded);
    });
  }

  void _toggleRoutine(int index) {
    if (index < 0 || index >= _routines.length) return;
    final storage = context.read<StorageService>();
    final item = _routines[index];
    final newDone = !item.isCompleted;
    final newStreak = newDone ? item.streak + 1 : (item.streak - 1).clamp(0, 999);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final updated = item.copyWith(
      isCompleted: newDone,
      streak: newStreak,
      lastCompletedDate: newDone ? todayStr : item.lastCompletedDate,
    );

    setState(() {
      _routines[index] = updated;
    });

    storage.saveRoutines(_routines);
    unawaited(SupabaseService.instance.syncRoutine(
      id: updated.id,
      title: updated.title,
      time: '',
      category: 'Rutin',
      iconCodePoint: updated.iconCodePoint,
      colorHex: updated.colorValue.toString(),
      accentHex: updated.accentValue.toString(),
      isCompleted: updated.isCompleted,
      streak: updated.streak,
    ).catchError((e, st) {
      ErrorLogger.log('RoutinesScreen.syncRoutine', e, st);
    }));
  }

  void _deleteRoutineById(String routineId) {
    final index = _routines.indexWhere((r) => r.id == routineId);
    if (index == -1) return;
    final storage = context.read<StorageService>();
    final removed = _routines.removeAt(index);
    setState(() {});

    storage.saveRoutines(_routines);
    unawaited(SupabaseService.instance.deleteRoutine(removed.id).catchError((e, st) {
      ErrorLogger.log('RoutinesScreen.deleteRoutine', e, st);
    }));
  }

  void _showAddRoutineSheet() {
    AddRoutineSheet.show(
      context,
      onRoutineAdded: (newRoutine) {
        final storage = context.read<StorageService>();
        setState(() {
          _routines.add(newRoutine);
        });
        storage.saveRoutines(_routines);
        unawaited(SupabaseService.instance.syncRoutine(
          id: newRoutine.id,
          title: newRoutine.title,
          time: '',
          category: 'Rutin',
          iconCodePoint: newRoutine.iconCodePoint,
          colorHex: newRoutine.colorValue.toString(),
          accentHex: newRoutine.accentValue.toString(),
          isCompleted: newRoutine.isCompleted,
          streak: newRoutine.streak,
        ).catchError((e, st) {
          ErrorLogger.log('RoutinesScreen.addRoutine.sync', e, st);
        }));
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
    final completedCount = _routines.where((r) => r.isCompleted).length;
    final totalCount = _routines.length;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── CTA: YENİ RUTİN EKLE (Planlayıcı Kartı ile Tam Uyumlu) ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BouncingWidget(
            onTap: _showAddRoutineSheet,
            borderRadius: BorderRadius.circular(26),
            child: Container(
              height: 66,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(26),
                border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF142814))
                        .withValues(alpha: isDark ? 0.30 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: ctaColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.task_alt_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yeni Rutin Ekle',
                          style: AppTypography.sfProRounded(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Alışkanlık veya günlük hedef oluştur',
                          style: AppTypography.sfPro(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ─── GÜNLÜK RUTİNLER BENTO KARTI ───
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: isDark
                  ? const Border(
                      top: BorderSide(color: AppColors.darkBorder, width: 1.0),
                      left: BorderSide(color: AppColors.darkBorder, width: 1.0),
                      right: BorderSide(color: AppColors.darkBorder, width: 1.0),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF142814))
                      .withValues(alpha: isDark ? 0.22 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 🌟 KART ÜST BAŞLIĞI: GÜNLÜK RUTİNLER & TAMAMLANMA BİLGİSİ ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Günlük Rutinler',
                          style: AppTypography.sfProRounded(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                        if (_routines.isNotEmpty)
                          Text(
                            completedCount == totalCount
                                ? 'Hepsi Tamam ✨'
                                : '$completedCount/$totalCount Tamamlandı',
                            style: AppTypography.sfPro(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: completedCount == totalCount
                                  ? (isDark ? const Color(0xFF68D391) : const Color(0xFF2E7D32))
                                  : (isDark ? AppColors.darkTextMuted : const Color(0xFF7A9981)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ─── MİNİMALİST ÇİZGİSEL İLERLEME (PEBBLE PROGRESS) ───
                  if (totalCount > 0) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
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
                    ),
                    const SizedBox(height: 12),
                  ] else
                    const SizedBox(height: 6),

                  // ─── RUTİNLER LİSTESİ VEYA BOŞ DURUM ───
                  Expanded(
                    child: _routines.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(32, 20, 32, MediaQuery.of(context).padding.bottom + 84),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Henüz rutin eklenmemiş',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.sfProRounded(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Yeni bir rutin eklemek için yukarıdaki "Yeni Rutin Ekle" butonuna dokunun.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.sfPro(
                                      fontSize: 13,
                                      color: mutedText,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              16,
                              4,
                              16,
                              MediaQuery.of(context).padding.bottom + (widget.isEmbedded ? 92 : 36),
                            ),
                            itemCount: _routines.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _routines[index];
                              final isDone = item.isCompleted;
                              final streak = item.streak;

                              return SwipeToDeleteTile(
                                key: ValueKey(item.id),
                                borderRadius: 22,
                                onDelete: () {
                                  _deleteRoutineById(item.id);
                                  AestheticSnackBar.showDelete(context, '${item.title} silindi');
                                },
                                child: BouncingWidget(
                                  onTap: () => _toggleRoutine(index),
                                  borderRadius: BorderRadius.circular(22),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isDone
                                          ? (isDark ? const Color(0xFF132018) : const Color(0xFFF3F7F2))
                                          : (isDark ? const Color(0xFF1E3025) : Colors.white.withValues(alpha: 0.85)),
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
                                                  : const Color(0xFFE2EBE0),
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

                                        // Başlık & Alevli Sade Seri Sayacı (🔥 8)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: AppTypography.sfProRounded(
                                                  fontSize: 16.0,
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
                                                      horizontal: 8,
                                                      vertical: 2.5,
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
                                                          size: 13,
                                                          color: Color(0xFFE27D60),
                                                        ),
                                                        const SizedBox(width: 3.5),
                                                        Text(
                                                          '$streak',
                                                          style: AppTypography.sfProRounded(
                                                            fontSize: 12.0,
                                                            fontWeight: FontWeight.w800,
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
            ),
          ),
        ),
      ],
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
