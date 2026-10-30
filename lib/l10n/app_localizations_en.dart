// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Coffely';

  @override
  String get welcomeTitle => 'Welcome to Coffely';

  @override
  String get welcomeSubtitle =>
      'Track your coffee consumption and stay within healthy limits';

  @override
  String get continueButton => 'Continue';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodDay => 'Good Day';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String todayIs(String weekday) {
    return 'Today is $weekday';
  }

  @override
  String get timeForCoffee => 'Time for coffee?';

  @override
  String get today => 'Today';

  @override
  String get drinksToday => 'Drinks today';

  @override
  String get caffeineToday => 'Caffeine today';

  @override
  String dailyLimit(String percentage) {
    return '$percentage% of daily limit';
  }

  @override
  String get lowCaffeineConsumption => 'Low caffeine consumption';

  @override
  String get optimalCaffeineConsumption => 'Optimal caffeine consumption';

  @override
  String get elevatedCaffeineConsumption => 'Elevated caffeine consumption';

  @override
  String get highCaffeineConsumption => 'High caffeine consumption';

  @override
  String get coffeeBreakTip => 'Maybe take a break from coffee?';

  @override
  String get noCaffeineYet => 'No coffee yet today? Time for a cup!';

  @override
  String get quickAdd => 'Quick add';

  @override
  String get espresso => 'Espresso';

  @override
  String get cappuccino => 'Cappuccino';

  @override
  String get latteMacchiato => 'Latte Macchiato';

  @override
  String get filterCoffee => 'Filter Coffee';

  @override
  String get instantCoffee => 'Instant Coffee';

  @override
  String get cremaCoffee => 'Crema Coffee';

  @override
  String drinkAdded(String drinkName) {
    return '$drinkName added';
  }

  @override
  String get recentlyConsumed => 'Recently consumed';

  @override
  String get showAll => 'Show all';

  @override
  String get noCoffeeConsumed => 'No coffee consumed';

  @override
  String get yourCoffeesShownHere => 'Your coffees will be shown here';

  @override
  String get addDrink => 'Add drink';

  @override
  String get addCustomDrink => 'Add custom drink';

  @override
  String get drinkName => 'Drink name';

  @override
  String get drinkNameHint => 'e.g. Double Espresso';

  @override
  String caffeineContent(int amount) {
    return 'Caffeine content: $amount mg';
  }

  @override
  String get add => 'Add';

  @override
  String caffeineMg(int amount) {
    return '$amount mg';
  }

  @override
  String get aboutCoffely =>
      'Coffely is your personal coffee tracking app that helps you monitor and optimize your coffee consumption.';

  @override
  String get aboutDescription =>
      'With Coffely, you can track your daily caffeine intake, visualize your consumption, and find a healthy balance. The app provides you with personalized insights and helps you better understand your coffee habits.';

  @override
  String get features =>
      'Features:\n• Tracking of coffee drinks and caffeine content\n• Personal statistics and trends\n• Visualization of your coffee consumption\n• Reminders and notifications\n• Recommendations for a balanced caffeine intake';

  @override
  String get developedWith => 'Developed with ♥ and lots of coffee in Germany';

  @override
  String get leoHappy1 => 'Today is a wonderful day for good coffee!';

  @override
  String get leoHappy2 => 'Your cup is perfectly tempered. Enjoy the moment.';

  @override
  String get leoHappy3 => 'A balanced coffee enjoyment - just right for you.';

  @override
  String get leoSleepy1 => 'Have you enjoyed your first cup today?';

  @override
  String get leoSleepy2 =>
      'A gentle start to the day begins with a good coffee.';

  @override
  String get leoSleepy3 => 'How about an espresso for a pleasant energy boost?';

  @override
  String get leoWarning1 =>
      'Perhaps a little coffee break? Water would be ideal now.';

  @override
  String get leoWarning2 =>
      'A moment to breathe - your caffeine level is quite high.';

  @override
  String get leoWarning3 => 'How about a herbal tea for a change?';

  @override
  String get leoProud1 => 'Wonderful! You have mastered your challenge.';

  @override
  String get leoProud2 => 'A nice success - your coffee balance is excellent.';

  @override
  String get leoProud3 => 'You did very well. Keep it up!';

  @override
  String get leoAddCoffee1 => 'Time for a new cup? What would you like?';

  @override
  String get leoAddCoffee2 => 'A coffee specialty for in between?';

  @override
  String get leoAddCoffee3 => 'Today is a good day for a cappuccino.';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get copyright => '© 2025 Wizard Dynamics GmbH';
}
