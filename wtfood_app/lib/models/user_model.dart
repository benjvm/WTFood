// user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final List<String> favoriteRecipes;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.favoriteRecipes = const [],
  });

  /// Construye un UserModel desde un documento de Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      favoriteRecipes: List<String>.from(data['favoriteRecipes'] ?? []),
    );
  }

  /// Serializa el modelo para guardarlo en Firestore.
  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  /// Copia inmutable con campos opcionales modificados.
  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    List<String>? favoriteRecipes,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
        favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      );

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, email: $email)';
}
