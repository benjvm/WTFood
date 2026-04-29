import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/core/theme.dart';
import 'package:wtfood_app/firebase_options.dart';
import 'package:wtfood_app/providers/fridge_provider.dart';
import 'package:wtfood_app/providers/user_provider.dart';
import 'package:wtfood_app/screens/auth/auth_wrapper.dart';
import 'package:wtfood_app/screens/fridge/fridge_screen.dart';
import 'package:wtfood_app/screens/scan/scan_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FridgeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routes: {
          '/scan': (_) => const ScanScreen(),
          '/fridge': (_) => Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(title: const Text('Mi nevera')),
                body: const FridgeScreen(),
              ),
        },
        home: const AuthWrapper(),
      ),
    );
  }
}
