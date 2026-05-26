import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/features/onboarding/onboarding.dart';
import 'package:wtfood_app/providers/user_provider.dart';
import 'package:wtfood_app/screens/auth/login_screen.dart';
import 'package:wtfood_app/screens/main_screen.dart';

/// Controla el flujo de sesion y sincroniza el estado global del usuario.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final OnboardingStorageService _onboardingStorageService =
      OnboardingStorageService();

  String? _lastLoadedUid;
  bool? _isOnboardingCompleted;
  int _mainScreenInitialTabIndex = MainScreen.homeTabIndex;

  Future<void> _loadOnboardingStatus(String uid) async {
    final isCompleted = await _onboardingStorageService.isOnboardingCompleted(
      uid: uid,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isOnboardingCompleted = isCompleted;
      if (isCompleted) {
        _mainScreenInitialTabIndex = MainScreen.homeTabIndex;
      }
    });
  }

  Future<void> _handleOnboardingCompleted() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isOnboardingCompleted = true;
      _mainScreenInitialTabIndex = MainScreen.scanTabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSplash();
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser != null) {
          if (_lastLoadedUid != firebaseUser.uid) {
            _lastLoadedUid = firebaseUser.uid;
            _isOnboardingCompleted = null;
            _mainScreenInitialTabIndex = MainScreen.homeTabIndex;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              userProvider.loadUser(firebaseUser.uid);
              _loadOnboardingStatus(firebaseUser.uid);
            });
          }

          return ListenableBuilder(
            listenable: userProvider,
            builder: (context, _) {
              if (userProvider.isLoading || _isOnboardingCompleted == null) {
                return _buildSplash();
              }

              if (_isOnboardingCompleted == false) {
                return OnboardingScreen(
                  storageService: _onboardingStorageService,
                  onCompleted: _handleOnboardingCompleted,
                );
              }

              return MainScreen(initialTabIndex: _mainScreenInitialTabIndex);
            },
          );
        }

        if (_lastLoadedUid != null) {
          _lastLoadedUid = null;
          _isOnboardingCompleted = null;
          _mainScreenInitialTabIndex = MainScreen.homeTabIndex;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.clearUser();
          });
        }

        return const LoginScreen();
      },
    );
  }

  Widget _buildSplash() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
