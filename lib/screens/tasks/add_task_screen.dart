import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  static const routeName = '/add_task';

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

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

  final List<String> dropdownItems = const [
    'Maintenance',
    'Event',
    'Inspection',
    'Reparation',
  ];

  final List<String> executorTypeItems = const [
    'Company',
    'Specific user',
    'Shared'
  ];

  String dropdownValue = 'Maintenance';
  String userDropdownValue = '';
  Item? selectedAsset;
  String executorDropdown = 'Company';
  AppUser? selectedUser;

  List<Item> allAssets = [];
  List<AppUser?> allUsers = [];

  TextEditingController? titleController =
      TextEditingController(text: 'Maintenance');

  DateTime? _taskDate;
  String _taskInterval = 'No';
  String _taskTitle = '';
  String _taskDescription = '';

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).initializeCompanyUsers();
  }

// add new task
  Future<Item?> _addNewTask() async {
    if (_formKey.currentState != null) {
      // validate user input
      final isValid = _formKey.currentState!.validate();
      FocusScope.of(context).unfocus();
      String? executorId;
      DateTime? nextDate;
      TaskExecutor taskExecutor;
      String? userId;
      String? selectedItemId;
      String? selectedLocation;

      if (isValid) {
        if (executorDropdown == 'Specific user') {
          executorId = selectedUser!.userId;
        }
        _formKey.currentState!.save();

        if (_taskInterval != 'No') {
          // set inspections interval
          List<String> duration = _taskInterval.split(' ');
          if (duration[1] == 'week' || duration[1] == 'weeks') {
            nextDate = DateTime(
              _taskDate!.year,
              _taskDate!.month,
              _taskDate!.day + (int.parse(duration[0]) * 7),
            );
          } else if (duration[1] == 'month' || duration[1] == 'months') {
            nextDate = DateTime(_taskDate!.year,
                _taskDate!.month + int.parse(duration[0]), _taskDate!.day);
          } else if (duration[1] == 'year' || duration[1] == 'years') {
            nextDate = DateTime(_taskDate!.year + int.parse(duration[0]),
                _taskDate!.month, _taskDate!.day);
          }
        }

        if (executorDropdown == 'Company') {
          taskExecutor = TaskExecutor.company;
        } else if (executorDropdown == 'Shared') {
          taskExecutor = TaskExecutor.shared;
        } else if (executorDropdown == 'Specific user') {
          taskExecutor = TaskExecutor.user;
          userId = selectedUser?.userId;
        } else {
          taskExecutor = TaskExecutor.all;
        }

        if (selectedAsset?.itemId != '') {
          selectedItemId = selectedAsset?.itemId;
          selectedLocation = selectedAsset?.location;
        }

        Task task = Task(
          title: _taskTitle,
          date: _taskDate!,
          nextDate: nextDate,
          taskInterval: _taskInterval,
          executor: taskExecutor,
          executorId: executorId,
          userId:
              Provider.of<UserProvider>(context, listen: false).user!.userId,
          itemId: selectedItemId,
          location: selectedLocation,
          description: _taskDescription,
          comments: '',
          status: TaskStatus.planned,
          type: TaskType.values[dropdownItems.indexOf(dropdownValue)],
        );

        // try to add data to DB and close current screen
        //or show snackbar with error message
        await Provider.of<TaskProvider>(context, listen: false)
            .addTask(task)
            .then((_) => Navigator.of(context).pop(true))
            .catchError((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error while adding new task'),
            ),
          );
          Navigator.of(context).pop();
        });
      }
    }
  }

  void _presentDayPicker(Color color) {
    showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: color,
              surface: Colors.black,
              onSurface: Colors.white70,
            ),
            dialogBackgroundColor: Colors.grey.shade900,
          ),
          child: child ?? const Text(''),
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    ).then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        _taskDate = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    allAssets = Provider.of<ItemProvider>(context).items;
    allAssets.insert(
      0,
      Item(
        itemId: '',
        internalId: '',
        producer: '',
        model: '',
        category: '',
        location: '',
        lastInspection: DateTime.now(),
        nextInspection: DateTime.now(),
        interval: '',
        inspectionStatus: 0,
      ),
    );

    allUsers = Provider.of<UserProvider>(context).allUsersInCompany;
    selectedUser ??= selectedUser = Provider.of<UserProvider>(context).user;
    userDropdownValue =
        Provider.of<UserProvider>(context, listen: false).user!.userName;
    String choosenDate;

    _taskDate ??= DateTime.now();

    choosenDate =
        'Execution date: ' + DateFormat('dd/MMM/yyyy').format(_taskDate!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new task'),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        actions: [
          IconButton(
            onPressed: _addNewTask,
            icon: Icon(
              Icons.save,
              size: SizeConfig.blockSizeHorizontal * 9,
            ),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 3,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: AnimatedPadding(
          padding: EdgeInsets.only(
            left: SizeConfig.blockSizeHorizontal * 10,
            right: SizeConfig.blockSizeHorizontal * 10,
            top: SizeConfig.blockSizeHorizontal * 5,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon depends on choosen task type
                    Icon(
                      eventIcons[dropdownItems.indexOf(dropdownValue)],
                      size: SizeConfig.blockSizeHorizontal * 20,
                      color: darkTheme[dropdownItems.indexOf(dropdownValue)],
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 3,
                    ),

                    // Type dropdown
                    DropdownButtonFormField(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).primaryIconTheme.color,
                        size: SizeConfig.blockSizeHorizontal * 8,
                      ),
                      alignment: AlignmentDirectional.centerStart,
                      decoration: InputDecoration(
                        labelText: '  Task type',
                        labelStyle: TextStyle(
                          color: Theme.of(context).appBarTheme.foregroundColor,
                          fontSize: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).splashColor, width: 0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).splashColor, width: 0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).splashColor,
                      ),
                      dropdownColor: Colors.grey.shade800,
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                          if (selectedAsset?.producer != null &&
                              selectedAsset?.producer != '') {
                            titleController!.text =
                                '$dropdownValue - ${selectedAsset?.producer} ${selectedAsset?.model} ${selectedAsset?.internalId}';
                          } else {
                            titleController!.text = dropdownValue;
                          }
                        });
                      },
                      items: dropdownItems.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal * 2,
                            ),
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 4,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 3,
                    ),

                    // Asset dropdown
                    // TODO
                    DropdownButtonFormField(
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).primaryIconTheme.color,
                        size: SizeConfig.blockSizeHorizontal * 8,
                      ),
                      alignment: AlignmentDirectional.centerStart,
                      decoration: InputDecoration(
                        labelText: '  Asset',
                        labelStyle: TextStyle(
                          color: Theme.of(context).appBarTheme.foregroundColor,
                          fontSize: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).splashColor, width: 0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).splashColor, width: 0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).splashColor,
                      ),
                      dropdownColor: Colors.grey.shade800,
                      value: '',
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedAsset = allAssets.firstWhere(
                              (element) => element.itemId == newValue!);
                          if (selectedAsset?.producer != null &&
                              selectedAsset?.producer != '') {
                            titleController!.text =
                                '$dropdownValue - ${selectedAsset?.producer} ${selectedAsset?.model} ${selectedAsset?.internalId}';
                          } else {
                            titleController!.text = dropdownValue;
                          }
                        });
                      },
                      items: allAssets.map((Item item) {
                        return DropdownMenuItem<String>(
                          value: '${item.itemId}',
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal * 2,
                            ),
                            child: Text(
                              '${item.producer} ${item.model} ${item.internalId}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 4,
                                // overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 3,
                    ),

                    // title
                    TextFormField(
                      controller: titleController,
                      // initialValue: dropdownValue,
                      key: const ValueKey('title'),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Task title',
                        labelStyle: TextStyle(
                          color: Theme.of(context).appBarTheme.foregroundColor,
                          fontSize: 20,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockSizeHorizontal * 1,
                          horizontal: SizeConfig.blockSizeHorizontal * 5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).splashColor,
                        // hintText: 'Task title',
                      ),
                      validator: (val) {
                        if (val!.length < 4) {
                          return 'Min. 4 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _taskTitle = value!;
                      },
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 3,
                    ),

                    // task descryption
                    TextFormField(
                      // controller: titleController,
                      // initialValue: dropdownValue,
                      key: const ValueKey('description'),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,

                      decoration: InputDecoration(
                        labelText: 'Task description',
                        labelStyle: TextStyle(
                          color: Theme.of(context).appBarTheme.foregroundColor,
                          fontSize: 20,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockSizeHorizontal * 1,
                          horizontal: SizeConfig.blockSizeHorizontal * 5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).splashColor,
                        // hintText: 'Task description',
                      ),
                      validator: (val) {
                        return null;
                      },
                      onSaved: (value) {
                        _taskDescription = value!;
                      },
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 3,
                    ),

                    // Task executor type dropdown
                    DropdownButtonFormField(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).primaryIconTheme.color,
                        size: SizeConfig.blockSizeHorizontal * 8,
                      ),
                      alignment: AlignmentDirectional.centerStart,
                      decoration: InputDecoration(
                        labelText: '  Task executor type',
                        labelStyle: TextStyle(
                          color: Theme.of(context).appBarTheme.foregroundColor,
                          fontSize: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).splashColor, width: 0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).splashColor, width: 0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).splashColor,
                      ),
                      dropdownColor: Colors.grey.shade800,
                      value: executorDropdown,
                      onChanged: (String? newValue) {
                        setState(() {
                          executorDropdown = newValue!;
                        });
                      },
                      items: executorTypeItems.map((String executorType) {
                        return DropdownMenuItem<String>(
                          value: executorType,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal * 2,
                            ),
                            child: Text(
                              executorType,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 4,
                                // overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 3,
                    ),

                    // Task executor dropdown
                    if (executorDropdown == 'Specific user')
                      DropdownButtonFormField(
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Theme.of(context).primaryIconTheme.color,
                          size: SizeConfig.blockSizeHorizontal * 8,
                        ),
                        alignment: AlignmentDirectional.centerStart,
                        decoration: InputDecoration(
                          labelText: '  Task executor',
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).appBarTheme.foregroundColor,
                            fontSize: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).splashColor, width: 0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).splashColor, width: 0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).splashColor,
                        ),
                        dropdownColor: Colors.grey.shade800,
                        value: Provider.of<UserProvider>(context, listen: false)
                            .user!
                            .userId,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedUser = allUsers.firstWhere(
                                (element) => element!.userId == newValue);
                          });
                          // print('user ${selectedUser!.userId}');
                          // print('user ${selectedUser!.userName}');
                        },
                        items: allUsers.map((AppUser? user) {
                          return DropdownMenuItem<String>(
                            value: user!.userId,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal * 2,
                              ),
                              child: Text(
                                user.userName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal * 4,
                                  // overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    // execution date - date picker
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            choosenDate,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 4,
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                            ),
                          ),
                        ),
                        SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                        TextButton(
                          onPressed: () {
                            _presentDayPicker(
                              darkTheme[dropdownItems.indexOf(dropdownValue)]!,
                            );
                          },
                          child: Text(
                            'Pick',
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 4,
                              color: darkTheme[
                                  dropdownItems.indexOf(dropdownValue)],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // inspection interval
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Cyclic task:',
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal * 4,
                            color: Theme.of(context).textTheme.headline6!.color,
                          ),
                        ),
                        DropdownButton<String>(
                          borderRadius: BorderRadius.circular(10),
                          value: _taskInterval,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          iconSize: SizeConfig.blockSizeHorizontal * 4,
                          alignment: Alignment.center,
                          elevation: 16,
                          style: TextStyle(
                            color:
                                darkTheme[dropdownItems.indexOf(dropdownValue)],
                            fontSize: SizeConfig.blockSizeHorizontal * 4,
                          ),
                          underline: Container(height: 0),
                          onChanged: (String? newValue) {
                            setState(() {
                              _taskInterval = newValue!;
                            });
                          },
                          dropdownColor:
                              Theme.of(context).appBarTheme.backgroundColor,
                          items: <String>[
                            'No',
                            '2 years',
                            '1 year',
                            '6 months',
                            '3 months',
                            '1 month',
                            '2 weeks',
                            '1 week',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 0.5,
                    ),
                    // save button
                    // ElevatedButton(
                    //   //TODO
                    //   onPressed: _addNewTask,
                    //   child: Text(
                    //     'Create task',
                    //     style: TextStyle(
                    //       fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                    //     ),
                    //   ),
                    //   style: ElevatedButton.styleFrom(
                    //     primary:
                    //         darkTheme[dropdownItems.indexOf(dropdownValue)],
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(30.0),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: SizeConfig.blockSizeVertical * 3,
                    // ),
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
