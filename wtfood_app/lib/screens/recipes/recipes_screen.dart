import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/recipe.dart';
import '../../providers/user_provider.dart';
import '../../services/recipe_service.dart';
import '../../widgets/recipe_card.dart';
import 'package:wtfood_app/screens/recipes/recipe_detail_screen.dart';

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
                        unselectedLabelStyle: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        tabs: const [
                          Tab(text: 'Explore'),
                          Tab(text: 'For You'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(children: [_ExploreTab(), _ForYouTab()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForYouTab extends StatefulWidget {
  const _ForYouTab();

  @override
  State<_ForYouTab> createState() => _ForYouTabState();
}

class _ForYouTabState extends State<_ForYouTab>
    with AutomaticKeepAliveClientMixin {
  late final Stream<List<Recipe>> _recipesStream;

  @override
  void initState() {
    super.initState();
    _recipesStream = RecipeService().getRecipes();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<Recipe>>(
      stream: _recipesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (snapshot.hasError) {
          return _CollectionStateMessage(
            icon: Icons.error_outline_rounded,
            title: 'Error al cargar las recetas',
            message: 'No pudimos abrir tu feed por ahora.',
          );
        }

        final recipes = snapshot.data ?? const <Recipe>[];
        if (recipes.isEmpty) {
          return _CollectionStateMessage(
            icon: Icons.receipt_long_outlined,
            title: 'No hay recetas disponibles',
            message: 'Cuando tengamos nuevas recetas aparecerán aquí.',
          );
        }

        return _RecipeMasonryGrid(
          recipes: recipes,
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingMd,
            AppConstants.paddingMd,
            AppConstants.paddingMd,
            140,
          ),
        );
      },
    );
  }
}

class _ExploreTab extends StatefulWidget {
  const _ExploreTab();

  @override
  State<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab>
    with AutomaticKeepAliveClientMixin {
  late final Stream<List<Recipe>> _recipesStream;

  @override
  void initState() {
    super.initState();
    _recipesStream = RecipeService().getRecipes(limit: 100);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final favoriteRecipeIds =
        context.watch<UserProvider>().user?.favoriteRecipes ?? const <String>[];

    return StreamBuilder<List<Recipe>>(
      stream: _recipesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (snapshot.hasError) {
          return _CollectionStateMessage(
            icon: Icons.error_outline_rounded,
            title: 'Error al cargar las categorías',
            message:
                'No pudimos preparar la experiencia de exploración en este momento.',
          );
        }

        final recipes = snapshot.data ?? const <Recipe>[];
        final favoriteRecipes = _sortedRecipesByIdOrder(
          recipes,
          favoriteRecipeIds,
        );
        final collections = _buildExploreCollections(
          recipes: recipes,
          favoriteRecipes: favoriteRecipes,
        );
        final featuredCollection = collections.first;
        final regularCollections = collections.skip(1).toList();

        return SingleChildScrollView(
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
                'Explora categorías',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Descubre recetas por categoría y vuelve a tus favoritas desde una experiencia más visual.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXl),
              _ExploreCollectionTile(
                collection: featuredCollection,
                isFeatured: true,
                onTap: () => _openCollection(context, featuredCollection),
              ),
              const SizedBox(height: AppConstants.paddingMd),
              LayoutBuilder(
                builder: (context, constraints) {
                  final tileWidth =
                      (constraints.maxWidth - AppConstants.paddingMd) / 2;

                  return Wrap(
                    spacing: AppConstants.paddingMd,
                    runSpacing: AppConstants.paddingMd,
                    children: regularCollections
                        .map(
                          (collection) => SizedBox(
                            width: tileWidth,
                            child: _ExploreCollectionTile(
                              collection: collection,
                              onTap: () => _openCollection(context, collection),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCollection(BuildContext context, _ExploreCollection collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RecipeCollectionScreen(collection: collection),
      ),
    );
  }
}

class _RecipeCollectionScreen extends StatelessWidget {
  const _RecipeCollectionScreen({required this.collection});

  final _ExploreCollection collection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final favoriteRecipeIds =
        context.watch<UserProvider>().user?.favoriteRecipes ?? const <String>[];

    final recipesStream = collection.isFavorites
        ? RecipeService().getFavoriteRecipes(favoriteRecipeIds)
        : RecipeService().getRecipesByCategory(collection.filterKey);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingMd,
                AppConstants.paddingMd,
                AppConstants.paddingMd,
                AppConstants.paddingSm,
              ),
              child: Row(
                children: [
                  _RoundActionButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppConstants.paddingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          collection.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Recipe>>(
                stream: recipesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _CollectionStateMessage(
                      icon: Icons.error_outline_rounded,
                      title: 'No pudimos cargar esta colección',
                      message: 'Inténtalo de nuevo dentro de un momento.',
                    );
                  }

                  final recipes = snapshot.data ?? const <Recipe>[];
                  if (recipes.isEmpty) {
                    return _CollectionStateMessage(
                      icon: collection.isFavorites
                          ? Icons.favorite_border_rounded
                          : collection.icon,
                      title: collection.isFavorites
                          ? 'Todavía no tienes favoritas'
                          : 'No hay recetas en ${collection.title.toLowerCase()}',
                      message: collection.isFavorites
                          ? 'Guarda recetas desde el detalle para encontrarlas aquí.'
                          : 'Cuando agreguemos más recetas de esta categoría aparecerán en este espacio.',
                    );
                  }

                  return _RecipeMasonryGrid(
                    recipes: recipes,
                    openDirectly: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingMd,
                      AppConstants.paddingSm,
                      AppConstants.paddingMd,
                      140,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeMasonryGrid extends StatelessWidget {
  const _RecipeMasonryGrid({
    required this.recipes,
    required this.padding,
    this.openDirectly = false,
  });

  final List<Recipe> recipes;
  final EdgeInsets padding;
  final bool openDirectly;

  @override
  Widget build(BuildContext context) {
    final leftColumn = <Widget>[];
    final rightColumn = <Widget>[];

    for (var i = 0; i < recipes.length; i++) {
      final recipe = recipes[i];
      final card = RecipeCard(
        recipe: recipe,
        layout: RecipeCardLayout.values[i % RecipeCardLayout.values.length],
        accent: RecipeCardAccent.values[i % RecipeCardAccent.values.length],
        onTap: openDirectly
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
              }
            : null,
      );

      if (i.isEven) {
        leftColumn.add(card);
      } else {
        rightColumn.add(card);
      }
    }

    return SingleChildScrollView(
      padding: padding,
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
  }
}

class _ExploreCollectionTile extends StatelessWidget {
  const _ExploreCollectionTile({
    required this.collection,
    required this.onTap,
    this.isFeatured = false,
  });

  final _ExploreCollection collection;
  final VoidCallback onTap;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasPhoto =
        collection.previewRecipe?.photoUrl.trim().isNotEmpty ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isFeatured ? 220 : 214,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasPhoto)
                Image.network(
                  collection.previewRecipe!.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _CollectionTileFallback(
                    colors: collection.gradientColors,
                    icon: collection.icon,
                  ),
                )
              else
                _CollectionTileFallback(
                  colors: collection.gradientColors,
                  icon: collection.icon,
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.22),
                      Colors.black.withValues(alpha: 0.62),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusXl,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: _ExploreMetaChip(
                                label: '${collection.recipeCount} recetas',
                                icon: collection.isFavorites
                                    ? Icons.favorite_rounded
                                    : Icons.restaurant_menu_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(collection.icon, color: Colors.white),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      collection.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (isFeatured
                                  ? theme.textTheme.headlineSmall
                                  : theme.textTheme.titleLarge)
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      collection.description,
                      maxLines: isFeatured ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
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

class _CollectionTileFallback extends StatelessWidget {
  const _CollectionTileFallback({required this.colors, required this.icon});

  final List<Color> colors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 54,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _ExploreMetaChip extends StatelessWidget {
  const _ExploreMetaChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: colorScheme.onSurface),
      ),
    );
  }
}

class _CollectionStateMessage extends StatelessWidget {
  const _CollectionStateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 34,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreCollection {
  const _ExploreCollection({
    required this.title,
    required this.description,
    required this.filterKey,
    required this.icon,
    required this.gradientColors,
    required this.recipeCount,
    this.previewRecipe,
    this.isFavorites = false,
  });

  final String title;
  final String description;
  final String filterKey;
  final IconData icon;
  final List<Color> gradientColors;
  final int recipeCount;
  final Recipe? previewRecipe;
  final bool isFavorites;
}

List<_ExploreCollection> _buildExploreCollections({
  required List<Recipe> recipes,
  required List<Recipe> favoriteRecipes,
}) {
  final breakfastRecipes = _recipesByCategory(recipes, 'breakfast');
  final easyRecipes = _recipesByCategory(recipes, 'easy');
  final dinnerRecipes = _recipesByCategory(recipes, 'dinner');
  final dessertRecipes = _recipesByCategory(recipes, 'dessert');

  return [
    _ExploreCollection(
      title: 'Favorite Recipes',
      description: 'Tus platos guardados para volver a ellos cuando quieras.',
      filterKey: 'favorites',
      icon: Icons.favorite_rounded,
      gradientColors: const [
        Color(0xFF114D3A),
        Color(0xFF0B8A43),
        Color(0xFF76C893),
      ],
      recipeCount: favoriteRecipes.length,
      previewRecipe: favoriteRecipes.isNotEmpty ? favoriteRecipes.first : null,
      isFavorites: true,
    ),
    _ExploreCollection(
      title: 'Breakfast',
      description: 'Ideas ligeras y rápidas para arrancar el día.',
      filterKey: 'breakfast',
      icon: Icons.wb_sunny_rounded,
      gradientColors: const [
        Color(0xFFFFB066),
        Color(0xFFFF7B54),
        Color(0xFFD85838),
      ],
      recipeCount: breakfastRecipes.length,
      previewRecipe: breakfastRecipes.isNotEmpty
          ? breakfastRecipes.first
          : null,
    ),
    _ExploreCollection(
      title: 'Easy',
      description: 'Recetas simples para cocinar sin complicarte.',
      filterKey: 'easy',
      icon: Icons.auto_awesome_rounded,
      gradientColors: const [
        Color(0xFF2E6F95),
        Color(0xFF184E77),
        Color(0xFF1B263B),
      ],
      recipeCount: easyRecipes.length,
      previewRecipe: easyRecipes.isNotEmpty ? easyRecipes.first : null,
    ),
    _ExploreCollection(
      title: 'Dinner',
      description: 'Opciones reconfortantes para cerrar el día.',
      filterKey: 'dinner',
      icon: Icons.dinner_dining_rounded,
      gradientColors: const [
        Color(0xFF303030),
        Color(0xFF151515),
        Color(0xFF000000),
      ],
      recipeCount: dinnerRecipes.length,
      previewRecipe: dinnerRecipes.isNotEmpty ? dinnerRecipes.first : null,
    ),
    _ExploreCollection(
      title: 'Dessert',
      description: 'El toque dulce perfecto para cualquier antojo.',
      filterKey: 'dessert',
      icon: Icons.cake_rounded,
      gradientColors: const [
        Color(0xFFFFD166),
        Color(0xFFE76F51),
        Color(0xFFA73E5C),
      ],
      recipeCount: dessertRecipes.length,
      previewRecipe: dessertRecipes.isNotEmpty ? dessertRecipes.first : null,
    ),
  ];
}

List<Recipe> _recipesByCategory(List<Recipe> recipes, String category) {
  final normalizedCategory = category.trim().toLowerCase();

  return recipes
      .where(
        (recipe) => recipe.category.trim().toLowerCase() == normalizedCategory,
      )
      .toList();
}

List<Recipe> _sortedRecipesByIdOrder(
  List<Recipe> recipes,
  List<String> orderedIds,
) {
  if (orderedIds.isEmpty) {
    return const <Recipe>[];
  }

  final orderedRecipes = recipes
      .where((recipe) => orderedIds.contains(recipe.id))
      .toList();

  orderedRecipes.sort(
    (a, b) => orderedIds.indexOf(a.id).compareTo(orderedIds.indexOf(b.id)),
  );

  return orderedRecipes;
}
