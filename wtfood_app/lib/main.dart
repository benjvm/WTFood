import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wtfood_app/app.dart';
import 'package:wtfood_app/core/theme.dart';
import 'package:wtfood_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final themePreferenceStorage = ThemePreferenceStorage();
  final initialThemePreference = await themePreferenceStorage.loadPreference();

  runApp(
    MainApp(
      initialThemePreference: initialThemePreference,
      themePreferenceStorage: themePreferenceStorage,
    ),
  );
}
