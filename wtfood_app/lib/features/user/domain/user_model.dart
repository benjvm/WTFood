// user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wtfood_app/features/pantry_update/domain/pantry_update_settings.dart';
import 'package:wtfood_app/features/shopping_list/domain/shopping_list.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final List<String> favoriteRecipes;
  final List<ShoppingList> shoppingLists;
  final PantryUpdateSettings pantryUpdateSettings;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.favoriteRecipes = const [],
    this.shoppingLists = const [],
    this.pantryUpdateSettings = const PantryUpdateSettings(),
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
      shoppingLists: ((data['shoppingLists'] as List<dynamic>?) ?? const [])
          .whereType<Map>()
          .map((item) => ShoppingList.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      pantryUpdateSettings: PantryUpdateSettings.fromMap(
        data['pantryUpdateSettings'] is Map
            ? Map<String, dynamic>.from(data['pantryUpdateSettings'] as Map)
            : null,
      ),
    );
  }

  /// Serializa el modelo para guardarlo en Firestore.
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'favoriteRecipes': favoriteRecipes,
    'shoppingLists': shoppingLists.map((list) => list.toMap()).toList(),
    'pantryUpdateSettings': pantryUpdateSettings.toFirestore(),
  };

  /// Copia inmutable con campos opcionales modificados.
  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    List<String>? favoriteRecipes,
    List<ShoppingList>? shoppingLists,
    PantryUpdateSettings? pantryUpdateSettings,
  }) => UserModel(
    uid: uid,
    name: name ?? this.name,
    email: email ?? this.email,
    photoUrl: photoUrl ?? this.photoUrl,
    createdAt: createdAt,
    favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
    shoppingLists: shoppingLists ?? this.shoppingLists,
    pantryUpdateSettings: pantryUpdateSettings ?? this.pantryUpdateSettings,
  );

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, email: $email)';
}
