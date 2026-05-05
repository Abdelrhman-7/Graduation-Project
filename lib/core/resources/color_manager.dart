import 'package:flutter/material.dart';

class ColorManager {
  static const Color primary = Color(0xFF137FEC); // Primary Blue from Figma
  static const Color background = Color(0xFFF6F7F8); // Background from Figma
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Text Colors
  static const Color headlineText = Color(0xFF0F172A); // Dark Heading
  static const Color bodyText = Color(0xFF475569); // Secondary Text
  static const Color subtitleText = Color(0xFF64748B); // Tertiary Text

  // Card Colors
  static const Color unselectedCardBackground = Color(0xFFF1F5F9); 
  
  // Borders
  static const Color borderColor = Color(0xFFE2E8F0); 
  
  // Custom Section Colors
  static const Color cardInnerBg = Color(0xFFF8FAFC);
  static const Color cancelRedBg = Color(0x1AEF4444); // 10% Opacity Red
  static const Color cancelRedText = Color(0xFFEF4444);
  static const Color pendingBg = Color(0x1A137FEC); // 10% Opacity Primary
  
  // Chat Colors
  static const Color chatPrimary = Color(0xFF7F13EC); // Electric Violet
  static const Color onlineStatus = Color(0xFF10B981); // Mountain Meadow
  static const Color chatBackground = Color(0xFFF8FAFC);
  static const Color chatBubbleDoctor = Color(0xFFFFFFFF);
  static const Color chatBubblePatient = Color(0xFF7F13EC);
  static const Color chatTime = Color(0xFF94A3B8);
  
  // Opacity Colors
  static Color primaryOpacity10 = const Color(0xFF137FEC).withValues(alpha: 0.1);
  static Color primaryOpacity15 = const Color(0xFF137FEC).withValues(alpha: 0.15);
  static Color primaryOpacity5 = const Color(0xFF137FEC).withValues(alpha: 0.05);
  static Color blackOpacity05 = const Color(0xFF000000).withValues(alpha: 0.05);
  static Color blackOpacity20 = const Color(0xFF000000).withValues(alpha: 0.2);

  // Lab Results Colors
  static const Color ebony = Color(0xFF23262F);
  static const Color grayChateau = Color(0xFFB1B5C3);
  static const Color whiteLilac = Color(0xFFF4F5F6);
  static const Color catskillWhite = Color(0xFFE6E8EC);
  static const Color salem = Color(0xFF0F9D58);
  static const Color feta = Color(0xFFE7F3EF);
  static const Color athensGray = Color(0xFFF4F5F6);
  static const Color tahitiGold = Color(0xFFF08700);
  static const Color butteryWhite = Color(0xFFFFF9E6);
  static const Color alizarinCrimson = Color(0xFFE22D2D);
  static const Color provincialPink = Color(0xFFFEF2F2);
  static const Color electricViolet = Color(0xFF7F13EC);
  static const Color premiumCardBg = Color(0xFF0F172A); // Dark Navy/Slate
  static const Color darkBlue = Color(0xFF1E293B);
  static const Color tealHighlight = Color(0xFF14B8A6);
  static const Color amberHighlight = Color(0xFFF59E0B);
  static const Color blueHighlight = Color(0xFF3B82F6);
}
