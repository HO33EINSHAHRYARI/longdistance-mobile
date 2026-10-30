import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF13131C);
  static const Color surfaceLight = Color(0xFF1C1C28);
  static const Color card = Color(0xFF181824);
  static const Color cardBorder = Color(0x30A855F7);
  
  // Neon Accents
  static const Color primary = Color(0xFFA855F7);
  static const Color primaryLight = Color(0xFFC084FC);
  static const Color primaryDark = Color(0xFF7E22CE);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFFEC4899);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // States
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSurface = Color(0x20EF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A26), Color(0xFF13131C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient storyGlow = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
