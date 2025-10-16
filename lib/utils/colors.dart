import 'package:flutter/material.dart';

class YeneFarmColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryDarkGreen = Color(0xFF1B5E20);
  static const Color primaryLightGreen = Color(0xFF4CAF50);
  
  // Accent Colors
  static const Color accentYellow = Color(0xFFFFD700);
  static const Color accentDarkYellow = Color(0xFFFFC400);
  static const Color accentOrange = Color(0xFFFF9800);
  
  // Natural Colors
  static const Color soilBrown = Color(0xFF8D6E63);
  static const Color soilLightBrown = Color(0xFFA1887F);
  static const Color skyBlue = Color(0xFF4FC3F7);
  static const Color waterBlue = Color(0xFF29B6F6);
  
  // Status Colors
  static const Color successGreen = Color(0xFF388E3C);
  static const Color warningRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color infoBlue = Color(0xFF1976D2);
  
  // Neutral Colors
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF666666);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFEEEEEE);
  
  // Gradient
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryLightGreen],
  );
  
  static const Gradient sunsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFD700), Color(0xFFFF9800)],
  );
  
  static const Gradient soilGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [soilBrown, soilLightBrown],
  );
}