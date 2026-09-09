import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/core/routes/app_routes.dart';
import 'package:wtfood_app/core/theme.dart';
import 'package:wtfood_app/features/onboarding/onboarding.dart';
import 'package:wtfood_app/features/user/application/user_provider.dart';
import 'package:wtfood_app/features/scan/data/ai_service.dart';
import 'package:wtfood_app/features/scan/presentation/screens/ingredients_review_screen.dart';

part '../widgets/scan_screen_widgets.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  static const String _showcaseScope = 'scan_screen_showcase';

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
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(scope: _showcaseScope);
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
    _showcaseView.unregister();
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

    final user = context.read<UserProvider>().user;
    final uid = user?.uid;
    if (uid == null) {
      return;
    }

    _isEvaluatingTutorial = true;
    final shouldShow = await _onboardingStorageService.shouldShowTutorial(
      ContextualTutorial.scanCamera,
      uid: uid,
    );
    _isEvaluatingTutorial = false;

    if (!mounted || !shouldShow || _hasTriggeredTutorial) {
      return;
    }

    _hasTriggeredTutorial = true;
    await _onboardingStorageService.markTutorialShown(
      ContextualTutorial.scanCamera,
      uid: uid,
    );

    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _showcaseView.startShowCase([_cameraTutorialKey]);
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
                          scope: _showcaseScope,
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
                          Navigator.of(context).pushNamed(AppRoutes.fridge),
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
