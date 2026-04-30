import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/models/shopping_list.dart';
import 'package:wtfood_app/providers/fridge_provider.dart';
import 'package:wtfood_app/providers/user_provider.dart';
import 'package:wtfood_app/screens/list/shopping_list_detail_screen.dart';

class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key, required this.onGoToRecipes});

  final VoidCallback onGoToRecipes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shoppingLists = context.watch<UserProvider>().shoppingLists;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: shoppingLists.isEmpty
            ? _EmptyShoppingListState(onGoToRecipes: onGoToRecipes)
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingLg,
                  AppConstants.paddingLg,
                  AppConstants.paddingLg,
                  160,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TU COCINA CURADA',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.secondary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Listas de compras',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Organiza los ingredientes que te faltan para cocinar tus proximas recetas.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingXl),
                        ...shoppingLists.map(
                          (shoppingList) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _ShoppingListCard(
                              shoppingList: shoppingList,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ShoppingListCard extends StatelessWidget {
  const _ShoppingListCard({required this.shoppingList});

  final ShoppingList shoppingList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userProvider = context.read<UserProvider>();
    final uid = userProvider.user?.uid ?? '';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShoppingListCardImage(shoppingList: shoppingList),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingLg,
                AppConstants.paddingLg,
                AppConstants.paddingLg,
                AppConstants.paddingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'LISTA DE COMPRA',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.onErrorContainer,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.restaurant_menu_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    shoppingList.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_basket_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${shoppingList.pendingItemsCount} articulo${shoppingList.pendingItemsCount == 1 ? '' : 's'} restante${shoppingList.pendingItemsCount == 1 ? '' : 's'}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingLg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (uid.isNotEmpty) {
                          await userProvider.refreshShoppingListAvailability(
                            uid,
                            shoppingList.id,
                            pantryItems: context
                                .read<FridgeProvider>()
                                .ingredients,
                          );
                        }

                        if (!context.mounted) {
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShoppingListDetailScreen(
                              listId: shoppingList.id,
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMd,
                          ),
                        ),
                      ),
                      child: const Text('Ver lista'),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMd),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: uid.isEmpty
                          ? null
                          : () async {
                              final shouldDelete =
                                  await _confirmDeleteShoppingList(context);

                              if (shouldDelete != true || !context.mounted) {
                                return;
                              }

                              final didDelete = await userProvider
                                  .deleteShoppingList(uid, shoppingList.id);

                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    didDelete
                                        ? 'Lista de compra eliminada.'
                                        : 'No se pudo eliminar la lista.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Eliminar lista de compra'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.24),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMd,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _confirmDeleteShoppingList(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Eliminar lista'),
      content: const Text(
        'Esta lista de compra se eliminara de tu cuenta. Quieres continuar?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.onError,
          ),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}

class _ShoppingListCardImage extends StatelessWidget {
  const _ShoppingListCardImage({required this.shoppingList});

  final ShoppingList shoppingList;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!shoppingList.hasPhoto) {
      return Container(
        height: 250,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFA14A), Color(0xFFDB5A2A)],
          ),
        ),
        child: Icon(
          Icons.shopping_bag_rounded,
          size: 72,
          color: Colors.white.withValues(alpha: 0.75),
        ),
      );
    }

    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Image.network(
        shoppingList.photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: colorScheme.surfaceContainerHigh,
          alignment: Alignment.center,
          child: Icon(
            Icons.restaurant_rounded,
            size: 72,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _EmptyShoppingListState extends StatelessWidget {
  const _EmptyShoppingListState({required this.onGoToRecipes});

  final VoidCallback onGoToRecipes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingLg,
          AppConstants.paddingLg,
          AppConstants.paddingLg,
          160,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingXl),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.playlist_add_check_circle_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLg),
                Text(
                  'Aun no tienes lista de compra',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Guarda los ingredientes desde una receta y apareceran aqui listos para revisarlos.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onGoToRecipes,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMd,
                        ),
                      ),
                    ),
                    child: const Text('Ir a recetas'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
