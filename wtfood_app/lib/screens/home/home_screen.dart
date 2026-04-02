import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Images + copy taken from Stitch "WTFood Home".
    const heroImageUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAebAP8LtK7PM5rvz1QkceKShJhGY7tLLZgjET0FBIMKVisg3718ExsB7xnkWBSJ_VU4KyK44SXFRhRW4CUED4jiepTtU55e27Oz89d142GHmipi4-W5F09OPuvtCmDGwmY7sPLyi2Gve65DVyLK5badQslPhF4uiXsuUpZngCfaIkypFw9D8LWjw05NsC3G6HD6wxA08KGGZ2oIgrYuS3Xl5s2c8AXecN2V5v6kD31zI87X6iHJIDyEPO6wyIbLJ3zXAUl0zUFQg';

    const fridgeChips = <_FridgeChipData>[
      _FridgeChipData(
        label: 'Egg',
        icon: Icons.egg_alt,
        iconColor: Color(0xFFFF9800),
      ),
      _FridgeChipData(
        label: 'Tomato',
        icon: Icons.local_dining,
        iconColor: Colors.redAccent,
      ),
      _FridgeChipData(
        label: 'Cheese',
        icon: Icons.trolley,
        iconColor: Color(0xFFFFD54F),
      ),
    ];

    const recipeSuggestions = <_RecipeSuggestionData>[
      _RecipeSuggestionData(
        title: 'Berry Nut Salad',
        timeLabel: '12 min',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC3fNWaEy5dRmaI2oSRCHELudun_iyJt_uoZtoEefBVKlZNBbWwfaGsp5tR-X88W9UE9XeEuFSWYKLHAb5vnW-LmX1nuW8hitfPGEoUsZsSxI4QuTZ_bYyfUv1RjGta2TR6OuWJpMfqpuMPrjazTOF15pYBsTQZZxa6GZEGEK_fnHNiBWMx3l6Upb2SMrxZkdcQzB8mDdXfrwPMZVqLJ0ijjO85vrXl5AiCw_QpUiCT3dcr8wIpUFFHdPoSPJUvAk_BAmAA7On7Rw',
        isFavorite: false,
      ),
      _RecipeSuggestionData(
        title: 'Basil Pesto Penne',
        timeLabel: '20 min',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBrmtGzos5Zp5lmPwdFw59terhymFNn0kVfC6Rdu32UyTmdZdtPzah9QqspiGEl8nD1gN6r_LGupYAcPBzfi2LlhuZ7TheBNj_1bmudSus7dsUBTIClXedVEJw6m4jKtGne7qBc-1fJhudYPEuvAhNj3eZc_E3bYKKg9kY3w6BNKm_-xbzkAY5rfV1e4f0f2oZaQKZ9HXMEQwaiJjTP6XEuVrQBiesu_vz893pv12AL0wLJGHDljWzxUmh3uHoLsaOBGFgqw0ObzA',
        isFavorite: false,
      ),
      _RecipeSuggestionData(
        title: 'Power Grain Bowl',
        timeLabel: '25 min',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDm95IU5Bnjv-c4ka-2hsNjaDiq_BfEZJxwRsYB3qR7RKRiZfIbkH0dO86X70sS_BpouQV94BvhUfsz_Z9YYaDLa0hDnsqPN5YEuGGKjF630YKSyngheoBHlgByZAQaRgVwD1OR6RJD0S_UZQAYMRy2KCsP5e3hnuUaIQdsKuiT5J2dml26OH9hVdYe9_zNYHBripZ7KcEy2Hipfzs_fGJ23rkFagSG4-0n0P4qQDiUySYiUJkWnjjXLEB4QDcLcpurdcQCuUmI2A',
        isFavorite: false,
      ),
      _RecipeSuggestionData(
        title: 'Blueberry Oats',
        timeLabel: '10 min',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC00E8l0I3ct4_lWaX_zkRwlo7zL-WjNp7G_WBFNg8MpQdoDBdj7jm-3X85jVWqgVbDkx84XS5HaSuefRrYcX19wV3CKJdKb6QXVUXu59qKOU4iZGT0tbEA0cnoZdvlYYY1JOjCVqVY8mWVjL6nr-zgOo4hm4pVbJUlQ9s0Bp1gPF0mzhULHLX36ajKKGtk7q5W5tDxsF7fXt6h0u8lvQmfZ7Z_Vt-SH-gw13C8jsmUGwCXSsdTwaPvrI9rRnH5yMd5bk65FmUnkQ',
        isFavorite: false,
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingLg,
          AppConstants.paddingMd,
          AppConstants.paddingLg,
          160, // Space for the floating bottom navigation.
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchBar(colorScheme: colorScheme),
                const SizedBox(height: AppConstants.paddingXl),
                _HeroBanner(colorScheme: colorScheme, imageUrl: heroImageUrl),
                const SizedBox(height: AppConstants.paddingXl),
                _YourFridgeSection(colorScheme: colorScheme, chips: fridgeChips),
                const SizedBox(height: AppConstants.paddingXl),
                _RecipeSuggestionsSection(
                  colorScheme: colorScheme,
                  recipes: recipeSuggestions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FridgeChipData {
  final String label;
  final IconData icon;
  final Color iconColor;

  const _FridgeChipData({
    required this.label,
    required this.icon,
    required this.iconColor,
  });
}

class _RecipeSuggestionData {
  final String title;
  final String timeLabel;
  final String imageUrl;
  final bool isFavorite;

  const _RecipeSuggestionData({
    required this.title,
    required this.timeLabel,
    required this.imageUrl,
    required this.isFavorite,
  });
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.75),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
      child: SizedBox(
        height: 56, // py-4 in Tailwind (~16px top/bottom).
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                contentPadding: const EdgeInsets.only(
                  left: 44,
                  right: 0,
                  top: 14,
                  bottom: 14,
                ),
              ),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.colorScheme,
    required this.imageUrl,
  });

  final ColorScheme colorScheme;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 24),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: AppConstants.paddingLg,
                right: AppConstants.paddingLg,
                bottom: AppConstants.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          color: colorScheme.primaryContainer.withValues(alpha: 0.9),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AI Powered',
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What to cook with these?',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YourFridgeSection extends StatelessWidget {
  const _YourFridgeSection({
    required this.colorScheme,
    required this.chips,
  });

  final ColorScheme colorScheme;
  final List<_FridgeChipData> chips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Fridge',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              '${chips.length} Items',
              style: TextStyle(
                color: colorScheme.tertiary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMd),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final chip in chips) ...[
                _FridgeChip(
                  colorScheme: colorScheme,
                  chip: chip,
                ),
                const SizedBox(width: AppConstants.paddingMd),
              ],
              _AddIngredientChip(
                colorScheme: colorScheme,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FridgeChip extends StatelessWidget {
  const _FridgeChip({
    required this.colorScheme,
    required this.chip,
  });

  final ColorScheme colorScheme;
  final _FridgeChipData chip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.icon, size: 20, color: chip.iconColor),
          const SizedBox(width: 8),
          Text(
            chip.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: () {},
            icon: Icon(
              Icons.close,
              color: colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddIngredientChip extends StatelessWidget {
  const _AddIngredientChip({
    required this.colorScheme,
    required this.onPressed,
  });

  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9999),
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Icon(Icons.add, size: 22, color: colorScheme.onPrimary),
      ),
    );
  }
}

class _RecipeSuggestionsSection extends StatelessWidget {
  const _RecipeSuggestionsSection({
    required this.colorScheme,
    required this.recipes,
  });

  final ColorScheme colorScheme;
  final List<_RecipeSuggestionData> recipes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recipe Suggestions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMd),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            // Needs a slightly taller cell so the card content
            // (square image + padded text) doesn't overflow.
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return _RecipeSuggestionCard(
              colorScheme: colorScheme,
              recipe: recipe,
            );
          },
        ),
      ],
    );
  }
}

class _RecipeSuggestionCard extends StatelessWidget {
  const _RecipeSuggestionCard({
    required this.colorScheme,
    required this.recipe,
  });

  final ColorScheme colorScheme;
  final _RecipeSuggestionData recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 24),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: recipe.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: 32,
                          height: 32,
                          color: Colors.white.withValues(alpha: 0.8),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 16,
                            visualDensity: VisualDensity.compact,
                            onPressed: () {},
                            icon: Icon(
                              Icons.favorite_border,
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              // Slightly tighter vertical padding prevents RenderFlex overflow.
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ).copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        recipe.timeLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        height: 1.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
