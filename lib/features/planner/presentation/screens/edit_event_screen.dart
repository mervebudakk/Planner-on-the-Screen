import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../widgets/aesthetic_color_picker.dart';

/// Ders veya Görev Ekleme/Düzenleme Ekranı
class EditEventScreen extends StatefulWidget {
  final ScheduleEvent? initialEvent;
  final int defaultDay;

  const EditEventScreen({
    super.key,
    this.initialEvent,
    required this.defaultDay,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;

  late int _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedColorHex;
  late bool _isNotificationEnabled;
  late int _reminderMinutesBefore;

  final List<int> _reminderOptions = [0, 5, 10, 15, 30, 60];

  @override
  void initState() {
    super.initState();
    final e = widget.initialEvent;

    _titleController = TextEditingController(text: e?.title ?? '');
    _subtitleController = TextEditingController(text: e?.subtitle ?? '');
    _selectedDay = e?.dayOfWeek ?? widget.defaultDay;

    _startTime = e != null
        ? TimeOfDay(hour: e.startHour, minute: e.startMinute)
        : const TimeOfDay(hour: 9, minute: 0);

    _endTime = e != null
        ? TimeOfDay(hour: e.endHour, minute: e.endMinute)
        : const TimeOfDay(hour: 10, minute: 30);

    _selectedColorHex = e?.colorHex ?? '#60A5FA';
    _isNotificationEnabled = e?.isNotificationEnabled ?? true;
    _reminderMinutesBefore = e?.reminderMinutesBefore ?? 15;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final initialTime = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentLight,
              surface: AppColors.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ders veya etkinlik adını girin'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final event = ScheduleEvent(
      id: widget.initialEvent?.id ?? const Uuid().v4(),
      title: title,
      subtitle: _subtitleController.text.trim(),
      dayOfWeek: _selectedDay,
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      endHour: _endTime.hour,
      endMinute: _endTime.minute,
      colorHex: _selectedColorHex,
      isNotificationEnabled: _isNotificationEnabled,
      reminderMinutesBefore: _reminderMinutesBefore,
    );

    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialEvent != null;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Dersi Düzenle' : 'Yeni Plan Ekle',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _save,
              child: Text(
                'Kaydet',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentLight,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Girişi
            Text(
              'Başlık',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Örn: Business class, Antrenman',
                hintStyle: GoogleFonts.inter(color: Colors.white38),
                filled: true,
                fillColor: AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 18),

            // Alt Başlık / Not Girişi
            Text(
              'Alt Başlık / Not (Opsiyonel)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _subtitleController,
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Örn: Sunum yapılacak, Salon 302',
                hintStyle: GoogleFonts.inter(color: Colors.white38),
                filled: true,
                fillColor: AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 22),

            // Gün Seçimi (Pzt - Paz)
            Text(
              'Hangi Gün?',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final isSelected = day == _selectedDay;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(DateTimeUtils.getShortDayName(day, isTurkish: true)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedDay = day);
                      },
                      selectedColor: AppColors.accent,
                      backgroundColor: AppColors.darkSurface,
                      labelStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.accentLight
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 22),

            // Saat Seçimi (Başlangıç ve Bitiş)
            Text(
              'Saat Aralığı',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTimePickerTile(
                    label: 'Başlangıç',
                    time: _startTime,
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePickerTile(
                    label: 'Bitiş',
                    time: _endTime,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Renk Seçimi
            Text(
              'Aesthetic Renk',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            AestheticColorPicker(
              selectedColorHex: _selectedColorHex,
              onColorChanged: (hex) => setState(() => _selectedColorHex = hex),
            ),

            const SizedBox(height: 28),

            // Akıllı Bildirim & Hatırlatıcı Bölümü (Kullanıcı İsteğine Özel)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isNotificationEnabled
                      ? AppColors.accent.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            size: 22,
                            color: _isNotificationEnabled
                                ? AppColors.accentLight
                                : Colors.white54,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ders Hatırlatıcısı',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Ders vakti yaklaşınca bildirim al',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isNotificationEnabled,
                        activeTrackColor: AppColors.accentLight,
                        onChanged: (val) =>
                            setState(() => _isNotificationEnabled = val),
                      ),
                    ],
                  ),

                  if (_isNotificationEnabled) ...[
                    const Divider(height: 24, color: AppColors.darkBorder),
                    Text(
                      'Ne kadar süre önce bildirilsin?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _reminderOptions.map((minutes) {
                        final isSelected = _reminderMinutesBefore == minutes;
                        final label = minutes == 0
                            ? 'Tam saatinde'
                            : '$minutes dk önce';

                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _reminderMinutesBefore = minutes);
                            }
                          },
                          selectedColor: AppColors.accent,
                          backgroundColor: AppColors.darkCard,
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatted,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Icon(Icons.schedule, size: 18, color: Colors.white38),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
