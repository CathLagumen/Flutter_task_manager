import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Fetch all tasks from API
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/todos'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Take only first 20 tasks for better performance
        return jsonData.take(20).map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  // Add a new task to API
  Future<Task> addTask(String title) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'completed': false, 'userId': 1}),
      );

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
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'completed': isCompleted}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Task.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to update task. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  // Update task title and completion status
  Future<Task> editTask(int id, String title, bool isCompleted) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'completed': isCompleted}),
      );

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
      final response = await http.delete(Uri.parse('$baseUrl/todos/$id'));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete task. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }
}
