import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Coffely'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Coffely'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your coffee consumption and stay within healthy limits'**
  String get welcomeSubtitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodDay.
  ///
  /// In en, this message translates to:
  /// **'Good Day'**
  String get goodDay;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @todayIs.
  ///
  /// In en, this message translates to:
  /// **'Today is {weekday}'**
  String todayIs(String weekday);

  /// No description provided for @timeForCoffee.
  ///
  /// In en, this message translates to:
  /// **'Time for coffee?'**
  String get timeForCoffee;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @drinksToday.
  ///
  /// In en, this message translates to:
  /// **'Drinks today'**
  String get drinksToday;

  /// No description provided for @caffeineToday.
  ///
  /// In en, this message translates to:
  /// **'Caffeine today'**
  String get caffeineToday;

  /// No description provided for @dailyLimit.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% of daily limit'**
  String dailyLimit(String percentage);

  /// No description provided for @lowCaffeineConsumption.
  ///
  /// In en, this message translates to:
  /// **'Low caffeine consumption'**
  String get lowCaffeineConsumption;

  /// No description provided for @optimalCaffeineConsumption.
  ///
  /// In en, this message translates to:
  /// **'Optimal caffeine consumption'**
  String get optimalCaffeineConsumption;

  /// No description provided for @elevatedCaffeineConsumption.
  ///
  /// In en, this message translates to:
  /// **'Elevated caffeine consumption'**
  String get elevatedCaffeineConsumption;

  /// No description provided for @highCaffeineConsumption.
  ///
  /// In en, this message translates to:
  /// **'High caffeine consumption'**
  String get highCaffeineConsumption;

  /// No description provided for @coffeeBreakTip.
  ///
  /// In en, this message translates to:
  /// **'Maybe take a break from coffee?'**
  String get coffeeBreakTip;

  /// No description provided for @noCaffeineYet.
  ///
  /// In en, this message translates to:
  /// **'No coffee yet today? Time for a cup!'**
  String get noCaffeineYet;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAdd;

  /// No description provided for @espresso.
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get espresso;

  /// No description provided for @cappuccino.
  ///
  /// In en, this message translates to:
  /// **'Cappuccino'**
  String get cappuccino;

  /// No description provided for @latteMacchiato.
  ///
  /// In en, this message translates to:
  /// **'Latte Macchiato'**
  String get latteMacchiato;

  /// No description provided for @filterCoffee.
  ///
  /// In en, this message translates to:
  /// **'Filter Coffee'**
  String get filterCoffee;

  /// No description provided for @instantCoffee.
  ///
  /// In en, this message translates to:
  /// **'Instant Coffee'**
  String get instantCoffee;

  /// No description provided for @cremaCoffee.
  ///
  /// In en, this message translates to:
  /// **'Crema Coffee'**
  String get cremaCoffee;

  /// No description provided for @drinkAdded.
  ///
  /// In en, this message translates to:
  /// **'{drinkName} added'**
  String drinkAdded(String drinkName);

  /// No description provided for @recentlyConsumed.
  ///
  /// In en, this message translates to:
  /// **'Recently consumed'**
  String get recentlyConsumed;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @noCoffeeConsumed.
  ///
  /// In en, this message translates to:
  /// **'No coffee consumed'**
  String get noCoffeeConsumed;

  /// No description provided for @yourCoffeesShownHere.
  ///
  /// In en, this message translates to:
  /// **'Your coffees will be shown here'**
  String get yourCoffeesShownHere;

  /// No description provided for @addDrink.
  ///
  /// In en, this message translates to:
  /// **'Add drink'**
  String get addDrink;

  /// No description provided for @addCustomDrink.
  ///
  /// In en, this message translates to:
  /// **'Add custom drink'**
  String get addCustomDrink;

  /// No description provided for @drinkName.
  ///
  /// In en, this message translates to:
  /// **'Drink name'**
  String get drinkName;

  /// No description provided for @drinkNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Double Espresso'**
  String get drinkNameHint;

  /// No description provided for @caffeineContent.
  ///
  /// In en, this message translates to:
  /// **'Caffeine content: {amount} mg'**
  String caffeineContent(int amount);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @caffeineMg.
  ///
  /// In en, this message translates to:
  /// **'{amount} mg'**
  String caffeineMg(int amount);

  /// No description provided for @aboutCoffely.
  ///
  /// In en, this message translates to:
  /// **'Coffely is your personal coffee tracking app that helps you monitor and optimize your coffee consumption.'**
  String get aboutCoffely;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'With Coffely, you can track your daily caffeine intake, visualize your consumption, and find a healthy balance. The app provides you with personalized insights and helps you better understand your coffee habits.'**
  String get aboutDescription;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features:\n• Tracking of coffee drinks and caffeine content\n• Personal statistics and trends\n• Visualization of your coffee consumption\n• Reminders and notifications\n• Recommendations for a balanced caffeine intake'**
  String get features;

  /// No description provided for @developedWith.
  ///
  /// In en, this message translates to:
  /// **'Developed with ♥ and lots of coffee in Germany'**
  String get developedWith;

  /// No description provided for @leoHappy1.
  ///
  /// In en, this message translates to:
  /// **'Today is a wonderful day for good coffee!'**
  String get leoHappy1;

  /// No description provided for @leoHappy2.
  ///
  /// In en, this message translates to:
  /// **'Your cup is perfectly tempered. Enjoy the moment.'**
  String get leoHappy2;

  /// No description provided for @leoHappy3.
  ///
  /// In en, this message translates to:
  /// **'A balanced coffee enjoyment - just right for you.'**
  String get leoHappy3;

  /// No description provided for @leoSleepy1.
  ///
  /// In en, this message translates to:
  /// **'Have you enjoyed your first cup today?'**
  String get leoSleepy1;

  /// No description provided for @leoSleepy2.
  ///
  /// In en, this message translates to:
  /// **'A gentle start to the day begins with a good coffee.'**
  String get leoSleepy2;

  /// No description provided for @leoSleepy3.
  ///
  /// In en, this message translates to:
  /// **'How about an espresso for a pleasant energy boost?'**
  String get leoSleepy3;

  /// No description provided for @leoWarning1.
  ///
  /// In en, this message translates to:
  /// **'Perhaps a little coffee break? Water would be ideal now.'**
  String get leoWarning1;

  /// No description provided for @leoWarning2.
  ///
  /// In en, this message translates to:
  /// **'A moment to breathe - your caffeine level is quite high.'**
  String get leoWarning2;

  /// No description provided for @leoWarning3.
  ///
  /// In en, this message translates to:
  /// **'How about a herbal tea for a change?'**
  String get leoWarning3;

  /// No description provided for @leoProud1.
  ///
  /// In en, this message translates to:
  /// **'Wonderful! You have mastered your challenge.'**
  String get leoProud1;

  /// No description provided for @leoProud2.
  ///
  /// In en, this message translates to:
  /// **'A nice success - your coffee balance is excellent.'**
  String get leoProud2;

  /// No description provided for @leoProud3.
  ///
  /// In en, this message translates to:
  /// **'You did very well. Keep it up!'**
  String get leoProud3;

  /// No description provided for @leoAddCoffee1.
  ///
  /// In en, this message translates to:
  /// **'Time for a new cup? What would you like?'**
  String get leoAddCoffee1;

  /// No description provided for @leoAddCoffee2.
  ///
  /// In en, this message translates to:
  /// **'A coffee specialty for in between?'**
  String get leoAddCoffee2;

  /// No description provided for @leoAddCoffee3.
  ///
  /// In en, this message translates to:
  /// **'Today is a good day for a cappuccino.'**
  String get leoAddCoffee3;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 Wizard Dynamics GmbH'**
  String get copyright;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
