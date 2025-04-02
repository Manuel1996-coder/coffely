import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Erweiterungsmethode für einfachen Zugriff auf lokalisierte Texte
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// Liste der unterstützten Sprachen
class L10n {
  static final all = [
    const Locale('de'),
    const Locale('en'),
  ];
} 