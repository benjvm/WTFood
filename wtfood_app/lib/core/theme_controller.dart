import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static AppThemePreference fromStorageValue(String? value) {
    return AppThemePreference.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => AppThemePreference.system,
    );
  }
}

class ThemePreferenceStorage {
  ThemePreferenceStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _themePreferenceKey = 'wtfood.theme.preference';

  Future<AppThemePreference> loadPreference() async {
    final value = await _preferences.getString(_themePreferenceKey);
    return AppThemePreference.fromStorageValue(value);
  }

  Future<void> savePreference(AppThemePreference preference) {
    return _preferences.setString(_themePreferenceKey, preference.name);
  }
}

class ThemeController extends ChangeNotifier {
  ThemeController({
    AppThemePreference initialPreference = AppThemePreference.system,
    ThemePreferenceStorage? storage,
  }) : _preference = initialPreference,
       _storage = storage ?? ThemePreferenceStorage();

  AppThemePreference _preference;
  final ThemePreferenceStorage _storage;

  AppThemePreference get preference => _preference;
  ThemeMode get themeMode => _preference.themeMode;

  Future<void> setPreference(AppThemePreference value) async {
    if (_preference == value) {
      return;
    }

    _preference = value;
    notifyListeners();
    await _storage.savePreference(value);
  }
}
