import 'dart:math' as math;

import 'package:fintrack/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SecurityIllustration extends StatefulWidget {
  const SecurityIllustration({super.key});

  @override
  State<SecurityIllustration> createState() => _SecurityIllustrationState();
}

class _SecurityIllustrationState extends State<SecurityIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Center(
              child: CustomPaint(
                size: const Size(284, 284),
                painter: _DashedCirclePainter(
                  color: AppColors.textSecondary.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),
          Positioned.fill(child: Center(child: _buildInnerGlowCircle())),
          Positioned(left: 235, top: 215, child: _buildBlueGlow()),

          Positioned(left: 75, top: 20, child: _buildPhoneFrame()),
          Positioned(left: 88, top: 48, child: _buildPhoneScreen()),

          Positioned(
            left: 142,
            top: 31,
            child: Container(
              width: 56,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Positioned(
            top: 62,
            left: 0,
            right: 0,
            child: Center(child: _buildSoundWave()),
          ),

          Positioned(left: 120, top: 118, child: _buildShieldCluster()),

          Positioned(left: 100, top: 250, child: _buildVaultRow()),

          Positioned(
            top: 20,
            right: 2,
            child: _buildPill(
              'Zero Knowledge',
              Icons.verified_user,
              AppColors.primary,
            ),
          ),
          Positioned(left: 6, top: 241, child: _buildKeyBadge()),
          Positioned(
            top: 291,
            right: 10,
            child: _buildPill(
              'Biometrics On',
              Icons.fingerprint,
              AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInnerGlowCircle() {
    return Container(
      width: 210,
      height: 210,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.0),
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
    );
  }

  Widget _buildBlueGlow() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.glowBlue.withValues(alpha: 0.6),
            AppColors.glowBlue.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }


  Widget _buildPhoneFrame() {
    return Container(
      width: 190,
      height: 278,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneScreen() {
    return Container(
      width: 164,
      height: 236,
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(26),
      ),
    );
  }

  Widget _buildSoundWave() {
    const heights = [12.0, 20.0, 26.0, 18.0, 12.0];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: heights.map((h) {
        return Container(
          width: 3.5,
          height: h,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShieldCluster() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              final t = _pulseAnimation.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(scale: t, child: _glowRing(96, 0.10)),
                  Transform.scale(
                    scale: 1 + (t - 1) / 2,
                    child: _glowRing(72, 0.18),
                  ),
                ],
              );
            },
          ),

          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Positioned(
                  right: -21,
                  bottom: -17,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowRing(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: alpha),
      ),
    );
  }

  Widget _buildVaultRow() {
    return Container(
      width: 140,
      height: 26,
      padding: const EdgeInsets.only(left: 26, right: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Vault Locked',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
            child: const Icon(
              Icons.check,
              size: 9,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPill(String text, IconData icon, Color iconColor) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyBadge() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 7, 12, 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.vpn_key,
              size: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Standard',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                  height: 1.2,
                ),
              ),
              Text(
                'AES 256-Bit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

   _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashLength = 8.0, 
    this.gapLength = 4.0,     
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();
    final dashAngle = dashLength / radius;
    final stepAngle = (2 * math.pi) / dashCount;

    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * stepAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}
