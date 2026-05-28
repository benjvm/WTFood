import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/features/fridge/application/fridge_provider.dart';
import 'package:wtfood_app/features/user/application/user_provider.dart';
import 'package:wtfood_app/features/scan/data/ai_service.dart';
import 'package:wtfood_app/shared/services/pixabay_service.dart';
import 'package:wtfood_app/features/scan/presentation/screens/recipe_result_screen.dart';

part '../widgets/ingredients_review_widgets.dart';

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
  final TextEditingController _addController = TextEditingController();
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ingredients = List<String>.from(widget.ingredients);
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  void _addIngredient() {
    final text = _addController.text.trim();
    if (text.isEmpty) {
      return;
    }

    if (_ingredients.any(
      (ingredient) => ingredient.toLowerCase() == text.toLowerCase(),
    )) {
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$text" ya esta en la lista'),
          backgroundColor: colorScheme.secondary,
        ),
      );
      return;
    }

    setState(() {
      _ingredients.add(text);
      _addController.clear();
      _errorMessage = null;
    });
  }

  Future<void> _saveIngredientsToFridge() async {
    if (_ingredients.isEmpty) {
      setState(() {
        _errorMessage = 'Necesitas al menos un ingrediente para guardarlo.';
      });
      return;
    }

    final addedIngredients = context.read<FridgeProvider>().addIngredients(
      _ingredients,
    );
    final user = context.read<UserProvider>().user;

    if (user != null) {
      await context.read<UserProvider>().registerPantryScan(user.uid);
    }

    if (!mounted) {
      return;
    }

    setState(() => _errorMessage = null);

    final message = addedIngredients == 0
        ? 'Estos ingredientes ya estaban guardados en tu nevera.'
        : '$addedIngredients ingrediente${addedIngredients == 1 ? '' : 's'} guardado${addedIngredients == 1 ? '' : 's'} en tu nevera.';

    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colorScheme.secondary),
    );
  }

  Future<void> _generateRecipe() async {
    if (_ingredients.isEmpty) {
      setState(() {
        _errorMessage = 'Anade al menos un ingrediente para continuar.';
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
      final recipeName = recipe['nombre']?.toString().trim() ?? '';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _isGenerating
          ? null
          : AppBar(
              title: const Text('Ingredientes detectados'),
              backgroundColor: colorScheme.surfaceContainerLowest,
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
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Elimina los incorrectos antes de guardar o generar la receta.',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
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
                        const SizedBox(height: 24),
                        Text(
                          'Anadir ingrediente',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _addController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onSubmitted: (_) => _addIngredient(),
                                decoration: InputDecoration(
                                  hintText: 'ej: tomates, queso, cebolla...',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _addIngredient,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primaryContainer,
                                  foregroundColor:
                                      colorScheme.onPrimaryContainer,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadiusMd,
                                    ),
                                  ),
                                ),
                                child: const Icon(Icons.add_rounded),
                              ),
                            ),
                          ],
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
              const Positioned.fill(child: _GeneratingRecipeOverlay()),
          ],
        ),
      ),
    );
  }
}
