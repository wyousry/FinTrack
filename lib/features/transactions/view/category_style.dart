
import 'package:flutter/material.dart';

class CategoryStyle {
  const CategoryStyle({
    required this.icon,
    required this.color,
    this.tint = _lightTint,
    this.iconColor = _muted,
  });

  final IconData icon;
  final Color color;
  final Color tint;
  final Color iconColor;

  static const Color _lightTint = Color(0xFFF2F3FF);
  static const Color _muted = Color(0xFF505F76);
  static const Color _slate = Color(0xFF38485D);
  static const Color _positive = Color(0xFF006C49);
  static const Color _negative = Color(0xFFBA1A1A);

  static const CategoryStyle fallback = CategoryStyle(
    icon: Icons.category_outlined,
    color: Color(0xFFBBCABF),
  );

  static const Map<String, CategoryStyle> _styles = {
    'food': CategoryStyle(icon: Icons.restaurant_outlined, color: Color(0xFF10B981), tint: Color(0xFFD3E4FE), iconColor: _slate),
    'shopping': CategoryStyle(icon: Icons.shopping_bag_outlined, color: Color(0xFF38485D), tint: Color(0xFFDAE2FD), iconColor: _slate),
    'transport': CategoryStyle(icon: Icons.directions_car_outlined, color: Color(0xFF54647A), tint: Color(0xFFD0E1FB), iconColor: _slate),
    'bills': CategoryStyle(icon: Icons.bolt_rounded, color: Color(0xFF68DBA9), tint: Color(0xFF85F8C4), iconColor: _positive),
    'entertainment': CategoryStyle(icon: Icons.confirmation_number_outlined, color: Color(0xFFF59E0B), tint: Color(0xFFFFDAD6), iconColor: _negative),
    'health': CategoryStyle(icon: Icons.favorite_border_rounded, color: Color(0xFFF43F5E), tint: Color(0xFFE2E7FF), iconColor: _negative),
    'education': CategoryStyle(icon: Icons.school_outlined, color: Color(0xFF6366F1), tint: Color(0xFFB7C8E1), iconColor: _slate),
    'travel': CategoryStyle(icon: Icons.flight_outlined, color: Color(0xFF0EA5E9), tint: Color(0xFFEAEDFF)),
    'groceries': CategoryStyle(icon: Icons.shopping_basket_outlined, color: Color(0xFF14B8A6), tint: Color(0xFF6FFBBE), iconColor: _positive),
    'personal_care': CategoryStyle(icon: Icons.spa_outlined, color: Color(0xFFA78BFA), tint: Color(0xFFE2E7FF)),
    'savings_investment': CategoryStyle(icon: Icons.trending_up_rounded, color: Color(0xFF3EB686), tint: Color(0xFF3EB686), iconColor: Colors.white),
    'other_expense': CategoryStyle(icon: Icons.more_horiz_rounded, color: Color(0xFFBBCABF)),
    'salary': CategoryStyle(icon: Icons.work_outline_rounded, color: Color(0xFF10B981), tint: Color(0xFF85F8C4), iconColor: _positive),
    'freelance': CategoryStyle(icon: Icons.laptop_mac_outlined, color: Color(0xFF14B8A6), tint: Color(0xFFD0E1FB), iconColor: _slate),
    'business': CategoryStyle(icon: Icons.business_center_outlined, color: Color(0xFF6366F1), tint: Color(0xFFDAE2FD), iconColor: _slate),
    'investment': CategoryStyle(icon: Icons.trending_up_rounded, color: Color(0xFF0EA5E9), tint: Color(0xFF3EB686), iconColor: Colors.white),
    'gift': CategoryStyle(icon: Icons.card_giftcard_outlined, color: Color(0xFFEC4899), tint: Color(0xFFFFDAD6), iconColor: _negative),
    'other_income': CategoryStyle(icon: Icons.more_horiz_rounded, color: Color(0xFFBBCABF)),
  };

  static CategoryStyle of(String categoryId) => _styles[categoryId] ?? fallback;
}