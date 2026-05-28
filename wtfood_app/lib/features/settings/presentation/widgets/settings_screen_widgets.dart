part of '../screens/settings_screen.dart';

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.child,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        border: Border.all(color: borderColor ?? colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.customLeading,
    this.iconColor,
    this.iconBackground,
    this.titleColor,
    this.trailingColor,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? customLeading;
  final Color? iconColor;
  final Color? iconBackground;
  final Color? titleColor;
  final Color? trailingColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Row(
          children: [
            customLeading ??
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBackground ?? colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor ?? colorScheme.primary),
                ),
            const SizedBox(width: AppConstants.paddingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: titleColor ?? colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: trailingColor ?? colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
      child: Divider(height: 1, color: color),
    );
  }
}

class _AppearanceOptionTile extends StatelessWidget {
  const _AppearanceOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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
                  icon,
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

class _ProfileRouteScreen extends StatelessWidget {
  const _ProfileRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const ProfileScreen(showBackButton: true),
    );
  }
}

String _appearanceSummary(AppThemePreference preference) {
  switch (preference) {
    case AppThemePreference.system:
      return 'Sigue la configuracion del dispositivo';
    case AppThemePreference.light:
      return 'Tema claro con la paleta original de WTFood';
    case AppThemePreference.dark:
      return 'Tema oscuro calido con verdes y naranjas de la marca';
  }
}

String _appearanceTitle(AppThemePreference preference) {
  switch (preference) {
    case AppThemePreference.system:
      return 'Automatico';
    case AppThemePreference.light:
      return 'Claro';
    case AppThemePreference.dark:
      return 'Oscuro';
  }
}

String _appearanceDescription(AppThemePreference preference) {
  switch (preference) {
    case AppThemePreference.system:
      return 'Usa el modo claro u oscuro segun el sistema.';
    case AppThemePreference.light:
      return 'Mantiene la version luminosa clasica de la app.';
    case AppThemePreference.dark:
      return 'Prioriza confort nocturno sin perder la identidad visual.';
  }
}

IconData _appearanceIcon(AppThemePreference preference) {
  switch (preference) {
    case AppThemePreference.system:
      return Icons.brightness_auto_rounded;
    case AppThemePreference.light:
      return Icons.light_mode_rounded;
    case AppThemePreference.dark:
      return Icons.dark_mode_rounded;
  }
}
