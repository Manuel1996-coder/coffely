import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = true;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isOnboardingCompleted => _userProfile?.onboardingCompleted ?? false;

  UserProvider() {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = await UserProfile.loadFromPrefs();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      _userProfile = UserProfile();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    _userProfile = profile;
    try {
      await profile.saveToPrefs();
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
    notifyListeners();
  }

  Future<void> updateCaffeineLimit(double limit) async {
    if (_userProfile != null) {
      _userProfile!.caffeineLimit = limit;
      await _userProfile!.saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    if (_userProfile != null) {
      _userProfile!.onboardingCompleted = true;
      await _userProfile!.saveToPrefs();
      notifyListeners();
    }
  }
} 