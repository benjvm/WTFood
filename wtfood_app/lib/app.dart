import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'screens/main_screen.dart';

class WTFoodApp extends StatelessWidget {
  const WTFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WTFood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}
