import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/screens/tasks/task_details_screen.dart';

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
                    return Dismissible(
                      key: Key(value[index].taskId!),
                      confirmDismiss: (direction) async {
                        bool response = false;
                        // swipe right - rapid complete
                        // rapid complete is a quick and easy way to complete standard tasks
                        if (direction == DismissDirection.startToEnd) {
                          var title = value[index].title;
                          await Provider.of<TaskProvider>(context,
                                  listen: false)
                              .rapidComplete(context, value[index])
                              .then((value) => response = value);

                          // undo rapid complete
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor:
                                  Theme.of(context).appBarTheme.backgroundColor,
                              content: Text('$title - Rapid Complete done!'),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                textColor: Colors.amber,
                                label: 'UNDO',
                                onPressed: () {
                                  Provider.of<TaskProvider>(context,
                                          listen: false)
                                      .undoRapidComplete();
                                },
                              ),
                            ),
                          );

                          // swipe left - delete
                        } else if (direction == DismissDirection.endToStart) {
                          await _showDeleteDialog(context, value[index])
                              .then((val) {
                            if (val) {
                              Provider.of<TaskProvider>(context, listen: false)
                                  .deleteTask(context, value[index]);
                              response = val;
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
                          size: SizeConfig.blockSizeHorizontal * 15,
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
                                    tag: value[index].taskId!,
                                    child: Container(
                                      color:
                                          darkTheme[value[index].type.index]!,
                                      width:
                                          SizeConfig.blockSizeHorizontal * 15,
                                      height:
                                          SizeConfig.blockSizeHorizontal * 15,
                                      child: Icon(
                                        eventIcons[value[index].type.index],
                                        color: Colors.white,
                                        size:
                                            SizeConfig.blockSizeHorizontal * 9,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 3,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          value[index].title,
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal *
                                                    4,
                                            // fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (value[index].description != '')
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeHorizontal,
                                          ),
                                        if (value[index].description != '')
                                          Text(
                                            value[index].description,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  Theme.of(context).hintColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    statusIcons[value[index].status.index],
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
                      ),
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
