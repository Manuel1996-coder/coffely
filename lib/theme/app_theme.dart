import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Kaffee-inspirierte Farbpalette
  static const Color primaryColor = Color(0xFF6F4E37); // Kaffeebraun
  static const Color secondaryColor = Color(0xFFB87333); // Kupfer/Zimtfarbe
  static const Color accentColor = Color(0xFFD4A76A); // Karamell
  static const Color backgroundColor =
      Color(0xFFF5F1E6); // Cremiger Milchschaum
  static const Color cardColor = Color(0xFFFFFBF5); // Heller Creme
  static const Color textColor = Color(0xFF362E2B); // Dunkles Kaffeebraun
  static const Color secondaryTextColor =
      Color(0xFF6D5C4D); // Helleres Kaffeebraun
  static const Color tertiaryTextColor =
      Color(0xFF9D8C7C); // Noch helleres Kaffeebraun
  static const Color successColor = Color(0xFF4A8D3D); // Espresso-Blatt-Grün
  static const Color warningColor = Color(0xFFD4953F); // Honig

  // Schatten für Tiefenwirkung
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  // Animation Dauer
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Übergangsanimation
  static final pageTransition = const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: const CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
    },
  );

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: cardColor,
        onSurface: textColor,
        error: Colors.red[400]!,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.raleway(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: GoogleFonts.raleway(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: GoogleFonts.raleway(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: GoogleFonts.raleway(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: secondaryTextColor,
        ),
        bodySmall: GoogleFonts.lato(
          fontSize: 12,
          color: tertiaryTextColor,
        ),
        labelLarge: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor:
              WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor:
              WidgetStateProperty.all(primaryColor.withOpacity(0.1)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor:
              WidgetStateProperty.all(primaryColor.withOpacity(0.1)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: GoogleFonts.lato(
          fontSize: 14,
          color: tertiaryTextColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      iconTheme: const IconThemeData(
        color: primaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.raleway(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        iconTheme: const IconThemeData(
          color: primaryColor,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primaryColor.withOpacity(0.2),
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 65,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor, size: 24);
          }
          return IconThemeData(color: textColor.withOpacity(0.5), size: 24);
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tertiaryTextColor.withOpacity(0.2),
        thickness: 1,
        space: 24,
      ),
      pageTransitionsTheme: pageTransition,
    );
  }
}
