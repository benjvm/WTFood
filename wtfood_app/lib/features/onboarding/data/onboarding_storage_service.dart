import 'package:shared_preferences/shared_preferences.dart';

enum ContextualTutorial { homeScanCta, scanCamera }

class OnboardingStorageService {
  OnboardingStorageService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _onboardingCompletedKey = 'wtfood.onboarding.completed';
  static const String _homeScanCtaTutorialKey =
      'wtfood.tutorial.home_scan_cta.shown';
  static const String _scanCameraTutorialKey =
      'wtfood.tutorial.scan_camera.shown';

  Future<bool> isOnboardingCompleted() async {
    return await _preferences.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> markOnboardingCompleted() async {
    await _preferences.setBool(_onboardingCompletedKey, true);
  }

  Future<bool> shouldShowTutorial(ContextualTutorial tutorial) async {
    return !(await _preferences.getBool(_tutorialKeyFor(tutorial)) ?? false);
  }

  Future<void> markTutorialShown(ContextualTutorial tutorial) async {
    await _preferences.setBool(_tutorialKeyFor(tutorial), true);
  }

  String _tutorialKeyFor(ContextualTutorial tutorial) {
    switch (tutorial) {
      case ContextualTutorial.homeScanCta:
        return _homeScanCtaTutorialKey;
      case ContextualTutorial.scanCamera:
        return _scanCameraTutorialKey;
    }
  }
}
