// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Coffely';

  @override
  String get welcomeTitle => 'Willkommen bei Coffely';

  @override
  String get welcomeSubtitle =>
      'Verfolge deinen Kaffeekonsum und bleibe innerhalb gesunder Grenzen';

  @override
  String get continueButton => 'Weiter';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodDay => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String todayIs(String weekday) {
    return 'Heute ist $weekday';
  }

  @override
  String get timeForCoffee => 'Zeit für Kaffee?';

  @override
  String get today => 'Heute';

  @override
  String get drinksToday => 'Getränke heute';

  @override
  String get caffeineToday => 'Koffein heute';

  @override
  String dailyLimit(String percentage) {
    return '$percentage% des täglichen Limits';
  }

  @override
  String get lowCaffeineConsumption => 'Niedriger Koffeinkonsum';

  @override
  String get optimalCaffeineConsumption => 'Optimaler Koffeinkonsum';

  @override
  String get elevatedCaffeineConsumption => 'Erhöhter Koffeinkonsum';

  @override
  String get highCaffeineConsumption => 'Hoher Koffeinkonsum';

  @override
  String get coffeeBreakTip => 'Vielleicht eine Pause vom Kaffee einlegen?';

  @override
  String get noCaffeineYet => 'Noch keinen Kaffee heute? Zeit für eine Tasse!';

  @override
  String get quickAdd => 'Schnell hinzufügen';

  @override
  String get espresso => 'Espresso';

  @override
  String get cappuccino => 'Cappuccino';

  @override
  String get latteMacchiato => 'Latte Macchiato';

  @override
  String get filterCoffee => 'Filterkaffee';

  @override
  String get instantCoffee => 'Instant-Kaffee';

  @override
  String get cremaCoffee => 'Kaffee Crema';

  @override
  String drinkAdded(String drinkName) {
    return '$drinkName hinzugefügt';
  }

  @override
  String get recentlyConsumed => 'Kürzlich getrunken';

  @override
  String get showAll => 'Alle anzeigen';

  @override
  String get noCoffeeConsumed => 'Kein Kaffee getrunken';

  @override
  String get yourCoffeesShownHere => 'Deine Kaffees werden hier angezeigt';

  @override
  String get addDrink => 'Getränk hinzufügen';

  @override
  String get addCustomDrink => 'Eigenes Getränk hinzufügen';

  @override
  String get drinkName => 'Name des Getränks';

  @override
  String get drinkNameHint => 'z.B. Doppelter Espresso';

  @override
  String caffeineContent(int amount) {
    return 'Koffeingehalt: $amount mg';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String caffeineMg(int amount) {
    return '$amount mg';
  }

  @override
  String get aboutCoffely =>
      'Coffely ist deine persönliche Kaffee-Tracking-App, die dir hilft, deinen Kaffeekonsum zu überwachen und zu optimieren.';

  @override
  String get aboutDescription =>
      'Mit Coffely kannst du deine tägliche Koffeinaufnahme verfolgen, deinen Konsum visualisieren und ein gesundes Gleichgewicht finden. Die App bietet dir personalisierte Einblicke und hilft dir, deine Kaffeegewohnheiten besser zu verstehen.';

  @override
  String get features =>
      'Features:\n• Tracking von Kaffeegetränken und Koffeingehalt\n• Persönliche Statistiken und Trends\n• Visualisierung deines Kaffeekonsums\n• Erinnerungen und Benachrichtigungen\n• Empfehlungen für einen ausgewogenen Koffeinkonsum';

  @override
  String get developedWith => 'Entwickelt mit ♥ und viel Kaffee in Deutschland';

  @override
  String get leoHappy1 => 'Heute ist ein wunderbarer Tag für guten Kaffee!';

  @override
  String get leoHappy2 =>
      'Deine Tasse ist perfekt temperiert. Genieße den Moment.';

  @override
  String get leoHappy3 =>
      'Ein ausgewogener Kaffeegenuss – genau richtig für dich.';

  @override
  String get leoSleepy1 => 'Na, schon die erste Tasse genossen heute?';

  @override
  String get leoSleepy2 =>
      'Ein sanfter Start in den Tag beginnt mit einem guten Kaffee.';

  @override
  String get leoSleepy3 =>
      'Wie wäre es mit einem Espresso für einen angenehmen Energieschub?';

  @override
  String get leoWarning1 =>
      'Vielleicht eine kleine Kaffeepause? Wasser wäre jetzt ideal.';

  @override
  String get leoWarning2 =>
      'Ein Moment zum Durchatmen – dein Koffeinlevel ist recht hoch.';

  @override
  String get leoWarning3 => 'Wie wäre es mit einem Kräutertee zur Abwechslung?';

  @override
  String get leoProud1 => 'Wunderbar! Du hast deine Challenge gemeistert.';

  @override
  String get leoProud2 =>
      'Ein schöner Erfolg – deine Kaffeebilanz ist ausgezeichnet.';

  @override
  String get leoProud3 => 'Das hast du ganz hervorragend gemacht. Weiter so!';

  @override
  String get leoAddCoffee1 => 'Zeit für eine neue Tasse? Was darf es sein?';

  @override
  String get leoAddCoffee2 => 'Eine Kaffeespezialität für zwischendurch?';

  @override
  String get leoAddCoffee3 => 'Heute ist ein guter Tag für einen Cappuccino.';

  @override
  String get close => 'Schließen';

  @override
  String get ok => 'OK';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get copyright => '© 2025 Wizard Dynamics GmbH';
}
