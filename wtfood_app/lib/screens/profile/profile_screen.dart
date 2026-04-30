import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/providers/user_provider.dart';
import 'package:wtfood_app/services/auth_service.dart';
import 'package:wtfood_app/services/cloudinary_service.dart';

class _ProfilePalette {
  static const Color background = Color(0xFFF6F7F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceBorder = Color(0xFFE8ECE6);
  static const Color shadow = Color(0x140D2A18);

  static const Color primary = Color(0xFF0B8A43);
  static const Color primaryDark = Color(0xFF067437);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color accent = Color(0xFFFF8A24);
  static const Color textPrimary = Color(0xFF29342D);
  static const Color textSecondary = Color(0xFF7A847C);
  static const Color textMuted = Color(0xFFAAB1AB);
  static const Color avatarBackground = Color(0xFFE3E3E3);
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

  // ── Guardar cambios de perfil ─────────────────────────────────────────────

  Future<void> _saveChanges() async {
    final provider = context.read<UserProvider>();
    final user = provider.user;
    if (user == null) return;

    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      _showSnackbar('Los campos no pueden estar vacíos.', isError: true);
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

      // Actualizar nombre en Firebase Auth
      if (newName != user.name) {
        await firebaseUser.updateDisplayName(newName);
      }

      // Actualizar email en Firebase Auth (requiere reautenticación si cambia)
      if (newEmail != user.email) {
        await firebaseUser.verifyBeforeUpdateEmail(newEmail);
      }

      if (newPhotoUrl != user.photoUrl) {
        await firebaseUser.updatePhotoURL(newPhotoUrl);
      }

      // Actualizar en Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'name': newName, 'email': newEmail, 'photoUrl': newPhotoUrl},
      );

      // Actualizar estado local
      provider.updateUser(
        user.copyWith(name: newName, email: newEmail, photoUrl: newPhotoUrl),
      );

      if (mounted) {
        setState(() => _selectedImage = null);
      }

      _showSnackbar('Cambios guardados correctamente.');
    } catch (e) {
      _showSnackbar('Error al guardar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Cerrar sesión ─────────────────────────────────────────────────────────

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Cerrar sesión',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) await AuthService().logout();
  }

  // ── Cambiar contraseña (bottom sheet) ─────────────────────────────────────

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

      if (pickedFile == null || !mounted) return;

      setState(() => _selectedImage = File(pickedFile.path));
    } catch (e) {
      _showSnackbar('No se pudo seleccionar la imagen: $e', isError: true);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return SafeArea(
      child: DecoratedBox(
        decoration: const BoxDecoration(color: _ProfilePalette.background),
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

            // Avatar
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _ProfilePalette.avatarBackground,
                      boxShadow: [
                        BoxShadow(
                          color: _ProfilePalette.shadow,
                          blurRadius: 20,
                          offset: Offset(0, 10),
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
                          color: _ProfilePalette.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _ProfilePalette.surface,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33FF8A24),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: _ProfilePalette.onPrimary,
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
                  color: _ProfilePalette.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Gestiona tu información personal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _ProfilePalette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingXl),

            // Nombre
            _EditableField(
              label: 'NOMBRE COMPLETO',
              controller: _nameController,
              keyboardType: TextInputType.name,
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppConstants.paddingMd),

            // Email
            _EditableField(
              label: 'EMAIL',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: AppConstants.paddingXl),

            // Cambiar contraseña
            _ActionRow(
              icon: Icons.lock_outline_rounded,
              label: 'Cambiar contraseña',
              useTertiary: true,
              onTap: _showChangePasswordSheet,
            ),

            const SizedBox(height: AppConstants.paddingXl),

            // Botón Save Changes
            SizedBox(
              width: double.infinity,
              height: 60,
              child: GestureDetector(
                onTap: _isSaving ? null : _saveChanges,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        _ProfilePalette.primaryDark,
                        _ProfilePalette.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330B8A43),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: _ProfilePalette.onPrimary,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Guardar cambios',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: _ProfilePalette.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingMd),

            // Sign out
            GestureDetector(
              onTap: _signOut,
              child: Center(
                child: Text(
                  'Cerrar sesión',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _ProfilePalette.accent,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: _ProfilePalette.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _ProfilePalette.surfaceBorder),
          boxShadow: const [
            BoxShadow(
              color: _ProfilePalette.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: _ProfilePalette.primaryDark,
            ),
            const SizedBox(width: 8),
            Text(
              'Volver a configuración',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: _ProfilePalette.primaryDark,
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
  final File? selectedImage;
  final String? photoUrl;

  const _ProfileAvatar({required this.selectedImage, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? imageProvider;

    if (selectedImage != null) {
      imageProvider = FileImage(selectedImage!);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(photoUrl!);
    }

    return CircleAvatar(
      backgroundColor: _ProfilePalette.avatarBackground,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? const Icon(
              Icons.person_rounded,
              size: 62,
              color: _ProfilePalette.surface,
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Campo editable
// ─────────────────────────────────────────────────────────────────────────────

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData icon;

  const _EditableField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.icon,
  });

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
              color: _ProfilePalette.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _ProfilePalette.surface,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
            border: Border.all(color: _ProfilePalette.surfaceBorder),
            boxShadow: const [
              BoxShadow(
                color: _ProfilePalette.shadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: _ProfilePalette.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: _ProfilePalette.primary,
              ),
              border: InputBorder.none,
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

// ─────────────────────────────────────────────────────────────────────────────
// Fila de acción (igual que el original)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool useTertiary;
  final VoidCallback? onTap;

  const _ActionRow({
    required this.label,
    required this.icon,
    this.useTertiary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = useTertiary
        ? _ProfilePalette.accent
        : _ProfilePalette.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
        decoration: BoxDecoration(
          color: _ProfilePalette.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          border: Border.all(color: _ProfilePalette.surfaceBorder),
          boxShadow: const [
            BoxShadow(
              color: _ProfilePalette.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _ProfilePalette.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _ProfilePalette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet: cambiar contraseña
// ─────────────────────────────────────────────────────────────────────────────

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
        () => _error = 'La nueva contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'Las contraseñas no coinciden.');
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

      // Reautenticar antes de cambiar la contraseña
      await firebaseUser.reauthenticateWithCredential(credential);
      await firebaseUser.updatePassword(newPass);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada correctamente.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = switch (e.code) {
          'wrong-password' => 'La contraseña actual es incorrecta.',
          'weak-password' => 'La contraseña es muy débil.',
          'too-many-requests' => 'Demasiados intentos. Inténtalo más tarde.',
          _ => 'Error: ${e.message}',
        };
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _ProfilePalette.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cambiar contraseña',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: _ProfilePalette.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Error
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.errorContainer),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Contraseña actual
          _PasswordField(
            controller: _currentController,
            label: 'Contraseña actual',
            obscure: _obscureCurrent,
            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 12),

          // Nueva contraseña
          _PasswordField(
            controller: _newController,
            label: 'Nueva contraseña',
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 12),

          // Confirmar contraseña
          _PasswordField(
            controller: _confirmController,
            label: 'Repite la contraseña',
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 24),

          // Botón
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ProfilePalette.primary,
                foregroundColor: _ProfilePalette.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: _ProfilePalette.onPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Actualizar contraseña',
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
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _ProfilePalette.textSecondary),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: _ProfilePalette.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: _ProfilePalette.textSecondary,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: _ProfilePalette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _ProfilePalette.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _ProfilePalette.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _ProfilePalette.primary),
        ),
      ),
    );
  }
}
