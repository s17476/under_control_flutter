import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/screens/inspection/add_inspection_screen.dart';

import 'task_details_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _isLoading = false;

  final List<Color?> darkTheme = const [
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.red,
  ];

  final List<IconData> eventIcons = const [
    Icons.health_and_safety_outlined,
    Icons.event,
    Icons.search_outlined,
    Icons.handyman_outlined,
  ];

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

  Map<String, List<Task>> _tasks = {};
  var executor = TaskExecutor.all;

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
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeVertical * 2.5,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Theme.of(context).errorColor,
                  fontSize: SizeConfig.blockSizeVertical * 2.5,
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }

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
    TaskProvider taskProvider = Provider.of<TaskProvider>(context);
    executor = taskProvider.executor;
    _tasks = taskProvider.getAllTasks;

    Map<String, List<Task>> filteredTasks = {};

    final keys = _tasks.keys.toList();

    if (executor == TaskExecutor.all) {
      filteredTasks = _tasks;
    } else {
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
          : filteredTasks.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
                  itemCount: keys.length,
                  itemBuilder: (ctx, index) {
                    List<Widget> listItems = [];
                    if (filteredTasks[keys[index]] != null) {
                      for (var task in filteredTasks[keys[index]]!) {
                        // if task date is after today date change status icon color
                        final dateFormat = DateFormat('dd/MM/yyyy');
                        final taskDate =
                            dateFormat.parse(dateFormat.format(task.date));
                        final nowDate = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day - 1,
                        );
                        final statusColor = taskDate.isAfter(nowDate)
                            ? Theme.of(context).hintColor
                            : Theme.of(context).errorColor;

                        listItems.add(Dismissible(
                          key: Key(task.taskId!),
                          confirmDismiss: (direction) async {
                            bool exit = false;
                            bool response = false;
                            // swipe right - rapid complete
                            // rapid complete is a quick and easy way to complete standard tasks
                            if (direction == DismissDirection.startToEnd) {
                              // if task is inspection
                              if (task.type == TaskType.inspection) {
                                await Navigator.of(context).pushNamed(
                                    AddInspectionScreen.routeName,
                                    arguments: [
                                      Provider.of<ItemProvider>(context,
                                              listen: false)
                                          .items
                                          .firstWhere((element) =>
                                              element.itemId == task.itemId),
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
// TODO
                              // print('task interval  ${task.taskInterval}');
                              if (task.taskInterval != null &&
                                  task.taskInterval != 'No') {
                                List<String> duration =
                                    task.taskInterval!.split(' ');
                                final today = DateTime.now();
                                if (duration[1] == 'week' ||
                                    duration[1] == 'weeks') {
                                  task.nextDate = DateTime(
                                    today.year,
                                    today.month,
                                    today.day + (int.parse(duration[0]) * 7),
                                  );
                                } else if (duration[1] == 'month' ||
                                    duration[1] == 'months') {
                                  task.nextDate = DateTime(
                                    today.year,
                                    today.month + int.parse(duration[0]),
                                    today.day,
                                  );
                                } else if (duration[1] == 'year' ||
                                    duration[1] == 'years') {
                                  task.nextDate = DateTime(
                                    today.year + int.parse(duration[0]),
                                    today.month,
                                    today.day,
                                  );
                                }
                              }

                              await Provider.of<TaskProvider>(context,
                                      listen: false)
                                  .rapidComplete(context, task)
                                  .then((value) => response = value);

                              var nextTask = await Provider.of<TaskProvider>(
                                      context,
                                      listen: false)
                                  .addNextTask(task);

                              // undo rapid complete

                              ScaffoldMessenger.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    backgroundColor: Theme.of(context)
                                        .appBarTheme
                                        .backgroundColor,
                                    content: Text(
                                        '${task.title} - Rapid Complete done!'),
                                    duration: const Duration(seconds: 4),
                                    action: SnackBarAction(
                                      textColor: Colors.amber,
                                      label: 'UNDO',
                                      onPressed: () async {
                                        await Provider.of<TaskProvider>(context,
                                                listen: false)
                                            .undoRapidComplete();
                                        if (nextTask != null) {
                                          await Provider.of<TaskProvider>(
                                                  context,
                                                  listen: false)
                                              .deleteTask(nextTask);
                                        }
                                      },
                                    ),
                                  ),
                                );

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
                                      content: const Text('Task deleted!'),
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
                              size: SizeConfig.blockSizeHorizontal * 15,
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
                                  size: SizeConfig.blockSizeHorizontal * 20,
                                ),
                                Text(
                                  'Rapid Complete',
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 5,
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3.0,
                                horizontal: 8.0,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  // height: 50,
                                  color: Theme.of(context).splashColor,
                                  child: Row(
                                    children: <Widget>[
                                      Hero(
                                        tag: task.taskId!,
                                        child: Container(
                                          color: darkTheme[task.type.index]!,
                                          width:
                                              SizeConfig.blockSizeHorizontal *
                                                  16,
                                          height:
                                              SizeConfig.blockSizeHorizontal *
                                                  18,
                                          child: Icon(
                                            eventIcons[task.type.index],
                                            color: Colors.white,
                                            size:
                                                SizeConfig.blockSizeHorizontal *
                                                    12,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              SizeConfig.blockSizeHorizontal *
                                                  3),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              task.title,
                                              style: TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal *
                                                    4,
                                                // fontWeight: FontWeight.w400,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (task.location != null &&
                                                task.location != '')
                                              SizedBox(
                                                height: SizeConfig
                                                    .blockSizeHorizontal,
                                              ),
                                            if (task.location != null &&
                                                task.location != '')
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                                  Text(
                                                    task.location!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        statusIcons[task.status.index],
                                        color: statusColor,
                                        size:
                                            SizeConfig.blockSizeHorizontal * 9,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ));
                      }
                    }
                    print(keys);
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
                  child: Text('You don\'t have any active tasks. Add some!'),
                ),
    );
  }
}
