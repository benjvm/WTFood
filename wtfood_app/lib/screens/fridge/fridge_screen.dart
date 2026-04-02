import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../models/ingredient.dart';
import '../../services/dummy_data_service.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

enum _FridgeTab {
  all,
  veggies,
  protein,
  dairy,
  pantry,
}

class _FridgeScreenState extends State<FridgeScreen> {
  late List<Ingredient> _ingredients;
  _FridgeTab _selectedTab = _FridgeTab.all;

  @override
  void initState() {
    super.initState();
    _ingredients = DummyDataService.getFridgeIngredients().toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalCount = _ingredients.length;

    final filtered = _ingredients.where((ing) {
      final category = ing.category;
      switch (_selectedTab) {
        case _FridgeTab.all:
          return true;
        case _FridgeTab.veggies:
          return category == 'Produce' || category == 'Herbs';
        case _FridgeTab.protein:
          return category == 'Meat';
        case _FridgeTab.dairy:
          return category == 'Dairy';
        case _FridgeTab.pantry:
          // Everything else not matched by other tabs.
          return category != 'Produce' &&
              category != 'Herbs' &&
              category != 'Meat' &&
              category != 'Dairy';
      }
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        // MainScreen uses `extendBody: true`, so the bottom nav overlays the body.
        // Extra bottom padding prevents small RenderFlex overflows.
        padding: const EdgeInsets.only(bottom: 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingLg,
                AppConstants.paddingMd,
                AppConstants.paddingLg,
                0,
              ),
              child: _SearchBar(colorScheme: colorScheme),
            ),
            SizedBox(height: AppConstants.paddingXl - 4),
            _SegmentedControl(
              colorScheme: colorScheme,
              selectedTab: _selectedTab,
              onChanged: (tab) => setState(() => _selectedTab = tab),
            ),
            const SizedBox(height: AppConstants.paddingXl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLg),
              child: _FridgeHeader(
                colorScheme: colorScheme,
                count: totalCount,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLg),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  // Slightly taller cells so the chip content fits.
                  childAspectRatio: 0.92,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final ingredient = filtered[index];
                  return _IngredientChip(
                    colorScheme: colorScheme,
                    ingredientName: ingredient.name,
                    onRemove: () {
                      setState(() {
                        // Remove from the backing list so tabs + counts update.
                        _ingredients.removeWhere((e) => e.id == ingredient.id);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Removed ${ingredient.name}'),
                          backgroundColor: colorScheme.primary,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Stitch has fixed-position CTA + quick add.
            // Here we keep them at the bottom of the page to avoid fighting MainScreen's bottom navigation.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingLg,
                0,
                AppConstants.paddingLg,
                AppConstants.paddingLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _QuickAddButton(
                      colorScheme: colorScheme,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Add Ingredient Clicked (Dummy)'),
                            backgroundColor: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMd),
                  _FindRecipesButton(
                    colorScheme: colorScheme,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Find Recipes with These!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64, // Tailwind h-16
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          // Approximation of Stitch's inset "soft-neumorphic-in".
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(6, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 14,
            offset: const Offset(-6, -6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                size: 22,
              ),
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'Add ingredients (e.g., eggs, tomato)...',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(44, 16, 16, 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.colorScheme,
    required this.selectedTab,
    required this.onChanged,
  });

  final ColorScheme colorScheme;
  final _FridgeTab selectedTab;
  final ValueChanged<_FridgeTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = <_FridgeTab, String>{
      _FridgeTab.all: 'All',
      _FridgeTab.veggies: 'Veggies',
      _FridgeTab.protein: 'Protein',
      _FridgeTab.dairy: 'Dairy',
      _FridgeTab.pantry: 'Pantry',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLg),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: tabs.entries.map((entry) {
            final tab = entry.key;
            final label = entry.value;
            final isSelected = tab == selectedTab;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(9999),
                  onTap: () => onChanged(tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FridgeHeader extends StatelessWidget {
  const _FridgeHeader({
    required this.colorScheme,
    required this.count,
  });

  final ColorScheme colorScheme;
  final int count;

  @override
  Widget build(BuildContext context) {
    // Stitch: "Currently in Fridge" + count pill text (primary-dim).
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Currently in Fridge',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
        ),
        Text(
          '$count Items',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
            color: colorScheme.primary.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({
    required this.colorScheme,
    required this.ingredientName,
    required this.onRemove,
  });

  final ColorScheme colorScheme;
  final String ingredientName;
  final VoidCallback onRemove;

  String _emojiFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('egg')) return '🥚';
    if (n.contains('tomato')) return '🍅';
    if (n.contains('cheese')) return '🧀';
    if (n.contains('chicken')) return '🍗';
    if (n.contains('broccoli')) return '🥦';
    if (n.contains('onion')) return '🧅';
    if (n.contains('avocado')) return '🥑';
    if (n.contains('bell') || n.contains('pepper')) return '🫑';
    if (n.contains('carrot')) return '🥕';
    return '🥕';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ingredientName),
                  backgroundColor: colorScheme.primary,
                ),
              );
            },
            child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  // Soft neumorphic feel.
                  BoxShadow(
                    color: colorScheme.onSurface.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(10, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.85),
                    blurRadius: 24,
                    offset: const Offset(-10, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji can be visually large; scale it down to avoid overflows.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _emojiFor(ingredientName),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ingredientName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: SizedBox(
            width: 24,
            height: 24,
            child: Material(
              shape: const CircleBorder(),
              color: colorScheme.primaryContainer,
              child: InkWell(
                borderRadius: BorderRadius.circular(9999),
                onTap: onRemove,
                child: Center(
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({
    required this.colorScheme,
    required this.onPressed,
  });

  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          borderRadius: BorderRadius.circular(9999),
          onTap: onPressed,
          child: Center(
            child: Icon(
              Icons.add,
              color: colorScheme.onPrimaryContainer,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class _FindRecipesButton extends StatelessWidget {
  const _FindRecipesButton({
    required this.colorScheme,
    required this.onPressed,
  });

  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: colorScheme.primary.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Find Recipes with These!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 22),
          ],
        ),
      ),
    );
  }
}
