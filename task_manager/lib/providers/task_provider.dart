import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

enum TaskFilter { all, completed, pending }

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  TaskFilter _currentFilter = TaskFilter.all;

  // Getters
  List<Task> get tasks {
    switch (_currentFilter) {
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return _tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.all:
        return _tasks;
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskFilter get currentFilter => _currentFilter;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;

  // Fetch tasks from API
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _apiService.fetchTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new task
  Future<void> addTask(String title) async {
    try {
      final newTask = await _apiService.addTask(title);
      _tasks.insert(0, newTask); // Add to top of list
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

    // Optimistic update
    task.toggleCompleted();
    notifyListeners();

    try {
      if (task.id != null) {
        await _apiService.updateTask(task.id!, task.isCompleted);
      }
    } catch (e) {
      // Revert on error
      task.isCompleted = originalStatus;
      _errorMessage = 'Failed to update task: $e';
      notifyListeners();
    }
  }

  // Delete a task
  Future<void> deleteTask(int index) async {
    final task = tasks[index];
    final removedTask = task;

    // Optimistic removal
    _tasks.remove(task);
    notifyListeners();

    try {
      if (task.id != null) {
        await _apiService.deleteTask(task.id!);
      }
    } catch (e) {
      // Revert on error
      _tasks.insert(index, removedTask);
      _errorMessage = 'Failed to delete task: $e';
      notifyListeners();
    }
  }

  // Edit a task
  Future<void> editTask(int index, String newTitle) async {
    final task = tasks[index];
    final originalTitle = task.title;

    // Optimistic update
    task.title = newTitle;
    notifyListeners();

    try {
      if (task.id != null) {
        await _apiService.editTask(task.id!, newTitle, task.isCompleted);
      }
    } catch (e) {
      // Revert on error
      task.title = originalTitle;
      _errorMessage = 'Failed to edit task: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Set filter
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
