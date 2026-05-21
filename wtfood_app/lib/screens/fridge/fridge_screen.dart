import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../providers/fridge_provider.dart';

class FridgeScreen extends StatelessWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fridgeIngredients = context.watch<FridgeProvider>().ingredients;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingLg,
          AppConstants.paddingLg,
          AppConstants.paddingLg,
          140,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeading(
              title: 'Mi nevera virtual',
              subtitle: fridgeIngredients.isEmpty
                  ? 'Escanea alimentos y guarda los ingredientes que quieras conservar.'
                  : 'Estos son los ingredientes que has guardado desde el escaneo.',
            ),
            const SizedBox(height: AppConstants.paddingXl),
            if (fridgeIngredients.isEmpty)
              _EmptyFridgeState(
                colorScheme: colorScheme,
                onScan: () => Navigator.of(context).pushNamed('/scan'),
              )
            else
              _SavedIngredientsSection(
                colorScheme: colorScheme,
                ingredients: fridgeIngredients,
                onScanMore: () => Navigator.of(context).pushNamed('/scan'),
                onRemove: (ingredient) {
                  context.read<FridgeProvider>().removeIngredient(ingredient);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$ingredient eliminado de tu nevera'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _EmptyFridgeState extends StatelessWidget {
  const _EmptyFridgeState({required this.colorScheme, required this.onScan});

  final ColorScheme colorScheme;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingXl),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.kitchen_outlined, size: 44, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'A\u00fan no has escaneado alimentos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando guardes ingredientes desde la pantalla de escaneo, apareceran aqui.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Escanear alimentos'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedIngredientsSection extends StatelessWidget {
  const _SavedIngredientsSection({
    required this.colorScheme,
    required this.ingredients,
    required this.onScanMore,
    required this.onRemove,
  });

  final ColorScheme colorScheme;
  final List<String> ingredients;
  final VoidCallback onScanMore;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Ingredientes guardados',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${ingredients.length} ITEMS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              ...List.generate(ingredients.length, (index) {
                final ingredient = ingredients[index];
                final showDivider = index != ingredients.length - 1;

                return Column(
                  children: [
                    _IngredientRow(
                      colorScheme: colorScheme,
                      label: ingredient,
                      onRemove: () => onRemove(ingredient),
                    ),
                    if (showDivider)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.surfaceContainerLow,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: onScanMore,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Escanear mas alimentos'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.colorScheme,
    required this.label,
    required this.onRemove,
  });

  final ColorScheme colorScheme;
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Quitar'),
            style: FilledButton.styleFrom(
              foregroundColor: colorScheme.primary,
              backgroundColor: colorScheme.primaryContainer.withValues(
                alpha: 0.55,
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
