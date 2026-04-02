import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/dummy_data_service.dart';
import '../../widgets/recipe_card.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = DummyDataService.getRecipes();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLg),
            child: Text(
              'All Recipes',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          
          // Search Bar Simulator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLg),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
                    blurRadius: 10,
                  )
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for recipes...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          
          // Recipe List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLg),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(recipe: recipes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Inner shadow extension removed. Instead we rely on surfaceContainerHigh background.
