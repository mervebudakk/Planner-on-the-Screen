import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../providers/planner_provider.dart';
import '../widgets/aesthetic_color_picker.dart';

/// 🍎 Apple iOS Standartlarında Yarı Saydam (Frosted Glass) Plan Ekleme / Düzenleme Modal Kartı
class EditEventSheet extends StatefulWidget {
  final ScheduleEvent? event;
  final int? initialDayOfWeek;
  final DateTime? initialDate;

  const EditEventSheet({
    super.key,
    this.event,
    this.initialDayOfWeek,
    this.initialDate,
  });

  /// Modal kart olarak alttan açar
  static Future<void> show(
    BuildContext context, {
    ScheduleEvent? event,
    int? initialDayOfWeek,
    DateTime? initialDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => EditEventSheet(
        event: event,
        initialDayOfWeek: initialDayOfWeek,
        initialDate: initialDate,
      ),
    );
  }

  @override
  State<EditEventSheet> createState() => _EditEventSheetState();
}

class _EditEventSheetState extends State<EditEventSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late int _selectedDayOfWeek;
  late DateTime? _eventDate;
  late TimeOfDay _startTime;
  TimeOfDay? _endTime;
  late bool _hasEndTime;
  late String _selectedColorHex;
  late bool _isReminderEnabled;
  late int _reminderMinutesBefore;

  // Fix #5: Controller'lar State'te yönetiliyor (build() içinde oluşturulmamalı)
  late FixedExtentScrollController _startHourCtrl;
  late FixedExtentScrollController _startMinuteCtrl;
  late FixedExtentScrollController _endHourCtrl;
  late FixedExtentScrollController _endMinuteCtrl;

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;

    _titleController = TextEditingController(text: event?.title ?? '');
    _subtitleController = TextEditingController(text: event?.subtitle ?? '');
    _selectedDayOfWeek = event?.dayOfWeek ??
        widget.initialDayOfWeek ??
        DateTimeUtils.currentDayOfWeek;
    _eventDate = widget.initialDate;
    _startTime = event != null
        ? TimeOfDay(hour: event.startHour, minute: event.startMinute)
        : const TimeOfDay(hour: 9, minute: 0);

    if (event != null) {
      if (event.hasNoEndTime) {
        _hasEndTime = false;
        _endTime = null;
      } else {
        _hasEndTime = true;
        _endTime = TimeOfDay(hour: event.endHour, minute: event.endMinute);
      }
    } else {
      _hasEndTime = false;
      _endTime = null;
    }

    _selectedColorHex = event?.colorHex ?? AppColors.defaultEventColorHex;
    _isReminderEnabled = event?.isNotificationEnabled ?? true;
    _reminderMinutesBefore = event?.reminderMinutesBefore ?? 15;

    // Fix #5: ScrollController'ları initState'te başlat
    _startHourCtrl   = FixedExtentScrollController(initialItem: _startTime.hour);
    _startMinuteCtrl = FixedExtentScrollController(initialItem: _startTime.minute ~/ 5);
    _endHourCtrl     = FixedExtentScrollController(initialItem: _endTime?.hour ?? 10);
    _endMinuteCtrl   = FixedExtentScrollController(initialItem: (_endTime?.minute ?? 0) ~/ 5);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    // Fix #5: ScrollController'ları dispose et
    _startHourCtrl.dispose();
    _startMinuteCtrl.dispose();
    _endHourCtrl.dispose();
    _endMinuteCtrl.dispose();
    super.dispose();
  }

  void _showCupertinoTimePicker({
    required BuildContext context,
    required String title,
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onTimeChanged,
    required bool isDark,
    VoidCallback? onClear,
  }) {
    int tempHour = initialTime.hour;
    int tempMinute = initialTime.minute;

    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A2B1D);
    final mutedTextColor = isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A);
    const ctaColor = Color(0xFF0E260A);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final pickerContent = Container(
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF14241B) : Colors.white)
                .withValues(alpha: isDark ? 0.94 : 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.85),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Üst Çizgi (Drag Handle)
                  Container(
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : const Color(0xFFD4DFD3),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Başlık Çubuğu: Vazgeç - Başlık - Bitti
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: Text(
                          'Vazgeç',
                          style: AppTypography.sfPro(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: mutedTextColor,
                          ),
                        ),
                      ),
                      Text(
                        title,
                        style: AppTypography.sfProRounded(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onTimeChanged(TimeOfDay(hour: tempHour, minute: tempMinute));
                          Navigator.pop(ctx);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: Text(
                          'Bitti',
                          style: AppTypography.sfPro(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFFB4D8C2) : ctaColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (onClear != null) ...[
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: () {
                        onClear();
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.alarm_off_rounded, size: 16, color: Color(0xFFEF4444)),
                      label: const Text(
                        'Bitiş Saatini Kaldır (Alarm Modu)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // ── Apple iOS Stili Çarklar ──
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IgnorePointer(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E3324).withValues(alpha: 0.65)
                                  : const Color(0xFFE8EFE5).withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2E4D37)
                                    : const Color(0xFFD0E1CD),
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTimeWheel(
                              itemCount: 24,
                              initialItem: tempHour,
                              primaryTextColor: primaryTextColor,
                              onSelectedItemChanged: (val) => tempHour = val,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                ':',
                                style: AppTypography.sfProRounded(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : ctaColor,
                                ),
                              ),
                            ),
                            _buildTimeWheel(
                              itemCount: 60,
                              initialItem: tempMinute,
                              primaryTextColor: primaryTextColor,
                              onSelectedItemChanged: (val) => tempMinute = val,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: kIsWeb
              ? pickerContent
              : BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: pickerContent,
                ),
        );
      },
    );
  }

  Widget _buildTimeWheel({
    required int itemCount,
    required int initialItem,
    required Color primaryTextColor,
    required ValueChanged<int> onSelectedItemChanged,
    FixedExtentScrollController? controller, // Fix #5: dışarıdan verilir
  }) {
    return SizedBox(
      width: 72,
      height: 200,
      child: CupertinoPicker.builder(
        // Fix #5: controller yoksa fallback olarak yeni oluştur (güvenli)
        scrollController: controller ?? FixedExtentScrollController(initialItem: initialItem),
        itemExtent: 48,
        selectionOverlay: const SizedBox.shrink(),
        useMagnifier: true,
        magnification: 1.18,
        squeeze: 1.15,
        onSelectedItemChanged: onSelectedItemChanged,
        childCount: itemCount,
        itemBuilder: (context, index) {
          final text = index.toString().padLeft(2, '0');
          return Center(
            child: Text(
              text,
              style: AppTypography.sfProRounded(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
          );
        },
      ),
    );
  }

  void _pickStartTime(bool isDark) {
    _showCupertinoTimePicker(
      context: context,
      title: 'Başlangıç Saati',
      initialTime: _startTime,
      isDark: isDark,
      onTimeChanged: (picked) {
        setState(() {
          _startTime = picked;
          if (_hasEndTime && _endTime != null) {
            if (_endTime!.hour < _startTime.hour ||
                (_endTime!.hour == _startTime.hour && _endTime!.minute <= _startTime.minute)) {
              _endTime = TimeOfDay(
                hour: (_startTime.hour + 1).clamp(0, 23).toInt(),
                minute: _startTime.minute,
              );
            }
          }
        });
      },
    );
  }

  void _pickEndTime(bool isDark) {
    final initial = _endTime ??
        TimeOfDay(
          hour: (_startTime.hour + 1).clamp(0, 23).toInt(),
          minute: _startTime.minute,
        );

    _showCupertinoTimePicker(
      context: context,
      title: 'Bitiş Saati',
      initialTime: initial,
      isDark: isDark,
      onTimeChanged: (picked) {
        setState(() {
          _hasEndTime = true;
          _endTime = picked;
        });
      },
      onClear: () {
        setState(() {
          _hasEndTime = false;
          _endTime = null;
        });
      },
    );
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_hasEndTime && _endTime != null && !_isEndTimeAfterStartTime()) {
      AestheticSnackBar.showWarning(context, 'Bitiş saati başlangıç saatinden sonra olmalı.');
      return;
    }

    final provider = context.read<PlannerProvider>();
    final selectedDateStr = widget.event?.dateStr ??
        (_eventDate != null
            ? DateFormat('yyyy-MM-dd').format(_eventDate!)
            : null);

    final endHour = (_hasEndTime && _endTime != null) ? _endTime!.hour : 0;
    final endMinute = (_hasEndTime && _endTime != null) ? _endTime!.minute : 0;

    final newEvent = ScheduleEvent(
      id: widget.event?.id ?? const Uuid().v4(),
      title: _limitText(_titleController.text, 100),
      subtitle: _limitText(_subtitleController.text, 200),
      dayOfWeek: _selectedDayOfWeek,
      dateStr: selectedDateStr,
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      endHour: endHour,
      endMinute: endMinute,
      colorHex: AppColors.normalizeHexColor(_selectedColorHex),
      isNotificationEnabled: _isReminderEnabled,
      reminderMinutesBefore: _reminderMinutesBefore,
    );

    if (_isReminderEnabled) {
      await NotificationService().requestPermissions();
    }

    if (isEditing) {
      try {
        await provider.updateEvent(newEvent);
      } catch (e) {
        if (mounted) {
          AestheticSnackBar.showWarning(context, 'Kaydedilemedi. Lütfen tekrar deneyin.');
        }
        return; // Fix #13: hata olursa ekran kapanmasın
      }
    } else {
      try {
        await provider.addEvent(newEvent);
      } catch (e) {
        if (mounted) {
          AestheticSnackBar.showWarning(context, 'Kaydedilemedi. Lütfen tekrar deneyin.');
        }
        return;
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    if (widget.event == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF14241B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Planı Sil',
          style: AppTypography.sfProRounded(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A2B1D),
          ),
        ),
        content: Text(
          'Bu planı silmek istediğinizden emin misiniz?',
          style: AppTypography.sfPro(
            fontSize: 14.5,
            color: isDark ? AppColors.darkTextMuted : const Color(0xFF5A7B62),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Vazgeç',
              style: AppTypography.sfPro(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PlannerProvider>().deleteEvent(widget.event!.id);
              Navigator.pop(context);
            },
            child: Text(
              'Sil',
              style: AppTypography.sfPro(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isEndTimeAfterStartTime() {
    if (!_hasEndTime || _endTime == null) return true;
    final startMinutes = (_startTime.hour * 60) + _startTime.minute;
    final endMinutes = (_endTime!.hour * 60) + _endTime!.minute;
    return endMinutes > startMinutes;
  }

  String _limitText(String value, int maxLength) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final targetDate = _eventDate ?? DateTime.now();
    final dayLabel = DateTimeUtils.getFullDayName(_selectedDayOfWeek);
    final dateLabel = '${targetDate.day} ${DateTimeUtils.formatMonthYear(targetDate).split(' ').first}';

    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A2B1D);
    final mutedTextColor = isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A);
    final ctaColor = isDark ? AppColors.darkPrimary : const Color(0xFF0E260A);

    final sheetBody = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Drag Handle
        const SizedBox(height: 12),
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
                const SizedBox(height: 14),

                // 2. Başlık Çubuğu: Sol Başlık + Sağ Kapatma & Sil
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Planı Düzenle' : 'Yeni Plan',
                              style: AppTypography.sfProRounded(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$dayLabel • $dateLabel',
                              style: AppTypography.sfPro(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFA1C4AA) : const Color(0xFF386644),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isEditing) ...[
                        GestureDetector(
                          onTap: _confirmDelete,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white12 : const Color(0xFFEFF4ED),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7A6E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Kaydırılabilir Form İçeriği
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── 1. PLAN DETAYLARI (BENTO KART) ───
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A2F23).withValues(alpha: 0.65)
                                  : const Color(0xFFF4F7F2).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2E4D37).withValues(alpha: 0.6)
                                    : const Color(0xFFE2EBE0),
                                width: 1.1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _titleController,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: AppTypography.sfProRounded(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: primaryTextColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Plan adı',
                                    hintStyle: AppTypography.sfProRounded(
                                      color: mutedTextColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Lütfen bir başlık girin';
                                    }
                                    return null;
                                  },
                                ),
                                Divider(
                                  height: 1,
                                  color: isDark ? const Color(0xFF283D30) : const Color(0xFFE2EBE0),
                                ),
                                TextFormField(
                                  controller: _subtitleController,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: AppTypography.sfPro(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: primaryTextColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Açıklama veya konum (isteğe bağlı)',
                                    hintStyle: AppTypography.sfPro(
                                      color: mutedTextColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ─── 2. SAAT ARALIĞI SEÇİMİ ───
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'SAAT ARALIĞI',
                              style: AppTypography.sfPro(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: mutedTextColor,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimePickerCard(
                                  title: 'Başlangıç',
                                  time: _startTime,
                                  isDark: isDark,
                                  onTap: () => _pickStartTime(isDark),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEndTimePickerCard(
                                  isDark: isDark,
                                  hasEndTime: _hasEndTime,
                                  time: _endTime,
                                  onTap: () => _pickEndTime(isDark),
                                  onRemove: () {
                                    setState(() {
                                      _hasEndTime = false;
                                      _endTime = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // ─── 3. SOFT PASTEL RENK SEÇİCİ ───
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'RENK ETİKETİ',
                              style: AppTypography.sfPro(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: mutedTextColor,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A2F23).withValues(alpha: 0.65)
                                  : const Color(0xFFF4F7F2).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2E4D37).withValues(alpha: 0.6)
                                    : const Color(0xFFE2EBE0),
                                width: 1.1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: AestheticColorPicker(
                              selectedColorHex: _selectedColorHex,
                              onColorSelected: (hex) => setState(() => _selectedColorHex = hex),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ─── 4. HATIRLATICI ───
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A2F23).withValues(alpha: 0.65)
                                  : const Color(0xFFF4F7F2).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2E4D37).withValues(alpha: 0.6)
                                    : const Color(0xFFE2EBE0),
                                width: 1.1,
                              ),
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _isReminderEnabled = !_isReminderEnabled),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Plan Hatırlatıcısı',
                                          style: AppTypography.sfPro(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                            color: primaryTextColor,
                                          ),
                                        ),
                                        Switch.adaptive(
                                          value: _isReminderEnabled,
                                          activeTrackColor: const Color(0xFF0E260A),
                                          onChanged: (val) async {
                                            if (val) {
                                              final granted = await NotificationService().requestPermissions();
                                              if (!context.mounted) return;
                                              if (!granted) {
                                                AestheticSnackBar.showWarning(
                                                  context,
                                                  'Bildirim izni kapalı. Ayarlar > Calenda bölümünden bildirimleri açabilirsiniz.',
                                                );
                                              }
                                            }
                                            if (!mounted) return;
                                            setState(() => _isReminderEnabled = val);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_isReminderEnabled) ...[
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : AppColors.lightBorder.withValues(alpha: 0.7),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Ne kadar önce?',
                                          style: AppTypography.sfPro(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: primaryTextColor,
                                          ),
                                        ),
                                        DropdownButton<int>(
                                          value: _reminderMinutesBefore,
                                          underline: const SizedBox.shrink(),
                                          icon: Icon(
                                            Icons.arrow_drop_down_rounded,
                                            color: isDark ? const Color(0xFFB4D8C2) : const Color(0xFF0E260A),
                                          ),
                                          dropdownColor: isDark ? const Color(0xFF14241B) : const Color(0xFFF8FAF5),
                                          borderRadius: BorderRadius.circular(16),
                                          style: AppTypography.sfPro(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: primaryTextColor,
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 5, child: Text('5 dk')),
                                            DropdownMenuItem(value: 10, child: Text('10 dk')),
                                            DropdownMenuItem(value: 15, child: Text('15 dk')),
                                            DropdownMenuItem(value: 30, child: Text('30 dk')),
                                            DropdownMenuItem(value: 60, child: Text('1 saat')),
                                            DropdownMenuItem(value: 120, child: Text('2 saat')),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() => _reminderMinutesBefore = val);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ─── 5. KAYDET / GÜNCELLE BUTONU ───
                          BouncingWidget(
                            onTap: _saveEvent,
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: ctaColor,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: ctaColor.withValues(alpha: 0.30),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  isEditing ? 'Değişiklikleri Güncelle' : 'Planı Kaydet',
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
                  ),
                ),
              ],
            );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF14241B) : Colors.white)
              .withValues(alpha: isDark ? 0.94 : 0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.85),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.10),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: kIsWeb
              ? sheetBody
              : BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: sheetBody,
                ),
        ),
      ),
    );
  }

  Widget _buildTimePickerCard({
    required String title,
    required TimeOfDay time,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A2B1D);
    final mutedTextColor = isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A);

    return BouncingWidget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A2F23).withValues(alpha: 0.65)
              : const Color(0xFFF4F7F2).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2E4D37).withValues(alpha: 0.6)
                : const Color(0xFFE2EBE0),
            width: 1.1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.sfPro(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: mutedTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: primaryTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  timeStr,
                  style: AppTypography.sfProRounded(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndTimePickerCard({
    required bool isDark,
    required bool hasEndTime,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A2B1D);
    final mutedTextColor = isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A);
    final ctaColor = isDark ? const Color(0xFFB4D8C2) : const Color(0xFF0E260A);

    if (!hasEndTime || time == null) {
      return BouncingWidget(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A2F23).withValues(alpha: 0.45)
                : const Color(0xFFF4F7F2).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2E4D37).withValues(alpha: 0.4)
                  : const Color(0xFFE2EBE0),
              width: 1.1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bitiş (İsteğe Bağlı)',
                style: AppTypography.sfPro(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: mutedTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    size: 18,
                    color: ctaColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Bitiş Ekle',
                    style: AppTypography.sfProRounded(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ctaColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return BouncingWidget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A2F23).withValues(alpha: 0.65)
              : const Color(0xFFF4F7F2).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2E4D37).withValues(alpha: 0.6)
                : const Color(0xFFE2EBE0),
            width: 1.1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bitiş',
                  style: AppTypography.sfPro(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: mutedTextColor,
                  ),
                ),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: mutedTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: primaryTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  timeStr,
                  style: AppTypography.sfProRounded(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔄 Geriye dönük uyumluluk için Route sarmalayıcısı
class EditEventScreen extends StatelessWidget {
  final ScheduleEvent? event;
  final int? initialDayOfWeek;
  final DateTime? initialDate;

  const EditEventScreen({
    super.key,
    this.event,
    this.initialDayOfWeek,
    this.initialDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: EditEventSheet(
            event: event,
            initialDayOfWeek: initialDayOfWeek,
            initialDate: initialDate,
          ),
        ),
      ),
    );
  }
}
