import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/widgets/task/tasks_list.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _isLoading = false;

  // refresh task list
  Future<void> _refreshTasks() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<TaskProvider>(context, listen: false)
        .fetchAndSetTasks()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // events to show
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshTasks,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      color: Theme.of(context).primaryColor,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : TasksList(),
    );
  }
}
