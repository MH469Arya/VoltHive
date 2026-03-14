import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Professional typography system for VoltHive
class AppTypography {
  AppTypography._();

  // Base font family - using Inter for professional, clean look
  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  // Display styles (large headings)
  static TextStyle displayLarge(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.2,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle displayMedium(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      height: 1.3,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle displaySmall(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  // Headline styles (section titles)
  static TextStyle headlineLarge(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle headlineMedium(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle headlineSmall(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  // Title styles (card headers)
  static TextStyle titleLarge(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle titleMedium(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle titleSmall(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  // Body styles (content text)
  static TextStyle bodyLarge(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle bodyMedium(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle bodySmall(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );
  }

  // Label styles (buttons, tags)
  static TextStyle labelLarge(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.1,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle labelMedium(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.5,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle labelSmall(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.5,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );
  }

  // Caption styles (small text)
  static TextStyle caption(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.3,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );
  }

  // Special styles
  static TextStyle buttonText(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.5,
    );
  }

  static TextStyle priceText(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.2,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle numberLarge(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.1,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }
}
