import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/apple_ambient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../providers/planner_provider.dart';
import '../widgets/aesthetic_color_picker.dart';

/// Apple iOS Tarzı Buzlu Cam (Frosted Glass) Plan Ekleme / Düzenleme Ekranı
class EditEventScreen extends StatefulWidget {
  final ScheduleEvent? event;
  final int? initialDayOfWeek;

  const EditEventScreen({
    super.key,
    this.event,
    this.initialDayOfWeek,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late int _selectedDayOfWeek;
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

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
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
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEndTimeAfterStartTime()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bitiş saati başlangıç saatinden sonra olmalı.'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final provider = context.read<PlannerProvider>();
    final newEvent = ScheduleEvent(
      id: widget.event?.id ?? const Uuid().v4(),
      title: _limitText(_titleController.text, 100),
      subtitle: _limitText(_subtitleController.text, 200),
      dayOfWeek: _selectedDayOfWeek,
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'Planı Düzenle' : 'Yeni Plan Ekle',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveEvent,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AppleAmbientBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // ─── 1. DERS / PLAN ADI GİRİŞİ (BUZLU CAM KART) ───
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Plan adı',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
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
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Açıklama veya konum (isteğe bağlı)',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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

                const SizedBox(height: 20),

                // ─── 2. GÜN SEÇİMİ ───
                Text(
                  'Gün Seçimi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  blur: 16,
                  opacity: isDark ? 0.40 : 0.70,
                  borderRadius: BorderRadius.circular(22),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final isSelected = _selectedDayOfWeek == day;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            onTap: () => setState(() => _selectedDayOfWeek = day),
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  DateTimeUtils.getShortDayName(day),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                // ─── 3. SAAT ARALIĞI SEÇİMİ ───
                Text(
                  'Saat Aralığı',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                        onTap: _pickStartTime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimePickerCard(
                        title: 'Bitiş',
                        time: _endTime,
                        isDark: isDark,
                        onTap: _pickEndTime,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ─── 4. SOFT PASTEL RENK SEÇİCİ (+ Özel Renk) ───
                GlassContainer(
                  blur: 16,
                  opacity: isDark ? 0.40 : 0.70,
                  borderRadius: BorderRadius.circular(22),
                  padding: const EdgeInsets.all(16),
                  child: AestheticColorPicker(
                    selectedColorHex: _selectedColorHex,
                    onColorSelected: (hex) {
                      setState(() => _selectedColorHex = hex);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ─── 5. BİLDİRİM & HATIRLATICI ───
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
              fontSize: 13,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
