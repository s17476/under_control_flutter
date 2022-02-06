import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/screens/inspection/add_inspection_screen.dart';
import 'package:under_control_flutter/screens/tasks/shared_task_detail_screen.dart';
import 'package:under_control_flutter/screens/tasks/task_details_screen.dart';
import 'package:under_control_flutter/widgets/task/task_list_item.dart';

// ignore: must_be_immutable
class TasksList extends StatefulWidget {
  TasksList({Key? key}) : super(key: key);

  TasksList.item({
    Key? key,
    required this.item,
  }) : super(key: key);

  Item? item;

  @override
  _TasksListState createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> with ResponsiveSize {
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
    super.initState();
    _tasks = Provider.of<TaskProvider>(context, listen: false).getAllTasks;
  }

  Future<bool> _showDeleteDialog(
    BuildContext context,
    Task task,
  ) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete task?'),
          content: SingleChildScrollView(
            child: Text(
              'Are you sure You want to delete \n${task.title} from the task list?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'No',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    TaskProvider taskProvider = Provider.of<TaskProvider>(context);
    executor = taskProvider.executor;
    _tasks = taskProvider.getAllTasks;

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
                padding: EdgeInsets.all(responsiveSizePx(small: 0, medium: 24)),
                itemCount: keys.length,
                itemBuilder: (ctx, index) {
                  List<Widget> listItems = [];
                  final dateFormat = DateFormat('dd/MM/yyyy');
                  if (taskProvider.isActive) {
                    keys.sort((a, b) =>
                        dateFormat.parse(a).compareTo(dateFormat.parse(b)));
                  } else {
                    keys.sort((a, b) =>
                        dateFormat.parse(b).compareTo(dateFormat.parse(a)));
                  }

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
                        (Provider.of<TaskProvider>(context).isActive &&
                                task.type != TaskType.inspection &&
                                task.executor != TaskExecutor.shared)
                            ?
                            // shows active tasks
                            Dismissible(
                                key: ValueKey(DateTime.now().toIso8601String()),
                                confirmDismiss: (direction) async {
                                  bool exit = false;
                                  bool response = false;

                                  // swipe right - rapid complete
                                  // rapid complete is a quick and easy way to complete standard tasks
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    // if task is inspection
                                    if (task.type == TaskType.inspection) {
                                      await Navigator.of(context).pushNamed(
                                          AddInspectionScreen.routeName,
                                          arguments: [
                                            Provider.of<ItemProvider>(context,
                                                    listen: false)
                                                .items
                                                .firstWhere((element) =>
                                                    element.itemId ==
                                                    task.itemId),
                                            task
                                          ]).then((value) {
                                        if (value != null) {
                                          exit = value as bool;
                                        }
                                      });
                                      if (exit == false) {
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  'Rapid Complete canceled!'),
                                              backgroundColor:
                                                  Theme.of(context).errorColor,
                                            ),
                                          );
                                        return false;
                                      }
                                    }

                                    await Provider.of<TaskProvider>(context,
                                            listen: false)
                                        .rapidComplete(context, task)
                                        .then((value) {
                                      response = value;

                                      filteredTasks[keys[index]]?.remove(task);
                                    });

                                    // swipe left - delete
                                  } else if (direction ==
                                      DismissDirection.endToStart) {
                                    await _showDeleteDialog(context, task)
                                        .then((value) {
                                      if (value) {
                                        Provider.of<TaskProvider>(context,
                                                listen: false)
                                            .deleteTask(task);
                                        response = value;
                                      } else {
                                        response = false;
                                      }
                                    });

                                    if (response) {
                                      ScaffoldMessenger.of(context)
                                        ..removeCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            content:
                                                const Text('Task deleted!'),
                                            backgroundColor:
                                                Theme.of(context).errorColor,
                                          ),
                                        );
                                    }
                                  }
                                  return response;
                                },
                                secondaryBackground: Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  alignment: Alignment.centerRight,
                                  color: Colors.red,
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size:
                                        responsiveSizePx(small: 50, medium: 70),
                                  ),
                                ),
                                background: Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  alignment: Alignment.centerLeft,
                                  color: Colors.green,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.done,
                                        color: Colors.white,
                                        size: responsiveSizePx(
                                            small: 60, medium: 90),
                                      ),
                                      Text(
                                        'Rapid Complete',
                                        style: TextStyle(
                                          fontSize: responsiveSizePx(
                                              small: 25, medium: 40),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(TaskDetailsScreen.routeName,
                                          arguments: task)
                                      .then((value) {
                                    if (value != null) {
                                      String msg = '';
                                      Color color = Theme.of(context)
                                          .appBarTheme
                                          .backgroundColor!;
                                      if (value == 'deleted') {
                                        msg = 'Task has been deleted!';
                                      } else if (value == 'completed') {
                                        msg = 'Task completed. Well done!';
                                        color = Theme.of(context).primaryColor;
                                      }
                                      ScaffoldMessenger.of(context)
                                        ..removeCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            content: Text(msg),
                                            backgroundColor: color,
                                          ),
                                        );
                                    }
                                  }),
                                  child: TaskListItem(task: task, item: item),
                                ),
                              )
                            : GestureDetector(
                                onTap: (task.executor == TaskExecutor.shared &&
                                        task.executorId == user!.companyId)
                                    ? () {
                                        Navigator.of(context).pushNamed(
                                            SharedTaskDetailsScreen.routeName,
                                            arguments: task);
                                      }
                                    : () => Navigator.of(context)
                                            .pushNamed(
                                                TaskDetailsScreen.routeName,
                                                arguments: task)
                                            .then((value) {
                                          if (value != null) {
                                            String msg = '';
                                            Color color = Theme.of(context)
                                                .appBarTheme
                                                .backgroundColor!;
                                            if (value == 'deleted') {
                                              msg = 'Task has been deleted!';
                                            } else if (value == 'completed') {
                                              msg =
                                                  'Task completed. Well done!';
                                              color = Theme.of(context)
                                                  .primaryColor;
                                            }
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: Text(msg),
                                                  backgroundColor: color,
                                                ),
                                              );
                                          }
                                        }),
                                child: TaskListItem(
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
                            horizontal: responsiveSizePx(small: 20, medium: 30),
                            vertical: 4,
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
