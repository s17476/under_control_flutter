import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/date_calc.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/company.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/screens/tasks/choose_shared_company_screen.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  static const routeName = '/add_task';

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? parameter;
  Item? item;

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

  // task types
  final List<String> dropdownItems = const [
    'Maintenance',
    'Event',
    'Inspection',
    'Reparation',
  ];

  // executor types
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

  String? choosenCompanyName;
  Company? choosenCompanyData;

  List<Item> allAssets = [];
  List<AppUser?> allUsers = [];

  TextEditingController? titleController = TextEditingController(text: '');

  DateTime? _taskDate;
  String _taskInterval = 'No';
  String _taskTitle = '';
  String _taskDescription = '';

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).initializeCompanyUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.settings.arguments != null) {
      parameter =
          (ModalRoute.of(context)!.settings.arguments as List)[0] as String;
      if (parameter == 'asset') {
        item =
            ((ModalRoute.of(context)!.settings.arguments as List)[1] as Item);
        selectedAsset = item;
        if (titleController!.text == '') {
          titleController!.text =
              '${item?.producer} ${item?.model} ${item?.internalId}';
        }
      }
    }
  }

// add new task
  Future<Item?> _addNewTask() async {
    if (_formKey.currentState != null) {
      // validate user input
      bool isValid = _formKey.currentState!.validate();
      FocusScope.of(context).unfocus();
      String? executorId;
      DateTime? nextDate;
      TaskExecutor taskExecutor;
      String? selectedItemId;
      String? selectedLocation;

      if (dropdownValue == 'Inspection' &&
          (selectedAsset == null || selectedAsset!.model.isEmpty)) {
        isValid = false;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Choose asset to inspect'),
              backgroundColor: Colors.red,
            ),
          );
      }

      if (dropdownValue == 'Inspection' && _taskInterval == 'No') {
        isValid = false;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Choose inspection interval'),
              backgroundColor: Colors.red,
            ),
          );
      }

      if (executorDropdown == 'Shared' && choosenCompanyData == null) {
        isValid = false;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Pick a company to share task with'),
              backgroundColor: Colors.red,
            ),
          );
      }

      if (isValid) {
        _formKey.currentState!.save();

        // set inspections interval
        if (_taskInterval != 'No') {
          nextDate = DateCalc.getNextDate(_taskDate!, _taskInterval);
        }
        if (executorDropdown == 'Company') {
          taskExecutor = TaskExecutor.company;
        } else if (executorDropdown == 'Shared') {
          taskExecutor = TaskExecutor.shared;
          executorId = choosenCompanyData!.companyId;
        } else if (executorDropdown == 'Specific user') {
          taskExecutor = TaskExecutor.user;
          executorId = selectedUser!.userId;
        } else {
          taskExecutor = TaskExecutor.all;
        }

        if (selectedAsset?.itemId != '') {
          selectedItemId = selectedAsset?.itemId;
          selectedLocation = selectedAsset?.location;
        }

        final itemProvider = Provider.of<ItemProvider>(context, listen: false);
        if (selectedItemId != null) {
          item = itemProvider.items
              .firstWhere((element) => element.itemId == selectedItemId);
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
          itemName: '${item?.producer ?? ''} ${item?.model ?? ''}',
          location: selectedLocation,
          description: _taskDescription,
          comments: '',
          status: TaskStatus.planned,
          type: TaskType.values[dropdownItems.indexOf(dropdownValue)],
        );

        // try to add data to DB and close current screen
        // or show snackbar with error message
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

  // date picker
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
    choosenCompanyName ??= 'No company selected';

    _taskDate ??= DateTime.now();

    choosenDate =
        'Execution date: ' + DateFormat('dd/MMM/yyyy').format(_taskDate!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new task'),
        iconTheme: const IconThemeData(color: Colors.green),
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
      body: Container(
        width: SizeConfig.blockSizeHorizontal * 100,
        height: SizeConfig.blockSizeVertical * 110,
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
          child: AnimatedPadding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
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
                              color: Theme.of(context).splashColor,
                              width: 0,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).splashColor,
                        ),
                        dropdownColor: Colors.grey.shade800,
                        value: dropdownValue,
                        onChanged: (String? newValue) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            dropdownValue = newValue!;
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
                        value: parameter == 'asset' ? item!.itemId : '',
                        onChanged: parameter == 'asset'
                            ? null
                            : (String? newValue) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                setState(() {
                                  selectedAsset = allAssets.firstWhere(
                                      (element) => element.itemId == newValue!);
                                  if (selectedAsset?.producer != null &&
                                      selectedAsset?.producer != '') {
                                    titleController!.text =
                                        '${selectedAsset?.producer} ${selectedAsset?.model} ${selectedAsset?.internalId}';
                                  } else {
                                    titleController!.text = '';
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
                        key: const ValueKey('title'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(color: Colors.black),
                          labelText: 'Task title',
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).appBarTheme.foregroundColor,
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
                        key: const ValueKey('description'),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(color: Colors.black),
                          labelText: 'Task description',
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).appBarTheme.foregroundColor,
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
                        value: executorDropdown,
                        onChanged: (String? newValue) {
                          FocusScope.of(context).requestFocus(FocusNode());
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
                                color: Theme.of(context).splashColor,
                                width: 0,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).splashColor,
                                width: 0,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).splashColor,
                          ),
                          dropdownColor: Colors.grey.shade800,
                          value:
                              Provider.of<UserProvider>(context, listen: false)
                                  .user!
                                  .userId,
                          onChanged: (String? newValue) {
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {
                              selectedUser = allUsers.firstWhere(
                                  (element) => element!.userId == newValue);
                            });
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
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 4,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      // Task executor dropdown - shared option
                      if (executorDropdown == 'Shared')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              choosenCompanyName!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 4,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .color,
                              ),
                            ),
                            SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(
                                        ChooseSharedCompanyScreen.routeName)
                                    .then((value) {
                                  if (value != null) {
                                    setState(() {
                                      choosenCompanyData = value as Company;
                                      choosenCompanyName =
                                          choosenCompanyData!.name;
                                    });
                                  }
                                });
                              },
                              child: Text(
                                'Pick a company',
                                style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal * 4,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      // execution date - date picker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            choosenDate,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 4,
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                            ),
                          ),
                          SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                          TextButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              _presentDayPicker(
                                darkTheme[
                                    dropdownItems.indexOf(dropdownValue)]!,
                              );
                            },
                            child: Text(
                              'Pick',
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 4,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // inspection interval
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cyclic task:',
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 4,
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
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
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal * 4,
                            ),
                            underline: Container(height: 0),
                            onChanged: (String? newValue) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              setState(() {
                                _taskInterval = newValue!;
                              });
                            },
                            dropdownColor: Colors.grey,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
