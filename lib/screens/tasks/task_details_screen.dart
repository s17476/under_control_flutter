import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/date_calc.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/inspection.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/company_provider.dart';
import 'package:under_control_flutter/providers/inspection_provider.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/inspection/inspection_form.dart';
import 'package:under_control_flutter/widgets/task/task_complete.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({Key? key}) : super(key: key);

  static const routeName = '/task-details';

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen>
    with SingleTickerProviderStateMixin, ResponsiveSize {
  final _formKey = GlobalKey<FormState>();

  late Task task;
  Item? item;
  Inspection? inspection;

  String _executorName = '';
  String _creatorName = '';
  bool _isInEditMode = false;
  bool _isTaskActive = true;
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
    await Provider.of<UserProvider>(context, listen: false)
        .getUserById(context, task.executorId!)
        .then((value) {
      setState(() {
        _executorName = value!.userName;
      });
    });
  }

  //get task executor name
  Future<void> _getExecutorCompanyName() async {
    await Provider.of<CompanyProvider>(context, listen: false)
        .getCompanyById(task.executorId!)
        .then((value) {
      if (value != '') {
        setState(() {
          _executorName = value;
        });
      } else {
        _getExecutorName();
      }
    });
  }

  //get task creator name
  Future<void> _getCreatorName() async {
    await Provider.of<UserProvider>(context)
        .getUserById(context, task.userId)
        .then((value) {
      if (value != null) {
        setState(() {
          _creatorName = value.userName;
        });
      }
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
              child: const Text(
                'No',
                style: TextStyle(
                  fontSize: 20,
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
                  fontSize: 20,
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
                  fontSize: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontSize: 20,
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
  Future<void> _completeTask(bool completed) async {
    // check if task is steel active
    await Provider.of<TaskProvider>(context, listen: false)
        .checkIfActive(task)
        .then((value) {
      if (!value) {
        _isTaskActive = value;
      }
    });

    if (!_isTaskActive) {
      return;
    }

    if (_formKey.currentState != null) {
      // validate user input
      bool isValid = _formKey.currentState!.validate();

      if (task.type == TaskType.inspection &&
          transferObjectTask?.taskInterval == 'No') {
        isValid = false;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Choose inspection interval!'),
              backgroundColor: Colors.red,
            ),
          );
      }

      if (isValid) {
        _formKey.currentState!.save();
        if (transferObjectTask!.duration != null) {
          task.duration = transferObjectTask!.duration;
        }

        // executor ID
        if (task.executor != TaskExecutor.shared) {
          task.executorId =
              Provider.of<UserProvider>(context, listen: false).user!.userId;
        }
        inspection?.user = task.executorId!;

        // date
        task.date = transferObjectTask!.date;
        inspection?.date = task.date;

        // next date if cyclic task
        if (transferObjectTask!.taskInterval != 'No') {
          task.taskInterval = transferObjectTask!.taskInterval;
          task.nextDate = DateCalc.getNextDate(
              transferObjectTask!.date, transferObjectTask!.taskInterval!);
        } else {
          task.nextDate = null;
          task.taskInterval = 'No';
        }

        // cost
        task.cost = transferObjectTask!.cost;

        // comments
        task.comments = transferObjectTask!.comments;
        inspection?.comments = task.comments;

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
        if (task.type == TaskType.inspection) {
          await Provider.of<InspectionProvider>(context, listen: false)
              .addInspection(
            item!,
            inspection!,
          )
              .then((value) {
            if (!value) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Error occured while adding to Data Base. Please try again later.'),
                    backgroundColor: Colors.red,
                  ),
                );
            } else {
              item!.inspectionStatus = inspection!.status;
              item!.interval = task.taskInterval!;

              item!.nextInspection = task.nextDate!;

              Provider.of<ItemProvider>(context, listen: false)
                  .updateItem(item!);

              Provider.of<ItemProvider>(context, listen: false)
                  .fetchInspectionsStatus();
              Provider.of<InspectionProvider>(context, listen: false)
                  .fetchByItem(item!);
            }
          });
        }
        if (completed) {
          Navigator.of(context).pop('completed');
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    task = ModalRoute.of(context)!.settings.arguments as Task;
    oldTask = task.copyWith();

    if (task.type == TaskType.inspection) {
      try {
        item = Provider.of<ItemProvider>(context, listen: false)
            .items
            .firstWhere((element) => element.itemId == task.itemId);
      } catch (e) {
        item = Item(
          internalId: '',
          producer: 'Deleted',
          model: 'asset',
          category: '',
          location: '',
          lastInspection: DateTime.now(),
          nextInspection: DateTime.now(),
          interval: '',
          inspectionStatus: 0,
        );
      }
    }

    if (task.type == TaskType.inspection && inspection == null) {
      inspection = Inspection(
        user: Provider.of<UserProvider>(context, listen: false).user!.userId,
        date: DateTime.now(),
        comments: '',
        status: InspectionStatus.ok.index,
        taskId: task.taskId,
      );
    }

    if (task.executor == TaskExecutor.user &&
        task.executorId != null &&
        _executorName == '') {
      _getExecutorName();
    } else if (task.executor == TaskExecutor.shared &&
        task.executorId != null &&
        _executorName == '') {
      _getExecutorCompanyName();
    }
    if (_creatorName == '') {
      _getCreatorName();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    // used to store task state before saving
    transferObjectTask ??= task.copyWith(date: DateTime.now());

    final items = Provider.of<ItemProvider>(context, listen: false).items;
    final textStyle = Theme.of(context).textTheme.headline6!.copyWith();

    final labelTextStyle = Theme.of(context).textTheme.headline6!.copyWith(
          fontSize: 12,
          color: Theme.of(context).hintColor,
        );

    Item? asset;

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
                  if (_isTaskActive) {
                    Provider.of<TaskProvider>(context, listen: false)
                        .deleteTask(task);
                    Navigator.of(context).pop('deleted');
                  } else {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: const Text(
                            'The task is no longer available. It has either already been completed by another user or deleted.',
                          ),
                          backgroundColor: Theme.of(context).errorColor,
                        ),
                      );
                  }
                }
              });
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).errorColor,
            ),
          ),
          // done appbar button
          if (_isInEditMode &&
              task.status != TaskStatus.completed &&
              task.type != TaskType.inspection)
            IconButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                _toggleEditMode();
                if (_isInEditMode) {
                  _animationController!.forward();
                } else {
                  _animationController!.reverse();
                }

                await _completeTask(false);

                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        _isTaskActive
                            ? 'Data saved'
                            : 'The task is no longer available. It has either already been completed by another user or deleted.',
                      ),
                      backgroundColor: _isTaskActive
                          ? Theme.of(context).appBarTheme.backgroundColor
                          : Theme.of(context).errorColor,
                    ),
                  );
              },
              icon: Icon(
                Icons.save,
                color: Theme.of(context).primaryColor,
              ),
            ),
          if (_isInEditMode && task.status != TaskStatus.completed)
            IconButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                bool exit = false;
                _showCompleteDialog(context, task).then((value) async {
                  if (value == true) {
                    _completeTask(true);
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: const Text(
                            'The task is no longer available. It has either already been completed by another user or deleted.',
                          ),
                          backgroundColor: Theme.of(context).errorColor,
                        ),
                      );
                  }
                });
              },
              icon: Icon(
                Icons.done,
                color: Theme.of(context).primaryColor,
              ),
            ),
          SizedBox(
            width: responsiveSizePx(small: 10, medium: 20),
          ),
        ],
      ),
      body: Container(
        width: responsiveSizePct(small: 100),
        height: responsiveSizeVerticalPct(small: 110),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.white10,
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
                            size: responsiveSizePx(small: 90, medium: 170),
                            color:
                                Theme.of(context).appBarTheme.foregroundColor,
                          ),
                          width: responsiveSizePx(small: 105, medium: 200),
                          height: responsiveSizePx(small: 105, medium: 200),
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
                      right: responsiveSizePx(small: 25, medium: 45),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _statusIcons[task.status.index],
                          color: Colors.white,
                          size: responsiveSizePx(small: 40, medium: 80),
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
                    if (task.executor != TaskExecutor.user &&
                        task.executor != TaskExecutor.shared)
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
                    if (task.executor == TaskExecutor.shared)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Task executor company',
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

                    if (item != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height:
                            _isInEditMode && task.type == TaskType.inspection
                                ? null
                                : 0,
                        child: Column(
                          children: [
                            FadeTransition(
                              opacity: _opacityAnimation!,
                              child: SlideTransition(
                                position: _userSlideAnimation!,
                                child: InspectionForm(
                                  inspection: inspection!,
                                  task: task,
                                  item: item!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // action buttons bar
              if (task.status != TaskStatus.completed)
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
                              600,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          } else {
                            _animationController!.reverse();
                          }
                        },
                        icon: _isInEditMode
                            ? Icon(
                                Icons.cancel,
                                size: responsiveSizePx(small: 25, medium: 40),
                                color: Theme.of(context).errorColor,
                              )
                            : Icon(
                                Icons.keyboard_arrow_down_outlined,
                                size: responsiveSizePx(small: 25, medium: 40),
                              ),
                        label: Text(
                          _isInEditMode ? 'Cancel' : 'Complete the task',
                          style: textStyle.copyWith(
                            color: _isInEditMode
                                ? Theme.of(context).appBarTheme.foregroundColor
                                : Theme.of(context).appBarTheme.backgroundColor,
                            fontSize: responsiveSizePx(small: 18, medium: 24),
                          ),
                        ),
                      ),
                      //save task button
                      if (_isInEditMode && task.type != TaskType.inspection)
                        TextButton.icon(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            _toggleEditMode();
                            if (_isInEditMode) {
                              _animationController!.forward();
                            } else {
                              _animationController!.reverse();
                            }

                            await _completeTask(false);

                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isTaskActive
                                        ? 'Data saved'
                                        : 'The task is no longer available. It has either already been completed by another user or deleted.',
                                  ),
                                  backgroundColor: _isTaskActive
                                      ? Theme.of(context)
                                          .appBarTheme
                                          .backgroundColor
                                      : Theme.of(context).errorColor,
                                ),
                              );
                          },
                          icon: Icon(
                            Icons.save,
                            size: responsiveSizePx(small: 25, medium: 40),
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Text(
                            'Save',
                            style: textStyle.copyWith(
                              color: _isInEditMode
                                  ? Theme.of(context)
                                      .appBarTheme
                                      .foregroundColor
                                  : Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor,
                              fontSize: responsiveSizePx(small: 18, medium: 24),
                            ),
                          ),
                        ),
                      //complete task button
                      if (_isInEditMode)
                        TextButton.icon(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();

                            _showCompleteDialog(context, task)
                                .then((value) async {
                              if (value == true) {
                                _completeTask(true);
                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'The task is no longer available. It has either already been completed by another user or deleted.',
                                      ),
                                      backgroundColor:
                                          Theme.of(context).errorColor,
                                    ),
                                  );
                              }
                            });
                          },
                          icon: Icon(
                            Icons.done,
                            size: responsiveSizePx(small: 25, medium: 40),
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Text(
                            'Complete',
                            style: textStyle.copyWith(
                              color: _isInEditMode
                                  ? Theme.of(context)
                                      .appBarTheme
                                      .foregroundColor
                                  : Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor,
                              fontSize: responsiveSizePx(small: 18, medium: 24),
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
