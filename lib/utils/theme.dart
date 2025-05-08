import 'package:flutter/material.dart';

class AppTheme {
  // Define the new seed color
  static const Color _seedColor = Color(0xFF673AB7); // Deep Purple

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      // The background color will be determined by the color scheme (typically surface)
      // If you want a specific color, you can set it e.g., backgroundColor: _seedColor
    ),
    // You can add more theme customizations here for a minimalist style
    // e.g., cardTheme, floatingActionButtonTheme, textTheme, etc.
  );

  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      // The background color will be determined by the color scheme (typically surface variant or similar)
    ),
    // You can add more theme customizations here for a minimalist style
  );
}
