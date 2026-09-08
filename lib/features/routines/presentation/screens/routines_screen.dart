import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/routine_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/error_logger.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/animated_strikethrough_text.dart';
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
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

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
    final now = DateTime.now();
    final todayStr = _dateFormat.format(now);
    final yesterdayStr = _dateFormat.format(now.subtract(const Duration(days: 1)));

    int newStreak;
    String? newLastDate;

    if (newDone) {
      // Tamamlandı olarak işaretlendi:
      if (item.lastCompletedDate == yesterdayStr) {
        // Dün yapılmıştı, bugün de yapıldı -> ardışık artış!
        newStreak = item.streak + 1;
      } else if (item.lastCompletedDate == todayStr) {
        // Zaten bugün yapılmıştı, tekrar işaretlendi
        newStreak = item.streak > 0 ? item.streak : 1;
      } else {
        // Yeni rutin veya seri daha önce kopmuş -> 1'den başla!
        newStreak = 1;
      }
      newLastDate = todayStr;
    } else {
      // Tamamlandı işareti geri alındı (uncheck):
      newStreak = (item.streak - 1).clamp(0, 999);
      newLastDate = newStreak > 0 ? yesterdayStr : null;
    }

    final updated = item.copyWith(
      isCompleted: newDone,
      streak: newStreak,
      lastCompletedDate: newLastDate,
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final dockOffset = (bottomPadding > 0 ? 4.0 : 10.0) + bottomPadding;
    final dockTotalHeight = dockOffset + 60.0;
    final cardBottomMargin = widget.isEmbedded ? (dockTotalHeight + 10.0) : (bottomPadding + 16.0);

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
                          context.l10n.newRoutine,
                          style: AppTypography.sfProRounded(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.createHabitSubtitle,
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
            margin: EdgeInsets.fromLTRB(20, 0, 20, cardBottomMargin),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(32),
              border: isDark
                  ? Border.all(color: AppColors.darkBorder, width: 1.0)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF142814))
                      .withValues(alpha: isDark ? 0.22 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
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
                          context.l10n.dailyRoutines,
                          style: AppTypography.sfProRounded(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                        if (_routines.isNotEmpty)
                          Text(
                            completedCount == totalCount
                                ? context.l10n.allDone
                                : context.l10n.completedRatio(completedCount, totalCount),
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
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.l10n.noRoutinesYet,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.sfProRounded(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.l10n.isTurkish
                                        ? 'Yeni bir rutin eklemek için yukarıdaki "Yeni Rutin Ekle" butonuna dokunun.'
                                        : 'Tap "Add New Routine" above to create a routine.',
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
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              4,
                              16,
                              16,
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
                                  AestheticSnackBar.showDelete(
                                    context,
                                    '${item.title} ${context.l10n.isTurkish ? 'silindi' : 'deleted'}',
                                  );
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

                                        // Başlık: Soldan Sağa Çizilme Efekti
                                        Expanded(
                                          child: AnimatedStrikethroughText(
                                            text: item.title,
                                            isCompleted: isDone,
                                            maxLines: null,
                                            overflow: TextOverflow.visible,
                                            style: AppTypography.sfProRounded(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w700,
                                              color: isDone ? mutedText : primaryText,
                                            ),
                                            strikeColor: isDark ? const Color(0xFF81A088) : const Color(0xFF4A6B53),
                                            strokeWidth: 2.2,
                                          ),
                                        ),
                                        // Sağ tarafta streak ikonu ve sayısı (streak > 0 ise göster, 0 ise kaybolur)
                                        if (streak > 0) ...[
                                          const SizedBox(width: 12),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.local_fire_department_rounded,
                                                size: 18,
                                                color: Color(0xFFE27D60),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$streak',
                                                style: AppTypography.sfProRounded(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFFE27D60),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
