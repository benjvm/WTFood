import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingMd),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surfaceContainerLowest,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(8, 8),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 18,
                          offset: Offset(-8, -8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_rounded,
                          size: 62,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 18,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            Center(
              child: Text(
                'My Profile',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Manage your personal information',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingXl),
            const _ProfileField(
              label: 'FULL NAME',
              value: 'Jane Doe',
            ),
            const SizedBox(height: AppConstants.paddingMd),
            const _ProfileField(
              label: 'EMAIL',
              value: 'jane.doe@example.com',
            ),
            const SizedBox(height: AppConstants.paddingXl),
            const _ActionRow(
              icon: Icons.lock_outline_rounded,
              label: 'Change Password',
              useTertiary: true,
            ),
            const SizedBox(height: AppConstants.paddingMd),
            const _ActionRow(
              icon: Icons.notifications_none_rounded,
              label: 'Notification Settings',
            ),
            const SizedBox(height: AppConstants.paddingXl),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.onPrimaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Save Changes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            Center(
              child: Text(
                'SIGN OUT',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.paddingMd),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(3, 3),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 10,
                offset: Offset(-3, -3),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool useTertiary;

  const _ActionRow({
    required this.label,
    required this.icon,
    this.useTertiary = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = useTertiary
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppConstants.paddingMd),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
