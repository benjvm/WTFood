import 'package:flutter/material.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/features/onboarding/data/onboarding_storage_service.dart';
import 'package:wtfood_app/features/onboarding/models/onboarding_page_model.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController({
    required OnboardingStorageService storageService,
    required Future<void> Function() onCompleted,
  }) : _storageService = storageService,
       _onCompleted = onCompleted;

  final OnboardingStorageService _storageService;
  final Future<void> Function() _onCompleted;

  final PageController pageController = PageController();

  final List<OnboardingPageModel> pages = const [
    OnboardingPageModel(
      title: 'Descubre qué cocinar hoy',
      description:
          'Escanea lo que ya tienes en casa y recibe ideas al instante.',
      assetPath: AppAssets.onboardingScreen1,
      fallbackIcon: Icons.restaurant_menu_rounded,
    ),
    OnboardingPageModel(
      title: 'Escanea tus ingredientes',
      description: 'Usa la cámara para detectar alimentos de forma rápida.',
      assetPath: AppAssets.onboardingScreen2,
      fallbackIcon: Icons.enhance_photo_translate_rounded,
    ),
    OnboardingPageModel(
      title: 'Todo en un solo lugar',
      description:
          'Guarda ingredientes, crea listas y organiza tu cocina sin esfuerzo.',
      assetPath: AppAssets.onboardingScreen3,
      fallbackIcon: Icons.playlist_add_check_circle_rounded,
    ),
  ];

  int _currentPage = 0;
  bool _isSubmitting = false;

  int get currentPage => _currentPage;
  bool get isSubmitting => _isSubmitting;
  bool get isLastPage => _currentPage == pages.length - 1;

  Future<void> onPrimaryActionPressed() async {
    if (_isSubmitting) {
      return;
    }

    if (isLastPage) {
      await completeOnboarding();
      return;
    }

    await pageController.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> completeOnboarding() async {
    if (_isSubmitting) {
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    await _storageService.markOnboardingCompleted();
    await _onCompleted();
  }

  void onPageChanged(int index) {
    if (_currentPage == index) {
      return;
    }

    _currentPage = index;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
