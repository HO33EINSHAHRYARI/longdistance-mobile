import 'package:flutter/material.dart';

class AppColors {
  // Exact web app canvases
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF0F0F15);
  static const Color card = Color(0xFF12121A);
  static const Color cardBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.08)
  static const Color surfaceLight = Color(0xFF181824);
  static const Color inputBg = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)

  // Brand Web Gradients (#c084fc -> #60a5fa)
  static const Color brandPurple = Color(0xFFC084FC);
  static const Color brandBlue = Color(0xFF60A5FA);
  static const Color primary = Color(0xFFC084FC);
  static const Color accent = Color(0xFFEC4899);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFC084FC), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Exact Web Card Gradient (165deg, rgba(20, 20, 32, 0.8) -> rgba(13, 13, 20, 0.92))
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xCC141420), Color(0xEB0D0D14)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // Exact Web Header Button Gradient (rgba(192,132,252,0.2) -> rgba(96,165,250,0.2))
  static const LinearGradient headerBtnGradient = LinearGradient(
    colors: [Color(0x33C084FC), Color(0x3360A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color headerBtnBorder = Color(0x4DC084FC); // rgba(192,132,252,0.3)

  // Tabs Header Background & Active Gradient
  static const Color tabsHeaderBg = Color(0x661E1E2D); // rgba(30,30,45,0.4)
  static const LinearGradient tabActiveGradient = LinearGradient(
    colors: [Color(0x40C084FC), Color(0x4060A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color tabActiveBorder = Color(0x33C084FC);

  // Gold Ring & Points Gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text colors
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xB3FFFFFF); // rgba(255,255,255,0.7)
  static const Color textMuted = Color(0x66FFFFFF);     // rgba(255,255,255,0.4)

  // States
  static const Color danger = Color(0xFFEF4444);
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
}
