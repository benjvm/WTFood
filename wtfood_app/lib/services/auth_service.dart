// auth_service.dart - Servicio de autenticación
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // REGISTRO de nuevo usuario
  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Actualizar displayName en Firebase Auth
    await credential.user?.updateDisplayName(name);

    // Guardar datos del usuario en Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'name': name,
      'email': email,
      'favoriteRecipes': const <String>[],
      'shoppingLists': const <Map<String, dynamic>>[],
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // INICIO DE SESIÓN
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Actualizar último login en Firestore
    await _firestore.collection('users').doc(credential.user!.uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // CERRAR SESIÓN
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
