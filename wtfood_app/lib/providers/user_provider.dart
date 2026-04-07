// user_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wtfood_app/models/user_model.dart';

/// Estado global del usuario autenticado.
///
/// Responsabilidades:
///   - Cargar los datos del usuario desde Firestore una única vez al iniciar sesión.
///   - Exponer los datos a toda la app de forma reactiva.
///   - Limpiar el estado al cerrar sesión.
class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // ── Getters públicos ──────────────────────────────────────────────────────

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Verdadero cuando los datos del usuario ya están disponibles.
  bool get isReady => _user != null && !_isLoading;

  // ── Carga de datos ────────────────────────────────────────────────────────

  /// Carga los datos del usuario desde Firestore.
  /// Llamar solo una vez al detectar sesión activa en [AuthWrapper].
  Future<void> loadUser(String uid) async {
    if (_isLoading) return; // evita cargas duplicadas

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _db.collection('users').doc(uid).get();

      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      } else {
        // El documento no existe todavía (puede ocurrir justo tras el registro
        // si auth_service no lo creó aún). No es un error crítico.
        _error = 'Perfil de usuario no encontrado.';
      }
    } catch (e) {
      _error = 'Error al cargar el perfil: $e';
      debugPrint('[UserProvider] $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Limpieza ──────────────────────────────────────────────────────────────

  /// Limpia todos los datos del estado. Llamar al cerrar sesión.
  void clearUser() {
    _user = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // ── Actualización local ───────────────────────────────────────────────────

  /// Actualiza el estado local sin volver a leer Firestore.
  /// Útil tras editar el perfil del usuario.
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}
