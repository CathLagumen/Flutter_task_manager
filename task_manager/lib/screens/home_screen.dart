import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
// import '../widgets/task_input.dart';
import '../widgets/task_list.dart';
import '../utils/constants.dart';
import '../utils/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks when screen loads
    Future.microtask(() {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  Future<void> _refreshTasks() async {
    await context.read<TaskProvider>().fetchTasks();
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter task title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await context.read<TaskProvider>().addTask(controller.text);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    final taskProvider = context.read<TaskProvider>();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('All Tasks'),
              trailing: taskProvider.currentFilter == TaskFilter.all
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                taskProvider.setFilter(TaskFilter.all);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Completed'),
              trailing: taskProvider.currentFilter == TaskFilter.completed
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                taskProvider.setFilter(TaskFilter.completed);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending),
              title: const Text('Pending'),
              trailing: taskProvider.currentFilter == TaskFilter.pending
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                taskProvider.setFilter(TaskFilter.pending);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterMenu,
            tooltip: 'Filter Tasks',
          ),
          // Theme toggle button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: themeProvider.isDarkMode 
                ? 'Switch to Light Mode' 
                : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          // Show loading indicator
          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error with retry option
          if (taskProvider.errorMessage != null && taskProvider.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading tasks',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    taskProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      taskProvider.clearError();
                      taskProvider.fetchTasks();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show tasks with pull-to-refresh
          return RefreshIndicator(
            onRefresh: _refreshTasks,
            child: Column(
              children: [
                // Task statistics
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Total', taskProvider.totalTasks, Colors.blue),
                      _buildStatCard('Completed', taskProvider.completedTasks, Colors.green),
                      _buildStatCard('Pending', taskProvider.pendingTasks, Colors.orange),
                    ],
                  ),
                ),
                Expanded(
                  child: TaskList(
                    tasks: taskProvider.tasks,
                    onToggleTask: (index) => taskProvider.toggleTask(index),
                    onDeleteTask: (index) => taskProvider.deleteTask(index),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}