import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color primary = Color(0xFF006B0A);
  static const Color primaryContainer = Color(0xFF59EE50);
  static const Color onPrimaryContainer = Color(0xFF005406);
  
  static const Color secondary = Color(0xFF006666);
  static const Color secondaryContainer = Color(0xFF8DEDEC);
  static const Color onSecondaryContainer = Color(0xFF005858);

  static const Color tertiary = Color(0xFF00666D);
  static const Color tertiaryContainer = Color(0xFF19EDFD);

  // Surface Colors
  static const Color surface = Color(0xFFDEFFE0);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFCCFDD1);
  static const Color surfaceContainerHigh = Color(0xFFB7F0BF);
  // Same value as Stitch "surface-container-highest".
  static const Color surfaceContainerHighest = Color(0xFFAEEBB8);
  static const Color surfaceVariant = surfaceContainerHighest;

  // Stitch "outline" tokens.
  static const Color outline = Color(0xFF58805F);
  static const Color outlineVariant = Color(0xFF8DB793);
  
  static const Color onSurface = Color(0xFF0E361B);
  static const Color onSurfaceVariant = Color(0xFF3D6445);
  
  // Custom Status
  static const Color error = Color(0xFFB02500);
}

class AppConstants {
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 16.0;
  static const double borderRadiusLg = 24.0;
  static const double borderRadiusXl = 32.0;

  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;
}
