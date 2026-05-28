part of '../screens/shopping_list_detail_screen.dart';

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
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLg,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: item.isChecked
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 34,
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
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      presentation.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isChecked
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.isFromPantry
                              ? 'Disponible en tu nevera'
                              : item.isChecked
                              ? 'Comprado'
                              : 'Pendiente',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: item.isChecked
                                ? colorScheme.onSurfaceVariant
                                : AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if ((item.sourceTag ?? '').isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.sourceTag!,
                              style: theme.textTheme.labelMedium?.copyWith(
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
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    presentation.amountLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
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
