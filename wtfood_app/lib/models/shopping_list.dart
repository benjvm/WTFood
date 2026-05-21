import 'package:wtfood_app/models/recipe.dart';

class ShoppingListItem {
  const ShoppingListItem({
    required this.id,
    required this.rawText,
    this.isChecked = false,
    this.isFromPantry = false,
    this.sourceTag,
  });

  final String id;
  final String rawText;
  final bool isChecked;
  final bool isFromPantry;
  final String? sourceTag;

  factory ShoppingListItem.fromMap(Map<String, dynamic> data) {
    return ShoppingListItem(
      id: data['id'] as String? ?? '',
      rawText: data['rawText'] as String? ?? '',
      isChecked: data['isChecked'] as bool? ?? false,
      isFromPantry: data['isFromPantry'] as bool? ?? false,
      sourceTag: data['sourceTag'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'rawText': rawText,
    'isChecked': isChecked,
    'isFromPantry': isFromPantry,
    'sourceTag': sourceTag,
  };

  ShoppingListItem copyWith({
    String? id,
    String? rawText,
    bool? isChecked,
    bool? isFromPantry,
    String? sourceTag,
    bool clearSourceTag = false,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      isChecked: isChecked ?? this.isChecked,
      isFromPantry: isFromPantry ?? this.isFromPantry,
      sourceTag: clearSourceTag ? null : sourceTag ?? this.sourceTag,
    );
  }
}

class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.recipeId,
    required this.title,
    required this.photoUrl,
    required this.category,
    required this.savedAt,
    required this.items,
  });

  final String id;
  final String recipeId;
  final String title;
  final String photoUrl;
  final String category;
  final DateTime savedAt;
  final List<ShoppingListItem> items;

  int get pendingItemsCount => items.where((item) => !item.isChecked).length;

  bool get hasPhoto => photoUrl.trim().isNotEmpty;

  factory ShoppingList.fromRecipe(
    Recipe recipe, {
    List<ShoppingListItem> items = const <ShoppingListItem>[],
  }) {
    final resolvedItems = items.isNotEmpty
        ? items
        : recipe.ingredients
              .asMap()
              .entries
              .map(
                (entry) => ShoppingListItem(
                  id: '${recipe.id}_${entry.key}',
                  rawText: entry.value,
                ),
              )
              .toList();

    return ShoppingList(
      id: recipe.id,
      recipeId: recipe.id,
      title: recipe.title,
      photoUrl: recipe.photoUrl,
      category: recipe.category,
      savedAt: DateTime.now(),
      items: resolvedItems,
    );
  }

  factory ShoppingList.fromMap(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final mappedItems = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    ShoppingListItem.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <ShoppingListItem>[];

    return ShoppingList(
      id: data['id'] as String? ?? '',
      recipeId: data['recipeId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      category: data['category'] as String? ?? '',
      savedAt:
          DateTime.tryParse(data['savedAt'] as String? ?? '') ?? DateTime.now(),
      items: mappedItems,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'recipeId': recipeId,
    'title': title,
    'photoUrl': photoUrl,
    'category': category,
    'savedAt': savedAt.toIso8601String(),
    'items': items.map((item) => item.toMap()).toList(),
  };

  ShoppingList copyWith({
    String? id,
    String? recipeId,
    String? title,
    String? photoUrl,
    String? category,
    DateTime? savedAt,
    List<ShoppingListItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      title: title ?? this.title,
      photoUrl: photoUrl ?? this.photoUrl,
      category: category ?? this.category,
      savedAt: savedAt ?? this.savedAt,
      items: items ?? this.items,
    );
  }
}
