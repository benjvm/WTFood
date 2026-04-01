import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wtfood_app/services/auth_service.dart';
import 'package:wtfood_app/screens/auth/login_screen.dart';
import 'package:wtfood_app/screens/main_screen.dart';

/// Widget que controla el flujo de sesión.
/// Escucha el stream de autenticación de Firebase y decide
/// si mostrar el login o la app principal.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Mientras Firebase comprueba el estado → splash/loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
          );
        }

        // Usuario autenticado → pantalla principal
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }

        // Sin sesión → pantalla de login
        return const LoginScreen();
      },
    );
  }
}
