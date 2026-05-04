import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_manager.dart';

class ThemeManager {
  static ThemeData getApplicationTheme() {
    return ThemeData(
      scaffoldBackgroundColor: ColorManager.background,
      primaryColor: ColorManager.primary,
      
      textTheme: TextTheme(
        // Heading 1: Join as a...
        displayLarge: GoogleFonts.lexend(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: ColorManager.headlineText,
          letterSpacing: -0.8, // -2.5% of 32
        ),
        // Heading 4: Patient / Doctor card titles
        headlineMedium: GoogleFonts.lexend(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ColorManager.headlineText,
        ),
        // Lexend/Regular: Body text
        bodyLarge: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ColorManager.bodyText,
          height: 1.5, // 24px line height
        ),
        // Lexend/Medium: Card description
        bodyMedium: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ColorManager.subtitleText,
          height: 1.375, // 19.25px line height
        ),
        // Semantic/Button
        labelLarge: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.24, // 1.5%
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          foregroundColor: ColorManager.white,
          elevation: 0,
          textStyle: GoogleFonts.lexend(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.25, // 1.47%
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      
      useMaterial3: true,
    );
  }
}
