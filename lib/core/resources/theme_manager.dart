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
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: ColorManager.headlineText,
          letterSpacing: -0.8, // -2.5% of 32
        ),
        // Heading 4: Patient / Doctor card titles
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ColorManager.headlineText,
        ),
        // Lexend/Regular: Body text
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ColorManager.bodyText,
          height: 1.5, // 24px line height
        ),
        // Lexend/Medium: Card description
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ColorManager.subtitleText,
          height: 1.375, // 19.25px line height
        ),
        // Semantic/Button
        labelLarge: GoogleFonts.cairo(
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
          textStyle: GoogleFonts.cairo(
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

  // Chat Text Styles
  static TextStyle getChatDateStyle() => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: ColorManager.chatPrimary,
        letterSpacing: 1.1, // 10%
      );

  static TextStyle getDoctorBubbleStyle() => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ColorManager.headlineText,
        height: 1.6,
      );

  static TextStyle getPatientBubbleStyle() => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ColorManager.white,
        height: 1.6,
      );

  static TextStyle getChatTimeStyle() => GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: ColorManager.chatTime,
      );

  static TextStyle getDoctorNameStyle() => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: ColorManager.headlineText,
      );

  static TextStyle getDoctorStatusStyle() => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: ColorManager.chatPrimary,
      );

  // Lab Results Text Styles
  static TextStyle getLabHeading1Style() => GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: ColorManager.ebony,
      );

  static TextStyle getLabHeading3Style() => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ColorManager.ebony,
      );

  static TextStyle getLabHeading4Style() => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: ColorManager.ebony,
      );

  static TextStyle getLabBodyStyle() => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ColorManager.grayChateau,
      );

  static TextStyle getLabBadgeStyle(Color color) => GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle getLabDateStyle() => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ColorManager.grayChateau,
      );
}
