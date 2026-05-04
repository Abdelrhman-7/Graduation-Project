import 'package:flutter/material.dart';

class ColorManager {
  static const Color primary = Color(0xFF7F13EC); // Electric Violet
  static const Color background = Color(0xFFFEF2F2); // Athens Gray (Pinkish)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Text Colors
  static const Color headlineText = Color(0xFF140D1B); // Cinder
  static const Color bodyText = Color(0xFF4B5563); // River Bed
  static const Color subtitleText = Color(0xFF6B7280); // Pale Sky

  // Card Colors
  static const Color unselectedCardBackground = Color(0xFFF1F5F9); // Athens Gray (Bluish)
  
  // Borders
  static const Color borderColor = Color(0xFFE2E8F0); // Athens Gray
  
  // Opacity Colors
  static Color primaryOpacity10 = const Color(0xFF7F13EC).withValues(alpha: 0.1);
  static Color primaryOpacity15 = const Color(0xFF7F13EC).withValues(alpha: 0.15);
  static Color primaryOpacity5 = const Color(0xFF7F13EC).withValues(alpha: 0.05);
  static Color blackOpacity05 = const Color(0xFF000000).withValues(alpha: 0.05);
  static Color blackOpacity20 = const Color(0xFF000000).withValues(alpha: 0.2);
}
