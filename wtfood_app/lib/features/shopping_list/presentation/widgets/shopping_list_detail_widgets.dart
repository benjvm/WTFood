part of '../screens/shopping_list_detail_screen.dart';

class _ShoppingProgressOverview extends StatelessWidget {
  const _ShoppingProgressOverview({required this.shoppingList});

  final ShoppingList shoppingList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = shoppingList.completionProgress.clamp(0.0, 1.0).toDouble();
    final percentage = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROGRESO DE COMPRA',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  _shoppingProgressMessage(progress, shoppingList),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMd),
              Text(
                '$percentage% (${shoppingList.completedItemsCount}/${shoppingList.totalItemsCount})',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

String _shoppingProgressMessage(double progress, ShoppingList shoppingList) {
  if (shoppingList.totalItemsCount == 0) {
    return 'Sin ingredientes';
  }

  if (progress >= 1) {
    return 'A cocinar!';
  }

  if (progress >= 0.7) {
    return 'Casi listo';
  }

  if (progress >= 0.35) {
    return 'Buen ritmo';
  }

  if (progress > 0) {
    return 'En marcha';
  }

  return 'Por empezar';
}

class _ShoppingListItemCard extends StatelessWidget {
  const _ShoppingListItemCard({required this.item, this.onTap});

  final ShoppingListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final presentation = _parseIngredient(item.rawText);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMd,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: item.isChecked
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.isChecked
                      ? AppColors.primary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isChecked
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.22),
                    width: 2,
                  ),
                ),
                child: item.isChecked
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 17,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      presentation.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isChecked
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.isFromPantry
                              ? 'Disponible en tu nevera'
                              : item.isChecked
                              ? 'Comprado'
                              : 'Pendiente',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: item.isChecked
                                ? colorScheme.onSurfaceVariant
                                : AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if ((item.sourceTag ?? '').isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.sourceTag!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (presentation.amountLabel.isNotEmpty) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    presentation.amountLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ParsedIngredient {
  const _ParsedIngredient({required this.name, required this.amountLabel});

  final String name;
  final String amountLabel;
}

_ParsedIngredient _parseIngredient(String rawText) {
  final normalized = rawText.trim().replaceAll(RegExp(r'\s+'), ' ');
  final match = RegExp(
    r'^(\d+(?:[.,]\d+)?(?:/\d+(?:[.,]\d+)?)?)\s*([A-Za-z]+)?\s+(.+)$',
  ).firstMatch(normalized);

  if (match == null) {
    return _ParsedIngredient(name: normalized, amountLabel: '');
  }

  final quantity = match.group(1)?.trim() ?? '';
  final unit = match.group(2)?.trim() ?? '';
  final name = match.group(3)?.trim() ?? normalized;
  final amountLabel = [
    quantity,
    unit,
  ].where((value) => value.isNotEmpty).join(' ').toUpperCase();

  return _ParsedIngredient(name: name, amountLabel: amountLabel);
}
