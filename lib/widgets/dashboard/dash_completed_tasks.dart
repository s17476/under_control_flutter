import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/task_provider.dart';

class DashCompletedTasks extends StatefulWidget {
  const DashCompletedTasks({Key? key}) : super(key: key);

  @override
  _DashCompletedTasksState createState() => _DashCompletedTasksState();
}

class _DashCompletedTasksState extends State<DashCompletedTasks>
    with ResponsiveSize {
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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    TextStyle cardTextStyle = Theme.of(context).textTheme.headline6!.copyWith(
          fontSize: responsiveSizePx(small: 16, medium: 22),
          color: Theme.of(context).appBarTheme.foregroundColor,
        );

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Theme.of(context).splashColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            margin: const EdgeInsets.only(
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    'Recently completed tasks',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontSize: responsiveSizePx(small: 18, medium: 30),
                        color: Theme.of(context).primaryColor),
                  ),
                  const Divider(),
                  FutureBuilder(
                    future: Provider.of<TaskProvider>(context)
                        .fetchAndGetCompletedTasks(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        final tasks = snapshot.data as List<Task>;
                        if (tasks.isEmpty) {
                          return const Text(
                            'You don\'t have any completed tasks.',
                          );
                        }
                        final List<Widget> widgets = [];
                        for (var task in tasks) {
                          widgets.add(Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: responsiveSizePct(small: 50),
                                  child: Text(
                                    task.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: cardTextStyle,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      DateFormat('dd/MMM').format(task.date),
                                      overflow: TextOverflow.ellipsis,
                                      style: cardTextStyle,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      eventIcons[task.type.index],
                                      color: darkTheme[task.type.index],
                                      size: responsiveSizePx(
                                          small: 30, medium: 55),
                                    ),
                                    Icon(
                                      Icons.done,
                                      size: responsiveSizePx(
                                          small: 30, medium: 55),
                                      color: Colors.green,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ));
                        }
                        return Column(
                          children: [...widgets],
                        );
                      }
                      return CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
