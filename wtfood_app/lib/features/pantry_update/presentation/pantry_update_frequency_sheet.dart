import 'package:flutter/material.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/features/pantry_update/domain/pantry_update_schedule.dart';

class PantryUpdateFrequencySheet extends StatelessWidget {
  const PantryUpdateFrequencySheet({
    super.key,
    required this.selectedSchedule,
    required this.onSelected,
  });

  final PantryUpdateSchedule selectedSchedule;
  final ValueChanged<PantryUpdateSchedule> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppConstants.paddingLg,
          AppConstants.paddingLg,
          AppConstants.paddingLg,
          AppConstants.paddingXl + viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actualizacion de despensa',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elige cada cuanto quieres que te recordemos actualizar tu nevera al entrar en Inicio.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            ...PantryUpdateSchedule.values.map(
              (schedule) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PantryUpdateOptionTile(
                  title: schedule.title,
                  subtitle: schedule.settingsSummary,
                  selected: selectedSchedule == schedule,
                  onTap: () => onSelected(schedule),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PantryUpdateOptionTile extends StatelessWidget {
  const _PantryUpdateOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primaryContainer.withValues(alpha: 0.75)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
            border: Border.all(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.28)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary.withValues(alpha: 0.14)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.kitchen_outlined,
                  color: selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
