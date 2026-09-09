import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/features/shopping_list/domain/shopping_list.dart';
import 'package:wtfood_app/features/fridge/application/fridge_provider.dart';
import 'package:wtfood_app/features/user/application/user_provider.dart';
import 'package:wtfood_app/features/shopping_list/presentation/screens/shopping_list_detail_screen.dart';

part '../widgets/shopping_lists_widgets.dart';

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
