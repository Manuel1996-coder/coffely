import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Kaffee-inspirierte Farbpalette
  static const Color primaryColor = Color(0xFF6F4E37); // Kaffeebraun
  static const Color secondaryColor = Color(0xFFB87333); // Kupfer/Zimtfarbe
  static const Color accentColor = Color(0xFFD4A76A); // Karamell
  static const Color backgroundColor =
      Color(0xFFF5F1E6); // Cremiger Milchschaum
  static const Color textColor = Color(0xFF362E2B); // Dunkles Kaffeebraun
  static const Color secondaryTextColor =
      Color(0xFF6D5C4D); // Helleres Kaffeebraun

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: Colors.white,
        background: backgroundColor,
        onBackground: textColor,
        onSurface: textColor,
        error: Colors.red[300]!,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.raleway(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: GoogleFonts.raleway(
          fontSize: 22,
          fontWeight: FontWeight.bold,
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
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      iconTheme: const IconThemeData(
        color: primaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primaryColor.withOpacity(0.2),
        backgroundColor: Colors.white,
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return IconThemeData(color: textColor.withOpacity(0.6));
        }),
      ),
    );
  }
}
