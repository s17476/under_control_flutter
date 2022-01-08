import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/date_calc.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/screens/inspection/add_inspection_screen.dart';
import 'package:under_control_flutter/screens/tasks/task_details_screen.dart';

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

class _TasksListState extends State<TasksList> {
  Map<String, List<Task>> _tasks = {};
  var executor = TaskExecutor.all;

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

  @override
  Widget build(BuildContext context) {
    TaskProvider taskProvider = Provider.of<TaskProvider>(context);
    executor = taskProvider.executor;
    _tasks = taskProvider.getAllTasks;

    Map<String, List<Task>> filteredTasks = {};

    final keys = _tasks.keys.toList();

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
                  if (taskProvider.isActive) {
                    keys.sort((a, b) =>
                        dateFormat.parse(a).compareTo(dateFormat.parse(b)));
                  } else {
                    keys.sort((a, b) =>
                        dateFormat.parse(b).compareTo(dateFormat.parse(a)));
                  }

                  if (filteredTasks[keys[index]] != null) {
                    for (var task in filteredTasks[keys[index]]!) {
                      // if task date is after today date change status icon color
                      // final dateFormat = DateFormat('dd/MM/yyyy');
                      // final taskDate =
                      //     dateFormat.parse(dateFormat.format(task.date));
                      // final nowDate = DateTime(
                      //   DateTime.now().year,
                      //   DateTime.now().month,
                      //   DateTime.now().day - 1,
                      // );
                      // final statusColor = taskDate.isAfter(nowDate)
                      //     ? Theme.of(context).hintColor
                      //     : Theme.of(context).errorColor;

                      final item =
                          Provider.of<ItemProvider>(context, listen: false)
                              .items
                              .firstWhere(
                                  (element) => element.itemId == task.itemId);

                      listItems.add(!Provider.of<TaskProvider>(context).isActive
                          ? GestureDetector(
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
                                              size: SizeConfig
                                                      .blockSizeHorizontal *
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
                                          color: Colors.green,
                                          size: SizeConfig.blockSizeHorizontal *
                                              9,
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          // shows active tasks
                          : Dismissible(
                              key: ValueKey(DateTime.now().toIso8601String()),
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
                                  // set task date to today
                                  task.date = DateTime.now();
                                  if (task.taskInterval != null &&
                                      task.taskInterval != 'No') {
                                    task.nextDate = DateCalc.getNextDate(
                                        task.date, task.taskInterval!);
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
                                              color:
                                                  darkTheme[task.type.index]!,
                                              width: SizeConfig
                                                      .blockSizeHorizontal *
                                                  16,
                                              height: SizeConfig
                                                      .blockSizeHorizontal *
                                                  18,
                                              child: Icon(
                                                eventIcons[task.type.index],
                                                color: Colors.white,
                                                size: SizeConfig
                                                        .blockSizeHorizontal *
                                                    12,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: SizeConfig
                                                      .blockSizeHorizontal *
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.location_on,
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor,
                                                          ),
                                                          Text(
                                                            task.location!,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .hintColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.handyman,
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor,
                                                          ),
                                                          Text(
                                                            '${item.producer} ${item.model}',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .hintColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                          // Icon(
                                          //   statusIcons[task.status.index],
                                          //   color: statusColor,
                                          //   size:
                                          //       SizeConfig.blockSizeHorizontal *
                                          //           9,
                                          // ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color:
                                                Theme.of(context).primaryColor,
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
