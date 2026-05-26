import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wtfood_app/features/onboarding/data/onboarding_storage_service.dart';
import 'package:wtfood_app/features/pantry_update/domain/pantry_update_settings.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OnboardingStorageService _onboardingStorageService =
      OnboardingStorageService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'name': name,
      'email': email,
      'favoriteRecipes': const <String>[],
      'shoppingLists': const <Map<String, dynamic>>[],
      'pantryUpdateSettings': const PantryUpdateSettings().toFirestore(),
      'onboardingState': _onboardingStorageService.createInitialState(),
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(credential.user!.uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No hay ninguna sesion activa.',
      );
    }

    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();
    final userData = snapshot.data();

    await userDoc.delete();

    try {
      await user.delete();
    } catch (error) {
      if (userData != null) {
        await userDoc.set(userData);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
