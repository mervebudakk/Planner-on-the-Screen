import 'package:flutter/material.dart';
import '../constants/app_typography.dart';
import '../localization/app_localizations.dart';
import '../utils/app_haptics.dart';

/// 🍎 Calenda Apple Tarzı Sağa/Sola Kaydırarak Düzenleme ve Silme Kutucuğu
class SwipeToDeleteTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final double borderRadius;
  final double actionWidth;

  const SwipeToDeleteTile({
    super.key,
    required this.child,
    required this.onDelete,
    this.onEdit,
    this.borderRadius = 24.0,
    this.actionWidth = 72.0,
  });

  @override
  State<SwipeToDeleteTile> createState() => _SwipeToDeleteTileState();
}

class _SwipeToDeleteTileState extends State<SwipeToDeleteTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0.0;

  double get _totalWidth => widget.onEdit != null ? (widget.actionWidth * 2) : widget.actionWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragExtent += details.primaryDelta ?? 0.0;
    if (_dragExtent > 0.0) _dragExtent = 0.0;
    if (_dragExtent < -_totalWidth) _dragExtent = -_totalWidth;

    _controller.value = (-_dragExtent) / _totalWidth;
  }

  void _handleDragEnd(DragEndDetails details) {
    final vx = details.primaryVelocity ?? 0.0;
    if (vx < -300 || _controller.value > 0.40) {
      _controller.animateTo(1.0, curve: Curves.easeOutCubic);
      _dragExtent = -_totalWidth;
      AppHaptics.lightImpact();
    } else {
      _controller.animateTo(0.0, curve: Curves.easeOutCubic);
      _dragExtent = 0.0;
    }
  }

  void _close() {
    _controller.animateTo(0.0, curve: Curves.easeOutCubic);
    _dragExtent = 0.0;
  }

  void _handleEdit() {
    AppHaptics.lightImpact();
    _close();
    widget.onEdit?.call();
  }

  void _handleDelete() {
    AppHaptics.mediumImpact();
    _close();
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final offset = -_controller.value * _totalWidth;
        final isOpen = _controller.value > 0.05;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 🔴 1. ARKADAKİ AKSİYON KUTULARI (Düzenle & Sil)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: _totalWidth,
              child: Opacity(
                opacity: _controller.value.clamp(0.0, 1.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Row(
                    children: [
                      // ✏️ Düzenleme Butonu (Mavi)
                      if (widget.onEdit != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Material(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(widget.borderRadius),
                              child: InkWell(
                                onTap: _handleEdit,
                                borderRadius: BorderRadius.circular(widget.borderRadius),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.edit,
                                        style: AppTypography.sfProRounded(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // 🗑️ Silme Butonu (Kırmızı)
                      Expanded(
                        child: Material(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          child: InkWell(
                            onTap: _handleDelete,
                            borderRadius: BorderRadius.circular(widget.borderRadius),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.delete,
                                    style: AppTypography.sfProRounded(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
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
            ),

            // 🎴 2. ÖNDEKİ KART İÇERİĞİ (Sola kayar)
            Transform.translate(
              offset: Offset(offset, 0),
              child: GestureDetector(
                onHorizontalDragUpdate: _handleDragUpdate,
                onHorizontalDragEnd: _handleDragEnd,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    widget.child,
                    if (isOpen)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _close,
                          behavior: HitTestBehavior.opaque,
                          child: const ColoredBox(color: Colors.transparent),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
