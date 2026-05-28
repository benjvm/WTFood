import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wtfood_app/features/recipes/presentation/screens/recipe_detail_screen.dart';

import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/features/recipes/domain/recipe.dart';
import 'package:wtfood_app/features/user/application/user_provider.dart';
import 'package:wtfood_app/features/recipes/data/recipe_service.dart';
import 'package:wtfood_app/features/recipes/presentation/widgets/recipe_card.dart';

part '../widgets/recipes_screen_widgets.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Container(
        color: colorScheme.surfaceContainerLowest,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                color: colorScheme.surface.withValues(alpha: 0.92),
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingMd,
                  AppConstants.paddingSm,
                  AppConstants.paddingMd,
                  AppConstants.paddingMd,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorColor: colorScheme.primary,
                        indicatorWeight: 3,
                        indicatorPadding: const EdgeInsets.only(
                          left: 18,
                          right: 18,
                          bottom: 2,
                        ),
                        labelColor: colorScheme.primary,
                        unselectedLabelColor: colorScheme.onSurfaceVariant,
                        labelStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        tabs: const [
                          Tab(text: 'Explora'),
                          Tab(text: 'Para ti'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(children: [_ExploreTab(), _ForYouTab()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
