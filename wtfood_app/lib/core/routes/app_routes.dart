import 'package:flutter/material.dart';
import 'package:wtfood_app/features/fridge/presentation/screens/fridge_screen.dart';
import 'package:wtfood_app/features/scan/presentation/screens/scan_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const scan = '/scan';
  static const fridge = '/fridge';

  static Map<String, WidgetBuilder> get routes => {
    scan: (_) => const ScanScreen(),
    fridge: (context) => Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Mi nevera')),
      body: const FridgeScreen(),
    ),
  };
}
