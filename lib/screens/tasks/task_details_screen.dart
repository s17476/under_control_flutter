import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/task.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({Key? key}) : super(key: key);

  static const routeName = '/task-details';

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task task;

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
  void didChangeDependencies() {
    task = ModalRoute.of(context)!.settings.arguments as Task;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                child: Icon(
                  eventIcons[task.type.index],
                  size: SizeConfig.blockSizeHorizontal * 20,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                width: SizeConfig.blockSizeHorizontal * 25,
                height: SizeConfig.blockSizeHorizontal * 25,
                decoration: BoxDecoration(
                  color: darkTheme[task.type.index],
                  // color: Colors.black,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(30.0),
                    // bottomLeft: Radius.circular(30.0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      // color: Colors.grey,
                      offset: Offset(3.0, 3.0),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
              ),
              Container(
                child: Text(task.title),
              ),
            ],
          )
        ],
      ),
    );
  }
}
