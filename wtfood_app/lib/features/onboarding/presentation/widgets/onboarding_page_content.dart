import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wtfood_app/core/constants.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    required this.assetPath,
    required this.fallbackIcon,
    required this.title,
    required this.description,
    required this.isActive,
    super.key,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final String title;
  final String description;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight = constraints.maxHeight < 620;
        final horizontalPadding = constraints.maxWidth >= 720
            ? AppConstants.paddingXl * 2
            : AppConstants.paddingLg;
        final artworkSize = math.min(
          constraints.maxWidth * (constraints.maxWidth >= 720 ? 0.48 : 0.72),
          isCompactHeight ? 260.0 : 340.0,
        );

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            isCompactHeight ? AppConstants.paddingSm : AppConstants.paddingLg,
            horizontalPadding,
            AppConstants.paddingMd,
          ),
          child: Column(
            children: [
              const Spacer(),
              AnimatedScale(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                scale: isActive ? 1 : 0.94,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  opacity: isActive ? 1 : 0.72,
                  child: _OnboardingArtwork(
                    assetPath: assetPath,
                    fallbackIcon: fallbackIcon,
                    size: artworkSize,
                  ),
                ),
              ),
              SizedBox(height: isCompactHeight ? 28 : 40),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        height: 1.14,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMd),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingArtwork extends StatelessWidget {
  const _OnboardingArtwork({
    required this.assetPath,
    required this.fallbackIcon,
    required this.size,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainer,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size * 0.06),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  fallbackIcon,
                  size: size * 0.28,
                  color: colorScheme.primary,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
