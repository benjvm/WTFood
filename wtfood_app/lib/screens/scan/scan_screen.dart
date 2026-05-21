import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../features/onboarding/onboarding.dart';
import '../../../services/ai_service.dart';
import 'ingredients_review_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final OnboardingStorageService _onboardingStorageService =
      OnboardingStorageService();
  final GlobalKey _cameraTutorialKey = GlobalKey();

  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _errorMessage;
  bool _isEvaluatingTutorial = false;
  bool _hasTriggeredTutorial = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    ShowcaseView.register();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    ShowcaseView.get().unregister();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _errorMessage = null);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked == null) {
        return;
      }

      setState(() => _selectedImage = File(picked.path));
    } catch (_) {
      setState(
        () => _errorMessage =
            'No se pudo acceder a la ${source == ImageSource.camera ? 'camara' : 'galeria'}.',
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final imageBytes = await _selectedImage!.readAsBytes();
      final extension = _selectedImage!.path.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

      final ingredients = await AiService.instance.analyzeIngredients(
        imageBytes: imageBytes,
        mimeType: mimeType,
      );

      if (!mounted) {
        return;
      }

      if (ingredients.isEmpty) {
        setState(() {
          _errorMessage =
              'No se detectaron ingredientes. Intenta con otra imagen.';
          _isAnalyzing = false;
        });
        return;
      }

      setState(() => _isAnalyzing = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IngredientsReviewScreen(
            ingredients: ingredients,
            imageFile: _selectedImage!,
          ),
        ),
      );
    } catch (error) {
      debugPrint('DEBUG ERROR AiService (scan): $error');
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Error: ${error.toString()}';
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _scheduleScanTutorial() async {
    if (_hasTriggeredTutorial || _isEvaluatingTutorial || !mounted) {
      return;
    }

    _isEvaluatingTutorial = true;
    final shouldShow = await _onboardingStorageService.shouldShowTutorial(
      ContextualTutorial.scanCamera,
    );
    _isEvaluatingTutorial = false;

    if (!mounted || !shouldShow || _hasTriggeredTutorial) {
      return;
    }

    _hasTriggeredTutorial = true;
    await _onboardingStorageService.markTutorialShown(
      ContextualTutorial.scanCamera,
    );

    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ShowcaseView.get().startShowCase([_cameraTutorialKey]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scheduleScanTutorial();
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Escanea tu nevera!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Haz una foto o sube una imagen y la IA identificara los ingredientes automaticamente.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _ImagePreviewCard(
                    image: _selectedImage,
                    pulseAnimation: _pulseAnimation,
                    isAnalyzing: _isAnalyzing,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Showcase(
                          key: _cameraTutorialKey,
                          title: 'Escaneo rapido',
                          description: 'Apunta la camara a tus ingredientes.',
                          tooltipBackgroundColor:
                              colorScheme.surfaceContainerLowest,
                          textColor: colorScheme.onSurface,
                          titleTextStyle: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          descTextStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                          overlayColor: colorScheme.onSurface,
                          overlayOpacity: 0.72,
                          targetBorderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMd,
                          ),
                          child: _SourceButton(
                            icon: Icons.photo_camera_rounded,
                            label: 'Camara',
                            onTap: _isAnalyzing
                                ? null
                                : () => _pickImage(ImageSource.camera),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SourceButton(
                          icon: Icons.photo_library_rounded,
                          label: 'Galeria',
                          onTap: _isAnalyzing
                              ? null
                              : () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    _ErrorBanner(message: _errorMessage!),
                  if (_errorMessage != null) const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: _selectedImage != null ? 1.0 : 0.45,
                    duration: const Duration(milliseconds: 300),
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: (_selectedImage != null && !_isAnalyzing)
                            ? _analyzeImage
                            : null,
                        icon: _isAnalyzing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.search_rounded),
                        label: Text(
                          _isAnalyzing
                              ? 'Analizando imagen...'
                              : 'Identificar ingredientes',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          disabledBackgroundColor: colorScheme.primary
                              .withValues(alpha: 0.4),
                          disabledForegroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMd,
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/fridge'),
                      icon: const Icon(Icons.kitchen_outlined),
                      label: Text(
                        'Ver mi nevera',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMd,
                          ),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _TipsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ImagePreviewCard extends StatelessWidget {
  const _ImagePreviewCard({
    required this.image,
    required this.pulseAnimation,
    required this.isAnalyzing,
    required this.onTap,
  });

  final File? image;
  final Animation<double> pulseAnimation;
  final bool isAnalyzing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = context.appPalette;

    return GestureDetector(
      onTap: isAnalyzing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 220,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
          border: Border.all(
            color: image != null
                ? colorScheme.primary.withValues(alpha: 0.4)
                : colorScheme.outline,
            width: image != null ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: image != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(image!, fit: BoxFit.cover),
                  if (isAnalyzing)
                    ColoredBox(
                      color: palette.overlayScrim,
                      child: Center(
                        child: ScaleTransition(
                          scale: pulseAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Identificando ingredientes...',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 36,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Toca para anadir una imagen',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG o PNG',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  const _TipsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tips = [
      (
        Icons.wb_sunny_rounded,
        'Buena iluminacion',
        'La imagen debe tener buena luz natural o artificial.',
      ),
      (
        Icons.grid_view_rounded,
        'Ingredientes visibles',
        'Coloca los ingredientes separados y bien visibles.',
      ),
      (
        Icons.crop_rounded,
        'Encuadre cercano',
        'Acercate para que los ingredientes ocupen la imagen.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consejos para mejores resultados',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusSm,
                      ),
                    ),
                    child: Icon(tip.$1, size: 16, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.$2,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          tip.$3,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
