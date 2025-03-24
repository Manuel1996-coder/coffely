import 'package:flutter/foundation.dart';
import '../models/coffee_drink.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class CoffeeProvider with ChangeNotifier {
  List<CoffeeDrink> _drinks = [];
  bool _isLoading = false;

  List<CoffeeDrink> get drinks => _drinks;
  bool get isLoading => _isLoading;

  CoffeeProvider() {
    _loadDrinks();
  }

  Future<void> _loadDrinks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final drinksJson = prefs.getStringList('drinks') ?? [];
      _drinks = drinksJson
          .map((json) => CoffeeDrink.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      debugPrint('Fehler beim Laden der Getränke: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveDrinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final drinksJson =
          _drinks.map((drink) => jsonEncode(drink.toJson())).toList();
      await prefs.setStringList('drinks', drinksJson);
    } catch (e) {
      debugPrint('Fehler beim Speichern der Getränke: $e');
    }
  }

  void addDrink(CoffeeDrink drink) {
    _drinks.add(drink);
    _saveDrinks();
    notifyListeners();
  }

  void removeDrink(CoffeeDrink drink) {
    _drinks.remove(drink);
    _saveDrinks();
    notifyListeners();
  }

  List<CoffeeDrink> getTodayDrinks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _drinks.where((drink) {
      final drinkDate = DateTime(
        drink.timestamp.year,
        drink.timestamp.month,
        drink.timestamp.day,
      );
      return drinkDate.isAtSameMomentAs(today);
    }).toList();
  }

  List<CoffeeDrink> getRecentDrinks() {
    final sortedDrinks = List<CoffeeDrink>.from(_drinks);
    sortedDrinks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedDrinks;
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Gerade eben';
    } else if (difference.inHours < 1) {
      return 'Vor ${difference.inMinutes} Minuten';
    } else if (difference.inHours < 24) {
      return 'Vor ${difference.inHours} Stunden';
    } else {
      return 'Vor ${difference.inDays} Tagen';
    }
  }

  List<CoffeeDrink> getDrinksForDay(DateTime date) {
    return _drinks.where((drink) {
      final drinkDate = DateTime(
        drink.timestamp.year,
        drink.timestamp.month,
        drink.timestamp.day,
      );
      final compareDate = DateTime(
        date.year,
        date.month,
        date.day,
      );
      return drinkDate == compareDate;
    }).toList();
  }

  double getTotalCaffeineForDay(DateTime date) {
    return getDrinksForDay(date).fold(
      0,
      (sum, drink) => sum + drink.caffeineAmount,
    );
  }

  Map<String, double> getWeeklyCaffeineConsumption() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final Map<String, double> weeklyConsumption = {};

    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateStr = '${date.day}.${date.month}';
      weeklyConsumption[dateStr] = getTotalCaffeineForDay(date);
    }

    return weeklyConsumption;
  }

  double getAverageDailyConsumption() {
    if (_drinks.isEmpty) return 0;

    final totalCaffeine = _drinks.fold(
      0.0,
      (sum, drink) => sum + drink.caffeineAmount,
    );

    final firstDrinkDate = _drinks
        .map((drink) => drink.timestamp)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final daysSinceFirst = DateTime.now().difference(firstDrinkDate).inDays + 1;

    return totalCaffeine / daysSinceFirst;
  }

  List<String> getFavoriteDrinks() {
    if (_drinks.isEmpty) return [];

    final drinkCounts = <String, int>{};
    for (final drink in _drinks) {
      drinkCounts[drink.name] = (drinkCounts[drink.name] ?? 0) + 1;
    }

    final sortedDrinks = drinkCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedDrinks.take(3).map((entry) => entry.key).toList();
  }

  double predictCaffeineLevel([DateTime? time]) {
    final targetTime = time ?? DateTime.now();
    var totalCaffeine = 0.0;

    for (final drink in _drinks) {
      final hoursSinceConsumption =
          targetTime.difference(drink.timestamp).inHours;
      if (hoursSinceConsumption >= 0) {
        final remainingCaffeine = drink.caffeineAmount *
            pow(0.5, hoursSinceConsumption / 5.0); // 5-hour half-life
        totalCaffeine += remainingCaffeine;
      }
    }

    return totalCaffeine;
  }
}
