import 'package:flutter/material.dart';
import 'package:wtfood_app/features/recipes/presentation/screens/recipe_detail_screen.dart';

import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/features/recipes/domain/recipe.dart';

enum RecipeCardLayout { portrait, square, landscape }

enum RecipeCardAccent { healthyChoice, highEnergy, breakfastFavorite, tested }

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    this.layout = RecipeCardLayout.portrait,
    this.accent = RecipeCardAccent.healthyChoice,
    this.onTap,
  });

  final Recipe recipe;
  final RecipeCardLayout layout;
  final RecipeCardAccent accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentMeta = _accentMeta(colorScheme);
    final hasPhoto = recipe.photoUrl.trim().isNotEmpty;
    final isDarkMode = theme.brightness == Brightness.dark;
    final durationBadgeColor = isDarkMode
        ? colorScheme.primaryContainer.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.84);
    final durationBadgeIconColor = isDarkMode
        ? colorScheme.onPrimaryContainer
        : colorScheme.primary;
    final durationBadgeTextColor = isDarkMode
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap ?? () => _showRecipeDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMd),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(12, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen placeholder (sin imageUrl en el modelo)
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: _aspectRatio,
                    child: hasPhoto
                        ? Image.network(
                            recipe.photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _RecipeCardPlaceholder(
                                  colorScheme: colorScheme,
                                ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return _RecipeCardPlaceholder(
                                colorScheme: colorScheme,
                              );
                            },
                          )
                        : _RecipeCardPlaceholder(colorScheme: colorScheme),
                  ),
                  // Badge de duración
                  Positioned(
                    top: AppConstants.paddingMd,
                    right: AppConstants.paddingMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: durationBadgeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: durationBadgeIconColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.duration,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: durationBadgeTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Badge de categoría
                  Positioned(
                    top: AppConstants.paddingMd,
                    left: AppConstants.paddingMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        recipe.category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _AccentFooter(meta: accentMeta),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double get _aspectRatio {
    switch (layout) {
      case RecipeCardLayout.portrait:
        return 3 / 4;
      case RecipeCardLayout.square:
        return 1;
      case RecipeCardLayout.landscape:
        return 16 / 10;
    }
  }

  _AccentMeta _accentMeta(ColorScheme colorScheme) {
    switch (accent) {
      case RecipeCardAccent.healthyChoice:
        return _AccentMeta(
          icon: Icons.eco_rounded,
          label: '${recipe.ingredients.length} ingredientes',
          textColor: colorScheme.onSurfaceVariant,
          iconColor: colorScheme.onPrimaryContainer,
          iconBackground: colorScheme.primaryContainer,
        );
      case RecipeCardAccent.highEnergy:
        return _AccentMeta(
          icon: Icons.bolt_rounded,
          label: '${recipe.ingredients.length} ingredientes',
          textColor: colorScheme.tertiary,
          iconColor: colorScheme.tertiary,
          iconBackground: colorScheme.tertiaryContainer.withValues(alpha: 0.28),
        );
      case RecipeCardAccent.breakfastFavorite:
        return _AccentMeta(
          chipLabel: recipe.category.toUpperCase(),
          textColor: colorScheme.primary,
          chipBackground: colorScheme.primaryContainer.withValues(alpha: 0.24),
        );
      case RecipeCardAccent.tested:
        return _AccentMeta(
          icon: Icons.favorite_rounded,
          label: '${recipe.ingredients.length} ingredientes',
          textColor: colorScheme.error,
          iconColor: colorScheme.error,
        );
    }
  }

  void _showRecipeDetail(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusXl),
        ),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppConstants.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),

              // Categoría + duración
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.9,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      recipe.category,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    recipe.duration,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMd),

              // Título
              Text(
                recipe.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                recipe.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),

              // Ingredientes
              Text(
                'Ingredientes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSm),
              ...recipe.ingredients.map(
                (ingredient) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ingredient,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón Ver receta
              const SizedBox(height: AppConstants.paddingLg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx); // cierra el bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book_rounded),
                  label: const Text('Ver receta'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusLg,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingXl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCardPlaceholder extends StatelessWidget {
  const _RecipeCardPlaceholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_rounded,
        size: 40,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      ),
    );
  }
}

class _AccentFooter extends StatelessWidget {
  const _AccentFooter({required this.meta});

  final _AccentMeta meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (meta.chipLabel != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: meta.chipBackground,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          meta.chipLabel!,
          style: theme.textTheme.labelMedium?.copyWith(
            color: meta.textColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      );
    }

    return Row(
      children: [
        if (meta.iconBackground != null)
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: meta.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(meta.icon, size: 14, color: meta.iconColor),
          )
        else
          Icon(meta.icon, size: 16, color: meta.iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            meta.label ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: meta.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccentMeta {
  const _AccentMeta({
    this.icon = Icons.circle,
    this.label,
    this.chipLabel,
    this.textColor,
    this.iconColor,
    this.iconBackground,
    this.chipBackground,
  });

  final IconData icon;
  final String? label;
  final String? chipLabel;
  final Color? textColor;
  final Color? iconColor;
  final Color? iconBackground;
  final Color? chipBackground;
}
