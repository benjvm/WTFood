import 'package:flutter/material.dart';

enum AppThemePreference {
  system,
  light,
  dark;

  ThemeMode get themeMode {
    switch (this) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}

class ThemeController extends ChangeNotifier {
  ThemeController({
    AppThemePreference initialPreference = AppThemePreference.system,
  }) : _preference = initialPreference;

  AppThemePreference _preference;

  AppThemePreference get preference => _preference;
  ThemeMode get themeMode => _preference.themeMode;

  void setPreference(AppThemePreference value) {
    if (_preference == value) {
      return;
    }

    _preference = value;
    notifyListeners();
  }
}
