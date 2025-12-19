import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class CacheService {
  static const String _tasksKey = 'cached_tasks';
  static const String _lastFetchKey = 'last_fetch_time';
  static const String _darkModeKey = 'dark_mode';
  static const String _viewModeKey = 'view_mode';


  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      await prefs.setString(_tasksKey, json.encode(tasksJson));
      await prefs.setString(_lastFetchKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving tasks to cache: $e');
    }
  }

  Future<List<Task>?> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksString = prefs.getString(_tasksKey);
      
      if (tasksString == null) return null;
      
      final List<dynamic> tasksJson = json.decode(tasksString);
      return tasksJson.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print('Error loading tasks from cache: $e');
      return null;
    }
  }

  Future<DateTime?> getLastFetchTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastFetchKey);
      
      if (timeString == null) return null;
      
      return DateTime.parse(timeString);
    } catch (e) {
      print('Error getting last fetch time: $e');
      return null;
    }
  }

  Future<void> clearTasksCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tasksKey);
      await prefs.remove(_lastFetchKey);
    } catch (e) {
      print('Error clearing tasks cache: $e');
    }
  }

  Future<void> saveDarkMode(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDarkMode);
    } catch (e) {
      print('Error saving dark mode preference: $e');
    }
  }

  Future<bool> loadDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_darkModeKey) ?? false;
    } catch (e) {
      print('Error loading dark mode preference: $e');
      return false;
    }
  }

  Future<bool> hasCachedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tasksKey);
  }

  Future<int?> getCacheAgeInHours() async {
    final lastFetch = await getLastFetchTime();
    if (lastFetch == null) return null;
    
    final difference = DateTime.now().difference(lastFetch);
    return difference.inHours;
  }

  // Save view mode preference (true = grid, false = list)
  Future<void> saveViewMode(bool isGridView) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_viewModeKey, isGridView);
    } catch (e) {
      print('Error saving view mode preference: $e');
    }
  }

  Future<bool> loadViewMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_viewModeKey) ?? false; // Default to list view
    } catch (e) {
      print('Error loading view mode preference: $e');
      return false;
    }
  }
}