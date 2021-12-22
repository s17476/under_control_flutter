import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/task_provider.dart';

class DashTaskStatusCard extends StatefulWidget {
  const DashTaskStatusCard({Key? key}) : super(key: key);

  @override
  _DashTaskStatusCardState createState() => _DashTaskStatusCardState();
}

class _DashTaskStatusCardState extends State<DashTaskStatusCard> {
  final List<IconData> eventIcons = const [
    Icons.event,
    Icons.search_outlined,
    Icons.handyman_outlined,
    Icons.health_and_safety_outlined,
  ];

  final List<Color?> darkTheme = const [
    Colors.blue,
    Colors.indigo,
    Colors.red,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    TextStyle cardTextStyle = Theme.of(context)
        .textTheme
        .headline6!
        .copyWith(fontSize: SizeConfig.blockSizeHorizontal * 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          margin: EdgeInsets.only(
            bottom: SizeConfig.blockSizeHorizontal * 4,
            left: SizeConfig.blockSizeHorizontal * 4,
            right: SizeConfig.blockSizeHorizontal * 4,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
            child: Column(
              children: [
                Text(
                  'Upcoming tasks',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      fontSize: SizeConfig.blockSizeHorizontal * 4,
                      color: Theme.of(context).primaryColor),
                ),
                const Divider(),
                FutureBuilder(
                  future: Provider.of<TaskProvider>(context)
                      .fetchAndGetUpcomingTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      final tasks = snapshot.data as List<Task>;
                      if (tasks.isEmpty) {
                        return Text(
                            'You don\'t have any active tasks. Add some!');
                      }
                      final List<Widget> widgets = [];
                      for (var task in tasks) {
                        widgets.add(Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                task.title,
                                overflow: TextOverflow.ellipsis,
                                style: cardTextStyle,
                              ),
                              Row(
                                children: [
                                  Text(
                                    DateFormat('dd/MMM').format(task.date),
                                    overflow: TextOverflow.ellipsis,
                                    style: cardTextStyle,
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal,
                                  ),
                                  Icon(eventIcons[task.type.index],
                                      color: darkTheme[task.type.index]),
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
                // Container(
                //   padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 3),
                //   alignment: Alignment.centerRight,
                //   child: const Text('data'),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
