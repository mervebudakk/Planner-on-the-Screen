import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../localization/app_localizations.dart';
import '../utils/app_haptics.dart';

/// 🍎 Calenda Apple Tarzı İki Yönlü Kaydırma Kutucuğu:
/// - Sağa Kaydırınca (Soldan Sağa): 🗓️ Yarına Aktar
/// - Sola Kaydırınca (Sağdan Sola): ✏️ Düzenle & 🗑️ Sil
class SwipeToDeleteTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDefer;
  final double borderRadius;
  final double actionWidth;
  final Color? deleteColor;
  final Color? editColor;
  final Color? deferColor;

  const SwipeToDeleteTile({
    super.key,
    required this.child,
    required this.onDelete,
    this.onEdit,
    this.onDefer,
    this.borderRadius = 24.0,
    this.actionWidth = 76.0,
    this.deleteColor,
    this.editColor,
    this.deferColor,
  });

  @override
  State<SwipeToDeleteTile> createState() => _SwipeToDeleteTileState();
}

class _SwipeToDeleteTileState extends State<SwipeToDeleteTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _animation;
  double _dragExtent = 0.0;

  double get _rightWidth =>
      widget.onEdit != null ? (widget.actionWidth * 2) : widget.actionWidth;
  double get _leftWidth => widget.onDefer != null ? widget.actionWidth : 0.0;

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
    if (_controller.isAnimating) return;

    final delta = details.primaryDelta ?? 0.0;
    final minExtent = -_rightWidth;
    final maxExtent = _leftWidth;

    setState(() {
      _dragExtent = (_dragExtent + delta).clamp(minExtent, maxExtent);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final vx = details.primaryVelocity ?? 0.0;

    if (_dragExtent > 0) {
      if (_leftWidth > 0 && (vx > 250 || _dragExtent > _leftWidth * 0.40)) {
        _animateTo(_leftWidth);
        AppHaptics.lightImpact();
      } else {
        _animateTo(0.0);
      }
    } else if (_dragExtent < 0) {
      if (vx < -250 || _dragExtent < -_rightWidth * 0.40) {
        _animateTo(-_rightWidth);
        AppHaptics.lightImpact();
      } else {
        _animateTo(0.0);
      }
    }
  }

  void _animateTo(double target) {
    _animation = Tween<double>(
      begin: _dragExtent,
      end: target,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0.0).then((_) {
      _dragExtent = target;
      if (mounted) setState(() {});
    });
  }

  void _close() {
    _animateTo(0.0);
  }

  void _handleDefer() {
    AppHaptics.mediumImpact();
    _close();
    widget.onDefer?.call();
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
        final currentExtent = _controller.isAnimating && _animation != null
            ? _animation!.value
            : _dragExtent;
        final isOpen = currentExtent.abs() > 2.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 🟡 1. SOL AKSİYON: YARINA AKTAR (Sağa çekilince açılır)
            if (widget.onDefer != null && currentExtent > 0)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: _leftWidth,
                child: Opacity(
                  opacity: (currentExtent / _leftWidth).clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Material(
                      color: widget.deferColor ?? AppColors.actionDefer,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: InkWell(
                        onTap: _handleDefer,
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.next_plan_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.transferToTomorrow,
                                textAlign: TextAlign.center,
                                style: AppTypography.sfProRounded(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 🔴 2. SAĞ AKSİYONLAR: DÜZENLE & SİL (Sola çekilince açılır)
            if (currentExtent < 0)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: _rightWidth,
                child: Opacity(
                  opacity: (-currentExtent / _rightWidth).clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Row(
                      children: [
                        // ✏️ Düzenleme Butonu (Muted Dusty Slate)
                        if (widget.onEdit != null)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Material(
                                color: widget.editColor ?? AppColors.actionEdit,
                                borderRadius:
                                    BorderRadius.circular(widget.borderRadius),
                                child: InkWell(
                                  onTap: _handleEdit,
                                  borderRadius:
                                      BorderRadius.circular(widget.borderRadius),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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

                        // 🗑️ Silme Butonu (Muted Terracotta Rose)
                        Expanded(
                          child: Material(
                            color: widget.deleteColor ?? AppColors.actionDelete,
                            borderRadius:
                                BorderRadius.circular(widget.borderRadius),
                            child: InkWell(
                              onTap: _handleDelete,
                              borderRadius:
                                  BorderRadius.circular(widget.borderRadius),
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

            // 🎴 3. ÖNDEKİ KART İÇERİĞİ
            Transform.translate(
              offset: Offset(currentExtent, 0),
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
