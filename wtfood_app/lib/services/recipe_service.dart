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

  Stream<List<Recipe>> getRecipesByCategory(
    String category, {
    int limit = 100,
  }) {
    final normalizedCategory = category.trim().toLowerCase();

    return getRecipes(limit: limit).map(
      (recipes) => recipes
          .where(
            (recipe) => recipe.category.trim().toLowerCase() == normalizedCategory,
          )
          .toList(),
    );
  }

  Stream<List<Recipe>> getFavoriteRecipes(
    List<String> favoriteRecipeIds, {
    int limit = 100,
  }) {
    if (favoriteRecipeIds.isEmpty) {
      return Stream<List<Recipe>>.value(const []);
    }

    final favoriteIdSet = favoriteRecipeIds.toSet();

    return getRecipes(limit: limit).map((recipes) {
      final filteredRecipes = recipes
          .where((recipe) => favoriteIdSet.contains(recipe.id))
          .toList();

      filteredRecipes.sort(
        (a, b) => favoriteRecipeIds
            .indexOf(a.id)
            .compareTo(favoriteRecipeIds.indexOf(b.id)),
      );

      return filteredRecipes;
    });
  }
}
