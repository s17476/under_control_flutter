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
    TextStyle cardTextStyle = Theme.of(context).textTheme.headline6!.copyWith(
        fontSize: SizeConfig.blockSizeHorizontal * 4,
        color: Theme.of(context).appBarTheme.foregroundColor);

    return Card(
      color: Theme.of(context).splashColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      margin: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
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
              future:
                  Provider.of<TaskProvider>(context).fetchAndGetUpcomingTasks(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  final tasks = snapshot.data as List<Task>;
                  if (tasks.isEmpty) {
                    return const Text(
                      'You don\'t have any active tasks. Add some!',
                    );
                  }
                  final List<Widget> widgets = [];
                  for (var task in tasks) {
                    // if task date is after today date change date text color
                    final dateFormat = DateFormat('dd/MM/yyyy');
                    final taskDate =
                        dateFormat.parse(dateFormat.format(task.date));
                    final nowDate = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day - 1,
                    );
                    final statusColor = taskDate.isAfter(nowDate)
                        ? Theme.of(context).appBarTheme.foregroundColor
                        : Colors.red;
                    widgets.add(Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal * 60,
                            child: Text(
                              task.title,
                              overflow: TextOverflow.ellipsis,
                              style: cardTextStyle.copyWith(color: statusColor),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                DateFormat('dd/MMM').format(task.date),
                                overflow: TextOverflow.ellipsis,
                                style:
                                    cardTextStyle.copyWith(color: statusColor),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal,
                              ),
                              Icon(
                                eventIcons[task.type.index],
                                color: darkTheme[task.type.index],
                                size: SizeConfig.blockSizeHorizontal * 7,
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
    );
  }
}
