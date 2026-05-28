import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/core/theme.dart';
import 'package:wtfood_app/features/pantry_update/domain/pantry_update_schedule.dart';
import 'package:wtfood_app/features/pantry_update/presentation/pantry_update_frequency_sheet.dart';
import 'package:wtfood_app/features/user/application/user_provider.dart';
import 'package:wtfood_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:wtfood_app/features/auth/data/auth_service.dart';

part '../widgets/settings_screen_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _ProfileRouteScreen()),
    );
  }

  Future<void> _openPantryUpdate() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user == null) {
      _showSnackBar(
        'No pudimos cargar tu configuracion de despensa.',
        isError: true,
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final selectedSchedule =
            sheetContext
                .watch<UserProvider>()
                .user
                ?.pantryUpdateSettings
                .schedule ??
            PantryUpdateSchedule.everyTwoDays;

        return PantryUpdateFrequencySheet(
          selectedSchedule: selectedSchedule,
          onSelected: (schedule) async {
            final didSave = await context
                .read<UserProvider>()
                .updatePantryUpdateSchedule(user.uid, schedule);

            if (!sheetContext.mounted) {
              return;
            }

            if (didSave) {
              Navigator.of(sheetContext).pop();
              _showSnackBar(schedule.confirmationMessage);
              return;
            }

            _showSnackBar(
              'No se pudo guardar tu preferencia de recordatorio.',
              isError: true,
            );
          },
        );
      },
    );
  }

  Future<void> _openAppearanceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        final themeController = sheetContext.watch<ThemeController>();
        final viewInsets = MediaQuery.of(sheetContext).viewInsets;

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
                  'Apariencia',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige como quieres ver WTFood durante el dia y la noche.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLg),
                ...AppThemePreference.values.map(
                  (preference) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AppearanceOptionTile(
                      title: _appearanceTitle(preference),
                      subtitle: _appearanceDescription(preference),
                      icon: _appearanceIcon(preference),
                      selected: themeController.preference == preference,
                      onTap: () => themeController.setPreference(preference),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themePreference = context.watch<ThemeController>().preference;
    final user = context.watch<UserProvider>().user;
    final pantryUpdateSchedule =
        user?.pantryUpdateSettings.schedule ??
        PantryUpdateSchedule.everyTwoDays;
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
              'Configuracion',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona tu cuenta y las preferencias de la app.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.paddingXl),
            Text(
              'Cuenta',
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
                  backgroundColor: colorScheme.secondaryContainer,
                  backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                  child: hasPhoto
                      ? null
                      : Icon(
                          Icons.person_rounded,
                          color: colorScheme.secondary,
                        ),
                ),
                onTap: _openProfile,
              ),
            ),
            const SizedBox(height: AppConstants.paddingXl),
            Text(
              'Configuracion',
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
                    subtitle: _appearanceSummary(themePreference),
                    onTap: _openAppearanceSheet,
                  ),
                  _SettingsDivider(color: colorScheme.outlineVariant),
                  _SettingsTile(
                    icon: Icons.kitchen_outlined,
                    title: 'Actualizacion de despensa',
                    subtitle: pantryUpdateSchedule.settingsSummary,
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
              backgroundColor: colorScheme.errorContainer.withValues(
                alpha: 0.22,
              ),
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
