import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({Key? key}) : super(key: key);

  static const routeName = '/task-details';

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task task;

  String executorName = '';
  String creatorName = '';

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

  final List<String> taskTypes = const [
    'Maintenance',
    'Event',
    'Inspection',
    'Reparation',
  ];

  final List<String> executorType = [
    'Shared',
    'Company',
    'User',
    'All',
  ];

  Future<void> _getExecutorName() async {
    await Provider.of<UserProvider>(context)
        .getUserById(context, task.executorId!)
        .then((value) {
      setState(() {
        executorName = value!.userName;
      });
    });
  }

  Future<void> _getCreatorName() async {
    await Provider.of<UserProvider>(context)
        .getUserById(context, task.userId)
        .then((value) {
      setState(() {
        creatorName = value!.userName;
      });
    });
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
  void didChangeDependencies() {
    task = ModalRoute.of(context)!.settings.arguments as Task;
    if (task.executorId != null && executorName == '') {
      _getExecutorName();
    }
    if (creatorName == '') {
      _getCreatorName();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ItemProvider>(context, listen: false).items;
    final textStyle = Theme.of(context).textTheme.headline6!.copyWith(
        // fontSize: SizeConfig.blockSizeHorizontal * 4.5,
        );
    final expiredTextStyle = textStyle.copyWith(
      color: Theme.of(context).errorColor,
    );
    final labelTextStyle = Theme.of(context).textTheme.headline6!.copyWith(
          fontSize: SizeConfig.blockSizeHorizontal * 3,
          color: Theme.of(context).hintColor,
        );

    Item? asset;

    print(task.itemId);
    final index = items.indexWhere((element) => element.itemId == task.itemId);
    if (index >= 0) {
      asset = items[index];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          // delete appbar button
          IconButton(
            onPressed: () {
              _showDeleteDialog(context, task).then((value) {
                if (value == true) {
                  Provider.of<TaskProvider>(context, listen: false)
                      .deleteTask(context, task);
                  Navigator.of(context).pop(value);
                }
              });
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).errorColor,
            ),
          ),
          // done appbar button
          IconButton(
            onPressed: () {}, //TODO
            icon: Icon(
              Icons.done,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 3,
          ),
        ],
      ),
      body: Container(
        width: SizeConfig.blockSizeHorizontal * 100,
        height: SizeConfig.blockSizeVertical * 100,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // type icon with color background
                  Row(
                    children: [
                      Hero(
                        tag: task.taskId!,
                        child: Container(
                          child: Icon(
                            eventIcons[task.type.index],
                            size: SizeConfig.blockSizeHorizontal * 20,
                            color:
                                Theme.of(context).appBarTheme.foregroundColor,
                          ),
                          width: SizeConfig.blockSizeHorizontal * 25,
                          height: SizeConfig.blockSizeHorizontal * 25,
                          decoration: BoxDecoration(
                            color: darkTheme[task.type.index],
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(30.0),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(3.0, 3.0),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task type',
                              style: labelTextStyle,
                            ),
                            Text(
                              taskTypes[task.type.index],
                              style: textStyle,
                            ),
                            Text(
                              'Execution date',
                              style: labelTextStyle,
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy').format(task.date),
                              style: textStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //  status icon
                  Padding(
                    padding: EdgeInsets.only(
                      right: SizeConfig.blockSizeHorizontal * 8,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          statusIcons[task.status.index],
                          color: Colors.white,
                          size: SizeConfig.blockSizeHorizontal * 10,
                        ),
                        Text(statusText[task.status.index]),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title
                    Text(
                      'Task title',
                      style: labelTextStyle,
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Text(
                      task.title,
                      style: textStyle,
                    ),
                    // asset
                    if (asset != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Asset',
                            style: labelTextStyle,
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            '${asset.producer} ${asset.model} ${asset.internalId}',
                            style: textStyle,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Location',
                            style: labelTextStyle,
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            task.location!,
                            style: textStyle,
                          ),
                        ],
                      ),
                    // description
                    if (task.description != '')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Task description',
                            style: labelTextStyle,
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            task.description,
                            style: textStyle,
                          ),
                        ],
                      ),

                    // comments
                    if (task.comments != '')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Comments',
                            style: labelTextStyle,
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            task.comments,
                            style: textStyle,
                          ),
                        ],
                      ),
                    // task executor
                    if (task.executor != TaskExecutor.user)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Task executor',
                            style: labelTextStyle,
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            executorType[task.executor.index],
                            style: textStyle,
                          ),
                        ],
                      ),
                    if (task.executor == TaskExecutor.user)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Task executor',
                            style: labelTextStyle,
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            executorName,
                            style: textStyle,
                          ),
                        ],
                      ),
                    // interval

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Cyclic task',
                          style: labelTextStyle,
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        Text(
                          task.taskInterval!,
                          style: textStyle,
                        ),
                      ],
                    ),
                    // next date
                    if (task.taskInterval != 'No')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Next date',
                            style: labelTextStyle,
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(task.nextDate!),
                            style: textStyle,
                          ),
                        ],
                      ),
                    // created by

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Task created by',
                          style: labelTextStyle,
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        Text(
                          creatorName,
                          style: textStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
