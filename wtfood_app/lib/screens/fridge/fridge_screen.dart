import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/dummy_data_service.dart';
import '../../widgets/ingredient_item.dart';

class FridgeScreen extends StatelessWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ingredients = DummyDataService.getFridgeIngredients();

    return SafeArea(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLg),
                child: Text(
                  'My Fridge',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    left: AppConstants.paddingLg,
                    right: AppConstants.paddingLg,
                    bottom: 100, // Space for FAB
                  ),
                  itemCount: ingredients.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppConstants.paddingMd),
                  itemBuilder: (context, index) {
                    return IngredientItem(ingredient: ingredients[index]);
                  },
                ),
              ),
            ],
          ),
          
          Positioned(
            bottom: AppConstants.paddingLg,
            right: AppConstants.paddingLg,
            child: FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Add Ingredient Clicked (Dummy)'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
