import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/room_furniture.dart';
import '../../../../core/models/room_state.dart';
import '../../../../core/utils/app_haptics.dart';

/// 🎨 Parallax & Canlı Mikro-Animasyonlu 2.5D İzometrik Oda Tuvali
/// Hem profil ekranındaki önizlemede hem de Odam editöründe kullanılır.
class ParallaxRoomCanvas extends StatefulWidget {
  final RoomState roomState;
  final bool isInteractive;
  final RoomCategory? selectedCategory;
  final ValueChanged<RoomCategory>? onSelectCategory;
  final bool enableParallax;
  final VoidCallback? onFloorToggle;

  const ParallaxRoomCanvas({
    super.key,
    required this.roomState,
    this.isInteractive = false,
    this.selectedCategory,
    this.onSelectCategory,
    this.enableParallax = true,
    this.onFloorToggle,
  });

  @override
  State<ParallaxRoomCanvas> createState() => _ParallaxRoomCanvasState();
}

class _ParallaxRoomCanvasState extends State<ParallaxRoomCanvas>
    with TickerProviderStateMixin {
  // Parallax Tilt Durumu
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  late AnimationController _springController;
  Animation<double>? _springAnimX;
  Animation<double>? _springAnimY;

  // Güneş Işığı Nefes Alma Mikro-Animasyonu
  late AnimationController _sunlightController;
  late Animation<double> _sunlightPulse;

  @override
  void initState() {
    super.initState();

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addListener(() {
        if (_springAnimX != null && _springAnimY != null) {
          setState(() {
            _tiltX = _springAnimX!.value;
            _tiltY = _springAnimY!.value;
          });
        }
      });

    _sunlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _sunlightPulse = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _sunlightController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    _sunlightController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (!widget.enableParallax) return;
    _springController.stop();

    setState(() {
      // Normalleştirilmiş -1.0 .. 1.0 aralığı
      _tiltX = (_tiltX + details.delta.dx / (size.width * 0.45)).clamp(-1.0, 1.0);
      _tiltY = (_tiltY - details.delta.dy / (size.height * 0.45)).clamp(-1.0, 1.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enableParallax) return;

    _springAnimX = Tween<double>(begin: _tiltX, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
    );
    _springAnimY = Tween<double>(begin: _tiltY, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
    );

    _springController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = widget.roomState.themeColor;
    final isFloor2 = widget.roomState.activeFloor == 1;

    return AspectRatio(
      aspectRatio: 800 / 600,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          Widget content = Stack(
            fit: StackFit.expand,
            children: [
              if (!isFloor2) ...[
                // ── 1. KAT: COZY ROOM (Zemin & Katmanlar) ──
                _buildBaseLayer(isDark),
                _buildWindowLayer(),
                _buildWallArtLayer(),
                _buildRugLayer(theme),
                _buildBedLayer(theme),
                _buildDeskLayer(theme),
                _buildDecorLayer(theme),

                // 2. Kat Geçiş Merdiveni & Ahşap Kiriş İllüzyonu (Mimari Bütünlük)
                _buildLoftStairwayAccent(isDark),

                // İnteraktif Hotspot Dokunma Alanları (Sadece editör modunda)
                if (widget.isInteractive) _buildHotspots(size, isDark),
              ] else ...[
                // ── 2. KAT: ÇALIŞMA LOFTU (Kilitli & Hazır Mimari) ──
                _buildFloor2View(isDark),
              ],
            ],
          );

          // 3D Perspektif Matrisi (Parallax Tilt)
          if (widget.enableParallax) {
            content = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) => _onPanUpdate(d, size),
              onPanEnd: _onPanEnd,
              child: Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0008)
                  ..rotateX(_tiltY * 0.05)
                  ..rotateY(_tiltX * 0.05),
                child: content,
              ),
            );
          }

          return content;
        },
      ),
    );
  }

  // ── Katman Oluşturucular (Depth Offset ile Parallax) ──

  Widget _buildBaseLayer(bool isDark) {
    return Image.asset(
      'assets/images/room/room_base.png',
      fit: BoxFit.contain,
    );
  }

  Widget _buildWindowLayer() {
    return AnimatedBuilder(
      animation: _sunlightPulse,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_tiltX * 2.2, -_tiltY * 1.8),
          child: Opacity(
            opacity: _sunlightPulse.value,
            child: child,
          ),
        );
      },
      child: Image.asset(
        'assets/images/room/window_lv1.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildWallArtLayer() {
    return Transform.translate(
      offset: Offset(_tiltX * 2.8, -_tiltY * 2.2),
      child: Image.asset(
        'assets/images/room/wall_decor_lv1.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildRugLayer(String theme) {
    return Transform.translate(
      offset: Offset(_tiltX * 4.0, -_tiltY * 3.2),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Image.asset(
          'assets/images/room/rug_lv1_$theme.png',
          key: ValueKey('rug_$theme'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildBedLayer(String theme) {
    final isSelected = widget.selectedCategory == RoomCategory.bed;
    return Transform.translate(
      offset: Offset(_tiltX * 5.5, -_tiltY * 4.4),
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Image.asset(
            'assets/images/room/bed_lv1_$theme.png',
            key: ValueKey('bed_$theme'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildDeskLayer(String theme) {
    final isSelected = widget.selectedCategory == RoomCategory.desk;
    return Transform.translate(
      offset: Offset(_tiltX * 5.8, -_tiltY * 4.6),
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Image.asset(
            'assets/images/room/desk_lv1_$theme.png',
            key: ValueKey('desk_$theme'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildDecorLayer(String theme) {
    final isSelected = widget.selectedCategory == RoomCategory.decor;
    return Transform.translate(
      offset: Offset(_tiltX * 7.2, -_tiltY * 5.8),
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Image.asset(
            'assets/images/room/decor_lv1_$theme.png',
            key: ValueKey('decor_$theme'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  /// Mimari Dokunuş: 2. Kata çıkan zarif ahşap tavan kirişi & merdiven illüzyonu
  Widget _buildLoftStairwayAccent(bool isDark) {
    return Positioned(
      top: 10,
      right: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF14241B) : Colors.white).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (isDark ? const Color(0xFF2C4434) : const Color(0xFFD3E2CE)).withValues(alpha: 0.9),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stairs_rounded,
              size: 13,
              color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
            ),
            const SizedBox(width: 4),
            Text(
              '1. Kat',
              style: AppTypography.sfProRounded(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFF8CEFA5) : const Color(0xFF285435),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. Kat Görünümü (Kilitli Mimari Loft Önizlemesi)
  Widget _buildFloor2View(bool isDark) {
    final nextTier = widget.roomState.nextTier;
    final xp = widget.roomState.xp;
    final targetXp = nextTier?.xpRequired ?? 300;
    final progress = (xp / targetXp).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF16231A),
                  const Color(0xFF101B14),
                  const Color(0xFF0D1610),
                ]
              : [
                  const Color(0xFFF7FAF4),
                  const Color(0xFFEEF5EA),
                  const Color(0xFFE2EFE0),
                ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Mimari Taslak Izgara Deseni (Blueprint Grid)
          CustomPaint(
            painter: _ArchitecturalGridPainter(
              color: (isDark ? const Color(0xFF2B4232) : const Color(0xFFCDDEC8))
                  .withValues(alpha: 0.35),
            ),
          ),

          // Merkez Kilitli Bilgi Kartı
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF18281E) : Colors.white).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? const Color(0xFF38553F) : const Color(0xFFCADBC5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC98A3C).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC98A3C).withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        color: Color(0xFFC98A3C),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '2. Kat · Çalışma & Kitap Loftu',
                    style: AppTypography.sfProRounded(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seviye 2\'ye (300 XP) ulaştığında açılır',
                    textAlign: TextAlign.center,
                    style: AppTypography.sfPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC98A3C)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$xp / $targetXp XP (%${(progress * 100).toInt()})',
                    style: AppTypography.sfProRounded(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC98A3C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── İnteraktif Hotspot Alanları ──
  Widget _buildHotspots(Size size, bool isDark) {
    final w = size.width;
    final h = size.height;

    return Stack(
      children: [
        // 1. Yatak (Sol-Orta)
        Positioned(
          left: w * 0.18,
          top: h * 0.46,
          width: w * 0.36,
          height: h * 0.32,
          child: _buildHotspotButton(
            category: RoomCategory.bed,
            label: 'Yatak',
            isDark: isDark,
          ),
        ),

        // 2. Çalışma Masası (Sağ-Orta)
        Positioned(
          left: w * 0.56,
          top: h * 0.44,
          width: w * 0.36,
          height: h * 0.34,
          child: _buildHotspotButton(
            category: RoomCategory.desk,
            label: 'Masa',
            isDark: isDark,
          ),
        ),

        // 3. Halı (Orta Zemin)
        Positioned(
          left: w * 0.38,
          top: h * 0.62,
          width: w * 0.24,
          height: h * 0.20,
          child: _buildHotspotButton(
            category: RoomCategory.rug,
            label: 'Halı',
            isDark: isDark,
          ),
        ),

        // 4. Pencere (Sol Duvar Üst)
        Positioned(
          left: w * 0.20,
          top: h * 0.18,
          width: w * 0.24,
          height: h * 0.28,
          child: _buildHotspotButton(
            category: RoomCategory.window,
            label: 'Pencere',
            isDark: isDark,
          ),
        ),

        // 5. Masa Dekoru (Masa Üstü)
        Positioned(
          left: w * 0.62,
          top: h * 0.42,
          width: w * 0.16,
          height: h * 0.14,
          child: _buildHotspotButton(
            category: RoomCategory.decor,
            label: 'Dekor',
            isDark: isDark,
          ),
        ),

        // 6. Duvar Tablosu (Sağ Duvar Üst)
        Positioned(
          left: w * 0.68,
          top: h * 0.20,
          width: w * 0.18,
          height: h * 0.24,
          child: _buildHotspotButton(
            category: RoomCategory.wallDecor,
            label: 'Tablo',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildHotspotButton({
    required RoomCategory category,
    required String label,
    required bool isDark,
  }) {
    final isSelected = widget.selectedCategory == category;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppHaptics.selectionClick();
        widget.onSelectCategory?.call(category);
      },
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF8CEFA5) : const Color(0xFF102E19))
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : const Color(0xFFB0C4A8).withValues(alpha: 0.85),
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.25 : 0.08),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category.iconEmoji,
                style: const TextStyle(fontSize: 11),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.sfProRounded(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? (isDark ? const Color(0xFF102E19) : Colors.white)
                      : const Color(0xFF102E19),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mimari Taslak Grid Çizicisi
class _ArchitecturalGridPainter extends CustomPainter {
  final Color color;

  const _ArchitecturalGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArchitecturalGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
