part of '../screens/recipes_screen.dart';

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
        final featuredCollections = collections
            .where((collection) => collection.isFavorites)
            .toList();
        final featuredCollection = featuredCollections.isNotEmpty
            ? featuredCollections.first
            : null;
        final regularCollections = collections
            .where((collection) => !collection.isFavorites)
            .toList();

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
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Explora ',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 36,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: 'Categorías',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 36,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Descubre recetas por categoría y encuentra tus favoritas desde una vista más clara y visual.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              if (featuredCollection != null) ...[
                const SizedBox(height: AppConstants.paddingXl),
                _ExploreFeaturedCollectionCard(
                  collection: featuredCollection,
                  onTap: () => _openCollection(context, featuredCollection),
                ),
              ],
              const SizedBox(height: AppConstants.paddingXl),
              Text(
                'Todas las categorías',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),
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
                            child: _ExploreCategoryTile(
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

class _ExploreFeaturedCollectionCard extends StatelessWidget {
  const _ExploreFeaturedCollectionCard({
    required this.collection,
    required this.onTap,
  });

  final _ExploreCollection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasPhoto =
        collection.previewRecipe?.photoUrl.trim().isNotEmpty ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
        child: Ink(
          height: 294,
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
                        Colors.black.withValues(alpha: 0.16),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!collection.isFavorites) ...[
                        const _FeaturedPill(label: 'Explorar'),
                        const Spacer(),
                      ] else
                        const Spacer(),
                      Text(
                        collection.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _FeaturedInfoChip(
                            icon: collection.icon,
                            label: '${collection.recipeCount} recetas',
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              collection.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _ExploreCategoryTile extends StatelessWidget {
  const _ExploreCategoryTile({required this.collection, required this.onTap});

  final _ExploreCollection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasPhoto =
        collection.previewRecipe?.photoUrl.trim().isNotEmpty ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        child: Ink(
          height: 156,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
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
                        Colors.black.withValues(alpha: 0.24),
                        Colors.black.withValues(alpha: 0.68),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: AppConstants.paddingMd,
                  right: AppConstants.paddingMd,
                  bottom: AppConstants.paddingMd,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collection.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 20,
                                height: 1.02,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${collection.recipeCount} recetas',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _FeaturedPill extends StatelessWidget {
  const _FeaturedPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8B2C),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FeaturedInfoChip extends StatelessWidget {
  const _FeaturedInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
  final breakfastRecipes = _recipesByCategory(recipes, 'desayuno');
  final easyRecipes = _recipesByCategory(recipes, 'fácil');
  final dinnerRecipes = _recipesByCategory(recipes, 'cena');
  final dessertRecipes = _recipesByCategory(recipes, 'postre');

  return [
    if (favoriteRecipes.isNotEmpty)
      _ExploreCollection(
        title: 'Recetas favoritas',
        description: 'Tus platos guardados para volver a ellos cuando quieras.',
        filterKey: 'favorites',
        icon: Icons.favorite_rounded,
        gradientColors: const [
          Color(0xFF114D3A),
          Color(0xFF0B8A43),
          Color(0xFF76C893),
        ],
        recipeCount: favoriteRecipes.length,
        previewRecipe: favoriteRecipes.first,
        isFavorites: true,
      ),
    _ExploreCollection(
      title: 'Desayuno',
      description: 'Ideas ligeras y rápidas para arrancar el día.',
      filterKey: 'desayuno',
      icon: Icons.breakfast_dining_rounded,
      gradientColors: const [
        Color(0xFFB6E2D3),
        Color(0xFF7BC4A4),
        Color(0xFF1F8A5B),
      ],
      recipeCount: breakfastRecipes.length,
      previewRecipe: breakfastRecipes.isNotEmpty
          ? breakfastRecipes.first
          : null,
    ),
    _ExploreCollection(
      title: 'Fáciles',
      description: 'Recetas simples para cocinar sin complicarte.',
      filterKey: 'fácil',
      icon: Icons.auto_awesome_rounded,
      gradientColors: const [
        Color(0xFFC8F0D8),
        Color(0xFF74C69D),
        Color(0xFF1B7F4B),
      ],
      recipeCount: easyRecipes.length,
      previewRecipe: easyRecipes.isNotEmpty ? easyRecipes.first : null,
    ),
    _ExploreCollection(
      title: 'Cenas',
      description: 'Opciones reconfortantes para cerrar el día.',
      filterKey: 'cena',
      icon: Icons.local_dining_rounded,
      gradientColors: const [
        Color(0xFFE8E8E8),
        Color(0xFFB7B7B7),
        Color(0xFF5D5D5D),
      ],
      recipeCount: dinnerRecipes.length,
      previewRecipe: dinnerRecipes.isNotEmpty ? dinnerRecipes.first : null,
    ),
    _ExploreCollection(
      title: 'Postres',
      description: 'El toque dulce perfecto para cualquier antojo.',
      filterKey: 'postre',
      icon: Icons.icecream_rounded,
      gradientColors: const [
        Color(0xFFFDE2E4),
        Color(0xFFF4A8B8),
        Color(0xFFC1121F),
      ],
      recipeCount: dessertRecipes.length,
      previewRecipe: dessertRecipes.isNotEmpty ? dessertRecipes.first : null,
    ),
  ];
}

List<Recipe> _recipesByCategory(List<Recipe> recipes, String category) {
  final normalizedCategory = _normalizeCategoryKey(category);

  return recipes
      .where(
        (recipe) =>
            _normalizeCategoryKey(recipe.category) == normalizedCategory,
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

String _normalizeCategoryKey(String category) {
  final normalizedCategory = category.trim().toLowerCase();

  switch (normalizedCategory) {
    case 'breakfast':
      return 'desayuno';
    case 'dinner':
      return 'cena';
    case 'dessert':
      return 'postre';
    case 'easy':
      return 'fácil';
    default:
      return normalizedCategory;
  }
}
