import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class StaffTasksPage extends StatefulWidget {
  const StaffTasksPage({super.key});

  @override
  State<StaffTasksPage> createState() => _StaffTasksPageState();
}

class _StaffTasksPageState extends State<StaffTasksPage> {
  bool _isLoading = true;
  List<EmployeeTask> _tasks = [];
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      String url = "http://192.168.18.7/swb_api/get_tasks.php";
      if (userId != null) {
        url += "?assigned_to=$userId";
      }

      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<dynamic> list = data['tasks'] as List<dynamic>;
        final items = list
            .map((e) => EmployeeTask.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _tasks = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _tasks = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _tasks = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tasks: $e')),
        );
      }
    }
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      final url = Uri.parse("http://192.168.18.7/swb_api/update_task_status.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "task_id": taskId,
          "status": newStatus,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        await _loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task status updated')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${data['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<EmployeeTask> get _filteredTasks {
    if (_filterStatus == 'All') return _tasks;
    return _tasks.where((t) => t.status == _filterStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _filterStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                          value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(
                          value: 'In Progress', child: Text('In Progress')),
                      DropdownMenuItem(
                          value: 'Completed', child: Text('Completed')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value ?? 'All';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                    ? const Center(
                        child: Text('No tasks found'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTasks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = _filteredTasks[index];
                            final statusColor = _getStatusColor(task.status);
                            final dateStr = task.scheduledDate
                                .toString()
                                .split(' ')[0];

                            return Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            task.taskType,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                statusColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            task.status,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      task.taskDescription,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16),
                                        const SizedBox(width: 4),
                                        Text(dateStr),
                                        if (task.scheduledTime != null) ...[
                                          const SizedBox(width: 12),
                                          const Icon(Icons.access_time, size: 16),
                                          const SizedBox(width: 4),
                                          Text(task.scheduledTime!),
                                        ],
                                      ],
                                    ),
                                    if (task.priority != 'Medium') ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.flag,
                                            size: 16,
                                            color: task.priority == 'High'
                                                ? Colors.red
                                                : Colors.blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Priority: ${task.priority}',
                                            style: TextStyle(
                                              color: task.priority == 'High'
                                                  ? Colors.red
                                                  : Colors.blue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    if (task.status != 'Completed')
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            String newStatus = task.status ==
                                                    'Pending'
                                                ? 'In Progress'
                                                : 'Completed';
                                            _updateTaskStatus(
                                                task.id, newStatus);
                                          },
                                          child: Text(
                                            task.status == 'Pending'
                                                ? 'Start Task'
                                                : 'Mark Complete',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
