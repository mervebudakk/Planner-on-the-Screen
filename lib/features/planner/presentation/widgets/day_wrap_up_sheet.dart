import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/schedule_event.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/aesthetic_snackbar.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../providers/planner_provider.dart';

/// 🌙 Günü Toparla (Day Wrap-Up) Alt Çekmecesi
/// Tamamlanmamış planları kullanıcı onayına sunarak ertesi güne birebir kopyalar.
class DayWrapUpSheet extends StatefulWidget {
  final List<ScheduleEvent> uncompletedEvents;
  final DateTime targetDate;
  final VoidCallback? onTransferred;

  const DayWrapUpSheet({
    super.key,
    required this.uncompletedEvents,
    required this.targetDate,
    this.onTransferred,
  });

  static Future<void> show(
    BuildContext context, {
    required List<ScheduleEvent> uncompletedEvents,
    required DateTime targetDate,
    VoidCallback? onTransferred,
  }) {
    AppHaptics.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DayWrapUpSheet(
        uncompletedEvents: uncompletedEvents,
        targetDate: targetDate,
        onTransferred: onTransferred,
      ),
    );
  }

  @override
  State<DayWrapUpSheet> createState() => _DayWrapUpSheetState();
}

class _DayWrapUpSheetState extends State<DayWrapUpSheet> {
  late Set<String> _selectedIds;
  bool _isTransferring = false;

  @override
  void initState() {
    super.initState();
    // Varsayılan olarak tüm tamamlanmamış planlar seçili gelir
    _selectedIds = widget.uncompletedEvents.map((e) => e.id).toSet();
  }

  void _toggleSelection(String id) {
    AppHaptics.selectionClick();
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleAll() {
    AppHaptics.selectionClick();
    setState(() {
      if (_selectedIds.length == widget.uncompletedEvents.length) {
        _selectedIds.clear();
      } else {
        _selectedIds = widget.uncompletedEvents.map((e) => e.id).toSet();
      }
    });
  }

  Future<void> _handleTransfer() async {
    if (_selectedIds.isEmpty || _isTransferring) return;

    setState(() => _isTransferring = true);
    AppHaptics.mediumImpact();

    final eventsToTransfer = widget.uncompletedEvents
        .where((e) => _selectedIds.contains(e.id))
        .toList();

    try {
      final provider = context.read<PlannerProvider>();
      final count = await provider.copyEventsToDate(
        eventsToTransfer,
        widget.targetDate,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onTransferred?.call();

      AestheticSnackBar.showSuccess(
        context,
        context.l10n.plansTransferredSuccess(count),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _isTransferring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final targetDayName = DateTimeUtils.getFullDayName(
      widget.targetDate.weekday,
      locale: l10n.locale.languageCode,
    );

    final bgColor = isDark ? const Color(0xFF14241B) : Colors.white;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedText = isDark ? AppColors.darkTextMuted : const Color(0xFF6E8272);
    final borderColor = isDark ? const Color(0xFF24402D) : const Color(0xFFE4EDE2);
    final ctaBg = isDark ? const Color(0xFF265433) : const Color(0xFF1E3A24);

    final allSelected = _selectedIds.length == widget.uncompletedEvents.length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. ÜST TUTAMAÇ ÇİZGİSİ (HANDLE) ──
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFD6DFD3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── 2. BAŞLIK, AÇIKLAMA VE KAPAT BUTONU ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3827) : const Color(0xFFE8F2E6),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2F543B) : const Color(0xFFD3E4D0),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF235431),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dayWrapUp,
                          style: AppTypography.sfProRounded(
                            fontSize: 19.0,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.dayWrapUpSubtitle,
                          style: AppTypography.sfPro(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BouncingWidget(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B2E21) : const Color(0xFFF0F4ED),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          color: mutedText,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── 3. SEÇİM KONTROL BARI ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedIds.length} / ${widget.uncompletedEvents.length} seçildi',
                    style: AppTypography.sfPro(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: mutedText,
                    ),
                  ),
                  if (widget.uncompletedEvents.length > 1)
                    BouncingWidget(
                      onTap: _toggleAll,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          allSelected ? l10n.deselectAll : l10n.selectAll,
                          style: AppTypography.sfProRounded(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF2E633C),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // ── 4. AKTARILACAK PLANLAR LİSTESİ ──
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.uncompletedEvents.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final event = widget.uncompletedEvents[index];
                    final isSelected = _selectedIds.contains(event.id);
                    final eventColor = AppColors.hexToColor(event.colorHex);

                    final itemBg = isSelected
                        ? (isDark
                            ? Color.alphaBlend(eventColor.withValues(alpha: 0.16), const Color(0xFF1B2E21))
                            : Color.alphaBlend(eventColor.withValues(alpha: 0.14), const Color(0xFFF6FAF3)))
                        : (isDark ? const Color(0xFF18261D) : const Color(0xFFF9FAF7));

                    final itemBorder = isSelected
                        ? (isDark
                            ? eventColor.withValues(alpha: 0.50)
                            : eventColor.withValues(alpha: 0.70))
                        : (isDark ? const Color(0xFF233829) : const Color(0xFFE5EDE1));

                    return BouncingWidget(
                      onTap: () => _toggleSelection(event.id),
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: itemBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: itemBorder, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            // Onay Yuvarlağı (Checkbox)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF2E633C))
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isDark ? Colors.white38 : const Color(0xFFA1B3A0)),
                                  width: 1.6,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: isDark ? const Color(0xFF0F2613) : Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Dikey Renk İzi
                            Container(
                              width: 3.5,
                              height: 24,
                              decoration: BoxDecoration(
                                color: eventColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Başlık & Alt Başlık
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    event.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.sfProRounded(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: primaryText,
                                    ),
                                  ),
                                  if (event.subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      event.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.sfPro(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        color: mutedText,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Saat Bilgisi (Yalnızca saatli olanlarda)
                            if (event.hasSpecificTime) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.25)
                                      : Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  event.formattedTimeRange,
                                  style: AppTypography.sfPro(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w600,
                                    color: mutedText,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ── 5. BİLGİLENDİRME METNİ (ZARİF & SADE) ──
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: mutedText.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.tomorrowSameTimeHint(targetDayName),
                      style: AppTypography.sfPro(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: mutedText.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── 6. ANA AKSİYON BUTONU: SEÇİLENLERİ YARINA AKTAR ──
              BouncingWidget(
                onTap: _selectedIds.isNotEmpty && !_isTransferring
                    ? _handleTransfer
                    : null,
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _selectedIds.isNotEmpty
                        ? ctaBg
                        : (isDark ? const Color(0xFF1D2E22) : const Color(0xFFE2EBE0)),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: _selectedIds.isNotEmpty
                        ? [
                            BoxShadow(
                              color: (isDark ? Colors.black : const Color(0xFF142814))
                                  .withValues(alpha: isDark ? 0.35 : 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: _isTransferring
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _selectedIds.isEmpty
                                ? l10n.transferToTomorrow
                                : l10n.transferToTomorrowCount(_selectedIds.length),
                            style: AppTypography.sfProRounded(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: _selectedIds.isNotEmpty
                                  ? Colors.white
                                  : (isDark ? Colors.white38 : const Color(0xFF90A391)),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
