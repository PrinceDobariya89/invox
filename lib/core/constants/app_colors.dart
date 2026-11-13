import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent
  static const Color primary = Color(0xFF4338CA); // Indigo 700
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF312E81); // Indigo 900
  static const Color primarySurface = Color(0xFFEEF2FF); // Indigo 50

  // Status & Financial Indicators
  static const Color received =
      Color(0xFF10B981); // Emerald 500 (Collected / Paid)
  static const Color receivedLight = Color(0xFFECFDF5);
  static const Color outstanding =
      Color(0xFFEF4444); // Red 500 (Unpaid / Outstanding)
  static const Color outstandingLight = Color(0xFFFEF2F2);
  static const Color partial = Color(0xFFF59E0B); // Amber 500 (Partially Paid)
  static const Color partialLight = Color(0xFFFFFBEB);
  static const Color billed = Color(0xFF2563EB); // Blue 600 (Billed amount)
  static const Color billedLight = Color(0xFFEFF6FF);
  static const Color overdue = Color(0xFFDC2626); // Red 600

  // Neutral & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFF1F5F9);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
}
