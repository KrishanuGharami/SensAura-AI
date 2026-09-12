import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF090C10);
  static const Color backgroundSecondary = Color(0xFF0E131B);
  static const Color cardSurface = Color(0xFF141923);
  static const Color cardSurfaceElevated = Color(0xFF1B2230);
  static const Color borderSubtle = Color(0xFF232B3C);
  static const Color borderActive = Color(0xFF3B4863);

  // iQOO Signature Accents
  static const Color primaryAmber = Color(0xFFFF6600);
  static const Color primaryAmberGlow = Color(0x33FF6600);
  static const Color cyberCyan = Color(0xFF00E5FF);
  static const Color cyberCyanGlow = Color(0x3300E5FF);
  static const Color electricViolet = Color(0xFF8B5CF6);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color warmGold = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);

  // Typography
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textHighlight = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusLocal = Color(0xFF10B981);
  static const Color statusStream = Color(0xFF00E5FF);
  static const Color statusBle = Color(0xFF8B5CF6);
  static const Color statusWarning = Color(0xFFF59E0B);

  // Linear Gradients
  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFFF6600), Color(0xFFFF8E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00B4D8), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF171D28), Color(0xFF10141D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1F2637), Color(0xFF121620)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
