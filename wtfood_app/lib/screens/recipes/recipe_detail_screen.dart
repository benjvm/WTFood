import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/providers/fridge_provider.dart';
import 'package:wtfood_app/models/recipe.dart';
import 'package:wtfood_app/providers/user_provider.dart';

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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.88),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor ?? colorScheme.onSurface),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHigh,
      child: Icon(
        Icons.restaurant_rounded,
        size: 64,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.child,
    required this.colorScheme,
    required this.theme,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final Widget child;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLg),
          child,
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.text,
    required this.theme,
    required this.colorScheme,
    required this.isLast,
  });

  final int index;
  final String text;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número + línea conectora
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Texto del paso
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppConstants.paddingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
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
