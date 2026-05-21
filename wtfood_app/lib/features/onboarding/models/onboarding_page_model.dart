import 'package:flutter/material.dart';

@immutable
class OnboardingPageModel {
  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.assetPath,
    required this.fallbackIcon,
  });

  final String title;
  final String description;
  final String assetPath;
  final IconData fallbackIcon;
}
