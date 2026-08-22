import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../providers/planner_provider.dart';
import '../widgets/aesthetic_color_picker.dart';

/// 🍎 Apple iOS SF Pro Standartlarında Plan Ekleme/Düzenleme Ekranı
class EditEventScreen extends StatefulWidget {
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
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late int _selectedDayOfWeek;
  late DateTime? _eventDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedColorHex;
  late bool _isReminderEnabled;
  late int _reminderMinutesBefore;

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
    _endTime = event != null
        ? TimeOfDay(hour: event.endHour, minute: event.endMinute)
        : const TimeOfDay(hour: 10, minute: 30);
    _selectedColorHex = event?.colorHex ?? AppColors.defaultEventColorHex;
    _isReminderEnabled = event?.isNotificationEnabled ?? true;
    _reminderMinutesBefore = event?.reminderMinutesBefore ?? 15;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _showCupertinoTimePicker({
    required BuildContext context,
    required String title,
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onTimeChanged,
    required bool isDark,
  }) {
    int tempHour = initialTime.hour;
    int tempMinute = initialTime.minute;

    final cardBgColor = isDark ? const Color(0xFF14241B) : const Color(0xFFF8FAF5);
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A2B1D);
    final mutedTextColor = isDark ? AppColors.darkTextMuted : const Color(0xFF8B948A);
    const ctaColor = Color(0xFF0E260A);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: cardBgColor.withValues(alpha: 0.98),
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
                            fontSize: 15,
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
                      BouncingWidget(
                        onTap: () {
                          onTimeChanged(TimeOfDay(hour: tempHour, minute: tempMinute));
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: ctaColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Bitti',
                            style: AppTypography.sfPro(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ⏰ Apple HIG Zaman Çarkları (Wheel Picker)
                  SizedBox(
                    height: 210,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ortadaki Şık Seçim Kapsülü
                        Container(
                          height: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3526)
                                : const Color(0xFFE8F1E4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2E4D37)
                                  : const Color(0xFFD0E1CD),
                              width: 1.2,
                            ),
                          ),
                        ),

                        // Saat ve Dakika Çarkları
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Saat Çarkı (00 - 23)
                            _buildTimeWheel(
                              itemCount: 24,
                              initialItem: tempHour,
                              primaryTextColor: primaryTextColor,
                              onSelectedItemChanged: (val) => tempHour = val,
                            ),

                            // İki Nokta ":"
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

                            // Dakika Çarkı (00 - 59)
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
            ),
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
  }) {
    return SizedBox(
      width: 72,
      height: 200,
      child: CupertinoPicker.builder(
        scrollController: FixedExtentScrollController(initialItem: initialItem),
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
          if (_endTime.hour < _startTime.hour ||
              (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1).clamp(0, 23).toInt(),
              minute: _startTime.minute,
            );
          }
        });
      },
    );
  }

  void _pickEndTime(bool isDark) {
    _showCupertinoTimePicker(
      context: context,
      title: 'Bitiş Saati',
      initialTime: _endTime,
      isDark: isDark,
      onTimeChanged: (picked) {
        setState(() => _endTime = picked);
      },
    );
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEndTimeAfterStartTime()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bitiş saati başlangıç saatinden sonra olmalı.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final provider = context.read<PlannerProvider>();
    final selectedDateStr = widget.event?.dateStr ??
        (_eventDate != null
            ? DateFormat('yyyy-MM-dd').format(_eventDate!)
            : null);

    final newEvent = ScheduleEvent(
      id: widget.event?.id ?? const Uuid().v4(),
      title: _limitText(_titleController.text, 100),
      subtitle: _limitText(_subtitleController.text, 200),
      dayOfWeek: _selectedDayOfWeek,
      dateStr: selectedDateStr,
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      endHour: _endTime.hour,
      endMinute: _endTime.minute,
      colorHex: AppColors.normalizeHexColor(_selectedColorHex),
      isNotificationEnabled: _isReminderEnabled,
      reminderMinutesBefore: _reminderMinutesBefore,
    );

    if (isEditing) {
      await provider.updateEvent(newEvent);
    } else {
      await provider.addEvent(newEvent);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  bool _isEndTimeAfterStartTime() {
    final startMinutes = (_startTime.hour * 60) + _startTime.minute;
    final endMinutes = (_endTime.hour * 60) + _endTime.minute;
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Planı Düzenle' : 'Yeni Plan',
              style: AppTypography.sfProRounded(
                fontSize: 19.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '$dayLabel • $dateLabel',
              style: AppTypography.sfPro(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFA1C4AA) : const Color(0xFF386644),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: BouncingWidget(
              onTap: _saveEvent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8.5),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  isEditing ? 'Güncelle' : 'Kaydet',
                  style: AppTypography.sfPro(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: AppleAmbientBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              physics: const BouncingScrollPhysics(),
              children: [
                // ─── 1. PLAN DETAYLARI (BENTO CARD) ───
                GlassContainer(
                  blur: 16,
                  opacity: isDark ? 0.40 : 0.75,
                  borderRadius: BorderRadius.circular(28),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: AppTypography.sfProRounded(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Plan adı',
                          hintStyle: AppTypography.sfProRounded(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontSize: 18.5,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                        style: AppTypography.sfPro(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Açıklama veya konum (isteğe bağlı)',
                          hintStyle: AppTypography.sfPro(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ─── 2. SAAT ARALIĞI SEÇİMİ ───
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    'SAAT ARALIĞI',
                    style: AppTypography.sfPro(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
                      child: _buildTimePickerCard(
                        title: 'Bitiş',
                        time: _endTime,
                        isDark: isDark,
                        onTap: () => _pickEndTime(isDark),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ─── 3. SOFT PASTEL RENK SEÇİCİ ───
                GlassContainer(
                  blur: 16,
                  opacity: isDark ? 0.40 : 0.75,
                  borderRadius: BorderRadius.circular(28),
                  padding: const EdgeInsets.all(18),
                  child: AestheticColorPicker(
                    selectedColorHex: _selectedColorHex,
                    onColorSelected: (hex) => setState(() => _selectedColorHex = hex),
                  ),
                ),

                const SizedBox(height: 18),

                // ─── 4. HATIRLATICI ───
                GlassContainer(
                  blur: 16,
                  opacity: isDark ? 0.40 : 0.75,
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Plan Hatırlatıcısı',
                          style: AppTypography.sfPro(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        value: _isReminderEnabled,
                        activeTrackColor: const Color(0xFF0E260A),
                        onChanged: (val) => setState(() => _isReminderEnabled = val),
                      ),
                      if (_isReminderEnabled) ...[
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.lightBorder.withValues(alpha: 0.7),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ne kadar önce?',
                                style: AppTypography.sfPro(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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

                const SizedBox(height: 32),
              ],
            ),
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

    return GlassContainer(
      blur: 16,
      opacity: isDark ? 0.40 : 0.75,
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.sfPro(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 19,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  timeStr,
                  style: AppTypography.sfProRounded(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
