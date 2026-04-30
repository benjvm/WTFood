import 'package:wtfood_app/core/utils/ingredient_normalizer.dart';

class IngredientMatcher {
  const IngredientMatcher._();

  static bool isIngredientAvailable({
    required String recipeIngredient,
    required List<String> pantryItems,
  }) {
    final normalizedRecipe = IngredientNormalizer.normalizeIngredient(
      recipeIngredient,
    );
    if (normalizedRecipe.isEmpty) {
      return false;
    }

    final recipeTokens = IngredientNormalizer.normalizedTokens(
      recipeIngredient,
    );
    final normalizedPantryItems = pantryItems
        .map(IngredientNormalizer.normalizeIngredient)
        .where((item) => item.isNotEmpty)
        .toSet();

    for (final pantryItem in normalizedPantryItems) {
      // Allow exact matches and broader variants like "tomate" vs "tomate cherry".
      if (pantryItem == normalizedRecipe ||
          pantryItem.contains(normalizedRecipe) ||
          normalizedRecipe.contains(pantryItem)) {
        return true;
      }

      final pantryTokens = pantryItem.split(' ');
      final sharedTokens = pantryTokens
          .where((token) => recipeTokens.contains(token))
          .length;

      if (sharedTokens > 0 &&
          (sharedTokens == pantryTokens.length ||
              sharedTokens == recipeTokens.length)) {
        return true;
      }
    }

    return false;
  }
}
