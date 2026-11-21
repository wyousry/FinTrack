import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutSegment {
  const DonutSegment({required this.value, required this.color});

  final double value;
  final Color color;
}

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.size = 120,
    this.strokeWidth = 16,
    this.center,
  });

  final List<DonutSegment> segments;
  final double size;
  final double strokeWidth;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) {
              return CustomPaint(
                size: Size.square(size),
                painter: _DonutPainter(
                  segments: segments,
                  strokeWidth: strokeWidth,
                  progress: progress,
                ),
              );
            },
          ),
          if (center != null)
            Padding(
              padding: EdgeInsets.all(strokeWidth + 6),
              child: center,
            ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.segments,
    required this.strokeWidth,
    required this.progress,
  });

  final List<DonutSegment> segments;
  final double strokeWidth;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;


    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    final gap = segments.length > 1 ? 0.05 : 0.0;
    var start = -math.pi / 2;

    for (final segment in segments) {
      final fullSweep = segment.value / total * 2 * math.pi;
      final sweep = math.max(fullSweep - gap, 0.0) * progress;
      canvas.drawArc(arcRect, start + gap / 2, sweep, false, paint..color = segment.color);
      start += fullSweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.segments != segments ||
      old.strokeWidth != strokeWidth ||
      old.progress != progress;
}