// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import '../widgets/error_widget.dart';
import 'task_detail_screen.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  Future<void> _refreshTasks() async {
    await context.read<TaskProvider>().loadTasks(forceRefresh: true);
  }

  void _showFilterDialog() {
    final provider = context.read<TaskProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<TaskFilter>(
              title: const Text('All Tasks'),
              value: TaskFilter.all,
              groupValue: provider.currentFilter,
              onChanged: (value) {
                if (value != null) {
                  provider.setFilter(value);
                  provider.saveFilterPreference(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<TaskFilter>(
              title: const Text('Completed'),
              value: TaskFilter.completed,
              groupValue: provider.currentFilter,
              onChanged: (value) {
                if (value != null) {
                  provider.setFilter(value);
                  provider.saveFilterPreference(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<TaskFilter>(
              title: const Text('Pending'),
              value: TaskFilter.pending,
              groupValue: provider.currentFilter,
              onChanged: (value) {
                if (value != null) {
                  provider.setFilter(value);
                  provider.saveFilterPreference(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          Consumer<TaskProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton(
                icon: Icon(
                  Icons.filter_list,
                  color: provider.currentFilter != TaskFilter.all
                      ? Colors.amber
                      : null,
                ),
                onSelected: (value) {
                  if (value == 'filter') {
                    _showFilterDialog();
                  } else if (value == 'settings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'filter',
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list),
                        const SizedBox(width: 8),
                        Text('Filter: ${_getFilterLabel(provider.currentFilter)}'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          // Show cached data banner if applicable
          if (provider.isUsingCachedData) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.orange[100],
                  child: Row(
                    children: [
                      Icon(Icons.offline_bolt, 
                        color: Colors.orange[800],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Showing cached data (Offline)',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildTaskList(provider)),
              ],
            );
          }

          // Loading state
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading tasks...'),
                ],
              ),
            );
          }

          // Error state (with no cached data)
          if (provider.error != null && 
              provider.tasks.isEmpty && 
              !provider.isUsingCachedData) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: _refreshTasks,
            );
          }

          // Success state - show tasks
          return _buildTaskList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),
            ),
          );
          
          if (result == true) {
            _refreshTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(TaskProvider provider) {
    if (provider.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new task',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child: ListView.builder(
        itemCount: provider.tasks.length,
        itemBuilder: (context, index) {
          final task = provider.tasks[index];
          return TaskItem(
            task: task,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(task: task),
                ),
              );
            },
            onToggle: (value) {
              provider.toggleTaskCompletion(task);
            },
          );
        },
      ),
    );
  }
}