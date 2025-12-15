import 'package:flutter/material.dart';


class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = Colors.blue;
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;

  // Dark Theme Colors
  static const Color darkPrimary = Colors.blueAccent;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightPrimary,
      surface: lightSurface,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkPrimary,
      surface: darkSurface,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: darkPrimary,
      foregroundColor: Colors.white,
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
    ),
  );
}