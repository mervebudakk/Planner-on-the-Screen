import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../providers/planner_provider.dart';
import '../widgets/aesthetic_color_picker.dart';

/// Apple iOS Tarzı Buzlu Cam (Frosted Glass) ve Cupertino Tekerlekli Saat Seçicili Sade Plan Ekleme / Düzenleme Ekranı
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
    _selectedColorHex = event?.colorHex ?? '#DAEAF6';
    _isReminderEnabled = event?.isNotificationEnabled ?? true;
    _reminderMinutesBefore = event?.reminderMinutesBefore ?? 15;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  /// 🍏 Apple iOS Cupertino Tekerlekli (Wheel Spinner) Saat Seçici
  void _showCupertinoTimePicker({
    required BuildContext context,
    required String title,
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onTimeChanged,
    required bool isDark,
  }) {
    TimeOfDay tempTime = initialTime;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Üst bar tutamacı
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Başlık & Butonlar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Vazgeç',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          onTimeChanged(tempTime);
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Bitti',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 🍏 Apple Cupertino Wheel Picker
                  SizedBox(
                    height: 200,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: isDark ? Brightness.dark : Brightness.light,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        initialDateTime: DateTime(2026, 1, 1, initialTime.hour, initialTime.minute),
                        onDateTimeChanged: (DateTime newDateTime) {
                          tempTime = TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
                        },
                      ),
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

  void _saveEvent() {
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
      provider.updateEvent(newEvent);
    } else {
      provider.addEvent(newEvent);
    }

    Navigator.pop(context);
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
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Planı Düzenle' : 'Yeni Plan Ekle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '$dayLabel • $dateLabel',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isEditing ? 'Güncelle' : 'Kaydet',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              children: [
                // ─── 1. PLAN DETAYLARI (BAŞLIK & AÇIKLAMA) ───
                GlassContainer(
                  blur: 16,
                  opacity: isDark ? 0.40 : 0.70,
                  borderRadius: BorderRadius.circular(22),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Plan adı',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightBorder.withValues(alpha: 0.7),
                      ),
                      TextFormField(
                        controller: _subtitleController,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Açıklama veya konum (isteğe bağlı)',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── 2. SAAT ARALIĞI SEÇİMİ (APPLE CUPERTINO WHEEL) ───
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    'SAAT ARALIĞI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      letterSpacing: 0.5,
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

                const SizedBox(height: 20),

                // ─── 3. SOFT PASTEL RENK SEÇİCİ (+ Özel Renk) ───
                GlassContainer(
                  blur: 16,
                  opacity: isDark ? 0.40 : 0.70,
                  borderRadius: BorderRadius.circular(22),
                  padding: const EdgeInsets.all(16),
                  child: AestheticColorPicker(
                    selectedColorHex: _selectedColorHex,
                    onColorSelected: (hex) => setState(() => _selectedColorHex = hex),
                  ),
                ),

                const SizedBox(height: 20),

                // ─── 4. BİLDİRİM VE HATIRLATICI AYARLARI ───
                GlassContainer(
                  blur: 16,
                  opacity: isDark ? 0.40 : 0.70,
                  borderRadius: BorderRadius.circular(22),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Ders Hatırlatıcısı',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Ders başlamadan önce bildirim al',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        value: _isReminderEnabled,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isReminderEnabled = val),
                      ),
                      if (_isReminderEnabled) ...[
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightBorder.withValues(alpha: 0.7),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kaç dakika önce?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              DropdownButton<int>(
                                value: _reminderMinutesBefore,
                                underline: const SizedBox.shrink(),
                                dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                                items: const [
                                  DropdownMenuItem(value: 5, child: Text('5 dakika')),
                                  DropdownMenuItem(value: 10, child: Text('10 dakika')),
                                  DropdownMenuItem(value: 15, child: Text('15 dakika')),
                                  DropdownMenuItem(value: 30, child: Text('30 dakika')),
                                  DropdownMenuItem(value: 60, child: Text('1 saat')),
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
    final hourStr = time.hour.toString().padLeft(2, '0');
    final minuteStr = time.minute.toString().padLeft(2, '0');

    return GlassContainer(
      blur: 16,
      opacity: isDark ? 0.40 : 0.70,
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '$hourStr:$minuteStr',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
