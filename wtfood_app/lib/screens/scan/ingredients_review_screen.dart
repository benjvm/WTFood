import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/constants.dart';
import '../../../core/env.dart';
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
    if (text.isEmpty) return;

    if (_ingredients.any((i) => i.toLowerCase() == text.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$text" ya esta en la lista'),
          backgroundColor: AppColors.secondary,
        ),
      );
      return;
    }

    setState(() {
      _ingredients.add(text);
      _addController.clear();
    });
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
      final promptText =
          'Eres un chef profesional. Con los siguientes ingredientes: '
          '$ingredientsList, crea una receta detallada y deliciosa.';

      final recipeSchema = Schema.object(
        properties: {
          'nombre': Schema.string(description: 'Nombre del plato'),
          'descripcion': Schema.string(
            description: 'Breve descripcion apetitosa del plato (2-3 frases)',
          ),
          'tiempo_preparacion': Schema.string(description: 'Ejemplo: 15 min'),
          'tiempo_coccion': Schema.string(description: 'Ejemplo: 30 min'),
          'porciones': Schema.integer(
            description: 'Cantidad de porciones, ejemplo: 2',
          ),
          'dificultad': Schema.string(
            description: 'Facil, Media o Dificil',
          ),
          'ingredientes': Schema.array(
            description: 'Lista de ingredientes con cantidades',
            items: Schema.object(
              properties: {
                'cantidad': Schema.string(),
                'unidad': Schema.string(),
                'nombre': Schema.string(),
              },
              requiredProperties: ['cantidad', 'unidad', 'nombre'],
            ),
          ),
          'pasos': Schema.array(
            description: 'Lista de pasos para la preparacion',
            items: Schema.string(),
          ),
          'consejos': Schema.string(
            description: 'Tip o consejo del chef para esta receta',
          ),
        },
        requiredProperties: [
          'nombre',
          'descripcion',
          'tiempo_preparacion',
          'tiempo_coccion',
          'porciones',
          'dificultad',
          'ingredientes',
          'pasos',
          'consejos',
        ],
      );

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: AppEnv.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          responseMimeType: 'application/json',
          responseSchema: recipeSchema,
        ),
      );

      final response = await model.generateContent([
        Content.text(promptText),
      ]);

      if (response.text == null) {
        throw Exception('La IA no devolvio texto.');
      }

      final recipe = jsonDecode(response.text!) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() => _isGenerating = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeResultScreen(
            recipe: recipe,
            usedIngredients: _ingredients,
          ),
        ),
      );
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error real: ${error.toString()}';
        _isGenerating = false;
      });
      debugPrint('Error Gemini al generar receta: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ingredientes detectados'),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
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
                      'Elimina los incorrectos o anade los que falten.',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_ingredients.isEmpty)
                      _EmptyIngredients()
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
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _addController,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _addIngredient(),
                            decoration: InputDecoration(
                              hintText: 'ej: tomates, queso, cebolla...',
                              hintStyle: GoogleFonts.manrope(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceContainerLowest,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMd,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.outline,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMd,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.outline,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMd,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: ElevatedButton(
                            onPressed: _addIngredient,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMd,
                                ),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            child: const Icon(Icons.add_rounded, size: 24),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _ErrorBanner(message: _errorMessage!),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        ingredientCount: _ingredients.length,
        isGenerating: _isGenerating,
        onGenerate: _generateRecipe,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                'Revisa y edita la lista antes de generar la receta.',
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
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _EmptyIngredients extends StatelessWidget {
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
            'Anade ingredientes usando el campo de abajo.',
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
    required this.isGenerating,
    required this.onGenerate,
  });

  final int ingredientCount;
  final bool isGenerating;
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
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: (ingredientCount > 0 && !isGenerating) ? onGenerate : null,
          icon: isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.onPrimary,
                  ),
                )
              : const Icon(Icons.restaurant_menu_rounded),
          label: Text(
            isGenerating ? 'Generando receta...' : 'Generar receta',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
            disabledForegroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
