import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../widgets/recipe_card.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Container(
        color: colorScheme.surfaceContainerLowest,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                color: colorScheme.surface.withValues(alpha: 0.92),
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingMd,
                  AppConstants.paddingSm,
                  AppConstants.paddingMd,
                  AppConstants.paddingMd,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorColor: colorScheme.primary,
                        indicatorWeight: 3,
                        indicatorPadding: const EdgeInsets.only(
                          left: 18,
                          right: 18,
                          bottom: 2,
                        ),
                        labelColor: colorScheme.primary,
                        unselectedLabelColor: colorScheme.onSurfaceVariant,
                        labelStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle:
                            theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [
                          Tab(text: 'Explore'),
                          Tab(text: 'For You'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const _ExploreTab(),
                    _ForYouTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _ForYouTab extends StatelessWidget {
  const _ForYouTab();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<Recipe>>(
      stream: RecipeService().getRecipes(),
      builder: (context, snapshot) {
        // Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        // Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 12),
                Text(
                  'Error al cargar las recetas',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        // Sin recetas
        final recipes = snapshot.data ?? [];
        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: colorScheme.outlineVariant),
                const SizedBox(height: 12),
                Text(
                  'No hay recetas disponibles',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant, fontSize: 16),
                ),
              ],
            ),
          );
        }

        // Masonry grid en dos columnas (igual que antes)
        final leftColumn = <Widget>[];
        final rightColumn = <Widget>[];

        for (var i = 0; i < recipes.length; i++) {
          final card = RecipeCard(
            recipe: recipes[i],
            layout:
                RecipeCardLayout.values[i % RecipeCardLayout.values.length],
            accent:
                RecipeCardAccent.values[i % RecipeCardAccent.values.length],
          );
          if (i.isEven) {
            leftColumn.add(card);
          } else {
            rightColumn.add(card);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingMd,
            AppConstants.paddingMd,
            AppConstants.paddingMd,
            140,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: leftColumn,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rightColumn,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingLg,
        AppConstants.paddingXl,
        AppConstants.paddingLg,
        140,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This screen stays intentionally empty for now while we define '
            'the discovery experience separately from the Firebase feed.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXl),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingXl),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusLg),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 68,
                    width: 68,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.travel_explore_rounded,
                      size: 32,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLg),
                  Text(
                    'No exploration modules yet.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}