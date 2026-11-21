
import 'package:flutter/material.dart';

class CategoryStyle {
  const CategoryStyle({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  static const CategoryStyle fallback = CategoryStyle(
    icon: Icons.category_outlined,
    color: Color(0xFFBBCABF),
  );

  static const Map<String, CategoryStyle> _styles = {
    'food': CategoryStyle(icon: Icons.local_cafe_outlined, color: Color(0xFF10B981)),
    'shopping': CategoryStyle(icon: Icons.shopping_bag_outlined, color: Color(0xFF38485D)),
    'bills': CategoryStyle(icon: Icons.receipt_long_outlined, color: Color(0xFF68DBA9)),
    'transport': CategoryStyle(icon: Icons.directions_car_outlined, color: Color(0xFF54647A)),
    'other_expense': fallback,
    'health': CategoryStyle(icon: Icons.favorite_border_rounded, color: Color(0xFFF43F5E)),
    'education': CategoryStyle(icon: Icons.school_outlined, color: Color(0xFF6366F1)),
    'entertainment': CategoryStyle(icon: Icons.movie_outlined, color: Color(0xFFF59E0B)),
    'travel': CategoryStyle(icon: Icons.flight_outlined, color: Color(0xFF0EA5E9)),
    'salary': CategoryStyle(icon: Icons.work_outline_rounded, color: Color(0xFF10B981)),
    'freelance': CategoryStyle(icon: Icons.laptop_mac_outlined, color: Color(0xFF14B8A6)),
    'business': CategoryStyle(icon: Icons.business_center_outlined, color: Color(0xFF6366F1)),
    'investment': CategoryStyle(icon: Icons.trending_up_rounded, color: Color(0xFF0EA5E9)),
    'gift': CategoryStyle(icon: Icons.card_giftcard_outlined, color: Color(0xFFEC4899)),
    'other_income': fallback,
  };

  static CategoryStyle of(String categoryId) => _styles[categoryId] ?? fallback;
}