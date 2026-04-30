import 'package:flutter/foundation.dart';
import 'package:wtfood_app/core/utils/ingredient_normalizer.dart';

class FridgeProvider extends ChangeNotifier {
  final List<String> _ingredients = <String>[];

  List<String> get ingredients => List.unmodifiable(_ingredients);

  int addIngredients(Iterable<String> ingredients) {
    final knownIngredients = _ingredients.map(_normalize).toSet();
    final addedIngredients = <String>[];

    for (final ingredient in ingredients) {
      final cleanedIngredient = ingredient.trim();
      if (cleanedIngredient.isEmpty) {
        continue;
      }

      final normalizedIngredient = _normalize(cleanedIngredient);
      if (knownIngredients.add(normalizedIngredient)) {
        addedIngredients.add(_formatIngredient(cleanedIngredient));
      }
    }

    if (addedIngredients.isEmpty) {
      return 0;
    }

    _ingredients.addAll(addedIngredients);
    notifyListeners();
    return addedIngredients.length;
  }

  void removeIngredient(String ingredient) {
    final ingredientIndex = _ingredients.indexWhere(
      (item) => _normalize(item) == _normalize(ingredient),
    );

    if (ingredientIndex == -1) {
      return;
    }

    _ingredients.removeAt(ingredientIndex);
    notifyListeners();
  }

  static String _normalize(String value) =>
      IngredientNormalizer.normalizeIngredient(value);

  static String _formatIngredient(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}
