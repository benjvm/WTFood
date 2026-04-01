import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wtfood_app/firebase_options.dart';
import 'package:wtfood_app/screens/auth/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), // 👈 Controla sesión automáticamente
    );
  }
}
