import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../providers/fridge_provider.dart';
import '../../../services/ai_service.dart';
import '../../../services/pixabay_service.dart';
import 'recipe_result_screen.dart';

class IngredientsReviewScreen extends StatefulWidget {
  const IngredientsReviewScreen({
    super.key,
    required this.ingredients,
    required this.imageFile,
  });

  final List<String> ingredients;
  final File imageFile;

  @override
  State<IngredientsReviewScreen> createState() =>
      _IngredientsReviewScreenState();
}

class _IngredientsReviewScreenState extends State<IngredientsReviewScreen> {
  late List<String> _ingredients;
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ingredients = List<String>.from(widget.ingredients);
  }

  void _removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  void _saveIngredientsToFridge() {
    if (_ingredients.isEmpty) {
      setState(() {
        _errorMessage = 'Necesitas al menos un ingrediente para guardarlo.';
      });
      return;
    }

    final addedIngredients =
        context.read<FridgeProvider>().addIngredients(_ingredients);

    setState(() {
      _errorMessage = null;
    });

    final message = addedIngredients == 0
        ? 'Estos ingredientes ya estaban guardados en tu nevera.'
        : '$addedIngredients ingrediente${addedIngredients == 1 ? '' : 's'} guardado${addedIngredients == 1 ? '' : 's'} en tu nevera.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  Future<void> _generateRecipe() async {
    if (_ingredients.isEmpty) {
      setState(() {
        _errorMessage = 'A\u00f1ade al menos un ingrediente para continuar.';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final ingredientsList = _ingredients.join(', ');
      final recipe = await AiService.instance.generateRecipe(ingredientsList);
      final recipeName = (recipe['nombre']?.toString().trim() ?? '');
      final recipePhoto = await const PixabayService().findRecipePhoto(
        recipeName,
      );

      if (mounted && recipePhoto != null) {
        try {
          await precacheImage(NetworkImage(recipePhoto.imageUrl), context);
        } catch (error, stackTrace) {
          debugPrint('No se pudo precargar la imagen de Pixabay: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      if (!mounted) {
        return;
      }

      setState(() => _isGenerating = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeResultScreen(
            recipe: recipe,
            usedIngredients: _ingredients,
            recipePhoto: recipePhoto,
          ),
        ),
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Error: ${error.toString()}';
        _isGenerating = false;
      });
      debugPrint('Error AiService al generar receta: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _isGenerating
          ? null
          : AppBar(
              title: const Text('Ingredientes detectados'),
              backgroundColor: AppColors.surfaceContainerLowest,
              elevation: 0,
            ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.paddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderSection(
                          imageFile: widget.imageFile,
                          count: _ingredients.length,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Ingredientes identificados',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Elimina los incorrectos antes de guardar o generar la receta.',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_ingredients.isEmpty)
                          const _EmptyIngredients()
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              _ingredients.length,
                              (i) => _IngredientChip(
                                label: _ingredients[i],
                                onDelete: () => _removeIngredient(i),
                              ),
                            ),
                          ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _ErrorBanner(message: _errorMessage!),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!_isGenerating)
                  _BottomBar(
                    ingredientCount: _ingredients.length,
                    onSave: _saveIngredientsToFridge,
                    onGenerate: _generateRecipe,
                  ),
              ],
            ),
            if (_isGenerating)
              const Positioned.fill(
                child: _GeneratingRecipeOverlay(),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.imageFile, required this.count});

  final File imageFile;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          child: Image.file(
            imageFile,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSm,
                  ),
                ),
                child: Text(
                  'Analisis completado',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$count ingrediente${count == 1 ? '' : 's'} encontrado${count == 1 ? '' : 's'}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'Revisa la lista antes de guardarla en tu nevera.',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.label, required this.onDelete});

  final String label;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm + 4),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _capitalize(label),
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}

class _EmptyIngredients extends StatelessWidget {
  const _EmptyIngredients();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        border: Border.all(
          color: AppColors.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_rounded,
            size: 36,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Sin ingredientes',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Prueba a escanear otra imagen para detectar nuevos alimentos.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.ingredientCount,
    required this.onSave,
    required this.onGenerate,
  });

  final int ingredientCount;
  final VoidCallback onSave;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingLg,
        AppConstants.paddingMd,
        AppConstants.paddingLg,
        AppConstants.paddingMd + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: ingredientCount > 0 ? onSave : null,
              icon: const Icon(Icons.bookmark_border_rounded),
              label: Text(
                'Guardar ingredientes',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.onSecondaryContainer,
                disabledBackgroundColor:
                    AppColors.secondaryContainer.withValues(alpha: 0.5),
                disabledForegroundColor:
                    AppColors.onSecondaryContainer.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMd),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: ingredientCount > 0 ? onGenerate : null,
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: Text(
                'Generar receta',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.4),
                disabledForegroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMd),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratingRecipeOverlay extends StatelessWidget {
  const _GeneratingRecipeOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: Lottie.asset(
                  'assets/json/Preparing Food.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Generando receta',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Estamos preparando la receta y cargando su imagen.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
