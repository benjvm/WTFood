import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ContextualTutorial { homeScanCta, scanCamera }

class OnboardingStorageService {
  OnboardingStorageService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _onboardingStateField = 'onboardingState';
  static const String _onboardingCompletedField = 'onboardingCompleted';
  static const String _homeScanCtaTutorialField = 'homeScanCtaShown';
  static const String _scanCameraTutorialField = 'scanCameraShown';

  Map<String, dynamic> createInitialState() => {
    _onboardingCompletedField: false,
    _homeScanCtaTutorialField: false,
    _scanCameraTutorialField: false,
  };

  Future<bool> isOnboardingCompleted({String? uid}) async {
    final state = await _readState(uid: uid);
    if (state == null) {
      return !_isFirstSessionForCurrentUser(uid: uid);
    }

    return state[_onboardingCompletedField] as bool? ?? true;
  }

  Future<void> markOnboardingCompleted({String? uid}) async {
    await _updateState(uid: uid, updates: {_onboardingCompletedField: true});
  }

  Future<bool> shouldShowTutorial(
    ContextualTutorial tutorial, {
    String? uid,
  }) async {
    final state = await _readState(uid: uid);
    if (state == null) {
      return _isFirstSessionForCurrentUser(uid: uid);
    }

    return !(state[_tutorialFieldFor(tutorial)] as bool? ?? true);
  }

  Future<void> markTutorialShown(
    ContextualTutorial tutorial, {
    String? uid,
  }) async {
    await _updateState(uid: uid, updates: {_tutorialFieldFor(tutorial): true});
  }

  String _tutorialFieldFor(ContextualTutorial tutorial) {
    switch (tutorial) {
      case ContextualTutorial.homeScanCta:
        return _homeScanCtaTutorialField;
      case ContextualTutorial.scanCamera:
        return _scanCameraTutorialField;
    }
  }

  Future<Map<String, dynamic>?> _readState({String? uid}) async {
    final resolvedUid = _resolveUid(uid);
    if (resolvedUid == null) {
      return null;
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(resolvedUid)
        .get();
    final data = snapshot.data();
    final state = data?[_onboardingStateField];

    if (state is Map<String, dynamic>) {
      return state;
    }

    if (state is Map) {
      return Map<String, dynamic>.from(state);
    }

    return null;
  }

  Future<void> _updateState({
    required Map<String, dynamic> updates,
    String? uid,
  }) async {
    final resolvedUid = _resolveUid(uid);
    if (resolvedUid == null) {
      return;
    }

    final serializedUpdates = <String, dynamic>{};
    for (final entry in updates.entries) {
      serializedUpdates['$_onboardingStateField.${entry.key}'] = entry.value;
    }

    await _firestore
        .collection('users')
        .doc(resolvedUid)
        .set(serializedUpdates, SetOptions(merge: true));
  }

  String? _resolveUid(String? uid) => uid ?? _auth.currentUser?.uid;

  bool _isFirstSessionForCurrentUser({String? uid}) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return false;
    }

    final resolvedUid = _resolveUid(uid);
    if (resolvedUid != currentUser.uid) {
      return false;
    }

    final createdAt = currentUser.metadata.creationTime;
    final lastSignInAt = currentUser.metadata.lastSignInTime;
    if (createdAt == null || lastSignInAt == null) {
      return false;
    }

    return createdAt.difference(lastSignInAt).abs() <
        const Duration(minutes: 1);
  }
}
