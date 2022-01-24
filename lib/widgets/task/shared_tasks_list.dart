import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/screens/tasks/shared_task_detail_screen.dart';
import 'package:under_control_flutter/widgets/task/shared_task_list_item.dart';

// ignore: must_be_immutable
class SharedTasksList extends StatefulWidget {
  SharedTasksList({Key? key}) : super(key: key);

  SharedTasksList.item({
    Key? key,
    required this.item,
    required this.task,
  }) : super(key: key);

  Item? item;
  Task? task;

  @override
  _SharedTasksListState createState() => _SharedTasksListState();
}

class _SharedTasksListState extends State<SharedTasksList> {
  Map<String, List<Task>> _tasks = {};
  var executor = TaskExecutor.all;

  final List<IconData> statusIcons = const [
    Icons.pending_actions_outlined,
    Icons.pause_outlined,
    Icons.done,
  ];

  final List<String> statusText = const [
    'Pending',
    'In progress',
    'Completed',
  ];

  @override
  void initState() {
    getItems();
    super.initState();
  }

  Future<void> getItems() async {
    String companyId = (await Provider.of<UserProvider>(context, listen: false)
            .getUserById(context, widget.task!.userId))!
        .companyId!;
    _tasks = await Provider.of<TaskProvider>(context, listen: false)
        .getSharedDoneTasks(widget.item!, companyId);
  }

  @override
  Widget build(BuildContext context) {
    TaskProvider taskProvider = Provider.of<TaskProvider>(context);
    executor = taskProvider.executor;

    Map<String, List<Task>> filteredTasks = {};

    final keys = _tasks.keys.toList();

    final user = Provider.of<UserProvider>(context).user;

    if (widget.item != null) {
      for (var key in keys) {
        if (_tasks[key] != null) {
          for (var task in _tasks[key]!) {
            if (task.itemId == widget.item!.itemId) {
              if (filteredTasks.containsKey(key)) {
                filteredTasks[key]!.add(task);
              } else {
                filteredTasks[key] = [task];
              }
            }
          }
        }
      }
    } else if (executor == TaskExecutor.all) {
      filteredTasks = _tasks;
    } else if (executor == TaskExecutor.company) {
      for (var key in keys) {
        if (_tasks[key] != null) {
          for (var task in _tasks[key]!) {
            if (task.executor == executor) {
              if (filteredTasks.containsKey(key)) {
                filteredTasks[key]!.add(task);
              } else {
                filteredTasks[key] = [task];
              }
            }
          }
        }
      }
    } else if (executor == TaskExecutor.user) {
      for (var key in keys) {
        if (_tasks[key] != null) {
          for (var task in _tasks[key]!) {
            if (task.executor == executor && task.executorId == user!.userId) {
              if (filteredTasks.containsKey(key)) {
                filteredTasks[key]!.add(task);
              } else {
                filteredTasks[key] = [task];
              }
            }
          }
        }
      }
    } else if (executor == TaskExecutor.shared) {
      for (var key in keys) {
        if (_tasks[key] != null) {
          for (var task in _tasks[key]!) {
            if (task.executor == executor) {
              if (filteredTasks.containsKey(key)) {
                filteredTasks[key]!.add(task);
              } else {
                filteredTasks[key] = [task];
              }
            }
          }
        }
      }
    }

    return taskProvider.isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : filteredTasks.isNotEmpty
            ? ListView.builder(
                // turn scroll off if showing in task details screen
                physics: widget.item != null
                    ? const NeverScrollableScrollPhysics()
                    : null,
                shrinkWrap: true,
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
                itemCount: keys.length,
                itemBuilder: (ctx, index) {
                  List<Widget> listItems = [];
                  final dateFormat = DateFormat('dd/MM/yyyy');
                  keys.sort((a, b) =>
                      dateFormat.parse(a).compareTo(dateFormat.parse(b)));

                  if (filteredTasks[keys[index]] != null) {
                    for (var task in filteredTasks[keys[index]]!) {
                      Item? item;
                      try {
                        item = Provider.of<ItemProvider>(context, listen: false)
                            .items
                            .firstWhere(
                                (element) => element.itemId == task.itemId);
                      } catch (e) {
                        item = null;
                      }

                      listItems.add(
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(
                              SharedTaskDetailsScreen.routeName,
                              arguments: task),
                          child: SharedTaskListItem(
                            task: task,
                            item: item,
                          ),
                        ),
                      );
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (listItems.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockSizeHorizontal * 5,
                            vertical: SizeConfig.blockSizeHorizontal,
                          ),
                          child: Text(keys[index]),
                        ),
                      ...listItems,
                    ],
                  );
                },
              )
            : const Center(
                child: Text(
                  'You don\'t have any tasks yet.\nAdd some!',
                  textAlign: TextAlign.center,
                ),
              );
  }
}
