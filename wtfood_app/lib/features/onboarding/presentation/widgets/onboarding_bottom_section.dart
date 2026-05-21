import 'package:flutter/material.dart';
import 'package:wtfood_app/core/constants.dart';

class OnboardingBottomSection extends StatelessWidget {
  const OnboardingBottomSection({
    required this.currentPage,
    required this.pageCount,
    required this.isLastPage,
    required this.isSubmitting,
    required this.onPrimaryPressed,
    super.key,
  });

  final int currentPage;
  final int pageCount;
  final bool isLastPage;
  final bool isSubmitting;
  final VoidCallback onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingLg,
        0,
        AppConstants.paddingLg,
        AppConstants.paddingLg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DotIndicator(currentPage: currentPage, count: pageCount),
            const SizedBox(height: AppConstants.paddingLg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: isSubmitting ? null : onPrimaryPressed,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(isLastPage ? 'Empezar' : 'Continuar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.currentPage, required this.count});

  final int currentPage;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: isActive ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isActive ? colorScheme.primary : colorScheme.outline,
          ),
        );
      }),
    );
  }
}
