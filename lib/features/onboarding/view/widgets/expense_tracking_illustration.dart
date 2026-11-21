
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ExpenseTrackingIllustration extends StatefulWidget {
  const ExpenseTrackingIllustration({super.key});

  @override
  State<ExpenseTrackingIllustration> createState() =>
      _ExpenseTrackingIllustrationState();
}

class _ExpenseTrackingIllustrationState
    extends State<ExpenseTrackingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
       
          _buildGlow(),

          Positioned(
            top: 20,
            left: 30,
            child: Transform.rotate(
              angle: 12* math.pi / 180, 
              child: _buildUsdChip(),
            ),
          ),


          Positioned(
            top: 15,
            right: 20,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: _buildExpenseChip(),
            ),
          ),

         
          Positioned(
            top: 95,
            child: _buildBudgetCard(),
          ),

          Positioned(
            top: 220,
            right: 50,
            child: _buildDollarBadge(),
          ),

          Positioned(
            bottom: 10,
            left: 15,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: _buildTrackedBadge(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildUsdChip() {
    return Container(
      width: 144,
      height: 80,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(18),
        
      ),
      child: Stack(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '\$ USD',
              style: TextStyle( fontWeight: FontWeight.w600,fontSize: 11),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              
              width: 30,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: const Icon(Icons.attach_money,size: 15, color: AppColors.primary  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.coffee_outlined, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          const Text(
            '-\$4.50',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 11),
          ),
        ],
      ),
    );
  }

  

  

 Widget _buildBudgetCard() {
  return Container(
    width: 192,
    height: 140,
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        // Top Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3EF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 15,
                color: AppColors.primary,
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'CARD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF52719D),
                ),
              ),
            ),
          ],
        ),

        const Spacer(),

        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // Small Icon
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_down_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 7),

              // Texts
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Budget',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Under control',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              // Percentage
              const Text(
                '78%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  Widget _buildDollarBadge() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Center(child: const Icon(Icons.monetization_on_sharp, color: Colors.white, size: 20)),
    );
  }

  Widget _buildTrackedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart, color: AppColors.primary, size: 14),
          const SizedBox(width: 6),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TRACKED', style: TextStyle(fontSize: 8, color: AppColors.textSecondary, height: 1)),
              Text('+18 Today', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, height: 1.3)),
            ],
          ),
        ],
      ),
    );
  }
}