import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

@immutable
class AppThemePalette extends ThemeExtension<AppThemePalette> {
  const AppThemePalette({
    required this.brandPrimaryStrong,
    required this.brandSecondaryStrong,
    required this.shadowSoft,
    required this.shadowStrong,
    required this.authBackground,
    required this.authGreenAccent,
    required this.authOrangeAccent,
    required this.authHeading,
    required this.authBody,
    required this.authFieldIcon,
    required this.authFieldBorder,
    required this.overlayScrim,
    required this.imagePlaceholderStart,
    required this.imagePlaceholderEnd,
    required this.profileAvatarBackground,
  });

  final Color brandPrimaryStrong;
  final Color brandSecondaryStrong;
  final Color shadowSoft;
  final Color shadowStrong;
  final Color authBackground;
  final Color authGreenAccent;
  final Color authOrangeAccent;
  final Color authHeading;
  final Color authBody;
  final Color authFieldIcon;
  final Color authFieldBorder;
  final Color overlayScrim;
  final Color imagePlaceholderStart;
  final Color imagePlaceholderEnd;
  final Color profileAvatarBackground;

  @override
  AppThemePalette copyWith({
    Color? brandPrimaryStrong,
    Color? brandSecondaryStrong,
    Color? shadowSoft,
    Color? shadowStrong,
    Color? authBackground,
    Color? authGreenAccent,
    Color? authOrangeAccent,
    Color? authHeading,
    Color? authBody,
    Color? authFieldIcon,
    Color? authFieldBorder,
    Color? overlayScrim,
    Color? imagePlaceholderStart,
    Color? imagePlaceholderEnd,
    Color? profileAvatarBackground,
  }) {
    return AppThemePalette(
      brandPrimaryStrong: brandPrimaryStrong ?? this.brandPrimaryStrong,
      brandSecondaryStrong: brandSecondaryStrong ?? this.brandSecondaryStrong,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      shadowStrong: shadowStrong ?? this.shadowStrong,
      authBackground: authBackground ?? this.authBackground,
      authGreenAccent: authGreenAccent ?? this.authGreenAccent,
      authOrangeAccent: authOrangeAccent ?? this.authOrangeAccent,
      authHeading: authHeading ?? this.authHeading,
      authBody: authBody ?? this.authBody,
      authFieldIcon: authFieldIcon ?? this.authFieldIcon,
      authFieldBorder: authFieldBorder ?? this.authFieldBorder,
      overlayScrim: overlayScrim ?? this.overlayScrim,
      imagePlaceholderStart:
          imagePlaceholderStart ?? this.imagePlaceholderStart,
      imagePlaceholderEnd: imagePlaceholderEnd ?? this.imagePlaceholderEnd,
      profileAvatarBackground:
          profileAvatarBackground ?? this.profileAvatarBackground,
    );
  }

  @override
  AppThemePalette lerp(ThemeExtension<AppThemePalette>? other, double t) {
    if (other is! AppThemePalette) {
      return this;
    }

    return AppThemePalette(
      brandPrimaryStrong:
          Color.lerp(brandPrimaryStrong, other.brandPrimaryStrong, t)!,
      brandSecondaryStrong:
          Color.lerp(brandSecondaryStrong, other.brandSecondaryStrong, t)!,
      shadowSoft: Color.lerp(shadowSoft, other.shadowSoft, t)!,
      shadowStrong: Color.lerp(shadowStrong, other.shadowStrong, t)!,
      authBackground: Color.lerp(authBackground, other.authBackground, t)!,
      authGreenAccent: Color.lerp(authGreenAccent, other.authGreenAccent, t)!,
      authOrangeAccent:
          Color.lerp(authOrangeAccent, other.authOrangeAccent, t)!,
      authHeading: Color.lerp(authHeading, other.authHeading, t)!,
      authBody: Color.lerp(authBody, other.authBody, t)!,
      authFieldIcon: Color.lerp(authFieldIcon, other.authFieldIcon, t)!,
      authFieldBorder: Color.lerp(authFieldBorder, other.authFieldBorder, t)!,
      overlayScrim: Color.lerp(overlayScrim, other.overlayScrim, t)!,
      imagePlaceholderStart:
          Color.lerp(imagePlaceholderStart, other.imagePlaceholderStart, t)!,
      imagePlaceholderEnd:
          Color.lerp(imagePlaceholderEnd, other.imagePlaceholderEnd, t)!,
      profileAvatarBackground: Color.lerp(
        profileAvatarBackground,
        other.profileAvatarBackground,
        t,
      )!,
    );
  }
}

extension AppThemePaletteContext on BuildContext {
  AppThemePalette get appPalette =>
      Theme.of(this).extension<AppThemePalette>()!;
}

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(_lightPalette);

  static ThemeData get darkTheme => _buildTheme(_darkPalette);

  static ThemeData _buildTheme(_ThemePalette palette) {
    final colorScheme = palette.colorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      scaffoldBackgroundColor: colorScheme.surface,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[palette.extension],
      textTheme: _buildTextTheme(colorScheme),
      dividerColor: colorScheme.outlineVariant,
      splashColor: colorScheme.primary.withValues(alpha: 0.08),
      highlightColor: colorScheme.primary.withValues(alpha: 0.04),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerLowest,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: palette.extension.shadowSoft,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: colorScheme.primary,
          letterSpacing: -0.6,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 0,
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 22),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.primary,
        contentTextStyle: GoogleFonts.manrope(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        ),
        textStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.manrope(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadiusXl),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppConstants.borderRadiusMd),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.35),
          disabledForegroundColor:
              colorScheme.onPrimary.withValues(alpha: 0.82),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusSm + 4,
            ),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.35),
          disabledForegroundColor:
              colorScheme.onPrimary.withValues(alpha: 0.82),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          ),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: GoogleFonts.manrope(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        hintStyle: GoogleFonts.manrope(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.manrope(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.manrope(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: colorScheme.primary,
        suffixIconColor: colorScheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 1.8),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return colorScheme.surfaceContainerLow;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimaryContainer;
            }
            return colorScheme.onSurfaceVariant;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.manrope(fontWeight: FontWeight.w700),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
            ),
          ),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurface,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }
}

class _ThemePalette {
  const _ThemePalette({
    required this.brightness,
    required this.colorScheme,
    required this.extension,
  });

  final Brightness brightness;
  final ColorScheme colorScheme;
  final AppThemePalette extension;
}

const _ThemePalette _lightPalette = _ThemePalette(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: Color(0xFFDDF4E4),
    onPrimaryContainer: Color(0xFF185634),
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: Color(0xFFFFE7D4),
    onSecondaryContainer: Color(0xFF8D4B16),
    tertiary: Color(0xFF405058),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE3E8EA),
    onTertiaryContainer: Color(0xFF2E3B41),
    surface: Color(0xFFF6F7F3),
    onSurface: Color(0xFF243129),
    onSurfaceVariant: Color(0xFF7A847C),
    outline: Color(0xFFD5DDD5),
    outlineVariant: Color(0xFFE4EAE3),
    surfaceDim: Color(0xFFE8ECE5),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF0F3EE),
    surfaceContainerHigh: Color(0xFFF2F4F0),
    surfaceContainerLow: Color(0xFFF8F9F6),
    surfaceContainerHighest: Color(0xFFE5EAE3),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: Color(0xFFFBE4D7),
    onErrorContainer: Color(0xFF7A3214),
  ),
  extension: AppThemePalette(
    brandPrimaryStrong: Color(0xFF067437),
    brandSecondaryStrong: AppColors.secondary,
    shadowSoft: Color(0x140D2A18),
    shadowStrong: Color(0x260D2A18),
    authBackground: Color(0xFFFFFCF7),
    authGreenAccent: Color(0xFF66DB6A),
    authOrangeAccent: Color(0xFFF4CC58),
    authHeading: Color(0xFF1A1E17),
    authBody: Color(0xFF7E857B),
    authFieldIcon: Color(0xFF8EB292),
    authFieldBorder: Color(0xFFD7DDD2),
    overlayScrim: Color(0x73243129),
    imagePlaceholderStart: Color(0xFFEAF4EC),
    imagePlaceholderEnd: Color(0xFFD8E8DB),
    profileAvatarBackground: Color(0xFFE3E3E3),
  ),
);

const _ThemePalette _darkPalette = _ThemePalette(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF36C56E),
    onPrimary: Color(0xFF062514),
    primaryContainer: Color(0xFF15432A),
    onPrimaryContainer: Color(0xFFBFF2CF),
    secondary: Color(0xFFFFA14A),
    onSecondary: Color(0xFF3A1D06),
    secondaryContainer: Color(0xFF583110),
    onSecondaryContainer: Color(0xFFFFE2C8),
    tertiary: Color(0xFF9DB2B8),
    onTertiary: Color(0xFF162126),
    tertiaryContainer: Color(0xFF29363B),
    onTertiaryContainer: Color(0xFFD8E5E8),
    surface: Color(0xFF101613),
    onSurface: Color(0xFFE8F0E9),
    onSurfaceVariant: Color(0xFFAAB6AD),
    outline: Color(0xFF3B4940),
    outlineVariant: Color(0xFF2C3830),
    surfaceDim: Color(0xFF0B100D),
    surfaceBright: Color(0xFF2A342E),
    surfaceContainer: Color(0xFF18201B),
    surfaceContainerHigh: Color(0xFF222B26),
    surfaceContainerLow: Color(0xFF141B17),
    surfaceContainerHighest: Color(0xFF2B3530),
    surfaceContainerLowest: Color(0xFF131914),
    error: Color(0xFFFF8C5A),
    onError: Color(0xFF431200),
    errorContainer: Color(0xFF622918),
    onErrorContainer: Color(0xFFFFDBCF),
  ),
  extension: AppThemePalette(
    brandPrimaryStrong: Color(0xFF1FA45A),
    brandSecondaryStrong: Color(0xFFFFA14A),
    shadowSoft: Color(0x30000000),
    shadowStrong: Color(0x52000000),
    authBackground: Color(0xFF0E1411),
    authGreenAccent: Color(0xFF1D7B46),
    authOrangeAccent: Color(0xFFB86A28),
    authHeading: Color(0xFFE8F0E9),
    authBody: Color(0xFFAAB6AD),
    authFieldIcon: Color(0xFF7CCB9D),
    authFieldBorder: Color(0xFF324039),
    overlayScrim: Color(0x8F000000),
    imagePlaceholderStart: Color(0xFF1C2922),
    imagePlaceholderEnd: Color(0xFF15211B),
    profileAvatarBackground: Color(0xFF26322B),
  ),
);
