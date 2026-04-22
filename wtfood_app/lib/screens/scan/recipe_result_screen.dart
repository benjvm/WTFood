import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';

class RecipeResultScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final List<String> usedIngredients;

  const RecipeResultScreen({
    super.key,
    required this.recipe,
    required this.usedIngredients,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = recipe['nombre'] as String? ?? 'Receta';
    final descripcion = recipe['descripcion'] as String? ?? '';
    final tiempoPrep = recipe['tiempo_preparacion'] as String? ?? '--';
    final tiempoCoc = recipe['tiempo_coccion'] as String? ?? '--';
    final porciones = recipe['porciones']?.toString() ?? '2';
    final dificultad = recipe['dificultad'] as String? ?? 'Media';
    final ingredientes =
        (recipe['ingredientes'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
    final pasos =
        (recipe['pasos'] as List<dynamic>? ?? []).cast<String>();
    final consejos = recipe['consejos'] as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ─────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(
                nombre,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimary,
                  letterSpacing: -0.4,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                    )
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0B8A43),
                          Color(0xFF067437),
                          Color(0xFF054F28),
                        ],
                      ),
                    ),
                  ),
                  // Decorative pattern
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -30,
                    child: Opacity(
                      opacity: 0.07,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay for title readability
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x88000000)],
                          stops: [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: 'Compartir receta',
                onPressed: () {
                  // TODO: implement share
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compartir próximamente...')),
                  );
                },
              ),
            ],
          ),

          // ── Body ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (descripcion.isNotEmpty) ...[
                    Text(
                      descripcion,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Stats row
                  _StatsRow(
                    tiempoPrep: tiempoPrep,
                    tiempoCoc: tiempoCoc,
                    porciones: porciones,
                    dificultad: dificultad,
                  ),

                  const SizedBox(height: 28),
                  const _Divider(),
                  const SizedBox(height: 28),

                  // Ingredients section
                  _SectionTitle(
                      icon: Icons.egg_alt_rounded, title: 'Ingredientes'),
                  const SizedBox(height: 14),
                  ...ingredientes.map(
                    (ing) => _IngredientRow(ingredient: ing),
                  ),

                  const SizedBox(height: 28),
                  const _Divider(),
                  const SizedBox(height: 28),

                  // Steps section
                  _SectionTitle(
                      icon: Icons.format_list_numbered_rounded,
                      title: 'Preparación'),
                  const SizedBox(height: 14),
                  ...pasos.asMap().entries.map(
                        (e) => _StepCard(number: e.key + 1, text: e.value),
                      ),

                  // Chef tip
                  if (consejos != null && consejos.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _ChefTip(tip: consejos),
                  ],

                  const SizedBox(height: 32),

                  // Used ingredients info
                  _UsedIngredientsNote(ingredients: usedIngredients),

                  const SizedBox(height: 40),

                  // Start over button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Pop back to scan screen
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        );
                      },
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(
                        'Escanear nuevos ingredientes',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.borderRadiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Sub-widgets
// ─────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final String tiempoPrep;
  final String tiempoCoc;
  final String porciones;
  final String dificultad;

  const _StatsRow({
    required this.tiempoPrep,
    required this.tiempoCoc,
    required this.porciones,
    required this.dificultad,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
            icon: Icons.timer_rounded,
            label: 'Preparación',
            value: tiempoPrep),
        _StatItem(
            icon: Icons.local_fire_department_rounded,
            label: 'Cocción',
            value: tiempoCoc),
        _StatItem(
            icon: Icons.people_rounded,
            label: 'Porciones',
            value: porciones),
        _StatItem(
            icon: Icons.bar_chart_rounded,
            label: 'Dificultad',
            value: dificultad,
            isLast: true),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isLast ? 0 : 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final Map<String, dynamic> ingredient;

  const _IngredientRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final cantidad = ingredient['cantidad']?.toString() ?? '';
    final unidad = ingredient['unidad']?.toString() ?? '';
    final nombre = ingredient['nombre']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _capitalize(nombre),
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Text(
            '$cantidad $unidad'.trim(),
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _StepCard extends StatelessWidget {
  final int number;
  final String text;

  const _StepCard({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Text(
                text,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.onSurface,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChefTip extends StatelessWidget {
  final String tip;
  const _ChefTip({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👨‍🍳', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consejo del chef',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.onSecondaryContainer,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsedIngredientsNote extends StatelessWidget {
  final List<String> ingredients;
  const _UsedIngredientsNote({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredientes usados para esta receta',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ingredients.map((ing) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSm),
                ),
                child: Text(
                  ing,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.outlineVariant,
    );
  }
}
