import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/diorama_item.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../core/services/glb_room_service.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../widgets/parallax_room_canvas.dart';

/// 🪴 The Cozy Room - 3D Diorama & Eşya Yerleştirme
class CozyRoomEditorScreen extends StatefulWidget {
  const CozyRoomEditorScreen({super.key});

  @override
  State<CozyRoomEditorScreen> createState() => _CozyRoomEditorScreenState();
}

class _CozyRoomEditorScreenState extends State<CozyRoomEditorScreen> {
  late ConfettiController _confettiController;
  String? _selectedItemId;
  String? _modelDataUri;
  bool _isLoadingModel = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 900));
    _selectedItemId = DioramaItem.floor1Items.first.id;
    _refresh3DModel();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _refresh3DModel() async {
    final unlocked = AchievementService.instance.unlockedDioramaItems;
    try {
      final uri = await GlbRoomService.instance.generateFilteredGlbDataUri(
        unlockedItemIds: unlocked,
      );
      if (mounted) {
        setState(() {
          _modelDataUri = uri;
          _isLoadingModel = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingModel = false;
        });
      }
    }
  }

  Future<void> _handlePurchase(DioramaItem item) async {
    AppHaptics.mediumImpact();
    final success = await AchievementService.instance.purchaseDioramaItem(item);
    if (success) {
      AppHaptics.heavyImpact();
      _confettiController.play();
      await _refresh3DModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final isEn = lang == 'en';

    return ListenableBuilder(
      listenable: AchievementService.instance,
      builder: (context, _) {
        final service = AchievementService.instance;
        final roomState = service.roomState;
        final isFloor2 = roomState.activeFloor == 1;
        final focusXP = service.focusXP;
        final unlockedCount = service.dioramaUnlockedCount;
        final totalCount = service.dioramaTotalCount;
        final progressRatio = service.dioramaProgressRatio;

        final selectedItem = DioramaItem.floor1Items.firstWhere(
          (i) => i.id == _selectedItemId,
          orElse: () => DioramaItem.floor1Items.first,
        );
        final isSelectedUnlocked = service.isDioramaItemUnlocked(selectedItem.id);
        final canAffordSelected = focusXP >= selectedItem.requiredXP;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F1712) : const Color(0xFFFAFBF8),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              onPressed: () {
                AppHaptics.lightImpact();
                Navigator.of(context).pop();
              },
            ),
            centerTitle: true,
            title: Text(
              isEn ? 'The Cozy Room' : 'Odam',
              style: AppTypography.sfProRounded(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            actions: [
              // Sağ Üst: Toplam Odak Puanı
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF223528) : const Color(0xFFEBF3E8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF35523E) : const Color(0xFFD3E2CF),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          '$focusXP XP',
                          style: AppTypography.sfProRounded(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // ── 1. Kat Değiştirme Segmenti ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF162319) : const Color(0xFFEDF3E9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF283D2D) : const Color(0xFFD6E4D1),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // 1. Kat Butonu
                            Expanded(
                              child: BouncingWidget(
                                onTap: () {
                                  AppHaptics.selectionClick();
                                  service.setActiveRoomFloor(0);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: !isFloor2
                                        ? (isDark ? const Color(0xFF243B2A) : Colors.white)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(11),
                                    boxShadow: !isFloor2
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('🏠', style: TextStyle(fontSize: 13)),
                                        const SizedBox(width: 6),
                                        Text(
                                          isEn ? '1st Floor' : '1. Kat',
                                          style: AppTypography.sfProRounded(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: !isFloor2
                                                ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                                                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 2. Kat Butonu
                            Expanded(
                              child: BouncingWidget(
                                onTap: () {
                                  AppHaptics.selectionClick();
                                  service.setActiveRoomFloor(1);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isFloor2
                                        ? (isDark ? const Color(0xFF243B2A) : Colors.white)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(11),
                                    boxShadow: isFloor2
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(roomState.isFloor2Unlocked ? '📚' : '🔒', style: const TextStyle(fontSize: 13)),
                                        const SizedBox(width: 6),
                                        Text(
                                          isEn ? '2nd Floor Loft' : '2. Kat Loft',
                                          style: AppTypography.sfProRounded(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isFloor2
                                                ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                                                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── 2. Kat Durumu & Eşya Sayacı ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            isFloor2
                                ? (isEn ? 'Study Loft' : 'Çalışma Loftu')
                                : (isEn ? 'Cozy Bedroom' : 'Yatak Odası'),
                            style: AppTypography.sfProRounded(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$unlockedCount / $totalCount ${isEn ? 'Items' : 'Eşya'}',
                            style: AppTypography.sfPro(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // İnce İlerleme Çizgisi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 3.5,
                          backgroundColor: isDark ? const Color(0xFF1D2E22) : const Color(0xFFE4EDE1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFF8CEFA5) : const Color(0xFF3B734C),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── 3. Canlı 3D Model Görüntüleyici ──
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isDark
                                  ? [
                                      const Color(0xFF141F17),
                                      const Color(0xFF1A281E),
                                      const Color(0xFF152219),
                                    ]
                                  : [
                                      const Color(0xFFFAFBF8),
                                      const Color(0xFFF4F7F1),
                                      const Color(0xFFE9F0E6),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? const Color(0xFF283A2E) : const Color(0xFFD6E3D0),
                              width: 1.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: isFloor2
                                ? ParallaxRoomCanvas(
                                    roomState: roomState,
                                    isInteractive: false,
                                    enableParallax: true,
                                  )
                                : (_isLoadingModel || _modelDataUri == null)
                                    ? const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : ModelViewer(
                                        key: ValueKey(_modelDataUri.hashCode),
                                        src: _modelDataUri!,
                                        alt: '3D Cozy Room',
                                        ar: false,
                                        autoRotate: false,
                                        cameraControls: true,
                                        cameraOrbit: '45deg 60deg 105%',
                                        minCameraOrbit: '5deg 35deg 50%',
                                        maxCameraOrbit: '85deg 75deg 150%',
                                        backgroundColor: Colors.transparent,
                                        shadowIntensity: 0.6,
                                        shadowSoftness: 0.8,
                                        exposure: 1.05,
                                      ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── 4. Eşya Seçici (Yatay Liste) ──
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        scrollDirection: Axis.horizontal,
                        itemCount: DioramaItem.floor1Items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final item = DioramaItem.floor1Items[index];
                          final isSelected = item.id == _selectedItemId;
                          final isUnlocked = service.isDioramaItemUnlocked(item.id);

                          return BouncingWidget(
                            onTap: () {
                              AppHaptics.selectionClick();
                              setState(() {
                                _selectedItemId = item.id;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF243B2A) : Colors.white)
                                    : (isDark ? const Color(0xFF142017) : const Color(0xFFEFF4EC)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF3B734C))
                                      : (isDark ? const Color(0xFF253729) : const Color(0xFFD7E3D2)),
                                  width: isSelected ? 1.4 : 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(item.icon, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.localizedName(isEn),
                                    style: AppTypography.sfProRounded(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? (isDark ? Colors.white : const Color(0xFF102E19))
                                          : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (isUnlocked)
                                    const Text('✓', style: TextStyle(fontSize: 11, color: Color(0xFF4CAF50), fontWeight: FontWeight.bold))
                                  else
                                    Text(
                                      '${item.requiredXP}P',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFF9EBAA4) : const Color(0xFF6B8A72),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ── 5. Sade Satın Alma / Durum Paneli ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0xFF162319) : Colors.white).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? const Color(0xFF283D2D) : const Color(0xFFD9E5D4),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Eşya Simgesi ve Adı
                            Text(selectedItem.icon, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedItem.localizedName(isEn),
                                    style: AppTypography.sfProRounded(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isSelectedUnlocked
                                        ? (isEn ? 'Placed in room' : 'Odada yerleştirildi')
                                        : '${selectedItem.requiredXP} XP',
                                    style: AppTypography.sfPro(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelectedUnlocked
                                          ? const Color(0xFF4CAF50)
                                          : (canAffordSelected
                                              ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435))
                                              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // İşlem Butonu
                            if (isSelectedUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isEn ? 'Placed' : 'Yerleşti',
                                  style: AppTypography.sfProRounded(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                              )
                            else
                              BouncingWidget(
                                onTap: canAffordSelected ? () => _handlePurchase(selectedItem) : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: canAffordSelected
                                        ? (isDark ? const Color(0xFF2C6843) : const Color(0xFF102E19))
                                        : (isDark ? const Color(0xFF1F2B22) : const Color(0xFFE2EBE0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        canAffordSelected
                                            ? (isEn ? 'Place Item' : 'Odaya Yerleştir')
                                            : (isEn ? 'Locked' : 'Kilitli'),
                                        style: AppTypography.sfProRounded(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: canAffordSelected
                                              ? Colors.white
                                              : (isDark ? const Color(0xFF5A7563) : const Color(0xFF8FA896)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Kutlama Konfetisi
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 20,
                  minBlastForce: 8,
                  emissionFrequency: 0.05,
                  numberOfParticles: 25,
                  gravity: 0.25,
                  colors: const [
                    Color(0xFF8CEFA5),
                    Color(0xFFFFC8DD),
                    Color(0xFFFFDFBA),
                    Color(0xFFA2D2FF),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
