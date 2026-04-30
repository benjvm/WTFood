class IngredientNormalizer {
  IngredientNormalizer._();

  static final RegExp _quantityPattern = RegExp(
    r'(^|\s)\d+(?:[.,]\d+)?(?:/\d+(?:[.,]\d+)?)?(?=\s|$)',
    caseSensitive: false,
  );

  static final RegExp _inlineQuantityPattern = RegExp(r'\b\d+[a-z]+\b');
  static final RegExp _separatorPattern = RegExp(r'[(),;:+\-]');
  static final RegExp _whitespacePattern = RegExp(r'\s+');

  static const Set<String> _units = <String>{
    'kg',
    'kilo',
    'kilos',
    'g',
    'gr',
    'gramo',
    'gramos',
    'mg',
    'l',
    'lt',
    'litro',
    'litros',
    'ml',
    'cl',
    'taza',
    'tazas',
    'cucharada',
    'cucharadas',
    'cucharadita',
    'cucharaditas',
    'cdta',
    'cda',
    'vaso',
    'vasos',
    'unidad',
    'unidades',
    'pieza',
    'piezas',
    'punado',
    'punados',
    'rebanada',
    'rebanadas',
    'rodaja',
    'rodajas',
    'lata',
    'latas',
    'bote',
    'botes',
    'paquete',
    'paquetes',
    'sobre',
    'sobres',
    'diente',
    'dientes',
  };

  static const Set<String> _stopWords = <String>{
    'de',
    'del',
    'la',
    'las',
    'el',
    'los',
    'y',
    'o',
    'con',
    'sin',
    'para',
    'al',
  };

  static const Set<String> _descriptiveWords = <String>{
    'fresco',
    'fresca',
    'frescos',
    'frescas',
    'picado',
    'picada',
    'picados',
    'picadas',
    'triturado',
    'triturada',
    'triturados',
    'trituradas',
    'grande',
    'grandes',
    'mediano',
    'mediana',
    'medianos',
    'medianas',
    'pequeno',
    'pequena',
    'pequenos',
    'pequenas',
    'entero',
    'entera',
    'enteros',
    'enteras',
    'rallado',
    'rallada',
    'rallados',
    'ralladas',
    'cortado',
    'cortada',
    'cortados',
    'cortadas',
    'laminado',
    'laminada',
    'laminados',
    'laminadas',
    'troceado',
    'troceada',
    'troceados',
    'troceadas',
    'pelado',
    'pelada',
    'pelados',
    'peladas',
    'natural',
    'naturales',
  };

  static String normalizeIngredient(String input) {
    final cleanedInput = removeDiacritics(input).toLowerCase().trim();
    if (cleanedInput.isEmpty) {
      return '';
    }

    // First strip quantities and separators so token cleanup can stay simple.
    final noQuantities = cleanedInput
        .replaceAll(_separatorPattern, ' ')
        .replaceAll(_quantityPattern, ' ')
        .replaceAll(_inlineQuantityPattern, ' ');

    final normalizedTokens = noQuantities
        .split(_whitespacePattern)
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .where((token) => !_units.contains(token))
        .where((token) => !_stopWords.contains(token))
        .where((token) => !_descriptiveWords.contains(token))
        .map(_singularize)
        .where((token) => token.isNotEmpty)
        .toList();

    return normalizedTokens.join(' ').trim();
  }

  static List<String> normalizedTokens(String input) {
    final normalized = normalizeIngredient(input);
    if (normalized.isEmpty) {
      return const <String>[];
    }

    return normalized.split(_whitespacePattern);
  }

  static String removeDiacritics(String input) {
    const replacements = <String, String>{
      '\u00E1': 'a',
      '\u00E0': 'a',
      '\u00E4': 'a',
      '\u00E2': 'a',
      '\u00E3': 'a',
      '\u00E9': 'e',
      '\u00E8': 'e',
      '\u00EB': 'e',
      '\u00EA': 'e',
      '\u00ED': 'i',
      '\u00EC': 'i',
      '\u00EF': 'i',
      '\u00EE': 'i',
      '\u00F3': 'o',
      '\u00F2': 'o',
      '\u00F6': 'o',
      '\u00F4': 'o',
      '\u00F5': 'o',
      '\u00FA': 'u',
      '\u00F9': 'u',
      '\u00FC': 'u',
      '\u00FB': 'u',
      '\u00F1': 'n',
      '\u00E7': 'c',
    };

    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final character = String.fromCharCode(rune);
      buffer.write(replacements[character] ?? character);
    }
    return buffer.toString();
  }

  static String _singularize(String token) {
    if (token.length <= 3) {
      return token;
    }

    // Basic Spanish plural heuristics keep common ingredient names stable.
    if (token.endsWith('ces') && token.length > 4) {
      return '${token.substring(0, token.length - 3)}z';
    }

    if (token.endsWith('es') && token.length > 4) {
      const removeEsAfter = <String>{'l', 'r', 'n', 'd', 'j', 'z', 'c'};
      final previousLetter = token[token.length - 3];
      if (removeEsAfter.contains(previousLetter)) {
        return token.substring(0, token.length - 2);
      }

      return token.substring(0, token.length - 1);
    }

    if (token.endsWith('s') && !token.endsWith('ss')) {
      return token.substring(0, token.length - 1);
    }

    return token;
  }
}
