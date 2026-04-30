import 'package:flutter_test/flutter_test.dart';
import 'package:wtfood_app/features/shopping_list/domain/ingredient_matcher.dart';

void main() {
  group('IngredientMatcher', () {
    test('matches normalized equivalents', () {
      expect(
        IngredientMatcher.isIngredientAvailable(
          recipeIngredient: '2 tomates frescos',
          pantryItems: const <String>['Tomate'],
        ),
        isTrue,
      );
      expect(
        IngredientMatcher.isIngredientAvailable(
          recipeIngredient: 'huevos',
          pantryItems: const <String>['Huevos'],
        ),
        isTrue,
      );
      expect(
        IngredientMatcher.isIngredientAvailable(
          recipeIngredient: 'Leche entera',
          pantryItems: const <String>['leche'],
        ),
        isTrue,
      );
      expect(
        IngredientMatcher.isIngredientAvailable(
          recipeIngredient: 'cebollas picadas',
          pantryItems: const <String>['cebolla'],
        ),
        isTrue,
      );
    });

    test('supports partial containment for variants', () {
      expect(
        IngredientMatcher.isIngredientAvailable(
          recipeIngredient: 'tomate cherry',
          pantryItems: const <String>['tomate'],
        ),
        isTrue,
      );
      expect(
        IngredientMatcher.isIngredientAvailable(
          recipeIngredient: 'queso rallado',
          pantryItems: const <String>['Tomates', 'Huevos'],
        ),
        isFalse,
      );
    });
  });
}
