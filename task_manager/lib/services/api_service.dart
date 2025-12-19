import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration timeoutDuration = Duration(seconds: 10);
  
  // Headers to avoid 403 error
  static Map<String, String> get headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    'User-Agent': 'Flutter-TaskManager/1.0',
  };
  
  // Fetch all tasks from API
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos'),
        headers: headers,  // ADD THIS
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        // Take first 20 tasks
        return jsonData
            .take(20)
            .map((json) => Task.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load tasks. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  // Fetch a single task by ID
  Future<Task> fetchTaskById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos/$id'),
        headers: headers,  // ADD THIS
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Task.fromJson(jsonData);
      } else {
        throw Exception('Failed to load task. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching task: $e');
    }
  }

  // Add new task to API
  Future<Task> addTask(String title, int userId, bool completed) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: headers,  // ALREADY HAD THIS
        body: json.encode({
          'title': title,
          'completed': completed,
          'userId': userId,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Task.fromJson(jsonData);
      } else {
        throw Exception('Failed to add task. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding task: $e');
    }
  }

  // Update task completion status
  Future<Task> updateTask(int id, bool isCompleted) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/todos/$id'),
        headers: headers,  // ALREADY HAD THIS
        body: json.encode({
          'completed': isCompleted,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Task.fromJson(jsonData);
      } else {
        throw Exception('Failed to update task. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  // Edit task title and status
  Future<Task> editTask(int id, String title, bool isCompleted) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/$id'),
        headers: headers,  // ALREADY HAD THIS
        body: json.encode({
          'title': title,
          'completed': isCompleted,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Task.fromJson(jsonData);
      } else {
        throw Exception('Failed to edit task. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error editing task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/todos/$id'),
        headers: headers,  // ADD THIS
      ).timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

  // Mock data fallback
  List<Task> getMockTasks() {
    return List.generate(20, (index) {
      return Task(
        id: index + 1,
        userId: (index % 5) + 1,
        title: [
          'Complete project documentation',
          'Review pull requests',
          'Fix bug in authentication',
          'Update dependencies',
          'Write unit tests',
          'Deploy to production',
          'Create user guide',
          'Optimize database queries',
          'Implement dark mode',
          'Add search functionality',
          'Refactor legacy code',
          'Setup CI/CD pipeline',
          'Design new landing page',
          'Conduct code review',
          'Update API documentation',
          'Fix mobile responsive issues',
          'Implement caching strategy',
          'Add error logging',
          'Create backup system',
          'Improve app performance',
        ][index % 20],
        isCompleted: index % 3 == 0,
      );
    });
  }
}