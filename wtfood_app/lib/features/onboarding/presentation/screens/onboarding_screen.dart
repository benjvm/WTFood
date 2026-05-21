import 'package:flutter/material.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/features/onboarding/data/onboarding_storage_service.dart';
import 'package:wtfood_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:wtfood_app/features/onboarding/presentation/widgets/onboarding_bottom_section.dart';
import 'package:wtfood_app/features/onboarding/presentation/widgets/onboarding_page_view.dart';
import 'package:wtfood_app/features/onboarding/presentation/widgets/onboarding_skip_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.onCompleted,
    this.storageService,
    super.key,
  });

  final Future<void> Function() onCompleted;
  final OnboardingStorageService? storageService;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController(
      storageService: widget.storageService ?? OnboardingStorageService(),
      onCompleted: widget.onCompleted,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.paddingLg,
                    AppConstants.paddingSm,
                    AppConstants.paddingLg,
                    0,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OnboardingSkipButton(
                      onPressed: _controller.isSubmitting
                          ? null
                          : () {
                              _controller.completeOnboarding();
                            },
                    ),
                  ),
                ),
                Expanded(
                  child: OnboardingPageView(
                    controller: _controller.pageController,
                    pages: _controller.pages,
                    currentPage: _controller.currentPage,
                    onPageChanged: _controller.onPageChanged,
                  ),
                ),
                OnboardingBottomSection(
                  currentPage: _controller.currentPage,
                  pageCount: _controller.pages.length,
                  isLastPage: _controller.isLastPage,
                  isSubmitting: _controller.isSubmitting,
                  onPrimaryPressed: () {
                    _controller.onPrimaryActionPressed();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
