import 'package:flutter/material.dart';

/// 📅 Calenda — İçinde Bugünün Tarihi Yazan Apple Tarzı Takvim İkonu
class CalendarDateIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isSelected;

  const CalendarDateIcon({
    super.key,
    this.size = 20.0,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().day;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: size,
            color: color,
          ),
          Padding(
            padding: EdgeInsets.only(top: size * 0.22),
            child: Text(
              '$today',
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ⏳ Calenda — Günün Saatlerine Göre Kumu Dolan Dinamik Kum Saati İkonu
///
/// Mantık:
/// - Sabah 06:00: Üst hazne tam dolu, alt hazne boş.
/// - Gün boyunca (06:00 - 24:00): Zaman ilerledikçe üstteki kum boğazdan aşağı akar.
/// - Gece saat 12 (00:00) ve gece uykusu süresince (00:00 - 05:59): Alt hazne tam dolu, üst boş.
class DynamicHourglassIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isSelected;
  final DateTime? customTime;

  const DynamicHourglassIcon({
    super.key,
    this.size = 20.0,
    required this.color,
    this.isSelected = false,
    this.customTime,
  });

  @override
  Widget build(BuildContext context) {
    final now = customTime ?? DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    // Akış İlerlemesi (0.0: Üst tam dolu -> 1.0: Alt tam dolu)
    double progress;
    if (hour >= 6) {
      // 06:00 - 24:00 arası 18 saatlik akış
      progress = ((hour - 6) * 60 + minute) / (18.0 * 60.0);
    } else {
      // Gece 12'den sabah 06:00'a kadar alt hazne tam dolu kalır
      progress = 1.0;
    }
    progress = progress.clamp(0.0, 1.0);

    return CustomPaint(
      size: Size(size, size),
      painter: _HourglassPainter(
        color: color,
        progress: progress,
      ),
    );
  }
}

class _HourglassPainter extends CustomPainter {
  final Color color;
  final double progress; // 0.0: top full, 1.0: bottom full

  _HourglassPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Üst ve Alt Düz Destek Barları
    final barHeight = h * 0.09;
    final barWidth = w * 0.72;
    final barRadius = Radius.circular(barHeight / 2);

    final topBarRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, barHeight / 2 + 1), width: barWidth, height: barHeight),
      barRadius,
    );
    final bottomBarRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, h - barHeight / 2 - 1), width: barWidth, height: barHeight),
      barRadius,
    );

    canvas.drawRRect(topBarRect, fillPaint);
    canvas.drawRRect(bottomBarRect, fillPaint);

    final bulbTop = barHeight + 1.2;
    final bulbBottom = h - barHeight - 1.2;
    final bulbHeight = bulbBottom - bulbTop;
    final midY = bulbTop + bulbHeight / 2;

    final topBulbWidth = w * 0.62;
    final neckWidth = w * 0.16;
    final bottomBulbWidth = w * 0.62;

    // Kum Saati Cam Gövde Yolu (Üst ve Alt Hazne)
    final glassPath = Path();

    // Sol kenar (üstten alta)
    glassPath.moveTo(w / 2 - topBulbWidth / 2, bulbTop);
    glassPath.cubicTo(
      w / 2 - topBulbWidth / 2, midY - bulbHeight * 0.15,
      w / 2 - neckWidth / 2, midY - bulbHeight * 0.06,
      w / 2 - neckWidth / 2, midY,
    );
    glassPath.cubicTo(
      w / 2 - neckWidth / 2, midY + bulbHeight * 0.06,
      w / 2 - bottomBulbWidth / 2, midY + bulbHeight * 0.15,
      w / 2 - bottomBulbWidth / 2, bulbBottom,
    );

    // Alt taban
    glassPath.lineTo(w / 2 + bottomBulbWidth / 2, bulbBottom);

    // Sağ kenar (alttan üste)
    glassPath.cubicTo(
      w / 2 + bottomBulbWidth / 2, midY + bulbHeight * 0.15,
      w / 2 + neckWidth / 2, midY + bulbHeight * 0.06,
      w / 2 + neckWidth / 2, midY,
    );
    glassPath.cubicTo(
      w / 2 + neckWidth / 2, midY - bulbHeight * 0.06,
      w / 2 + topBulbWidth / 2, midY - bulbHeight * 0.15,
      w / 2 + topBulbWidth / 2, bulbTop,
    );

    glassPath.close();

    // 1. Kum / Doluluk Çizimi (Maskelenerek)
    canvas.save();
    canvas.clipPath(glassPath);

    // ── Üst Haznedeki Kum (Günün başında dolu, akıp azalır) ──
    final topRemaining = (1.0 - progress);
    if (topRemaining > 0.01) {
      final topFillHeight = (midY - bulbTop) * topRemaining;
      final topRect = Rect.fromLTRB(
        0,
        midY - topFillHeight,
        w,
        midY,
      );
      canvas.drawRect(topRect, fillPaint);
    }

    // ── Alt Haznedeki Kum (Günün başında boş, akıp dolar) ──
    if (progress > 0.01) {
      final bottomFillHeight = (bulbBottom - midY) * progress;
      final bottomRect = Rect.fromLTRB(
        0,
        bulbBottom - bottomFillHeight,
        w,
        bulbBottom,
      );
      canvas.drawRect(bottomRect, fillPaint);
    }

    // ── Akış Hattı (Kum akarken boğazdan ince bir hat süzülür) ──
    if (progress > 0.03 && progress < 0.97) {
      final tricklePaint = Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(w / 2, midY - 2.5),
        Offset(w / 2, midY + 3.0),
        tricklePaint,
      );
    }

    canvas.restore();

    // 2. Cam Çerçevesinin Çizimi (Stroke)
    canvas.drawPath(glassPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _HourglassPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}
