import 'package:flutter/material.dart';
import '../constants/app_typography.dart';
import '../utils/app_haptics.dart';

/// 🍎 Calenda Apple Tarzı Sağa/Sola Kaydırarak Silme Kutucuğu
///
/// Kartı sağdan sola kaydırınca sağda kırmızı bir "Sil" kutusu belirir.
/// Kart anında kazara silinmez; kullanıcı açık olan kırmızı "Sil" kutusuna
/// dokunduğunda doğrudan silme işlemi gerçekleşir (onay diyaloğu sormaz).
class SwipeToDeleteTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final double borderRadius;
  final double actionWidth;

  const SwipeToDeleteTile({
    super.key,
    required this.child,
    required this.onDelete,
    this.borderRadius = 24.0,
    this.actionWidth = 78.0,
  });

  @override
  State<SwipeToDeleteTile> createState() => _SwipeToDeleteTileState();
}

class _SwipeToDeleteTileState extends State<SwipeToDeleteTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0.0;

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
    // Yalnızca sağdan sola (dx < 0) veya açıkken geri sağa harekete izin ver
    _dragExtent += details.primaryDelta ?? 0.0;
    if (_dragExtent > 0.0) _dragExtent = 0.0;
    if (_dragExtent < -widget.actionWidth) _dragExtent = -widget.actionWidth;

    _controller.value = (-_dragExtent) / widget.actionWidth;
  }

  void _handleDragEnd(DragEndDetails details) {
    final vx = details.primaryVelocity ?? 0.0;
    if (vx < -300 || _controller.value > 0.45) {
      // Sola hızlı fırlatıldıysa veya yarıdan fazla çekildiyse açık bırak
      _controller.animateTo(1.0, curve: Curves.easeOutCubic);
      _dragExtent = -widget.actionWidth;
      AppHaptics.lightImpact();
    } else {
      // Geri kapat
      _controller.animateTo(0.0, curve: Curves.easeOutCubic);
      _dragExtent = 0.0;
    }
  }

  void _close() {
    _controller.animateTo(0.0, curve: Curves.easeOutCubic);
    _dragExtent = 0.0;
  }

  void _handleDelete() {
    AppHaptics.mediumImpact();
    _close();
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final offset = -_controller.value * widget.actionWidth;
        final isOpen = _controller.value > 0.05;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 🔴 1. ARKADAKİ SİLME KUTUSU (Yalnızca açıldıkça görünür)
            // Not: Stack'te ilk sırada, kart sola kayınca üstte kalır.
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: widget.actionWidth,
              child: Opacity(
                opacity: _controller.value.clamp(0.0, 1.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
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
                              size: 22,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sil',
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
            ),

            // 🎴 2. ÖNDEKİ KART İÇERİĞİ (Sola kayar)
            // GestureDetector yalnızca kartı sarar; Sil kutusunu KAPSAMAZ.
            // Böylece kart açıkken Sil kutusuna yapılan dokunuşlar InkWell'e ulaşır.
            Transform.translate(
              offset: Offset(offset, 0),
              child: GestureDetector(
                onHorizontalDragUpdate: _handleDragUpdate,
                onHorizontalDragEnd: _handleDragEnd,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    widget.child,
                    // Eğer menü açıksa, karta dokununca menüyü kapatsın
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
