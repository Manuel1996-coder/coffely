import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

enum MascotState {
  happy, // Glücklich nach einem Kaffee
  sleepy, // Müde, braucht Kaffee
  excited, // Zu viel Kaffee getrunken
  success, // Erfolg bei einer Challenge
  greeting // Normale Begrüßung
}

class CoffeeMascot extends StatefulWidget {
  final MascotState state;
  final double size;
  final VoidCallback? onTap;
  final String animationPath;

  const CoffeeMascot({
    super.key,
    this.state = MascotState.greeting,
    this.size = 120,
    this.onTap,
    required this.animationPath,
  });

  @override
  State<CoffeeMascot> createState() => _CoffeeMascotState();
}

class _CoffeeMascotState extends State<CoffeeMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Einmalig abspielen für bestimmte Zustände, wiederholen für andere
    if (widget.state == MascotState.success ||
        widget.state == MascotState.excited) {
      _controller.forward();
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CoffeeMascot oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Wenn sich der Zustand ändert, setzen wir die Animation zurück
    if (oldWidget.state != widget.state) {
      _controller.reset();

      if (widget.state == MascotState.success ||
          widget.state == MascotState.excited) {
        _controller.forward();
      } else {
        _controller.repeat();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Lottie.asset(
          widget.animationPath,
          controller: _controller,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class BouncingMascot extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const BouncingMascot({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 4 * sin(value * 3.14 * 2)),
          child: child,
        );
      },
      child: child,
    );
  }
}

// Ein Mascot-Manager, der verschiedene Animationen basierend auf dem State zurückgibt
class MascotManager {
  static String getAnimationForState(MascotState state) {
    // Später kannst du verschiedene Animationen für verschiedene Zustände hinzufügen
    // Aktuell wird nur eine Animation verwendet
    return 'assets/animations/coffee_mascot.json';
  }

  static String getMessage(MascotState state, BuildContext context) {
    switch (state) {
      case MascotState.happy:
        return 'Perfekter Kaffee! Ich fühle mich großartig!';
      case MascotState.sleepy:
        return 'Ich brauche etwas Kaffee... *gähn*';
      case MascotState.excited:
        return 'Wow! So viel Energie! Zu viel Kaffee!';
      case MascotState.success:
        return 'Gut gemacht! Du hast eine Herausforderung gemeistert!';
      case MascotState.greeting:
        return 'Hallo! Zeit für einen Kaffee?';
    }
  }
}
