import 'dart:math' as math;

import 'package:fintrack/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BudgetsIllustration extends StatefulWidget {
  const BudgetsIllustration({super.key});

  @override
  State<BudgetsIllustration> createState() => _BudgetsIllustrationState();
}

class _BudgetsIllustrationState extends State<BudgetsIllustration>
    with SingleTickerProviderStateMixin {
  static const double _targetProgress = 0.82;

  static const double _panelW = 223;
  static const double _panelH = 145;
  static const double _barsBaseline = 116; 
  
  static const List<({double x, double h, Color color})> _bars = [
    (x: 24.0, h: 28.0, color: AppColors.chartBlueLight),
    (x: 50.0, h: 44.0, color: AppColors.chartBlue),
    (x: 75.0, h: 58.0, color: AppColors.chartGreenMid),
    (x: 99.0, h: 74.0, color: AppColors.primaryDeep),
  ];

  late final AnimationController _controller;
  late final Animation<double> _grow;
  late final Animation<double> _draw;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _grow = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _draw = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width - 20;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 290, height: 245, child: _buildScene()),
        const SizedBox(height: 20),
        SizedBox(
          height: 72,
          child: OverflowBox(
            minWidth: cardWidth,
            maxWidth: cardWidth,
            child: _buildTargetCard(),
          ),
        ),
      ],
    );
  }


  Widget _buildScene() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: 10, top: -10, child: _buildGlow()),
        Positioned(left: 55, top: 188, child: _buildGround()),
        Positioned(left: 32, top: 35, child: _buildPanel()),
        Positioned(left: 175, top: 108, child: _buildRingCard()),
        Positioned(left: 18, top: 165, child: _buildCoins()),
        Positioned(
          top: 4,
          left: 0,
          right: 0,
          child: Center(child: _buildBadge()),
        ),

        Positioned(left: 246, top: 23, child: _sparkle(14, AppColors.primary)),
        Positioned(
          left: 260,
          top: 92,
          child: _dot(6, AppColors.primary.withValues(alpha: 0.55)),
        ),
        Positioned(
          left: 20,
          top: 66,
          child: Icon(
            Icons.add,
            size: 10,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
        Positioned(left: 14, top: 150, child: _dot(5, AppColors.chartBlueLight)),
      ],
    );
  }

  Widget _buildGlow() {
    return Container(
      width: 270,
      height: 270,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.primary.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildGround() {
    return Container(
      width: 190,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.glowBlue.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.all(Radius.elliptical(95, 22)),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      height: 30,
      padding: const EdgeInsets.fromLTRB(5, 0, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_upward_rounded, size: 13, color: Colors.white),
          ),
          const SizedBox(width: 6),
          const Text(
            'Budget +18%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPanel() {
    return Container(
      width: _panelW,
      height: _panelH,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _grow,
              builder: (context, _) {
                return Stack(
                  children: [
                    for (final b in _bars)
                      Positioned(
                        left: b.x,
                        bottom: _panelH - _barsBaseline,
                        width: 14,
                        height: b.h * _grow.value,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: b.color,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _draw,
              builder: (context, _) {
                return CustomPaint(painter: _CurvePainter(_draw.value));
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRingCard() {
    return AnimatedBuilder(
      animation: _grow,
      builder: (context, _) {
        return Container(
          width: 100,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 0.78 * _grow.value,
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.mint,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.mint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryDeep,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star, size: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  width: 56,
                  height: 4,
                  child: LinearProgressIndicator(
                    value: 0.7 * _grow.value,
                    minHeight: 4,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildCoins() {
    return SizedBox(
      width: 52,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _CoinsPainter())),
          Positioned(left: 21, top: 4, child: _sparkle(10, Colors.white)),
        ],
      ),
    );
  }


  Widget _buildTargetCard() {
    return AnimatedBuilder(
      animation: _grow,
      builder: (context, _) {
        final value = _targetProgress * _grow.value;

        return Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.savings, size: 20, color: AppColors.primaryDeep),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Monthly Target',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(value * 100).round()}% saved',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: AppColors.glowBlue.withValues(alpha: 0.45),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _sparkle(double size, Color color) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(color),
    );
  }
}


void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint,
    {double dash = 3, double gap = 3}) {
  final total = (b - a).distance;
  final dir = (b - a) / total;
  var d = 0.0;
  while (d < total) {
    canvas.drawLine(a + dir * d, a + dir * math.min(d + dash, total), paint);
    d += dash + gap;
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    for (final y in const [52.0, 85.0]) {
      _drawDashedLine(canvas, Offset(18, y), Offset(size.width - 14, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurvePainter extends CustomPainter {
  const _CurvePainter(this.progress);

  final double progress;

  static const Offset _midDot = Offset(143, 31);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final firstSegment = Path()
      ..moveTo(8, 94)
      ..cubicTo(45, 90, 80, 60, 143, 31);

    final path = Path.from(firstSegment)..cubicTo(165, 21, 185, 17, 200, 9);

    final metric = path.computeMetrics().first;
    final midFraction = firstSegment.computeMetrics().first.length / metric.length;
    final drawnLength = metric.length * progress;

    canvas.drawPath(
      metric.extractPath(0, drawnLength),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    if (progress >= midFraction) _drawDot(canvas, _midDot, 4.5);

    final head = metric.getTangentForOffset(drawnLength)!.position;
    _drawDot(canvas, head, 5.5);
  }

  void _drawDot(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius + 2.5, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CoinsPainter extends CustomPainter {
  const _CoinsPainter();

  static const List<Color> _tops = [
    AppColors.primaryDeep,
    AppColors.primaryDark,
    AppColors.primary,
    AppColors.primaryLight,
  ];
  static const List<Color> _sides = [
    Color(0xFF064E3B),
    AppColors.primaryDeep,
    AppColors.primaryDark,
    AppColors.primary,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const ellipseH = 17.0;
    const thickness = 9.0;
    const step = 9.0;
    final w = size.width;

    for (var i = 0; i < 4; i++) {
      final y = size.height - ellipseH - thickness - i * step;
      final sidePaint = Paint()..color = _sides[i];

      canvas.drawOval(Rect.fromLTWH(0, y + thickness, w, ellipseH), sidePaint);
      canvas.drawRect(Rect.fromLTWH(0, y + ellipseH / 2, w, thickness), sidePaint);
      canvas.drawOval(Rect.fromLTWH(0, y, w, ellipseH), Paint()..color = _tops[i]);
    }

    final topY = size.height - ellipseH - thickness - 3 * step;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, topY + ellipseH * 0.2, w * 0.64, ellipseH * 0.6),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}