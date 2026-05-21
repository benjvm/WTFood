import 'package:flutter_test/flutter_test.dart';
import 'package:wtfood_app/core/utils/ingredient_normalizer.dart';

void main() {
  group('IngredientNormalizer', () {
    test('normalizes quantities, descriptors and plurals', () {
      expect(
        IngredientNormalizer.normalizeIngredient('2 tomates frescos'),
        'tomate',
      );
      expect(IngredientNormalizer.normalizeIngredient('huevos'), 'huevo');
      expect(IngredientNormalizer.normalizeIngredient('Leche entera'), 'leche');
      expect(
        IngredientNormalizer.normalizeIngredient('cebollas picadas'),
        'cebolla',
      );
    });

    test('removes accents and units', () {
      expect(
        IngredientNormalizer.normalizeIngredient('500g de azucar morena'),
        'azucar morena',
      );
      expect(
        IngredientNormalizer.normalizeIngredient('1 cucharada de limon'),
        'limon',
      );
    });
  });
}
