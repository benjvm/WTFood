import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/features/shopping_list/domain/shopping_list.dart';
import 'package:wtfood_app/features/user/application/user_provider.dart';

part '../widgets/shopping_list_detail_widgets.dart';

class ShoppingListDetailScreen extends StatelessWidget {
  const ShoppingListDetailScreen({super.key, required this.listId});

  final String listId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userProvider = context.watch<UserProvider>();
    final shoppingList = userProvider.shoppingListById(listId);

    if (shoppingList == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Lista'),
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.playlist_remove_rounded,
                    size: 34,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLg),
                Text(
                  'Esta lista ya no esta disponible',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final uid = userProvider.user?.uid ?? '';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        titleSpacing: AppConstants.paddingLg,
        title: const Text('Que falta?'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingLg,
            AppConstants.paddingLg,
            AppConstants.paddingLg,
            AppConstants.paddingXl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LISTA DE COMPRA',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    shoppingList.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${shoppingList.pendingItemsCount} ingrediente${shoppingList.pendingItemsCount == 1 ? '' : 's'} pendiente${shoppingList.pendingItemsCount == 1 ? '' : 's'}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXl),
                  Text(
                    'Toca un ingrediente para marcarlo como comprado.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLg),
                  ...shoppingList.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ShoppingListItemCard(
                        item: item,
                        onTap: uid.isEmpty
                            ? null
                            : () {
                                userProvider.toggleShoppingListItem(
                                  uid,
                                  shoppingList.id,
                                  item.id,
                                );
                              },
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
