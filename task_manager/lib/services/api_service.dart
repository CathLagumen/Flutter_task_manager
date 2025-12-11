// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  
  // Timeout duration for API calls
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Fetch all tasks
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/todos'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Task.fromJson(json)).toList();
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
      final response = await http
          .get(Uri.parse('$baseUrl/todos/$id'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load task. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching task: $e');
    }
  }

  // Create a new task
  Future<Task> createTask({
    required int userId,
    required String title,
    required bool completed,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'title': title,
          'completed': completed,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 201) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create task. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating task: $e');
    }
  }

  // Update a task
  Future<Task> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update task. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/todos/$id'))
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }
}