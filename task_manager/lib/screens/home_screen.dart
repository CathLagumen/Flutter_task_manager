import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_list.dart';
import '../utils/constants.dart';
import '../utils/theme_provider.dart';
import 'task_form_screen.dart';
import 'settings_screen.dart';
import '../providers/view_mode_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    
    Future.microtask(() {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  Future<void> _refreshTasks() async {
    await context.read<TaskProvider>().fetchTasks();
  }

  void _navigateToAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskFormScreen(),
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
    Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        actions: [
          Consumer<ViewModeProvider>(
            builder: (context, viewModeProvider, child) {
              return IconButton(
                icon: Icon(
                  viewModeProvider.isGridView ? Icons.view_list : Icons.grid_view,
                ),
                onPressed: () {
                  viewModeProvider.toggleViewMode();
                },
                tooltip: viewModeProvider.isGridView ? 'Switch to List View' : 'Switch to Grid View',
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterMenu,
            tooltip: 'Filter Tasks',
          ),

          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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

          // pull to refresh
          return RefreshIndicator(
            onRefresh: _refreshTasks,
            child: Column(
              children: [
                _buildCacheIndicator(taskProvider),
                _buildSearchBar(taskProvider),
                
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
                  child: Consumer<ViewModeProvider>(
                    builder: (context, viewModeProvider, child) {
                      return TaskList(
                        tasks: taskProvider.tasks,
                        isGridView: viewModeProvider.isGridView,
                        onToggleTask: (index) => taskProvider.toggleTask(index),
                        onDeleteTask: (index) => taskProvider.deleteTask(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
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

  Widget _buildSearchBar(TaskProvider taskProvider) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: TextField(
      onChanged: (value) {
        taskProvider.setSearchQuery(value);
      },
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: taskProvider.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  taskProvider.clearSearchQuery();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C2C)
            : Colors.grey[100],
      ),
    ),
  );
}

  Widget _buildCacheIndicator(TaskProvider taskProvider) {
  if (!taskProvider.isUsingCache) return const SizedBox.shrink();

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: Colors.orange.withOpacity(0.2),
    child: Row(
      children: [
        const Icon(Icons.offline_bolt, color: Colors.orange, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Offline Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
              if (taskProvider.lastFetchTime != null)
                Text(
                  'Last updated: ${_formatCacheTime(taskProvider.lastFetchTime!)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => taskProvider.fetchTasks(),
          child: const Text(
            'Refresh',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

String _formatCacheTime(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inDays < 1) {
    return '${difference.inHours} hours ago';
  } else {
    return '${difference.inDays} days ago';
  }
}

  
}