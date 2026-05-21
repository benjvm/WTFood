import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/theme.dart';
import 'package:wtfood_app/core/theme_controller.dart';
import 'package:wtfood_app/firebase_options.dart';
import 'package:wtfood_app/providers/fridge_provider.dart';
import 'package:wtfood_app/providers/user_provider.dart';
import 'package:wtfood_app/screens/auth/auth_wrapper.dart';
import 'package:wtfood_app/screens/fridge/fridge_screen.dart';
import 'package:wtfood_app/screens/scan/scan_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => FridgeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          routes: {
            '/scan': (_) => const ScanScreen(),
            '/fridge': (context) => Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(title: const Text('Mi nevera')),
              body: const FridgeScreen(),
            ),
          },
          home: const InitialAnimationGate(child: AuthWrapper()),
        ),
      ),
    );
  }
}

class InitialAnimationGate extends StatefulWidget {
  const InitialAnimationGate({required this.child, super.key});

  final Widget child;

  @override
  State<InitialAnimationGate> createState() => _InitialAnimationGateState();
}

class _InitialAnimationGateState extends State<InitialAnimationGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasFinished = false;
  bool _fallbackScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _scheduleFallback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleFallback() {
    if (_fallbackScheduled) return;
    _fallbackScheduled = true;

    Future<void>.delayed(const Duration(seconds: 7), () {
      if (!mounted || _hasFinished) return;
      _finishAnimation();
    });
  }

  void _finishAnimation() {
    if (_hasFinished || !mounted) return;
    setState(() {
      _hasFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasFinished) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SizedBox(
          width: 500,
          child: Lottie.asset(
            'assets/json/WTFood-animation.json',
            controller: _controller,
            fit: BoxFit.contain,
            repeat: false,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..forward().whenComplete(_finishAnimation);
            },
          ),
        ),
      ),
    );
  }
}
