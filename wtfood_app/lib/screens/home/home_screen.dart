import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../services/dummy_data_service.dart';
import '../../widgets/recipe_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recentRecipes = DummyDataService.getRecipes().take(2).toList();
    final highlights = DummyDataService.getPrograms();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning,',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      'Chef WTFood',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  backgroundImage: const CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1595273611495-9ff038eaeb6f?auto=format&fit=crop&q=80&w=200',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingXl),

            // Highlights
            Text(
              'Highlights',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingMd),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: highlights.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppConstants.paddingMd),
                itemBuilder: (context, index) {
                  final program = highlights[index];
                  return Container(
                    width: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(program.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(AppConstants.paddingMd),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                                ),
                          ),
                          Text(
                            program.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.surfaceContainerLowest.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingXl),

            // Recent Recipes
            Text(
              'Recently Added',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingMd),
            ...recentRecipes.map((recipe) => RecipeCard(recipe: recipe)).toList(),
          ],
        ),
      ),
    );
  }
}
