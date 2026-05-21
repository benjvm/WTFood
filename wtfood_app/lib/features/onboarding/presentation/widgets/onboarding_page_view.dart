import 'package:flutter/material.dart';
import 'package:wtfood_app/features/onboarding/models/onboarding_page_model.dart';
import 'package:wtfood_app/features/onboarding/presentation/widgets/onboarding_page_content.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    required this.controller,
    required this.pages,
    required this.currentPage,
    required this.onPageChanged,
    super.key,
  });

  final PageController controller;
  final List<OnboardingPageModel> pages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: pages.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final page = pages[index];

        return _OnboardingPageCard(page: page, isActive: index == currentPage);
      },
    );
  }
}

class _OnboardingPageCard extends StatelessWidget {
  const _OnboardingPageCard({required this.page, required this.isActive});

  final OnboardingPageModel page;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageContent(
      assetPath: page.assetPath,
      fallbackIcon: page.fallbackIcon,
      title: page.title,
      description: page.description,
      isActive: isActive,
    );
  }
}
