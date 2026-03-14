import 'package:flutter/material.dart';

/// Professional dark-first color scheme for VoltHive
/// Electric blue accents · Amber-orange energy · Deep dark surfaces
class AppColors {
  AppColors._();

  // ─── Primary Accent ───────────────────────────────────────────────────────
  /// Electric / neon blue – CTAs, highlights, "Active" badges, sidebar
  static const Color primary = Color(0xFF3B82F6);

  /// Slightly brighter electric blue variant for gradients / glow effects
  static const Color primaryBright = Color(0xFF0066FF);

  // ─── Energy Palette ───────────────────────────────────────────────────────
  /// Solar / generation line – vibrant amber-orange  (#F97316)
  static const Color solarProduction = Color(0xFFF97316);

  /// Solar lighter variant – for fills, gradients
  static const Color solarProductionLight = Color(0xFFFB923C);

  /// Grid / consumption line – professional blue (#60A5FA)
  static const Color gridConsumption = Color(0xFF60A5FA);

  /// Net surplus area – clean success green (#22C55E)
  static const Color netSurplus = Color(0xFF22C55E);

  /// Growth / positive change indicators – emerald green
  static const Color growth = Color(0xFF10B981);

  // ─── Battery ──────────────────────────────────────────────────────────────
  /// Battery charged / healthy state
  static const Color batteryCharged = Color(0xFF10B981);

  /// Battery tech colour (informational blue)
  static const Color batteryTech = Color(0xFF3B82F6);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success     = Color(0xFF10B981);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color error       = Color(0xFFEF4444);
  static const Color info        = Color(0xFF3B82F6);

  static const Color successLight = Color(0xFF052E16);
  static const Color warningLight = Color(0xFF451A03);
  static const Color errorLight   = Color(0xFF450A0A);

  // ─── Dark Mode Surfaces ───────────────────────────────────────────────────
  /// Main scaffold background – deepest dark, subtle purple-brown undertone
  static const Color darkBackground    = Color(0xFF0F121A);

  /// Alt scaffold (slightly lighter, used for modals / sheets)
  static const Color darkBackgroundAlt = Color(0xFF1A1F2E);

  /// Card / panel surface – elevated above background
  static const Color darkSurface       = Color(0xFF1E2330);

  /// Higher-elevation surface (dialogs, dropdowns)
  static const Color darkSurfaceAlt    = Color(0xFF2A2F40);

  /// Border / separator lines – muted gray-blue
  static const Color darkBorder        = Color(0xFF2A3345);

  /// Divider lines (slightly more opaque)
  static const Color darkDivider       = Color(0xFF334155);

  /// Primary text – off-white for maximum readability
  static const Color darkTextPrimary   = Color(0xFFF3F4F6);

  /// Secondary text – light gray, used for labels and subtitles
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  /// Muted tertiary text – legends, timestamps
  static const Color darkTextMuted     = Color(0xFF64748B);

  // ─── Light Mode Surfaces ──────────────────────────────────────────────────
  static const Color lightBackground    = Color(0xFFF8FAFC);
  static const Color lightBackgroundAlt = Color(0xFFFFFFFF);
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightBorder        = Color(0xFFE2E8F0);
  static const Color lightDivider       = Color(0xFFE2E8F0);
  static const Color lightTextPrimary   = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // ─── Graph / Chart Palette ────────────────────────────────────────────────
  /// Chart background area – deep dark with subtle purple undertone
  static const Color chartBackground = Color(0xFF121826);

  /// Chart grid lines / axes – muted gray-blue (use at 30–50% opacity)
  static const Color chartGrid        = Color(0xFF2A3345);

  /// Production / generated energy line – vibrant amber-orange
  static const Color chartProduction  = Color(0xFFF97316);

  /// Consumption / usage line – bright professional blue
  static const Color chartConsumption = Color(0xFF60A5FA);

  /// Net / surplus line or area – clean success green
  static const Color chartNet         = Color(0xFF22C55E);

  /// Positive-change / growth indicators
  static const Color chartGrowth      = Color(0xFF10B981);

  /// Chart label & legend text – light slate
  static const Color chartLabel       = Color(0xFFE2E8F0);

  /// Chart secondary label (muted hierarchy)
  static const Color chartLabelMuted  = Color(0xFF94A3B8);

  /// Tooltip background
  static const Color chartTooltipBg   = Color(0xFF1E293B);

  /// Tooltip text
  static const Color chartTooltipText = Color(0xFFF1F5F9);

  // Legacy aliases kept for backward-compatibility in existing widgets
  static const Color chartGreen  = Color(0xFF10B981);
  static const Color chartAmber  = Color(0xFFF97316);
  static const Color chartBlue   = Color(0xFF60A5FA);
  static const Color chartGray   = Color(0xFF64748B);
  static const Color chartRed    = Color(0xFFEF4444);
  static const Color chartPurple = Color(0xFF8B5CF6);

  // ─── Opacity Helpers ─────────────────────────────────────────────────────
  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);
  static Color blackWithOpacity(double opacity) =>
      Colors.black.withValues(alpha: opacity);
  static Color whiteWithOpacity(double opacity) =>
      Colors.white.withValues(alpha: opacity);
}
