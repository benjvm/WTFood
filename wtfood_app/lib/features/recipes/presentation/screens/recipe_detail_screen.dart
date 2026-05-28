import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/features/fridge/application/fridge_provider.dart';
import 'package:wtfood_app/features/recipes/domain/recipe.dart';
import 'package:wtfood_app/features/user/application/user_provider.dart';

part '../widgets/recipe_detail_widgets.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasPhoto = widget.recipe.photoUrl.trim().isNotEmpty;

    final userProvider = context.watch<UserProvider>();
    final isFav = userProvider.isFavorite(widget.recipe.id);
    final isShoppingListSaved = userProvider.isShoppingListSaved(
      widget.recipe.id,
    );
    final uid = userProvider.user?.uid ?? '';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingLg,
            AppConstants.paddingMd,
            AppConstants.paddingLg,
            AppConstants.paddingLg,
          ),
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: uid.isEmpty
                  ? null
                  : () async {
                      final wasAlreadySaved = isShoppingListSaved;
                      final didSave = await userProvider.saveShoppingList(
                        uid,
                        widget.recipe,
                        pantryItems: context.read<FridgeProvider>().ingredients,
                      );

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            didSave
                                ? wasAlreadySaved
                                      ? 'Lista de compra actualizada.'
                                      : 'Lista de compra guardada.'
                                : 'No se pudo guardar la lista de compra.',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMd,
                            ),
                          ),
                          margin: const EdgeInsets.fromLTRB(
                            AppConstants.paddingLg,
                            0,
                            AppConstants.paddingLg,
                            AppConstants.paddingLg,
                          ),
                        ),
                      );
                    },
              icon: Icon(
                isShoppingListSaved
                    ? Icons.playlist_add_check_circle_rounded
                    : Icons.playlist_add_rounded,
              ),
              label: const Text('Guardar lista de compra'),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
                colorScheme: colorScheme,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _CircleIconButton(
                  icon: isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: isFav ? Colors.redAccent : null,
                  onTap: () async {
                    final wasAlreadyFav = isFav;
                    await userProvider.toggleFavoriteRecipe(
                      uid,
                      widget.recipe.id,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          wasAlreadyFav
                              ? 'Eliminado de favoritos'
                              : 'Guardado en favoritos',
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMd,
                          ),
                        ),
                        margin: const EdgeInsets.fromLTRB(
                          AppConstants.paddingLg,
                          0,
                          AppConstants.paddingLg,
                          AppConstants.paddingLg,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  colorScheme: colorScheme,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  hasPhoto
                      ? Image.network(
                          widget.recipe.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _HeroPlaceholder(colorScheme: colorScheme),
                        )
                      : _HeroPlaceholder(colorScheme: colorScheme),
                  // Gradiente inferior para legibilidad
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            colorScheme.surface.withValues(alpha: 0.85),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingLg,
                AppConstants.paddingMd,
                AppConstants.paddingLg,
                140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría label
                  Text(
                    widget.recipe.category.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Título
                  Text(
                    widget.recipe.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMd),

                  // Pills de info
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(
                        icon: Icons.schedule_rounded,
                        label: widget.recipe.duration,
                        backgroundColor: colorScheme.secondaryContainer,
                        iconColor: colorScheme.secondary,
                        textColor: colorScheme.onSecondaryContainer,
                      ),
                      _InfoPill(
                        icon: Icons.restaurant_rounded,
                        label: widget.recipe.category,
                        backgroundColor: colorScheme.primaryContainer,
                        iconColor: colorScheme.primary,
                        textColor: colorScheme.onPrimaryContainer,
                      ),
                      _InfoPill(
                        icon: Icons.list_alt_rounded,
                        label:
                            '${widget.recipe.ingredients.length} ingredientes',
                        backgroundColor: colorScheme.tertiaryContainer,
                        iconColor: colorScheme.tertiary,
                        textColor: colorScheme.onTertiaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingLg),

                  // Descripción
                  Text(
                    widget.recipe.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXl),

                  // ── Ingredientes ────────────────────────────────
                  _SectionCard(
                    icon: Icons.shopping_basket_rounded,
                    iconBackground: colorScheme.primaryContainer,
                    iconColor: colorScheme.onPrimaryContainer,
                    title: 'Ingredientes',
                    colorScheme: colorScheme,
                    theme: theme,
                    child: Column(
                      children: widget.recipe.ingredients
                          .map(
                            (ingredient) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      ingredient,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLg),

                  // ── Pasos ───────────────────────────────────────
                  if (widget.recipe.steps.isNotEmpty)
                    _SectionCard(
                      icon: Icons.format_list_numbered_rounded,
                      iconBackground: colorScheme.secondaryContainer,
                      iconColor: colorScheme.onSecondaryContainer,
                      title: 'Preparación',
                      colorScheme: colorScheme,
                      theme: theme,
                      child: Column(
                        children: List.generate(
                          widget.recipe.steps.length,
                          (i) => _StepRow(
                            index: i,
                            text: widget.recipe.steps[i],
                            theme: theme,
                            colorScheme: colorScheme,
                            isLast: i == widget.recipe.steps.length - 1,
                          ),
                        ),
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

// ── Widgets privados ────────────────────────────────────────────────────────
