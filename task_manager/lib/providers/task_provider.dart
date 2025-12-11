// lib/providers/task_provider.dart

import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';

enum TaskFilter { all, completed, pending }

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final PreferencesService _prefsService = PreferencesService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  TaskFilter _currentFilter = TaskFilter.all;
  bool _isUsingCachedData = false;
  String _viewMode = 'list';

  List<Task> get tasks {
    switch (_currentFilter) {
      case TaskFilter.completed:
        return _tasks.where((task) => task.completed).toList();
      case TaskFilter.pending:
        return _tasks.where((task) => !task.completed).toList();
      case TaskFilter.all:
      default:
        return _tasks;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  TaskFilter get currentFilter => _currentFilter;
  bool get isUsingCachedData => _isUsingCachedData;
  String get viewMode => _viewMode;

  // Load tasks from API or cache
  Future<void> loadTasks({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to fetch from API
      final fetchedTasks = await _apiService.fetchTasks();
      _tasks = fetchedTasks;
      _isUsingCachedData = false;
      
      // Cache the tasks
      await _prefsService.cacheTasks(fetchedTasks);
      
    } catch (e) {
      // If API fails, try to load from cache
      final cachedTasks = await _prefsService.getCachedTasks();
      
      if (cachedTasks != null && cachedTasks.isNotEmpty) {
        _tasks = cachedTasks;
        _isUsingCachedData = true;
        _error = 'Showing cached data. Unable to fetch latest tasks.';
      } else {
        _error = 'Failed to load tasks: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new task
  Future<bool> addTask({
    required int userId,
    required String title,
    required bool completed,
  }) async {
    try {
      final newTask = await _apiService.createTask(
        userId: userId,
        title: title,
        completed: completed,
      );
      
      // Add to the beginning of the list for visibility
      _tasks.insert(0, newTask);
      
      // Update cache
      await _prefsService.cacheTasks(_tasks);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update task completion status
  Future<void> toggleTaskCompletion(Task task) async {
    try {
      final updatedTask = task.copyWith(completed: !task.completed);
      
      // Update locally first for instant feedback
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
      
      // Update on server (JSONPlaceholder won't actually update)
      await _apiService.updateTask(updatedTask);
      
      // Update cache
      await _prefsService.cacheTasks(_tasks);
      
    } catch (e) {
      _error = 'Failed to update task: ${e.toString()}';
      notifyListeners();
    }
  }

  // Delete a task
  Future<void> deleteTask(int taskId) async {
    try {
      await _apiService.deleteTask(taskId);
      
      _tasks.removeWhere((task) => task.id == taskId);
      
      // Update cache
      await _prefsService.cacheTasks(_tasks);
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete task: ${e.toString()}';
      notifyListeners();
    }
  }

  // Set filter
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Load filter preference
  Future<void> loadFilterPreference() async {
    final filterString = await _prefsService.getDefaultFilter();
    switch (filterString) {
      case 'completed':
        _currentFilter = TaskFilter.completed;
        break;
      case 'pending':
        _currentFilter = TaskFilter.pending;
        break;
      default:
        _currentFilter = TaskFilter.all;
    }
    notifyListeners();
  }

  // Save filter preference
  Future<void> saveFilterPreference(TaskFilter filter) async {
    String filterString;
    switch (filter) {
      case TaskFilter.completed:
        filterString = 'completed';
        break;
      case TaskFilter.pending:
        filterString = 'pending';
        break;
      default:
        filterString = 'all';
    }
    await _prefsService.setDefaultFilter(filterString);
  }

  // Load view mode preference
  Future<void> loadViewMode() async {
    _viewMode = await _prefsService.getViewMode();
    notifyListeners();
  }

  // Set view mode
  Future<void> setViewMode(String mode) async {
    _viewMode = mode;
    await _prefsService.setViewMode(mode);
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}