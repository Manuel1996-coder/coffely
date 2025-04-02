import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum LeoState {
  happy,     // Standard-Leo bei normalem Kaffeekonsum
  sleepy,    // Müder Leo, wenn noch kein Kaffee konsumiert wurde
  warning,   // Warnender Leo bei zu hohem Koffeinlevel
  proud,     // Stolzer Leo nach Abschluss einer Challenge
  addCoffee  // Leo zum Hinzufügen eines Kaffees
}

class LeoMascot extends StatelessWidget {
  final LeoState state;
  final double size;
  final VoidCallback? onTap;
  final String? customMessage;

  const LeoMascot({
    super.key,
    this.state = LeoState.happy,
    this.size = 120,
    this.onTap,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          _getLeoImagePath(),
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  String _getLeoImagePath() {
    switch (state) {
      case LeoState.happy:
        return 'assets/leo/leo_happy.png';
      case LeoState.sleepy:
        return 'assets/leo/leo_sleepy.png';
      case LeoState.warning:
        return 'assets/leo/leo_warning.png';
      case LeoState.proud:
        return 'assets/leo/leo_proud.png';
      case LeoState.addCoffee:
        return 'assets/leo/leo_addcoffee.png';
    }
  }
}

class LeoTooltip extends StatelessWidget {
  final String message;
  final bool isVisible;
  final VoidCallback? onDismiss;

  const LeoTooltip({
    super.key,
    required this.message,
    this.isVisible = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        constraints: const BoxConstraints(
          maxWidth: 250,
        ),
        transform: Matrix4.translationValues(
          0,
          isVisible ? 0 : 20,
          0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.black54,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LeoManager {
  // Aktuelle BuildContext-Referenz
  static BuildContext? _currentContext;
  
  // Methode, um den Context zu setzen (aus dem HomeScreen aufrufen)
  static void setContext(BuildContext context) {
    _currentContext = context;
  }
  
  static String getRandomMessage(LeoState state) {
    final Random random = Random();
    
    // Fallback-Nachrichten, falls Kontext nicht verfügbar
    List<String> messages = _getDefaultMessages(state);
    
    // Versuche, lokalisierte Nachrichten zu laden, wenn Kontext verfügbar
    if (_currentContext != null) {
      final l10n = AppLocalizations.of(_currentContext!);
      if (l10n != null) {
        messages = _getLocalizedMessages(state, l10n);
      }
    }

    return messages[random.nextInt(messages.length)];
  }
  
  static List<String> _getLocalizedMessages(LeoState state, AppLocalizations l10n) {
    switch (state) {
      case LeoState.happy:
        return [
          l10n.leoHappy1,
          l10n.leoHappy2,
          l10n.leoHappy3,
        ];
      case LeoState.sleepy:
        return [
          l10n.leoSleepy1,
          l10n.leoSleepy2,
          l10n.leoSleepy3,
        ];
      case LeoState.warning:
        return [
          l10n.leoWarning1,
          l10n.leoWarning2,
          l10n.leoWarning3,
        ];
      case LeoState.proud:
        return [
          l10n.leoProud1,
          l10n.leoProud2,
          l10n.leoProud3,
        ];
      case LeoState.addCoffee:
        return [
          l10n.leoAddCoffee1,
          l10n.leoAddCoffee2,
          l10n.leoAddCoffee3,
        ];
    }
  }
  
  static List<String> _getDefaultMessages(LeoState state) {
    switch (state) {
      case LeoState.happy:
        return [
          'Today is a wonderful day for good coffee!',
          'Your cup is perfectly tempered. Enjoy the moment.',
          'A balanced coffee enjoyment - just right for you.',
        ];
      case LeoState.sleepy:
        return [
          'Have you enjoyed your first cup today?',
          'A gentle start to the day begins with a good coffee.',
          'How about an espresso for a pleasant energy boost?',
        ];
      case LeoState.warning:
        return [
          'Perhaps a little coffee break? Water would be ideal now.',
          'A moment to breathe - your caffeine level is quite high.',
          'How about a herbal tea for a change?',
        ];
      case LeoState.proud:
        return [
          'Wonderful! You have mastered your challenge.',
          'A nice success - your coffee balance is excellent.',
          'You did very well. Keep it up!',
        ];
      case LeoState.addCoffee:
        return [
          'Time for a new cup? What would you like?',
          'A coffee specialty for in between?',
          'Today is a good day for a cappuccino.',
        ];
    }
  }

  static LeoState getLeoState(int todayDrinks, double currentCaffeine, double caffeineLimit, bool challengeCompleted) {
    if (challengeCompleted) {
      return LeoState.proud;
    }
    
    if (todayDrinks == 0) {
      return LeoState.sleepy;
    }
    
    if (currentCaffeine > caffeineLimit * 0.8) {
      return LeoState.warning;
    }
    
    return LeoState.happy;
  }
} 