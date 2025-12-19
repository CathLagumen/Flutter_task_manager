import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

enum TaskFilter { all, completed, pending }

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();
  
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  TaskFilter _currentFilter = TaskFilter.all;
  bool _isUsingCache = false;
  DateTime? _lastFetchTime;
  String _searchQuery = '';

  // Getters
  List<Task> get tasks {
    // First apply filter
    List<Task> filteredTasks;
    
    if (_currentFilter == TaskFilter.completed) {
      filteredTasks = _tasks.where((task) => task.isCompleted).toList();
    } else if (_currentFilter == TaskFilter.pending) {
      filteredTasks = _tasks.where((task) => !task.isCompleted).toList();
    } else {
      filteredTasks = _tasks;
    }

    // Then apply search query
    if (_searchQuery.isEmpty) {
      return filteredTasks;
    }

    return filteredTasks.where((task) {
      return task.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskFilter get currentFilter => _currentFilter;
  bool get isUsingCache => _isUsingCache;
  DateTime? get lastFetchTime => _lastFetchTime;
  String get searchQuery => _searchQuery;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;

  Future<void> loadCachedTasks() async {
    final cachedTasks = await _cacheService.loadTasks();
    if (cachedTasks != null && cachedTasks.isNotEmpty) {
      _tasks = cachedTasks;
      _isUsingCache = true;
      _lastFetchTime = await _cacheService.getLastFetchTime();
      notifyListeners();
    }
  }

  Future<void> fetchTasks({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _tasks = await _apiService.fetchTasks();
      _isUsingCache = false;
      _lastFetchTime = DateTime.now();
      
      
      await _cacheService.saveTasks(_tasks);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      
      // Try to load from cache if API fails
      if (_tasks.isEmpty) {
        final cachedTasks = await _cacheService.loadTasks();
        if (cachedTasks != null && cachedTasks.isNotEmpty) {
          _tasks = cachedTasks;
          _isUsingCache = true;
          _lastFetchTime = await _cacheService.getLastFetchTime();
          _errorMessage = 'Showing cached data (offline mode)';
        }
      }
      
      notifyListeners();
    }
  }

  
  Future<void> addTask(String title, int userId, bool completed) async {
    try {
      final newTask = await _apiService.addTask(title, userId, completed);
      _tasks.insert(0, newTask);
      
      // Update cache
      await _cacheService.saveTasks(_tasks);
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add task: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Toggle task completion 
  Future<void> toggleTask(int index) async {
    final task = tasks[index];
    final originalStatus = task.isCompleted;
    
    task.toggleCompleted();
    notifyListeners();

    try {
      if (task.id != null) {
        await _apiService.updateTask(task.id!, task.isCompleted);
        
        await _cacheService.saveTasks(_tasks);
      }
    } catch (e) {
      
      task.isCompleted = originalStatus;
      _errorMessage = 'Failed to update task: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTask(int index) async {
    final task = tasks[index];
    final removedTask = task;
    final originalIndex = _tasks.indexOf(task);
    
    _tasks.remove(task);
    notifyListeners();

    try {
      if (task.id != null) {
        await _apiService.deleteTask(task.id!);
        
        await _cacheService.saveTasks(_tasks);
      }
    } catch (e) {
      _tasks.insert(originalIndex, removedTask);
      _errorMessage = 'Failed to delete task: $e';
      notifyListeners();
    }
  }

  Future<void> editTask(int index, String newTitle) async {
    final task = tasks[index];
    final originalTitle = task.title;
    
    
    task.title = newTitle;
    notifyListeners();

    try {
      if (task.id != null) {
        await _apiService.editTask(task.id!, newTitle, task.isCompleted);
        
        
        await _cacheService.saveTasks(_tasks);
      }
    } catch (e) {
      task.title = originalTitle;
      _errorMessage = 'Failed to edit task: $e';
      notifyListeners();
      rethrow;
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> clearCache() async {
    await _cacheService.clearTasksCache();
    _isUsingCache = false;
    _lastFetchTime = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  
  Future<int?> getCacheAge() async {
    return await _cacheService.getCacheAgeInHours();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }
}