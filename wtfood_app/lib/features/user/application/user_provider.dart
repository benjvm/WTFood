import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wtfood_app/core/utils/ingredient_normalizer.dart';
import 'package:wtfood_app/features/pantry_update/domain/pantry_update_schedule.dart';
import 'package:wtfood_app/features/pantry_update/domain/pantry_update_settings.dart';
import 'package:wtfood_app/features/shopping_list/domain/ingredient_matcher.dart';
import 'package:wtfood_app/features/recipes/domain/recipe.dart';
import 'package:wtfood_app/features/shopping_list/domain/shopping_list.dart';
import 'package:wtfood_app/features/user/domain/user_model.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ShoppingList> get shoppingLists => _user?.shoppingLists ?? const [];

  bool get isReady => _user != null && !_isLoading;

  Future<void> loadUser(String uid) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _db.collection('users').doc(uid).get();

      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      } else {
        _error = 'Perfil de usuario no encontrado.';
      }
    } catch (e) {
      _error = 'Error al cargar el perfil: $e';
      debugPrint('[UserProvider] $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  Future<bool> updatePantryUpdateSchedule(
    String uid,
    PantryUpdateSchedule schedule,
  ) async {
    if (_user == null) {
      return false;
    }

    final previousUser = _user!;
    final updatedSettings = previousUser.pantryUpdateSettings.copyWith(
      schedule: schedule,
    );

    updateUser(previousUser.copyWith(pantryUpdateSettings: updatedSettings));

    try {
      await _savePantryUpdateSettings(uid, updatedSettings);
      return true;
    } catch (e) {
      updateUser(previousUser);
      debugPrint('[UserProvider] Error al guardar recordatorio: $e');
      return false;
    }
  }

  Future<void> registerPantryScan(String uid) async {
    if (_user == null) {
      return;
    }

    final previousUser = _user!;
    final updatedSettings = previousUser.pantryUpdateSettings.copyWith(
      lastScanAt: DateTime.now(),
      clearLastPromptAt: true,
    );

    updateUser(previousUser.copyWith(pantryUpdateSettings: updatedSettings));

    try {
      await _savePantryUpdateSettings(uid, updatedSettings);
    } catch (e) {
      updateUser(previousUser);
      debugPrint('[UserProvider] Error al registrar escaneo: $e');
    }
  }

  Future<void> markPantryUpdatePromptShown(String uid) async {
    if (_user == null) {
      return;
    }

    final previousUser = _user!;
    final updatedSettings = previousUser.pantryUpdateSettings.copyWith(
      lastPromptAt: DateTime.now(),
    );

    updateUser(previousUser.copyWith(pantryUpdateSettings: updatedSettings));

    try {
      await _savePantryUpdateSettings(uid, updatedSettings);
    } catch (e) {
      updateUser(previousUser);
      debugPrint('[UserProvider] Error al registrar aviso de despensa: $e');
    }
  }

  Future<void> toggleFavoriteRecipe(String uid, String recipeId) async {
    if (_user == null) {
      return;
    }

    final previousUser = _user!;
    final isFav = previousUser.favoriteRecipes.contains(recipeId);
    final updatedList = isFav
        ? previousUser.favoriteRecipes.where((id) => id != recipeId).toList()
        : [...previousUser.favoriteRecipes, recipeId];

    updateUser(previousUser.copyWith(favoriteRecipes: updatedList));

    try {
      await _db.collection('users').doc(uid).update({
        'favoriteRecipes': updatedList,
      });
    } catch (e) {
      updateUser(previousUser);
      debugPrint('[UserProvider] Error al actualizar favoritos: $e');
    }
  }

  bool isFavorite(String recipeId) =>
      _user?.favoriteRecipes.contains(recipeId) ?? false;

  bool isShoppingListSaved(String recipeId) =>
      shoppingLists.any((shoppingList) => shoppingList.recipeId == recipeId);

  ShoppingList? shoppingListById(String listId) {
    for (final shoppingList in shoppingLists) {
      if (shoppingList.id == listId) {
        return shoppingList;
      }
    }

    return null;
  }

  Future<bool> refreshShoppingListAvailability(
    String uid,
    String listId, {
    List<String> pantryItems = const <String>[],
  }) async {
    if (_user == null) {
      return false;
    }

    final previousUser = _user!;
    final updatedLists = previousUser.shoppingLists.map((shoppingList) {
      if (shoppingList.id != listId) {
        return shoppingList;
      }

      return shoppingList.copyWith(
        items: _syncItemsWithPantry(shoppingList.items, pantryItems),
      );
    }).toList();

    updateUser(previousUser.copyWith(shoppingLists: updatedLists));

    try {
      await _saveShoppingLists(uid, updatedLists);
      return true;
    } catch (e) {
      updateUser(previousUser);
      debugPrint('[UserProvider] Error al refrescar disponibilidad: $e');
      return false;
    }
  }

  Future<bool> saveShoppingList(
    String uid,
    Recipe recipe, {
    List<String> pantryItems = const <String>[],
  }) async {
    if (_user == null) {
      return false;
    }

    final previousUser = _user!;
    final existingIndex = previousUser.shoppingLists.indexWhere(
      (shoppingList) => shoppingList.recipeId == recipe.id,
    );
    final existingList = existingIndex >= 0
        ? previousUser.shoppingLists[existingIndex]
        : null;
    final preservedItems = <String, ShoppingListItem>{
      for (final item in existingList?.items ?? const <ShoppingListItem>[])
        IngredientNormalizer.normalizeIngredient(item.rawText): item,
    };
    final rebuiltItems = recipe.ingredients.asMap().entries.map((entry) {
      final normalizedIngredient = IngredientNormalizer.normalizeIngredient(
        entry.value,
      );
      final preservedItem = preservedItems[normalizedIngredient];

      return _mergeShoppingListItemWithPantry(
        recipeIngredient: entry.value,
        pantryItems: pantryItems,
        itemId: preservedItem?.id ?? '${recipe.id}_${entry.key}',
        previousItem: preservedItem,
      );
    }).toList();
    final updatedList = ShoppingList.fromRecipe(recipe, items: rebuiltItems);
    final updatedLists = [
      updatedList,
      ...previousUser.shoppingLists.where(
        (shoppingList) => shoppingList.recipeId != recipe.id,
      ),
    ];

    updateUser(previousUser.copyWith(shoppingLists: updatedLists));

    try {
      await _saveShoppingLists(uid, updatedLists);
      return true;
    } catch (e) {
      updateUser(previousUser);
      debugPrint('[UserProvider] Error al guardar la lista de compra: $e');
      return false;
    }
  }

  Future<void> toggleShoppingListItem(
    String uid,
    String listId,
    String itemId,
  ) async {
    if (_user == null) {
      return;
    }

    final previousUser = _user!;
    final updatedLists = previousUser.shoppingLists.map((shoppingList) {
      if (shoppingList.id != listId) {
        return shoppingList;
      }

      final updatedItems = shoppingList.items.map((item) {
        if (item.id != itemId) {
          return item;
        }

        return item.copyWith(isChecked: !item.isChecked);
      }).toList();

      return shoppingList.copyWith(items: updatedItems);
    }).toList();

    updateUser(previousUser.copyWith(shoppingLists: updatedLists));

    try {
      await _saveShoppingLists(uid, updatedLists);
    } catch (e) {
      updateUser(previousUser);
      debugPrint('[UserProvider] Error al actualizar la lista: $e');
    }
  }

  Future<bool> deleteShoppingList(String uid, String listId) async {
    if (_user == null) {
      return false;
    }

    final previousUser = _user!;
    final updatedLists = previousUser.shoppingLists
        .where((shoppingList) => shoppingList.id != listId)
        .toList();

    updateUser(previousUser.copyWith(shoppingLists: updatedLists));

    try {
      await _saveShoppingLists(uid, updatedLists);
      return true;
    } catch (e) {
      updateUser(previousUser);
      debugPrint('[UserProvider] Error al eliminar la lista: $e');
      return false;
    }
  }

  Future<void> _saveShoppingLists(
    String uid,
    List<ShoppingList> shoppingLists,
  ) {
    return _db.collection('users').doc(uid).update({
      'shoppingLists': shoppingLists.map((list) => list.toMap()).toList(),
    });
  }

  Future<void> _savePantryUpdateSettings(
    String uid,
    PantryUpdateSettings settings,
  ) {
    return _db.collection('users').doc(uid).update({
      'pantryUpdateSettings': settings.toFirestore(),
    });
  }

  List<ShoppingListItem> _syncItemsWithPantry(
    List<ShoppingListItem> items,
    List<String> pantryItems,
  ) {
    return items
        .map(
          (item) => _mergeShoppingListItemWithPantry(
            recipeIngredient: item.rawText,
            pantryItems: pantryItems,
            itemId: item.id,
            previousItem: item,
          ),
        )
        .toList();
  }

  ShoppingListItem _mergeShoppingListItemWithPantry({
    required String recipeIngredient,
    required List<String> pantryItems,
    required String itemId,
    ShoppingListItem? previousItem,
  }) {
    final isFromPantry = IngredientMatcher.isIngredientAvailable(
      recipeIngredient: recipeIngredient,
      pantryItems: pantryItems,
    );
    final sourceTag = isFromPantry ? 'Ya lo tengo' : null;
    final wasCheckedManually =
        (previousItem?.isChecked ?? false) &&
        !(previousItem?.isFromPantry ?? false);

    return ShoppingListItem(
      id: itemId,
      rawText: recipeIngredient,
      isChecked: isFromPantry || wasCheckedManually,
      isFromPantry: isFromPantry,
      sourceTag: sourceTag,
    );
  }
}
