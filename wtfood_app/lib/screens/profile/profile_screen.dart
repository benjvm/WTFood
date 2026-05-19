import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/core/theme.dart';
import 'package:wtfood_app/providers/user_provider.dart';
import 'package:wtfood_app/services/auth_service.dart';
import 'package:wtfood_app/services/cloudinary_service.dart';

class _ProfilePalette {
  const _ProfilePalette({
    required this.background,
    required this.surface,
    required this.surfaceBorder,
    required this.shadow,
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.avatarBackground,
  });

  final Color background;
  final Color surface;
  final Color surfaceBorder;
  final Color shadow;
  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color avatarBackground;

  factory _ProfilePalette.of(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = context.appPalette;

    return _ProfilePalette(
      background: colorScheme.surface,
      surface: colorScheme.surfaceContainerLowest,
      surfaceBorder: colorScheme.outlineVariant,
      shadow: palette.shadowSoft,
      primary: colorScheme.primary,
      primaryDark: palette.brandPrimaryStrong,
      onPrimary: colorScheme.onPrimary,
      accent: colorScheme.secondary,
      textPrimary: colorScheme.onSurface,
      textSecondary: colorScheme.onSurfaceVariant,
      textMuted: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
      avatarBackground: palette.profileAvatarBackground,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.showBackButton = false,
  });

  final bool showBackButton;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  bool _isSaving = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final provider = context.read<UserProvider>();
    final user = provider.user;
    if (user == null) {
      return;
    }

    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      _showSnackbar('Los campos no pueden estar vacios.', isError: true);
      return;
    }

    if (newName == user.name &&
        newEmail == user.email &&
        _selectedImage == null) {
      _showSnackbar('No hay cambios que guardar.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser!;
      String? newPhotoUrl = user.photoUrl;

      if (_selectedImage != null) {
        newPhotoUrl = await _cloudinaryService.uploadProfileImage(
          _selectedImage!,
        );
      }

      if (newName != user.name) {
        await firebaseUser.updateDisplayName(newName);
      }

      if (newEmail != user.email) {
        await firebaseUser.verifyBeforeUpdateEmail(newEmail);
      }

      if (newPhotoUrl != user.photoUrl) {
        await firebaseUser.updatePhotoURL(newPhotoUrl);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'name': newName, 'email': newEmail, 'photoUrl': newPhotoUrl},
      );

      provider.updateUser(
        user.copyWith(name: newName, email: newEmail, photoUrl: newPhotoUrl),
      );

      if (mounted) {
        setState(() => _selectedImage = null);
      }

      _showSnackbar('Cambios guardados correctamente.');
    } catch (error) {
      _showSnackbar('Error al guardar: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('Estas seguro de que quieres cerrar sesion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Cerrar sesion',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();
    }
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null || !mounted) {
        return;
      }

      setState(() => _selectedImage = File(pickedFile.path));
    } catch (error) {
      _showSnackbar('No se pudo seleccionar la imagen: $error', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final palette = _ProfilePalette.of(context);

    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(color: palette.background),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showBackButton) ...[
                _BackToSettingsButton(
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: AppConstants.paddingLg),
              ],
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
                        color: palette.avatarBackground,
                        boxShadow: [
                          BoxShadow(
                            color: palette.shadow,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _ProfileAvatar(
                          selectedImage: _selectedImage,
                          photoUrl: user?.photoUrl,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: _isSaving ? null : _pickProfileImage,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: palette.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: palette.surface,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: palette.accent.withValues(alpha: 0.24),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: palette.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),
              Center(
                child: Text(
                  'Mi Perfil',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: palette.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Gestiona tu informacion personal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingXl),
              _EditableField(
                label: 'NOMBRE COMPLETO',
                controller: _nameController,
                keyboardType: TextInputType.name,
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: AppConstants.paddingMd),
              _EditableField(
                label: 'EMAIL',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: AppConstants.paddingXl),
              _ActionRow(
                icon: Icons.lock_outline_rounded,
                label: 'Cambiar contrasena',
                useTertiary: true,
                onTap: _showChangePasswordSheet,
              ),
              const SizedBox(height: AppConstants.paddingXl),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: GestureDetector(
                  onTap: _isSaving ? null : _saveChanges,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          palette.primaryDark,
                          palette.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: palette.primary.withValues(alpha: 0.24),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSaving
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: palette.onPrimary,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Guardar cambios',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: palette.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMd),
              GestureDetector(
                onTap: _signOut,
                child: Center(
                  child: Text(
                    'Cerrar sesion',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: palette.accent,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackToSettingsButton extends StatelessWidget {
  const _BackToSettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _ProfilePalette.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: palette.primaryDark,
            ),
            const SizedBox(width: 8),
            Text(
              'Volver a configuracion',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.selectedImage, required this.photoUrl});

  final File? selectedImage;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final palette = _ProfilePalette.of(context);
    ImageProvider<Object>? imageProvider;

    if (selectedImage != null) {
      imageProvider = FileImage(selectedImage!);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(photoUrl!);
    }

    return CircleAvatar(
      backgroundColor: palette.avatarBackground,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(
              Icons.person_rounded,
              size: 62,
              color: palette.surface,
            )
          : null,
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.icon,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = _ProfilePalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.paddingMd),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 1.2,
              color: palette.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
            border: Border.all(color: palette.surfaceBorder),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: palette.primary),
              border: InputBorder.none,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLg,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.icon,
    this.useTertiary = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool useTertiary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _ProfilePalette.of(context);
    final iconColor = useTertiary ? palette.accent : palette.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          border: Border.all(color: palette.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
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
                      color: palette.textPrimary,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Rellena todos los campos.');
      return;
    }
    if (newPass.length < 6) {
      setState(
        () => _error = 'La nueva contrasena debe tener al menos 6 caracteres.',
      );
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'Las contrasenas no coinciden.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: current,
      );

      await firebaseUser.reauthenticateWithCredential(credential);
      await firebaseUser.updatePassword(newPass);

      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Contrasena actualizada correctamente.'),
            backgroundColor: colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = switch (e.code) {
          'wrong-password' => 'La contrasena actual es incorrecta.',
          'weak-password' => 'La contrasena es muy debil.',
          'too-many-requests' => 'Demasiados intentos. Intentalo mas tarde.',
          _ => 'Error: ${e.message}',
        };
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _ProfilePalette.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: palette.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cambiar contrasena',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.errorContainer),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _PasswordField(
            controller: _currentController,
            label: 'Contrasena actual',
            obscure: _obscureCurrent,
            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _newController,
            label: 'Nueva contrasena',
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _confirmController,
            label: 'Repite la contrasena',
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: palette.onPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Actualizar contrasena',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = _ProfilePalette.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: palette.textSecondary),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: palette.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: palette.textSecondary,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary),
        ),
      ),
    );
  }
}
