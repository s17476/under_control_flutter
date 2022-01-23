import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/date_calc.dart';
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

class CalendarEventsList extends StatelessWidget {
  const CalendarEventsList({
    Key? key,
    required this.selectedEvents,
  }) : super(key: key);

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

  // events to show
  final ValueNotifier<List<Task>> selectedEvents;

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
    return Expanded(
      child: ValueListenableBuilder<List<Task>>(
        valueListenable: selectedEvents,
        builder: (context, value, _) {
          // return list of events for selected day
          return value.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
                  itemCount: value.length,
                  itemBuilder: (ctx, index) {
                    Item? item;
                    try {
                      item = Provider.of<ItemProvider>(context, listen: false)
                          .items
                          .firstWhere((element) =>
                              element.itemId == value[index].itemId);
                    } catch (e) {
                      item = null;
                    }
                    return Provider.of<TaskProvider>(context).isActive &&
                            value[index].type != TaskType.inspection &&
                            value[index].executor != TaskExecutor.shared
                        ? Dismissible(
                            key: Key(value[index].taskId!),
                            confirmDismiss: (direction) async {
                              bool response = false;
                              bool exit = false;
                              // swipe right - rapid complete
                              // rapid complete is a quick and easy way to complete standard tasks
                              if (direction == DismissDirection.startToEnd) {
                                // if task is inspection
                                if (value[index].type == TaskType.inspection) {
                                  await Navigator.of(context).pushNamed(
                                      AddInspectionScreen.routeName,
                                      arguments: [
                                        Provider.of<ItemProvider>(context,
                                                listen: false)
                                            .items
                                            .firstWhere((element) =>
                                                element.itemId ==
                                                value[index].itemId),
                                        value[index]
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
                                // value[index].date = DateTime.now();
                                // if (value[index].taskInterval != null &&
                                //     value[index].taskInterval != 'No') {
                                //   value[index].nextDate = DateCalc.getNextDate(
                                //       value[index].date,
                                //       value[index].taskInterval!);
                                // }

                                // Task tmpTask = value[index];
                                await Provider.of<TaskProvider>(context,
                                        listen: false)
                                    .rapidComplete(context, value[index])
                                    .then((val) {
                                  response = val;
                                });

                                // swipe left - delete
                              } else if (direction ==
                                  DismissDirection.endToStart) {
                                await _showDeleteDialog(context, value[index])
                                    .then((val) {
                                  if (val) {
                                    Provider.of<TaskProvider>(context,
                                            listen: false)
                                        .deleteTask(value[index]);
                                    response = val;
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
                                    size: SizeConfig.blockSizeHorizontal * 15,
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
                                      arguments: value[index])
                                  .then((value) {
                                if (value != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Item deleted'),
                                    ),
                                  );
                                }
                              }),
                              child:
                                  TaskListItem(task: value[index], item: item),
                            ),
                          )
                        : GestureDetector(
                            onTap: value[index].executor ==
                                        TaskExecutor.shared &&
                                    value[index].executorId ==
                                        Provider.of<UserProvider>(context,
                                                listen: false)
                                            .user!
                                            .companyId
                                ? () => Navigator.of(context).pushNamed(
                                    SharedTaskDetailsScreen.routeName,
                                    arguments: value[index])
                                : () => Navigator.of(context)
                                        .pushNamed(TaskDetailsScreen.routeName,
                                            arguments: value[index])
                                        .then((value) {
                                      if (value != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Item deleted'),
                                          ),
                                        );
                                      }
                                    }),
                            child: TaskListItem(task: value[index], item: item),
                          );
                  },
                )
              : Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 5),
                  child: const Text("No events for the selected date"),
                );
        },
      ),
    );
  }
}
