import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/coffee_provider.dart';
import 'providers/user_provider.dart';
import 'providers/stamp_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/l10n.dart';

// Extension für einfachen Zugriff auf lokalisierte Strings
extension LocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setze Statusbar-Farbe für ein konsistentes Design
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoffeeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StampProvider()),
      ],
      child: MaterialApp(
        title: 'Coffely',
        theme: AppTheme.theme,
        home: const AppStartupRouter(),
        debugShowCheckedModeBanner: false,
        // Lokalisierungskonfiguration
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: L10n.all,
        // Füge einen Observer hinzu, um die Navigation zu überwachen
        navigatorObservers: [
          NavigationObserver(),
        ],
      ),
    );
  }
}

// Observer für die Navigation, der bei Routing-Fehlern helfen kann
class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Hier kann man später Logging hinzufügen, um Navigation zu debuggen
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Hier kann man später Logging hinzufügen, um Navigation zu debuggen
  }
}

// Router Widget to decide between onboarding and main screen
class AppStartupRouter extends StatelessWidget {
  const AppStartupRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          // Show loading screen while checking user status
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Check if onboarding is completed
        if (!userProvider.isOnboardingCompleted) {
          return const OnboardingScreen();
        }
        
        // Onboarding completed, go to main screen
        return const MainScreen();
      },
    );
  }
}
