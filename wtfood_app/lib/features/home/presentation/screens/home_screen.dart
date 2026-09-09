import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/core/theme.dart';
import 'package:wtfood_app/features/onboarding/onboarding.dart';
import 'package:wtfood_app/features/pantry_update/presentation/pantry_update_prompt_dialog.dart';
import 'package:wtfood_app/features/recipes/domain/recipe.dart';
import 'package:wtfood_app/features/user/application/user_provider.dart';
import 'package:wtfood_app/features/recipes/data/recipe_service.dart';
import 'package:wtfood_app/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:wtfood_app/features/scan/presentation/screens/scan_screen.dart';

part '../widgets/home_screen_widgets.dart';

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

    final user = context.read<UserProvider>().user;
    final uid = user?.uid;
    if (uid == null) {
      return;
    }

    _isEvaluatingTutorial = true;
    final shouldShow = await _onboardingStorageService.shouldShowTutorial(
      ContextualTutorial.homeScanCta,
      uid: uid,
    );
    _isEvaluatingTutorial = false;

    if (!mounted || !shouldShow || _hasTriggeredTutorial) {
      return;
    }

    _hasTriggeredTutorial = true;
    await _onboardingStorageService.markTutorialShown(
      ContextualTutorial.homeScanCta,
      uid: uid,
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
