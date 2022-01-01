import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/task/task_complete.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({Key? key}) : super(key: key);

  static const routeName = '/task-details';

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late Task task;

  String _executorName = '';
  String _creatorName = '';
  bool _isInEditMode = false;
  Task? oldTask;
  Task? transferObjectTask;

  final ScrollController _scrollController = ScrollController();

  final List<Color?> darkTheme = const [
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.red,
  ];

  final List<IconData> _eventIcons = const [
    Icons.health_and_safety_outlined,
    Icons.event,
    Icons.search_outlined,
    Icons.handyman_outlined,
  ];

  final List<IconData> _statusIcons = const [
    Icons.pending_actions_outlined,
    Icons.pause_outlined,
    Icons.done,
  ];

  final List<String> _statusText = const [
    'Pending',
    'In progress',
    'Completed',
  ];

  final List<String> _taskTypes = const [
    'Maintenance',
    'Event',
    'Inspection',
    'Reparation',
  ];

  final List<String> _executorType = [
    'Shared',
    'Company',
    'User',
    'All',
  ];

  AnimationController? _animationController;
  Animation<Offset>? _userSlideAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;
  Animation<double>? _opacityAnimationBackward;

  @override
  void initState() {
    super.initState();

    //initialize animations controllers
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _userSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
      ),
    );

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    ));

    _opacityAnimationBackward =
        Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    ));
  }

  //dispose animation controller
  @override
  void dispose() {
    super.dispose();
    _animationController!.dispose();
  }

  //get task executor name
  Future<void> _getExecutorName() async {
    await Provider.of<UserProvider>(context)
        .getUserById(context, task.executorId!)
        .then((value) {
      setState(() {
        _executorName = value!.userName;
      });
    });
  }

  //get task creator name
  Future<void> _getCreatorName() async {
    await Provider.of<UserProvider>(context)
        .getUserById(context, task.userId)
        .then((value) {
      setState(() {
        _creatorName = value!.userName;
      });
    });
  }

  // show delete confirmation dialog
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

  // show complete confirmation dialog
  Future<bool> _showCompleteDialog(
    BuildContext context,
    Task task,
  ) async {
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete task?'),
          content: SingleChildScrollView(
            child: Text(
              'Are you sure You want to complete \n${task.title}?',
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
                  color: Theme.of(context).errorColor,
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

  // toggle view / edit mode
  void _toggleEditMode() => setState(() {
        _isInEditMode = !_isInEditMode;
      });

  // save changes if completed == false
  // complete task if completed == true
  void _completeTask(bool completed) {
    if (_formKey.currentState != null) {
      // validate user input
      final isValid = _formKey.currentState!.validate();
      if (isValid) {
        _formKey.currentState!.save();
        if (transferObjectTask!.duration != null) {
          task.duration = transferObjectTask!.duration;
        }

        if (transferObjectTask!.taskInterval != 'No') {
          List<String> duration = transferObjectTask!.taskInterval!.split(' ');
          task.taskInterval = transferObjectTask!.taskInterval;
          if (duration[1] == 'week' || duration[1] == 'weeks') {
            task.nextDate = DateTime(
              transferObjectTask!.date.year,
              transferObjectTask!.date.month,
              transferObjectTask!.date.day + (int.parse(duration[0]) * 7),
            );
          } else if (duration[1] == 'month' || duration[1] == 'months') {
            task.nextDate = DateTime(
              transferObjectTask!.date.year,
              transferObjectTask!.date.month + int.parse(duration[0]),
              transferObjectTask!.date.day,
            );
          } else if (duration[1] == 'year' || duration[1] == 'years') {
            task.nextDate = DateTime(
              transferObjectTask!.date.year + int.parse(duration[0]),
              transferObjectTask!.date.month,
              transferObjectTask!.date.day,
            );
          }
        } else {
          task.nextDate = null;
          task.taskInterval = 'No';
        }
        // executor ID
        task.executorId =
            Provider.of<UserProvider>(context, listen: false).user!.userId;

        // date
        task.date = transferObjectTask!.date;

        // cost
        task.cost = transferObjectTask!.cost;

        // comments
        task.comments = transferObjectTask!.comments;

        // task is started, but not finished
        task.status = TaskStatus.started;
        Provider.of<TaskProvider>(context, listen: false).updateTask(task);
        // task finished and moved to archive
        if (completed) {
          task.status = TaskStatus.completed;
          Provider.of<TaskProvider>(context, listen: false)
              .completeTask(task, oldTask!);
          var tmp = task.copyWith(
            comments: '',
            cost: 0,
            duration: 0,
            status: TaskStatus.planned,
          );

          Provider.of<TaskProvider>(context, listen: false).addNextTask(tmp);
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    task = ModalRoute.of(context)!.settings.arguments as Task;
    oldTask = task.copyWith();

    if (task.executorId != null && _executorName == '') {
      _getExecutorName();
    }
    if (_creatorName == '') {
      _getCreatorName();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // used to store task state before saving
    transferObjectTask ??= task.copyWith(date: DateTime.now());

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

    // print(task.itemId);
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
                      .deleteTask(task);
                  Navigator.of(context).pop('deleted');
                }
              });
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).errorColor,
            ),
          ),
          // done appbar button
          if (_isInEditMode)
            IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                _toggleEditMode();
                if (_isInEditMode) {
                  _animationController!.forward();
                } else {
                  _animationController!.reverse();
                }

                _completeTask(false);
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: const Text('Data saved'),
                      backgroundColor:
                          Theme.of(context).appBarTheme.backgroundColor,
                    ),
                  );
              },
              icon: Icon(
                Icons.save,
                color: Theme.of(context).primaryColor,
              ),
            ),
          // SizedBox(
          //   width: SizeConfig.blockSizeHorizontal * 3,
          // ),
          if (_isInEditMode)
            IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                _showCompleteDialog(context, task).then((value) {
                  if (value == true) {
                    _completeTask(true);
                    Navigator.of(context).pop('completed');
                  }
                });
                Provider.of<TaskProvider>(context, listen: false)
                    .fetchAndSetTasks();
              },
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
        height: SizeConfig.blockSizeVertical * 110,
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
          controller: _scrollController,
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
                            _eventIcons[task.type.index],
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
                              _taskTypes[task.type.index],
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
                  //  status
                  Padding(
                    padding: EdgeInsets.only(
                      right: SizeConfig.blockSizeHorizontal * 8,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _statusIcons[task.status.index],
                          color: Colors.white,
                          size: SizeConfig.blockSizeHorizontal * 10,
                        ),
                        Text(
                          _statusText[task.status.index],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            _executorType[task.executor.index],
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
                            _executorName,
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
                    if (task.taskInterval != 'No' && task.nextDate != null)
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
                          _creatorName,
                          style: textStyle,
                        ),
                      ],
                    ),
                    // cost
                    if (task.cost != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Cost',
                            style: labelTextStyle,
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            '${task.cost} EUR',
                            style: textStyle,
                          ),
                        ],
                      ),
                    // duration
                    if (task.duration != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Duration',
                            style: labelTextStyle,
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            '${task.duration! ~/ 60} hrs, ${task.duration! % 60} min',
                            style: textStyle,
                          ),
                        ],
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: _isInEditMode ? null : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              FadeTransition(
                                opacity: _opacityAnimation!,
                                child: SlideTransition(
                                  position: _userSlideAnimation!,
                                  child: TaskComplete(
                                    task: transferObjectTask!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // action buttons bar
              AnimatedContainer(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                duration: const Duration(milliseconds: 500),
                color: _isInEditMode
                    ? Theme.of(context).appBarTheme.backgroundColor
                    : null,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // complete / cancel button
                    TextButton.icon(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _toggleEditMode();
                        if (_isInEditMode) {
                          _animationController!.forward();
                          _scrollController.animateTo(
                            500,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        } else {
                          _animationController!.reverse();
                          // _scrollController.animateTo(
                          //   -200,
                          //   duration: Duration(milliseconds: 500),
                          //   curve: Curves.easeIn,
                          // );
                        }
                      },
                      icon: _isInEditMode
                          ? Icon(
                              Icons.cancel,
                              size: SizeConfig.blockSizeHorizontal * 6,
                              color: Theme.of(context).errorColor,
                            )
                          : Icon(
                              Icons.keyboard_arrow_down_outlined,
                              size: SizeConfig.blockSizeHorizontal * 8,
                            ),
                      label: Text(
                        _isInEditMode ? 'Cancel' : 'Complete the task',
                        style: textStyle.copyWith(
                          color: _isInEditMode
                              ? Theme.of(context).appBarTheme.foregroundColor
                              : Theme.of(context).appBarTheme.backgroundColor,
                          fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                        ),
                      ),
                    ),
                    //save task button
                    if (_isInEditMode)
                      TextButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _toggleEditMode();
                          if (_isInEditMode) {
                            _animationController!.forward();
                          } else {
                            _animationController!.reverse();
                          }

                          _completeTask(false);

                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: const Text('Data saved'),
                                backgroundColor: Theme.of(context)
                                    .appBarTheme
                                    .backgroundColor,
                              ),
                            );
                        },
                        icon: Icon(
                          Icons.save,
                          size: SizeConfig.blockSizeHorizontal * 6,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: Text(
                          'Save',
                          style: textStyle.copyWith(
                            color: _isInEditMode
                                ? Theme.of(context).appBarTheme.foregroundColor
                                : Theme.of(context).appBarTheme.backgroundColor,
                            fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                          ),
                        ),
                      ),
                    //complete task button
                    if (_isInEditMode)
                      TextButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _showCompleteDialog(context, task).then((value) {
                            if (value == true) {
                              _completeTask(true);
                              Navigator.of(context).pop('completed');
                            }
                          });
                          // Provider.of<TaskProvider>(context, listen: false)
                          //     .fetchAndSetTasks();
                        },
                        icon: Icon(
                          Icons.done,
                          size: SizeConfig.blockSizeHorizontal * 6,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: Text(
                          'Complete',
                          style: textStyle.copyWith(
                            color: _isInEditMode
                                ? Theme.of(context).appBarTheme.foregroundColor
                                : Theme.of(context).appBarTheme.backgroundColor,
                            fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                          ),
                        ),
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
