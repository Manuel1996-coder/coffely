import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Gender { male, female, diverse }

class UserProfile {
  String? name;
  Gender? gender;
  int? age;
  double? weight;
  double? height;
  double caffeineLimit;
  bool onboardingCompleted;

  UserProfile({
    this.name,
    this.gender,
    this.age,
    this.weight,
    this.height,
    this.caffeineLimit = 400.0,
    this.onboardingCompleted = false,
  });

  // Convert Gender enum to string for storage
  static String _genderToString(Gender? gender) {
    if (gender == null) return '';
    return gender.toString().split('.').last;
  }

  // Convert string back to Gender enum
  static Gender? _stringToGender(String? gender) {
    if (gender == null || gender.isEmpty) return null;
    return Gender.values.firstWhere(
      (e) => e.toString().split('.').last == gender,
      orElse: () => Gender.diverse,
    );
  }

  // Calculate recommended caffeine limit based on weight
  static double calculateCaffeineLimit(double weight) {
    // EFSA recommends 3mg per kg body weight
    return weight * 3;
  }

  // Save profile to shared preferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (name != null) await prefs.setString('user_name', name!);
    if (gender != null) await prefs.setString('user_gender', _genderToString(gender));
    if (age != null) await prefs.setInt('user_age', age!);
    if (weight != null) await prefs.setDouble('user_weight', weight!);
    if (height != null) await prefs.setDouble('user_height', height!);
    
    await prefs.setDouble('caffeine_limit', caffeineLimit);
    await prefs.setBool('onboarding_completed', onboardingCompleted);
  }

  // Load profile from shared preferences
  static Future<UserProfile> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    return UserProfile(
      name: prefs.getString('user_name'),
      gender: _stringToGender(prefs.getString('user_gender')),
      age: prefs.getInt('user_age'),
      weight: prefs.getDouble('user_weight'),
      height: prefs.getDouble('user_height'),
      caffeineLimit: prefs.getDouble('caffeine_limit') ?? 400.0,
      onboardingCompleted: prefs.getBool('onboarding_completed') ?? false,
    );
  }
} 