import 'package:flutter/cupertino.dart';

class AppColors {
  // Brand Accents
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryCyan = Color(0xFF0284C7);
  static const Color accentViolet = Color(0xFF7C3AED);
  static const Color accentAmber = Color(0xFFD97706);
  static const Color accentEmerald = Color(0xFF059669);
  static const Color accentRose = Color(0xFFE11D48);

  // Light Theme (Default upon opening/settings)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightGlassSurface = Color(0xE6FFFFFF);
  static const Color lightGlassBorder = Color(0x33CBD5E1);
  static const Color lightCardBorder = Color(0x1F94A3B8);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);
  static const Color lightDivider = Color(0x1E000000);
  static const Color lightTrack = Color(0xFFE2E8F0);

  // OLED Dark Theme (Deep Pitch Black & Midnight Velvet)
  static const Color darkBackground = Color(0xFF05070D);
  static const Color darkSurface = Color(0xFF0F131D);
  static const Color darkGlassSurface = Color(0xCC111827);
  static const Color darkGlassBorder = Color(0x334B5563);
  static const Color darkCardBorder = Color(0x269CA3AF);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  static const Color darkDivider = Color(0x26FFFFFF);
  static const Color darkTrack = Color(0xFF1F2937);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetAmberGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassHighlightGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
