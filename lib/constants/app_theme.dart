import 'package:flutter/material.dart';

//color constants for the app
class AppColors {
  AppColors._();

  //primary palette
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF262626);
  static const Color surfaceLight = Color(0xFF2D2D2D);
  static const Color surfaceDark = Color(0xFF0A0A0A);

  //accent colors
  static const Color primary = Color(0xFF4ECDC4);
  static const Color primaryDark = Color(0xFF2A8A84);
  static const Color secondary = Color(0xFFF5F5DC);
  static const Color secondaryDark = Color(0xFF6A6A50);

  //text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFF5F5DC);
  static const Color textMuted = Color(0xFF666666);
  static const Color textDisabled = Color(0xFF444444);

  //UI element colors
  static const Color border = Color(0xFF3A3A3A);
  static const Color shadow = Color(0xFF0A0A0A);
  static const Color gridLine = Color(0xFF222222);

  //default drawing palette
  static const List<Color> defaultPalette = [
    Color(0xFFF5F5DC), // Cream
    Color(0xFF4ECDC4), // Cyan
    Color(0xFFFF6B6B), // Red
    Color(0xFFFFE66D), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFFFAA5A), // Orange
    Color(0xFFDDA0DD), // Plum
    Color(0xFF87CEEB), // Sky
    Color(0xFF1A1A1A), // Dark
    Color(0xFFFFFFFF), // White
    Color(0xFF666666), // Grey
    Color(0xFF333333), // Dark grey
  ];
}

//sizing
class AppSizes {
  AppSizes._();

  // Responsive breakpoints
  static const double smallScreenWidth = 400;
  static const double mediumScreenWidth = 600;

  //getting responsive sizes based on screen width
  static ResponsiveSizes getResponsiveSizes(double screenWidth) {
    if (screenWidth < smallScreenWidth) {
      return ResponsiveSizes.small();
    } else if (screenWidth < mediumScreenWidth) {
      return ResponsiveSizes.medium();
    } else {
      return ResponsiveSizes.large();
    }
  }
}

//size  presets for different screen sizes
class ResponsiveSizes {
  final double iconLarge;
  final double iconMedium;
  final double iconSmall;
  final double titleText;
  final double headingText;
  final double bodyText;
  final double captionText;
  final double buttonHeight;
  final double toolbarButton;
  final double paletteSize;
  final double spacing;
  final double shadowOffset;

  const ResponsiveSizes({
    required this.iconLarge,
    required this.iconMedium,
    required this.iconSmall,
    required this.titleText,
    required this.headingText,
    required this.bodyText,
    required this.captionText,
    required this.buttonHeight,
    required this.toolbarButton,
    required this.paletteSize,
    required this.spacing,
    required this.shadowOffset,
  });

  factory ResponsiveSizes.small() => const ResponsiveSizes(
    iconLarge: 80,
    iconMedium: 22,
    iconSmall: 20,
    titleText: 44,
    headingText: 20,
    bodyText: 16,
    captionText: 12,
    buttonHeight: 60,
    toolbarButton: 44,
    paletteSize: 42,
    spacing: 10,
    shadowOffset: 5,
  );

  factory ResponsiveSizes.medium() => const ResponsiveSizes(
    iconLarge: 100,
    iconMedium: 24,
    iconSmall: 22,
    titleText: 52,
    headingText: 22,
    bodyText: 18,
    captionText: 14,
    buttonHeight: 68,
    toolbarButton: 48,
    paletteSize: 46,
    spacing: 14,
    shadowOffset: 6,
  );

  factory ResponsiveSizes.large() => const ResponsiveSizes(
    iconLarge: 120,
    iconMedium: 26,
    iconSmall: 24,
    titleText: 60,
    headingText: 26,
    bodyText: 20,
    captionText: 16,
    buttonHeight: 72,
    toolbarButton: 52,
    paletteSize: 50,
    spacing: 16,
    shadowOffset: 6,
  );
}

//text styles and decoration helpers
class AppStyles {
  AppStyles._();

  static const String fontFamily = 'XeDogma';

  static TextStyle title(double fontSize) => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle heading(double fontSize) => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle body(double fontSize) => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle button(double fontSize) => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: AppColors.background,
    letterSpacing: 2,
  );

  static TextStyle caption(double fontSize) => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 3,
  );

  // Voxel shadow decoration
  static BoxDecoration voxelBox({
    required Color color,
    required Color shadowColor,
    double shadowOffset = 5,
    Color? borderColor,
  }) => BoxDecoration(
    color: color,
    border: borderColor != null
        ? Border.all(color: borderColor, width: 2)
        : null,
    boxShadow: [
      BoxShadow(
        color: shadowColor,
        offset: Offset(0, shadowOffset),
        blurRadius: 0,
      ),
    ],
  );
}
