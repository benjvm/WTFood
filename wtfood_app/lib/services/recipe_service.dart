import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Devuelve un stream de recetas en tiempo real.
  ///
  /// [limit] limita el número de recetas cargadas de Firestore.
  /// Aumenta el valor o quita el `.limit()` si quieres cargar todas,
  /// pero paginar mejora notablemente el tiempo de carga inicial.
  Stream<List<Recipe>> getRecipes({int limit = 20}) {
    return _db
        .collection('recipes')
        .orderBy('title')
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs.map(Recipe.fromFirestore).toList(),
        );
  }
}