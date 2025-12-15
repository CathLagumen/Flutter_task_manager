import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appTitle = 'Task Manager';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
}