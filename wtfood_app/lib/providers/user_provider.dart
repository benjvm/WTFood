import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wtfood_app/models/recipe.dart';
import 'package:wtfood_app/models/shopping_list.dart';
import 'package:wtfood_app/models/user_model.dart';

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

  Future<bool> saveShoppingList(String uid, Recipe recipe) async {
    if (_user == null) {
      return false;
    }

    final previousUser = _user!;
    final existingIndex = previousUser.shoppingLists.indexWhere(
      (shoppingList) => shoppingList.recipeId == recipe.id,
    );
    final existingList =
        existingIndex >= 0 ? previousUser.shoppingLists[existingIndex] : null;
    final preservedItems = <String, ShoppingListItem>{
      for (final item in existingList?.items ?? const <ShoppingListItem>[])
        item.rawText.trim().toLowerCase(): item,
    };
    final rebuiltItems = recipe.ingredients.asMap().entries.map((entry) {
      final preservedItem = preservedItems[entry.value.trim().toLowerCase()];

      return ShoppingListItem(
        id: preservedItem?.id ?? '${recipe.id}_${entry.key}',
        rawText: entry.value,
        isChecked: preservedItem?.isChecked ?? false,
      );
    }).toList();
    final updatedList = ShoppingList.fromRecipe(
      recipe,
      items: rebuiltItems,
    );
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
}
