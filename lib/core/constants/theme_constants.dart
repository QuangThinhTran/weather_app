import 'package:flutter/material.dart';

class ThemeConstants {
  // Theme Mode Options
  static const String themeLight = 'light';
  static const String themeDark = 'dark';
  static const String themeSystem = 'system';
  
  // Light Theme Colors - Modern Weather Theme
  static const Color lightPrimary = Color(0xFF2563EB); // Modern blue
  static const Color lightPrimaryVariant = Color(0xFF1D4ED8);
  static const Color lightSecondary = Color(0xFF06B6D4); // Cyan for accents
  static const Color lightBackground = Color(0xFFF8FAFC); // Subtle gray-blue
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFEF4444);
  
  // Weather-specific gradient colors
  static const Color lightGradientStart = Color(0xFF60A5FA);
  static const Color lightGradientEnd = Color(0xFF3B82F6);
  static const Color lightCardGradientStart = Color(0xFFEBF8FF);
  static const Color lightCardGradientEnd = Color(0xFFF0F9FF);
  
  // Dark Theme Colors - Modern Weather Dark Theme
  static const Color darkPrimary = Color(0xFF60A5FA);
  static const Color darkPrimaryVariant = Color(0xFF3B82F6);
  static const Color darkSecondary = Color(0xFF22D3EE);
  static const Color darkBackground = Color(0xFF0F172A); // Deep slate
  static const Color darkSurface = Color(0xFF1E293B); // Slate-800
  static const Color darkError = Color(0xFFF87171);
  
  // Dark weather-specific gradient colors
  static const Color darkGradientStart = Color(0xFF1E3A8A);
  static const Color darkGradientEnd = Color(0xFF1E40AF);
  static const Color darkCardGradientStart = Color(0xFF1E293B);
  static const Color darkCardGradientEnd = Color(0xFF334155);
  
  // Text Colors
  static const Color lightOnPrimary = Colors.white;
  static const Color lightOnSecondary = Colors.black;
  static const Color lightOnBackground = Colors.black87;
  static const Color lightOnSurface = Colors.black87;
  static const Color lightOnError = Colors.white;
  
  static const Color darkOnPrimary = Colors.black;
  static const Color darkOnSecondary = Colors.black;
  static const Color darkOnBackground = Colors.white;
  static const Color darkOnSurface = Colors.white;
  static const Color darkOnError = Colors.black;
  
  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeXXLarge = 32.0;
  
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Border Radius - Modern rounded corners
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusXXLarge = 32.0;
  
  // Elevation levels for modern layering
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationXHigh = 12.0;
  
  // Glass morphism effects
  static const double glassOpacity = 0.1;
  static const double glassBlur = 20.0;
  
  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}