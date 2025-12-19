import 'package:flutter/material.dart';
import '../services/cache_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  final CacheService _cacheService = CacheService();
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  // Load saved theme preference
  Future<void> loadThemePreference() async {
    final isDark = await _cacheService.loadDarkMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _isInitialized = true;
    notifyListeners();
  }

  // Toggle theme and save preference
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    
    await _cacheService.saveDarkMode(isDarkMode);
    notifyListeners();
  }

  // Set specific theme and save preference
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await _cacheService.saveDarkMode(isDarkMode);
    notifyListeners();
  }
}