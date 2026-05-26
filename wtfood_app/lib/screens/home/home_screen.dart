import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../features/onboarding/onboarding.dart';
import '../../features/pantry_update/presentation/pantry_update_prompt_dialog.dart';
import '../../models/recipe.dart';
import '../../providers/user_provider.dart';
import '../../services/recipe_service.dart';
import '../recipes/recipe_detail_screen.dart';
import '../scan/scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onTabSelected});

  final ValueChanged<int>? onTabSelected;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _showcaseScope = 'home_screen_showcase';

  final OnboardingStorageService _onboardingStorageService =
      OnboardingStorageService();
  final GlobalKey _scanShowcaseKey = GlobalKey();

  String? _lastPantryPromptKey;
  bool _isShowingPantryPrompt = false;
  bool _isEvaluatingTutorial = false;
  bool _hasTriggeredTutorial = false;
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(scope: _showcaseScope);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedulePantryUpdatePrompt();
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  void _schedulePantryUpdatePrompt() {
    if (_isShowingPantryPrompt) {
      return;
    }

    final userProvider = context.read<UserProvider>();
    if (!userProvider.isReady) {
      return;
    }

    final user = userProvider.user;
    if (user == null) {
      return;
    }

    final settings = user.pantryUpdateSettings;
    final promptKey = [
      user.uid,
      settings.schedule.storageKey,
      settings.lastScanAt?.millisecondsSinceEpoch ?? 0,
      settings.lastPromptAt?.millisecondsSinceEpoch ?? 0,
    ].join(':');

    if (_lastPantryPromptKey == promptKey || !settings.shouldShowPrompt()) {
      return;
    }

    _lastPantryPromptKey = promptKey;
    _isShowingPantryPrompt = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      await context.read<UserProvider>().markPantryUpdatePromptShown(user.uid);

      if (!mounted) {
        return;
      }

      final shouldUpdate = await showDialog<bool>(
        context: context,
        builder: (_) => const PantryUpdatePromptDialog(),
      );

      _isShowingPantryPrompt = false;

      if (!mounted || shouldUpdate != true) {
        return;
      }

      _openScan();
    });
  }

  Future<void> _scheduleHomeTutorial() async {
    if (_hasTriggeredTutorial || _isEvaluatingTutorial || !mounted) {
      return;
    }

    _isEvaluatingTutorial = true;
    final shouldShow = await _onboardingStorageService.shouldShowTutorial(
      ContextualTutorial.homeScanCta,
    );
    _isEvaluatingTutorial = false;

    if (!mounted || !shouldShow || _hasTriggeredTutorial) {
      return;
    }

    _hasTriggeredTutorial = true;
    await _onboardingStorageService.markTutorialShown(
      ContextualTutorial.homeScanCta,
    );

    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _showcaseView.startShowCase([_scanShowcaseKey]);
    });
  }

  void _openScan() {
    if (widget.onTabSelected != null) {
      widget.onTabSelected!(2);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<UserProvider>().user;
    final displayName = _displayNameFromUser(user?.name);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleHomeTutorial();
    });

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: StreamBuilder<List<Recipe>>(
          stream: RecipeService().getRecipes(limit: 100),
          builder: (context, snapshot) {
            final recipes = snapshot.data ?? const <Recipe>[];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingLg,
                AppConstants.paddingLg,
                AppConstants.paddingLg,
                160,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HomeIntro(displayName: displayName),
                      const SizedBox(height: AppConstants.paddingXl),
                      Showcase(
                        key: _scanShowcaseKey,
                        scope: _showcaseScope,
                        title: 'Empieza aqui',
                        description:
                            'Empieza aqui para descubrir recetas con tus ingredientes.',
                        tooltipBackgroundColor:
                            colorScheme.surfaceContainerLowest,
                        textColor: colorScheme.onSurface,
                        titleTextStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        descTextStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                        overlayColor: colorScheme.onSurface,
                        overlayOpacity: 0.72,
                        targetBorderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusLg,
                        ),
                        child: _ScanCallToAction(onTap: _openScan),
                      ),
                      const SizedBox(height: AppConstants.paddingXl),
                      _RecipeOfTheDaySection(
                        recipes: recipes,
                        isLoading:
                            snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData,
                        hasError: snapshot.hasError,
                      ),
                      const SizedBox(height: AppConstants.paddingXl),
                      _ExploreCategoriesSection(
                        recipes: recipes,
                        isLoading:
                            snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeIntro extends StatelessWidget {
  const _HomeIntro({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenido, $displayName',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.secondary,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '¿Qué vamos a\n',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 37,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              TextSpan(
                text: 'cocinar',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 37,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.primary,
                ),
              ),
              TextSpan(
                text: '\n hoy?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 37,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Escanea tus ingredientes y descubre recetas pensadas para lo que tienes ahora mismo.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ScanCallToAction extends StatelessWidget {
  const _ScanCallToAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final palette = context.appPalette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, palette.brandPrimaryStrong],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLg,
            vertical: AppConstants.paddingMd,
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: const Icon(
                  Icons.enhance_photo_translate_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escanear alimentos',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'La forma más rápida de convertir tu nevera en una receta.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeOfTheDaySection extends StatelessWidget {
  const _RecipeOfTheDaySection({
    required this.recipes,
    required this.isLoading,
    required this.hasError,
  });

  final List<Recipe> recipes;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipe = _recipeOfTheDay(recipes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receta del día',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMd),
        if (isLoading)
          const _RecipeOfDaySkeleton()
        else if (hasError)
          const _HomeMessageCard(
            icon: Icons.error_outline_rounded,
            title: 'No pudimos cargar la recomendación de hoy',
            message: 'Inténtalo de nuevo dentro de un momento.',
          )
        else if (recipe == null)
          const _HomeMessageCard(
            icon: Icons.receipt_long_rounded,
            title: 'Todavía no hay recetas disponibles',
            message:
                'Cuando añadamos recetas, aquí aparecerá una destacada cada día.',
          )
        else
          _RecipeOfTheDayCard(recipe: recipe),
      ],
    );
  }
}

class _RecipeOfTheDayCard extends StatelessWidget {
  const _RecipeOfTheDayCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecipeCardImage(
              photoUrl: recipe.photoUrl,
              height: 290,
              iconSize: 64,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingLg,
                AppConstants.paddingLg,
                AppConstants.paddingLg,
                AppConstants.paddingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Receta del día',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    recipe.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _RecipeMetaItem(
                        icon: Icons.schedule_rounded,
                        label: recipe.duration,
                      ),
                      const SizedBox(width: 18),
                      _RecipeMetaItem(
                        icon: Icons.sell_rounded,
                        label: _categoryLabel(recipe.category),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMd,
                          ),
                        ),
                      ),
                      child: const Text('Ver receta'),
                    ),
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

class _RecipeMetaItem extends StatelessWidget {
  const _RecipeMetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ExploreCategoriesSection extends StatelessWidget {
  const _ExploreCategoriesSection({
    required this.recipes,
    required this.isLoading,
  });

  final List<Recipe> recipes;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final sections = [
      _CategoryShelfData(
        title: 'Desayunos',
        subtitle: 'Ideas rápidas para empezar el día',
        recipes: _recipesByCategory(recipes, 'desayuno'),
      ),
      _CategoryShelfData(
        title: 'Cenas',
        subtitle: 'Opciones sabrosas para la noche',
        recipes: _recipesByCategory(recipes, 'cena'),
      ),
      _CategoryShelfData(
        title: 'Postres',
        subtitle: 'Recetas dulces de la categoría dessert',
        recipes: _recipesByCategory(recipes, 'postre'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.paddingLg),
        if (isLoading)
          const _CategoryShelfSkeleton()
        else
          for (final section in sections) ...[
            _CategoryShelf(section: section),
            const SizedBox(height: AppConstants.paddingLg),
          ],
      ],
    );
  }
}

class _CategoryShelf extends StatelessWidget {
  const _CategoryShelf({required this.section});

  final _CategoryShelfData section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          section.subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        if (section.recipes.isEmpty)
          const _InlineEmptyCategoryCard()
        else
          SizedBox(
            height: 226,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: section.recipes.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final recipe = section.recipes[index];
                return _CategoryRecipeCard(recipe: recipe);
              },
            ),
          ),
      ],
    );
  }
}

class _CategoryRecipeCard extends StatelessWidget {
  const _CategoryRecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 172,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(recipe: recipe),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _RecipeCardImage(
                        photoUrl: recipe.photoUrl,
                        height: double.infinity,
                        iconSize: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          recipe.duration,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeCardImage extends StatelessWidget {
  const _RecipeCardImage({
    required this.photoUrl,
    required this.height,
    required this.iconSize,
  });

  final String photoUrl;
  final double height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPhoto = photoUrl.trim().isNotEmpty;

    if (!hasPhoto) {
      return _RecipeImagePlaceholder(iconSize: iconSize);
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        placeholder: (context, imageUrl) => Container(
          color: colorScheme.surfaceContainerHigh,
          alignment: Alignment.center,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: colorScheme.primary,
            ),
          ),
        ),
        errorWidget: (context, imageUrl, error) =>
            _RecipeImagePlaceholder(iconSize: iconSize),
      ),
    );
  }
}

class _RecipeImagePlaceholder extends StatelessWidget {
  const _RecipeImagePlaceholder({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.imagePlaceholderStart, palette.imagePlaceholderEnd],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_rounded,
        size: iconSize,
        color: colorScheme.primary.withValues(alpha: 0.4),
      ),
    );
  }
}

class _HomeMessageCard extends StatelessWidget {
  const _HomeMessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeOfDaySkeleton extends StatelessWidget {
  const _RecipeOfDaySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
      ),
    );
  }
}

class _CategoryShelfSkeleton extends StatelessWidget {
  const _CategoryShelfSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerLow;

    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 18,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 226,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemBuilder: (context, index) => Container(
                    width: 172,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusLg,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineEmptyCategoryCard extends StatelessWidget {
  const _InlineEmptyCategoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        'Todavía no hay recetas en esta categoría.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CategoryShelfData {
  const _CategoryShelfData({
    required this.title,
    required this.subtitle,
    required this.recipes,
  });

  final String title;
  final String subtitle;
  final List<Recipe> recipes;
}

Recipe? _recipeOfTheDay(List<Recipe> recipes) {
  if (recipes.isEmpty) {
    return null;
  }

  final sortedRecipes = [...recipes]..sort((a, b) => a.id.compareTo(b.id));
  final now = DateTime.now();
  final daySeed = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(2024)).inDays;

  return sortedRecipes[daySeed % sortedRecipes.length];
}

List<Recipe> _recipesByCategory(List<Recipe> recipes, String category) {
  final normalizedCategory = _normalizeCategoryKey(category);

  return recipes
      .where(
        (recipe) =>
            _normalizeCategoryKey(recipe.category) == normalizedCategory,
      )
      .toList();
}

String _displayNameFromUser(String? fullName) {
  final trimmed = fullName?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Chef';
  }

  return trimmed.split(RegExp(r'\s+')).first;
}

String _categoryLabel(String category) {
  final normalized = category.trim().toLowerCase();

  switch (normalized) {
    case 'breakfast':
    case 'desayuno':
      return 'Desayuno';
    case 'dinner':
    case 'cena':
      return 'Cena';
    case 'dessert':
    case 'postre':
      return 'Postre';
    case 'easy':
    case 'fácil':
      return 'Fácil';
    case 'lunch':
      return 'Comida';
    default:
      if (normalized.isEmpty) {
        return 'Receta';
      }

      return normalized[0].toUpperCase() + normalized.substring(1);
  }
}

String _normalizeCategoryKey(String category) {
  final normalizedCategory = category.trim().toLowerCase();

  switch (normalizedCategory) {
    case 'breakfast':
      return 'desayuno';
    case 'dinner':
      return 'cena';
    case 'dessert':
      return 'postre';
    case 'easy':
      return 'fácil';
    default:
      return normalizedCategory;
  }
}
