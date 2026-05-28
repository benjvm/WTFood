import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/routes/app_routes.dart';
import 'package:wtfood_app/core/theme.dart';
import 'package:wtfood_app/core/widgets/initial_animation_gate.dart';
import 'package:wtfood_app/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:wtfood_app/features/fridge/application/fridge_provider.dart';
import 'package:wtfood_app/features/user/application/user_provider.dart';

class MainApp extends StatelessWidget {
  const MainApp({
    required this.initialThemePreference,
    required this.themePreferenceStorage,
    super.key,
  });

  final AppThemePreference initialThemePreference;
  final ThemePreferenceStorage themePreferenceStorage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeController(
            initialPreference: initialThemePreference,
            storage: themePreferenceStorage,
          ),
        ),
        ChangeNotifierProvider(create: (_) => FridgeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          routes: AppRoutes.routes,
          home: const InitialAnimationGate(child: AuthWrapper()),
        ),
      ),
    );
  }
}
