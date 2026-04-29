import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/providers/user_provider.dart';
import 'package:wtfood_app/screens/profile/profile_screen.dart';
import 'package:wtfood_app/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const _ProfileRouteScreen(),
      ),
    );
  }

  Future<void> _openPantryUpdate() async {
    await Navigator.of(context).pushNamed('/fridge');
  }

  void _showAppearanceMessage() {
    _showSnackBar('Apariencia estara disponible proximamente.');
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('Estas seguro de que quieres salir de la app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Cerrar sesion',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar cuenta'),
        content: const Text(
          'Esta accion eliminara tu cuenta y tus datos guardados. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Borrar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) {
      return;
    }

    try {
      await _authService.deleteAccount();
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString().contains('requires-recent-login')
          ? 'Por seguridad, vuelve a iniciar sesion antes de borrar tu cuenta.'
          : 'No se pudo borrar la cuenta: $error';
      _showSnackBar(message, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<UserProvider>().user;
    final photoUrl = user?.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final title = user != null && user.name.trim().isNotEmpty
        ? user.name
        : 'Mi perfil';
    final subtitle = user != null && user.email.trim().isNotEmpty
        ? user.email
        : 'Informacion personal';

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
            Text(
              'Settings',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona tu cuenta y las preferencias de la app.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.paddingXl),
            Text(
              'Account',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            _SettingsCard(
              child: _SettingsTile(
                title: title,
                subtitle: subtitle,
                customLeading: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.secondaryContainer,
                  backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                  child: hasPhoto
                      ? null
                      : const Icon(
                          Icons.person_rounded,
                          color: AppColors.secondary,
                        ),
                ),
                onTap: _openProfile,
              ),
            ),
            const SizedBox(height: AppConstants.paddingXl),
            Text(
              'Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            _SettingsCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Apariencia',
                    subtitle: 'Personaliza el aspecto de la app',
                    onTap: _showAppearanceMessage,
                  ),
                  _SettingsDivider(color: colorScheme.outlineVariant),
                  _SettingsTile(
                    icon: Icons.kitchen_outlined,
                    title: 'Actualizacion de despensa',
                    subtitle: 'Revisa y ajusta tus ingredientes',
                    onTap: _openPantryUpdate,
                  ),
                  _SettingsDivider(color: colorScheme.outlineVariant),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Cerrar sesion',
                    subtitle: 'Salir de tu cuenta actual',
                    iconColor: colorScheme.error,
                    iconBackground: colorScheme.errorContainer.withValues(
                      alpha: 0.45,
                    ),
                    onTap: _confirmLogout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            _SettingsCard(
              backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.22),
              borderColor: colorScheme.errorContainer,
              child: _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Borrar cuenta',
                subtitle: 'Elimina definitivamente tu cuenta',
                iconColor: colorScheme.error,
                iconBackground: colorScheme.errorContainer.withValues(
                  alpha: 0.6,
                ),
                titleColor: colorScheme.error,
                trailingColor: colorScheme.error,
                onTap: _confirmDeleteAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.child,
    this.backgroundColor = AppColors.surfaceContainerLowest,
    this.borderColor = AppColors.outlineVariant,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.05),
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
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.primaryContainer,
    this.titleColor = AppColors.onSurface,
    this.trailingColor = AppColors.onSurfaceVariant,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? customLeading;
  final Color iconColor;
  final Color iconBackground;
  final Color titleColor;
  final Color trailingColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
            const SizedBox(width: AppConstants.paddingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: trailingColor,
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

class _ProfileRouteScreen extends StatelessWidget {
  const _ProfileRouteScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: ProfileScreen(showBackButton: true),
    );
  }
}
