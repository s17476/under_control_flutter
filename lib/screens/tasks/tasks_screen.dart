import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/task_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
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

    return filteredTasks.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
            itemCount: keys.toList().length,
            itemBuilder: (ctx, index) {
              List<Widget> listItems = [];
              for (var task in filteredTasks[keys.toList()[index]]!) {
                listItems.add(Dismissible(
                  key: Key(task.taskId!),
                  confirmDismiss: (direction) async {
                    bool response = false;
                    // swipe right - rapid complete
                    // rapid complete is a quick and easy way to complete standard tasks
                    if (direction == DismissDirection.startToEnd) {
                      await Provider.of<TaskProvider>(context, listen: false)
                          .rapidComplete(context, task)
                          .then((value) => response = value);

                      // undo rapid complete
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor:
                              Theme.of(context).appBarTheme.backgroundColor,
                          content: Text('${task.title} - Rapid Complete done!'),
                          duration: const Duration(seconds: 4),
                          action: SnackBarAction(
                            textColor: Colors.amber,
                            label: 'UNDO',
                            onPressed: () {
                              Provider.of<TaskProvider>(context, listen: false)
                                  .undoRapidComplete();
                            },
                          ),
                        ),
                      );

                      // swipe left - delete
                    } else if (direction == DismissDirection.endToStart) {
                      await _showDeleteDialog(context, task).then((value) {
                        if (value) {
                          Provider.of<TaskProvider>(context, listen: false)
                              .deleteTask(context, task);
                          response = value;
                        } else {
                          response = false;
                        }
                      });
                      String msg;
                      if (response) {
                        msg = 'Task deleted!';
                      } else {
                        msg = 'Task not deleted.';
                      }
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: Theme.of(context).errorColor,
                        ),
                      );
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
                    child: Icon(
                      Icons.done,
                      color: Colors.white,
                      size: SizeConfig.blockSizeHorizontal * 20,
                    ),
                  ),
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
                            Container(
                              color: darkTheme[task.type.index]!,
                              width: SizeConfig.blockSizeHorizontal * 15,
                              height: SizeConfig.blockSizeHorizontal * 20,
                              child: Icon(
                                eventIcons[task.type.index],
                                color: Colors.white,
                                size: SizeConfig.blockSizeHorizontal * 9,
                              ),
                            ),
                            SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 4,
                                      // fontWeight: FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (task.description != '')
                                    SizedBox(
                                      height: SizeConfig.blockSizeHorizontal,
                                    ),
                                  if (task.description != '')
                                    Text(
                                      task.description,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              statusIcons[task.status.index],
                              color: Colors.white,
                              size: SizeConfig.blockSizeHorizontal * 9,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          );
  }
}
