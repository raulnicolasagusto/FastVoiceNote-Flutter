import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/onboarding_logo_animation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) {
      // Navigate to root (Home)
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> onboardingData = [
      {
        'title': l10n.onboardingStep1Title,
        'desc': l10n.onboardingStep1Desc,
        'icon': null,
        'customHeader': const OnboardingLogoAnimation(
          imagePath: 'assets/main1.png',
          size: 250,
          entranceType: EntranceType.top,
        ),
      },
      {
        'title': l10n.onboardingStep2Title,
        'desc': l10n.onboardingStep2Desc,
        'icon': null,
        'customHeader': const OnboardingLogoAnimation(
          imagePath: 'assets/first-note.png',
          size: 250,
          entranceType: EntranceType.top,
        ),
      },
      {
        'title': l10n.onboardingStep3Title,
        'desc': l10n.onboardingStep3Desc,
        'icon': null,
        'customHeader': const OnboardingLogoAnimation(
          imagePath: 'assets/main2.png',
          size: 250,
          entranceType: EntranceType.none,
        ),
      },
      {
        'title': l10n.onboardingStep4Title,
        'desc': l10n.onboardingStep4Desc,
        'icon': null,
        'customHeader': const OnboardingLogoAnimation(
          imagePath: 'assets/main3.png',
          size: 250,
          entranceType: EntranceType.left,
        ),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black, // Match design background
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) => OnboardingContent(
                title: onboardingData[index]['title'],
                description: onboardingData[index]['desc'],
                icon: onboardingData[index]['icon'],
                customHeader: onboardingData[index]['customHeader'],
              ),
            ),
            // Next/Start Button (Top Right)
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _currentPage == onboardingData.length - 1
                    ? _completeOnboarding
                    : () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF4B7FD6), // Blue accent
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  _currentPage == onboardingData.length - 1
                      ? l10n.onboardingStart
                      : l10n.onboardingNext,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Dots Indicator (Bottom Center, part of the card implicitly or over it)
            // The design shows dots inside the card area.
            // Since OnboardingContent has the card, we can overlook "Bottom Center" relative to screen
            // but we need to place it ON TOP of the card.
            // Let's place it aligned with the card bottom content.
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF4B7FD6)
                          : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
