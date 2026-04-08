import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import '../../models/ingredient.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  static const int _maxPreviewItemsPerCategory = 4;
  late final TextEditingController _searchController;
  List<Ingredient> _catalogIngredients = <Ingredient>[];
  List<Ingredient> _fridgeIngredients = <Ingredient>[];
  List<String> _categories = <String>[];

  String _query = '';
  String _selectedCategory = _allCategoriesLabel;
  bool _isLoading = true;

  static const String _allCategoriesLabel = 'Todas';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadIngredients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fridgeSections = _buildSections(_fridgeIngredients);
    final catalogSections = _buildSections(
      _filteredCatalogIngredients,
      limitItemsPerSection: _selectedCategory == _allCategoriesLabel
          ? _maxPreviewItemsPerCategory
          : null,
    );

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.12),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingLg,
            AppConstants.paddingMd,
            AppConstants.paddingLg,
            140,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchBar(
                colorScheme: colorScheme,
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _query = value.trim().toLowerCase());
                },
              ),
              const SizedBox(height: AppConstants.paddingLg),
              _CategoryChips(
                colorScheme: colorScheme,
                categories: _categories,
                selectedCategory: _selectedCategory,
                onChanged: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              const SizedBox(height: 28),
              _SectionHeading(
                title: 'Lo que hay en tu nevera',
                subtitle:
                    'Dinos que ingredientes tienes disponibles y nosotros te daremos una receta!',
              ),
              const SizedBox(height: 14),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                _SelectedIngredientsPanel(
                  colorScheme: colorScheme,
                  sections: fridgeSections,
                  onRemove: _removeIngredientFromFridge,
                  onCreateRecipe: _handleCreateRecipe,
                ),
                const SizedBox(height: 28),
                _SectionHeading(
                  title: 'Añadir ingredientes',
                  subtitle:
                      'Explora la lista y pulsa + para agregar ingredientes a tu nevera.',
                ),
                const SizedBox(height: 14),
                _InventorySections(
                  colorScheme: colorScheme,
                  sections: catalogSections,
                  actionLabel: 'AGREGAR',
                  actionIcon: Icons.add_rounded,
                  onAction: _addIngredientToFridge,
                  onViewAll: _selectedCategory == _allCategoriesLabel
                      ? _showCategory
                      : null,
                  emptyTitle: 'No encontramos ingredientes',
                  emptySubtitle:
                      'Prueba con otra categoría o ajusta la búsqueda.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadIngredients() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/ingredientes.json');
      final decoded = json.decode(jsonString) as List<dynamic>;
      final ingredients = decoded
          .whereType<Map<String, dynamic>>()
          .map(_ingredientFromJson)
          .toList();
      final categories = ingredients
          .map((ingredient) => ingredient.category)
          .toSet()
          .toList()
        ..sort();

      if (!mounted) {
        return;
      }

      setState(() {
        _catalogIngredients = ingredients;
        _fridgeIngredients = <Ingredient>[];
        _categories = <String>[_allCategoriesLabel, ...categories];
        _selectedCategory = _allCategoriesLabel;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _catalogIngredients = <Ingredient>[];
        _fridgeIngredients = <Ingredient>[];
        _categories = const <String>[_allCategoriesLabel];
        _selectedCategory = _allCategoriesLabel;
        _isLoading = false;
      });
    }
  }

  Ingredient _ingredientFromJson(Map<String, dynamic> jsonMap) {
    return Ingredient(
      id: jsonMap['id'].toString(),
      name: jsonMap['nombre']?.toString() ?? '',
      quantity: 1,
      unit: 'unidad',
      category: jsonMap['categoria']?.toString() ?? 'Sin categoría',
      imageUrl: '',
    );
  }

  List<_InventorySectionData> _buildSections(
    List<Ingredient> items, {
    int? limitItemsPerSection,
  }) {
    final groupedItems = <String, List<Ingredient>>{};

    for (final ingredient in items) {
      groupedItems.putIfAbsent(ingredient.category, () => <Ingredient>[]);
      groupedItems[ingredient.category]!.add(ingredient);
    }

    return groupedItems.entries
        .map(
          (entry) {
            final allItems = entry.value;
            final visibleItems = limitItemsPerSection == null
                ? allItems
                : allItems.take(limitItemsPerSection).toList();

            return _InventorySectionData(
              title: entry.key,
              items: visibleItems,
              totalItemsCount: allItems.length,
              hasMoreItems: visibleItems.length < allItems.length,
            );
          },
        )
        .toList();
  }

  List<Ingredient> get _filteredCatalogIngredients {
    return _catalogIngredients.where((ingredient) {
      final matchesSearch = _query.isEmpty ||
          ingredient.name.toLowerCase().contains(_query) ||
          ingredient.category.toLowerCase().contains(_query);
      final matchesCategory = _selectedCategory == _allCategoriesLabel ||
          ingredient.category == _selectedCategory;
      final isAlreadyInFridge =
          _fridgeIngredients.any((item) => item.id == ingredient.id);

      return matchesSearch && matchesCategory && !isAlreadyInFridge;
    }).toList();
  }

  void _addIngredientToFridge(Ingredient ingredient) {
    final alreadyAdded =
        _fridgeIngredients.any((item) => item.id == ingredient.id);
    if (alreadyAdded) {
      return;
    }

    setState(() {
      _fridgeIngredients = <Ingredient>[..._fridgeIngredients, ingredient];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ingredient.name} añadido a tu nevera'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _removeIngredientFromFridge(Ingredient ingredient) {
    setState(() {
      _fridgeIngredients.removeWhere((item) => item.id == ingredient.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ingredient.name} eliminado de tu nevera'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _handleCreateRecipe() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Pronto podrás generar una receta con estos ingredientes.',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.colorScheme,
    required this.controller,
    required this.onChanged,
  });

  final ColorScheme colorScheme;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 12,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Busca ingredientes...',
          hintStyle: TextStyle(
            color: colorScheme.outline.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.outline,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.colorScheme,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final ColorScheme colorScheme;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onChanged(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(
                          alpha: isSelected ? 0.14 : 0.05,
                        ),
                        blurRadius: 12,
                        offset: const Offset(4, 4),
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        blurRadius: 10,
                        offset: Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SelectedIngredientsPanel extends StatelessWidget {
  const _SelectedIngredientsPanel({
    required this.colorScheme,
    required this.sections,
    required this.onRemove,
    required this.onCreateRecipe,
  });

  final ColorScheme colorScheme;
  final List<_InventorySectionData> sections;
  final ValueChanged<Ingredient> onRemove;
  final VoidCallback onCreateRecipe;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return _EmptyState(
        colorScheme: colorScheme,
        title: 'Tu nevera está vacía',
        subtitle: 'Todavía no has añadido ingredientes.',
      );
    }

    return Column(
      children: [
        _InventorySections(
          colorScheme: colorScheme,
          sections: sections,
          actionLabel: 'QUITAR',
          actionIcon: Icons.close_rounded,
          onAction: onRemove,
          emptyTitle: '',
          emptySubtitle: '',
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onCreateRecipe,
            icon: const Icon(Icons.restaurant_menu_rounded),
            label: const Text('Crear receta'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InventorySections extends StatelessWidget {
  const _InventorySections({
    required this.colorScheme,
    required this.sections,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.onViewAll,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final ColorScheme colorScheme;
  final List<_InventorySectionData> sections;
  final String actionLabel;
  final IconData actionIcon;
  final ValueChanged<Ingredient> onAction;
  final ValueChanged<String>? onViewAll;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return _EmptyState(
        colorScheme: colorScheme,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return Column(
      children: sections.map((section) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: _InventorySectionCard(
            colorScheme: colorScheme,
            section: section,
            actionLabel: actionLabel,
            actionIcon: actionIcon,
            onAction: onAction,
            onViewAll: onViewAll,
          ),
        );
      }).toList(),
    );
  }
}

class _InventorySectionCard extends StatelessWidget {
  const _InventorySectionCard({
    required this.colorScheme,
    required this.section,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.onViewAll,
  });

  final ColorScheme colorScheme;
  final _InventorySectionData section;
  final String actionLabel;
  final IconData actionIcon;
  final ValueChanged<Ingredient> onAction;
  final ValueChanged<String>? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${section.totalItemsCount} ITEMS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              ...List.generate(section.items.length, (index) {
                final item = section.items[index];
                final showDivider = index != section.items.length - 1 ||
                    (section.hasMoreItems && onViewAll != null);

                return Column(
                  children: [
                    _InventoryRow(
                      colorScheme: colorScheme,
                      label: item.name,
                      actionLabel: actionLabel,
                      actionIcon: actionIcon,
                      onAction: () => onAction(item),
                    ),
                    if (showDivider)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.surfaceContainerLow,
                      ),
                  ],
                );
              }),
              if (section.hasMoreItems && onViewAll != null)
                _ViewAllRow(
                  colorScheme: colorScheme,
                  label: 'Ver todas las ${section.title.toLowerCase()}',
                  onTap: () => onViewAll!(section.title),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({
    required this.colorScheme,
    required this.label,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final ColorScheme colorScheme;
  final String label;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: onAction,
            icon: Icon(actionIcon, size: 18),
            label: Text(actionLabel),
            style: FilledButton.styleFrom(
              foregroundColor: colorScheme.primary,
              backgroundColor:
                  colorScheme.primaryContainer.withValues(alpha: 0.55),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewAllRow extends StatelessWidget {
  const _ViewAllRow({
    required this.colorScheme,
    required this.label,
    required this.onTap,
  });

  final ColorScheme colorScheme;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.colorScheme,
    required this.title,
    required this.subtitle,
  });

  final ColorScheme colorScheme;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingXl),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.kitchen_outlined,
            size: 36,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _InventorySectionData {
  const _InventorySectionData({
    required this.title,
    required this.items,
    required this.totalItemsCount,
    required this.hasMoreItems,
  });

  final String title;
  final List<Ingredient> items;
  final int totalItemsCount;
  final bool hasMoreItems;
}
