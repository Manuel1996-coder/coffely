import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/coffee_provider.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../main_screen.dart';
import 'welcome_page.dart';
import 'personal_info_page.dart';
import 'caffeine_explainer_page.dart';
import 'result_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final UserProfile _userProfile = UserProfile();
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: AppTheme.normalAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppTheme.normalAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateUserProfile({
    Gender? gender,
    int? age,
    double? weight,
    double? height,
  }) {
    setState(() {
      if (gender != null) _userProfile.gender = gender;
      if (age != null) _userProfile.age = age;
      if (weight != null) _userProfile.weight = weight;
      if (height != null) _userProfile.height = height;
    });
  }

  void _calculateCaffeineLimit() {
    if (_userProfile.weight != null) {
      final limit = UserProfile.calculateCaffeineLimit(_userProfile.weight!);
      setState(() {
        _userProfile.caffeineLimit = limit.roundToDouble();
      });
    }
  }

  Future<void> _completeOnboarding() async {
    _userProfile.onboardingCompleted = true;
    
    // Save user profile data
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.saveUserProfile(_userProfile);
    
    // Update caffeine limit in coffee provider too
    final coffeeProvider = Provider.of<CoffeeProvider>(context, listen: false);
    await coffeeProvider.setCaffeineLimit(_userProfile.caffeineLimit);
    
    // Navigate to main screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Seite ${_currentPage + 1} von 4',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 4,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  WelcomePage(onNext: _nextPage),
                  PersonalInfoPage(
                    onNext: _nextPage,
                    onPrevious: _previousPage,
                    onUpdateUserProfile: _updateUserProfile,
                  ),
                  CaffeineExplainerPage(
                    onNext: () {
                      _calculateCaffeineLimit();
                      _nextPage();
                    },
                    onPrevious: _previousPage,
                    userProfile: _userProfile,
                  ),
                  ResultPage(
                    onComplete: _completeOnboarding,
                    onPrevious: _previousPage,
                    userProfile: _userProfile,
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