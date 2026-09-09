import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/shared/services/pixabay_service.dart';

class RecipeResultScreen extends StatefulWidget {
  const RecipeResultScreen({
    super.key,
    required this.recipe,
    required this.usedIngredients,
    this.recipePhoto,
  });

  final Map<String, dynamic> recipe;
  final List<String> usedIngredients;
  final PixabayPhoto? recipePhoto;

  @override
  State<RecipeResultScreen> createState() => _RecipeResultScreenState();
}

class _RecipeResultScreenState extends State<RecipeResultScreen> {
  late final Future<PixabayPhoto?> _photoFuture;

  @override
  void initState() {
    super.initState();
    _photoFuture = widget.recipePhoto != null
        ? Future<PixabayPhoto?>.value(widget.recipePhoto)
        : const PixabayService().findRecipePhoto(_recipeName);
  }

  String get _recipeName =>
      _readText(widget.recipe['nombre'], fallback: 'Receta');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final description = _readText(widget.recipe['descripcion']);
    final prepTime = _readText(
      widget.recipe['tiempo_preparacion'],
      fallback: '--',
    );
    final cookTime = _readText(widget.recipe['tiempo_coccion'], fallback: '--');
    final servings = _readText(widget.recipe['porciones'], fallback: '2');
    final difficulty = _readText(
      widget.recipe['dificultad'],
      fallback: 'Media',
    );
    final chefTip = _readText(widget.recipe['consejos']);
    final ingredients = _readIngredients(widget.recipe['ingredientes']);
    final steps = _readSteps(widget.recipe['pasos']);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
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
                  icon: Icons.ios_share_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Compartir receta proximamente.'),
                      ),
                    );
                  },
                  colorScheme: colorScheme,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: FutureBuilder<PixabayPhoto?>(
                future: _photoFuture,
                builder: (context, snapshot) {
                  final photo = snapshot.data;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      if (photo != null)
                        Image.network(
                          photo.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _HeroPlaceholder(colorScheme: colorScheme),
                        )
                      else
                        _HeroPlaceholder(colorScheme: colorScheme),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                colorScheme.surface.withValues(alpha: 0.9),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      if (photo != null)
                        Positioned(
                          left: AppConstants.paddingLg,
                          bottom: AppConstants.paddingLg,
                          child: _PhotoCreditChip(author: photo.author),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
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
                  Text(
                    'RECETA GENERADA',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _recipeName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMd),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(
                        icon: Icons.schedule_rounded,
                        label: prepTime,
                        backgroundColor: colorScheme.secondaryContainer,
                        iconColor: colorScheme.secondary,
                        textColor: colorScheme.onSecondaryContainer,
                      ),
                      _InfoPill(
                        icon: Icons.local_fire_department_rounded,
                        label: cookTime,
                        backgroundColor: colorScheme.primaryContainer,
                        iconColor: colorScheme.primary,
                        textColor: colorScheme.onPrimaryContainer,
                      ),
                      _InfoPill(
                        icon: Icons.people_alt_rounded,
                        label: '$servings porciones',
                        backgroundColor: colorScheme.tertiaryContainer,
                        iconColor: colorScheme.tertiary,
                        textColor: colorScheme.onTertiaryContainer,
                      ),
                      _InfoPill(
                        icon: Icons.bar_chart_rounded,
                        label: difficulty,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        iconColor: colorScheme.onSurfaceVariant,
                        textColor: colorScheme.onSurface,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingLg),
                  Text(
                    description.isEmpty
                        ? 'Una propuesta deliciosa creada a partir de los ingredientes detectados.'
                        : description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXl),
                  _SectionCard(
                    icon: Icons.shopping_basket_rounded,
                    iconBackground: colorScheme.primaryContainer,
                    iconColor: colorScheme.onPrimaryContainer,
                    title: 'Ingredientes',
                    colorScheme: colorScheme,
                    theme: theme,
                    child: Column(
                      children: ingredients
                          .map(
                            (ingredient) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: _IngredientRow(
                                ingredient: ingredient,
                                theme: theme,
                                colorScheme: colorScheme,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (steps.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.paddingLg),
                    _SectionCard(
                      icon: Icons.format_list_numbered_rounded,
                      iconBackground: colorScheme.secondaryContainer,
                      iconColor: colorScheme.onSecondaryContainer,
                      title: 'Preparacion',
                      colorScheme: colorScheme,
                      theme: theme,
                      child: Column(
                        children: List.generate(
                          steps.length,
                          (index) => _StepRow(
                            index: index,
                            text: steps[index],
                            theme: theme,
                            colorScheme: colorScheme,
                            isLast: index == steps.length - 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (chefTip.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.paddingLg),
                    _SectionCard(
                      icon: Icons.lightbulb_rounded,
                      iconBackground: colorScheme.tertiaryContainer,
                      iconColor: colorScheme.onTertiaryContainer,
                      title: 'Consejo del chef',
                      colorScheme: colorScheme,
                      theme: theme,
                      child: Text(
                        chefTip,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                  if (widget.usedIngredients.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.paddingLg),
                    _SectionCard(
                      icon: Icons.eco_rounded,
                      iconBackground: colorScheme.primaryContainer,
                      iconColor: colorScheme.onPrimaryContainer,
                      title: 'Ingredientes usados',
                      colorScheme: colorScheme,
                      theme: theme,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.usedIngredients
                            .map(
                              (ingredient) =>
                                  _UsedIngredientChip(label: ingredient),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(
        onRestart: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  static String _readText(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static List<_RecipeIngredient> _readIngredients(dynamic rawIngredients) {
    final items = rawIngredients as List<dynamic>? ?? const [];
    return items
        .map(_RecipeIngredient.fromDynamic)
        .where((ingredient) => ingredient.name.isNotEmpty)
        .toList();
  }

  static List<String> _readSteps(dynamic rawSteps) {
    final items = rawSteps as List<dynamic>? ?? const [];
    return items
        .map((step) => step.toString().trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }
}

class _RecipeIngredient {
  const _RecipeIngredient({required this.name, required this.amount});

  final String name;
  final String amount;

  factory _RecipeIngredient.fromDynamic(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final quantity = (raw['cantidad']?.toString().trim() ?? '');
      final unit = (raw['unidad']?.toString().trim() ?? '');
      final name = (raw['nombre']?.toString().trim() ?? '');

      return _RecipeIngredient(
        name: _capitalize(name),
        amount: [quantity, unit].where((part) => part.isNotEmpty).join(' '),
      );
    }

    final text = raw?.toString().trim() ?? '';
    return _RecipeIngredient(name: _capitalize(text), amount: '');
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

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
        child: Icon(icon, size: 20, color: colorScheme.onSurface),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDim,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.restaurant_menu_rounded,
            size: 44,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _PhotoCreditChip extends StatelessWidget {
  const _PhotoCreditChip({required this.author});

  final String author;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Foto: $author en Pixabay',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
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

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.ingredient,
    required this.theme,
    required this.colorScheme,
  });

  final _RecipeIngredient ingredient;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            ingredient.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (ingredient.amount.isNotEmpty)
          Text(
            ingredient.amount,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
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

class _UsedIngredientChip extends StatelessWidget {
  const _UsedIngredientChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm + 4),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingLg,
        AppConstants.paddingMd,
        AppConstants.paddingLg,
        AppConstants.paddingMd + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('Escanear nuevos ingredientes'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
            ),
          ),
        ),
      ),
    );
  }
}
