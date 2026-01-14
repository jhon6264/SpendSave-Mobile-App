import 'package:flutter/material.dart';

class AppTheme {
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFE259), Color(0xFFFFA751)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient savingsGradient = LinearGradient(
    colors: [Color(0xFF834D9B), Color(0xFFD04ED6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background Gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color accentText = Color(0xFF6A11CB);

  // Card Colors (Glassmorphism)
  static Color glassCardColor = Colors.white.withOpacity(0.15);
  static const Color glassBorderColor = Color(0x33FFFFFF);

  // Spacing
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  // Border Radius (SMALLER as requested: 5-10px)
  static const double borderRadiusXSmall = 5.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadius = 10.0;  // Main borderRadius
  static const double borderRadiusLarge = 12.0;

  // Font Sizes (SMALLER as requested)
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;  // Reduced from 16
  static const double fontSizeLarge = 18.0;   // Reduced from 24
  static const double fontSizeXLarge = 22.0;  // Reduced from 32
  static const double fontSizeXXLarge = 28.0; // Reduced from 48

  // Text Styles (Updated with smaller sizes)
  static TextStyle headline1 = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: fontSizeXXLarge,
    fontWeight: FontWeight.w700,
    color: primaryText,
  );

  static TextStyle headline2 = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  static TextStyle headline3 = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  static TextStyle headline4 = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  static TextStyle bodyText1 = const TextStyle(
    fontFamily: 'Inter',
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w400,
    color: primaryText,
  );

  static TextStyle bodyText2 = const TextStyle(
    fontFamily: 'Inter',
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.w400,  // Changed from w500 to w400
    color: secondaryText,
  );

  static TextStyle captionText = const TextStyle(
    fontFamily: 'Inter',
    fontSize: fontSizeXSmall,
    fontWeight: FontWeight.w400,
    color: secondaryText,
  );

  static TextStyle numberText = const TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w500,
    color: primaryText,
  );

  static TextStyle buttonText = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  // Button colors
  static const Color editButtonColor = Color(0xFF1E90FF);
  static const Color historyButtonColor = Color(0xFF00B09B);
  static const Color saveButtonColor = Color(0xFF6A11CB);
  static const Color cancelButtonColor = Color(0xFF666666);

  // Add this helper for envelope colors
  static List<List<Color>> envelopeColorOptions = [
    [const Color(0xFF8A2BE2), const Color(0xFF4B0082)], // Purple
    [const Color(0xFF1E90FF), const Color(0xFF00BFFF)], // Blue
    [const Color(0xFF00B09B), const Color(0xFF96C93D)], // Green
    [const Color(0xFFFFA500), const Color(0xFFFF6347)], // Orange
    [const Color(0xFFFF69B4), const Color(0xFFDB7093)], // Pink
    [const Color(0xFFFF416C), const Color(0xFFFF4B2B)], // Red
    [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Teal
    [const Color(0xFF6A11CB), const Color(0xFF2575FC)], // Royal
    [const Color(0xFF9C27B0), const Color(0xFF673AB7)], // Deep Purple
    [const Color(0xFF2196F3), const Color(0xFF03A9F4)], // Light Blue
    [const Color(0xFF4CAF50), const Color(0xFF8BC34A)], // Light Green
    [const Color(0xFFFFC107), const Color(0xFFFF9800)], // Amber
    [const Color(0xFFFF5722), const Color(0xFFE64A19)], // Deep Orange
    [const Color(0xFF795548), const Color(0xFF5D4037)], // Brown
    [const Color(0xFF607D8B), const Color(0xFF455A64)], // Blue Grey
    [const Color(0xFFE91E63), const Color(0xFFC2185B)], // Pink Dark
  ];
}