// auth_wrapper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/providers/user_provider.dart';
import 'package:wtfood_app/screens/auth/login_screen.dart';
import 'package:wtfood_app/screens/main_screen.dart';

/// Controla el flujo de sesión y sincroniza el estado global del usuario.
///
/// Flujo:
///   1. Firebase emite un [User] → se dispara [UserProvider.loadUser].
///   2. Firebase emite null       → se dispara [UserProvider.clearUser].
///   3. Mientras se cargan los datos se muestra un splash de carga.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  /// UID del último usuario procesado para evitar cargas repetidas
  /// si el stream reemite el mismo usuario (ej.: token refresh).
  String? _lastLoadedUid;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ── Estado de espera inicial ──────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSplash();
        }

        final firebaseUser = snapshot.data;

        // ── Usuario autenticado ───────────────────────────────────────────
        if (firebaseUser != null) {
          // Solo cargamos si es un UID distinto al último procesado.
          if (_lastLoadedUid != firebaseUser.uid) {
            _lastLoadedUid = firebaseUser.uid;
            // Lanzamos la carga sin await para no bloquear el build.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              userProvider.loadUser(firebaseUser.uid);
            });
          }

          // Esperamos a que los datos estén disponibles antes de mostrar la app.
          return ListenableBuilder(
            listenable: userProvider,
            builder: (context, _) {
              if (userProvider.isLoading) return _buildSplash();
              return const MainScreen();
            },
          );
        }

        // ── Sin sesión: limpieza y pantalla de login ──────────────────────
        if (_lastLoadedUid != null) {
          _lastLoadedUid = null;
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
      body: Center(
        child: CircularProgressIndicator(color: Colors.deepOrange),
      ),
    );
  }
}
