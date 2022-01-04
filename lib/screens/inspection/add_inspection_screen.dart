import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/checklist.dart';
import 'package:under_control_flutter/models/inspection.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/checklist_provider.dart';
import 'package:under_control_flutter/providers/inspection_provider.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';

class AddInspectionScreen extends StatefulWidget {
  const AddInspectionScreen({Key? key}) : super(key: key);

  static const routeName = '/inspection-add';

  @override
  _AddInspectionScreenState createState() => _AddInspectionScreenState();
}

class _AddInspectionScreenState extends State<AddInspectionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late Item item;
  late Task? task;

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];

  String _statusString = 'OK';
  DateTime? _inspectionDate;
  String _checklistName = 'New checklist';
  String _inspectionInterval = 'No';

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _commentsTextController = TextEditingController();

  late Checklist _selectedChecklist;

  List<Checklist> checklists = [];

  @override
  void initState() {
    super.initState();
    _inspectionDate = DateTime.now();
    checklists =
        Provider.of<ChecklistProvider>(context, listen: false).checklists;
    _selectedChecklist = checklists[0];
  }

  @override
  void didChangeDependencies() {
    item = (ModalRoute.of(context)!.settings.arguments as List<dynamic>)[0]
        as Item;
    task = (ModalRoute.of(context)!.settings.arguments as List<dynamic>)[1]
        as Task?;
    checklists = Provider.of<ChecklistProvider>(context).checklists;
    _animationControllers.clear();
    _animations.clear();
    _inspectionInterval = item.interval;
    // print('keys lenght ${_selectedChecklist.fields.keys.length}');
    _updateAnimationControllers();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateAnimationControllers() {
    for (int i = 0; i < _selectedChecklist.fields.keys.length; i++) {
      _animationControllers.insert(
          i,
          AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 500),
          ));

      _animations.insert(
          i,
          CurvedAnimation(
              parent: _animationControllers[i], curve: Curves.easeOut));
    }
  }

  void _presentDayPicker() {
    FocusScope.of(context).requestFocus(FocusNode());
    showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
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
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        _inspectionDate = value;
      });
    });
  }

  void saveInspection() {
    int statusValue;
    if (_selectedChecklist.name == 'New checklist') {
      _selectedChecklist.name = '';
    }
    if (_statusString == 'OK') {
      statusValue = InspectionStatus.ok.index;
    } else if (_statusString == 'Needs attention') {
      statusValue = InspectionStatus.needsAttention.index;
    } else {
      statusValue = InspectionStatus.failed.index;
    }

    Inspection inspection = Inspection(
      user: Provider.of<UserProvider>(context, listen: false).user!.userId,
      date: _inspectionDate!,
      comments: _commentsTextController.text,
      checklist: _selectedChecklist,
      status: statusValue,
      taskId: task?.taskId,
    );
    Provider.of<InspectionProvider>(context, listen: false)
        .addInspection(
      item,
      inspection,
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
        item.inspectionStatus = inspection.status;
        item.lastInspection = inspection.date;
        item.interval = _inspectionInterval;

// TODO make one function
        List<String> duration = item.interval.split(' ');

        if (duration[1] == 'week' || duration[1] == 'weeks') {
          item.nextInspection = DateTime(
            item.lastInspection.year,
            item.lastInspection.month,
            item.lastInspection.day + (int.parse(duration[0]) * 7),
          );
        } else if (duration[1] == 'month' || duration[1] == 'months') {
          item.nextInspection = DateTime(
            item.lastInspection.year,
            item.lastInspection.month + int.parse(duration[0]),
            item.lastInspection.day,
          );
        } else if (duration[1] == 'year' || duration[1] == 'years') {
          item.nextInspection = DateTime(
            item.lastInspection.year + int.parse(duration[0]),
            item.lastInspection.month,
            item.lastInspection.day,
          );
        }
        Provider.of<ItemProvider>(context, listen: false)
            .updateItem(item)
            .then((_) => Navigator.of(context).pop(value));
        Provider.of<ItemProvider>(context, listen: false)
            .fetchInspectionsStatus();
        Provider.of<InspectionProvider>(context, listen: false)
            .fetchByItem(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // set shown date
    String choosenDate;
    _inspectionDate ??= DateTime.now();
    choosenDate = 'Inspection date: ' +
        DateFormat('dd/MMM/yyyy').format(_inspectionDate!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add inspection'),
        actions: [
          IconButton(
            onPressed: () {
              saveInspection();
            },
            icon: Icon(
              Icons.save,
              color: Colors.green,
              size: SizeConfig.blockSizeHorizontal * 9,
            ),
          ),
          const SizedBox(
            width: 8,
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
              Colors.white12,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Choose checklist:',
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 4,
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                            ),
                          ),

                          // choose checklist
                          DropdownButton<String>(
                            borderRadius: BorderRadius.circular(10),
                            value: _checklistName,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            iconSize: SizeConfig.blockSizeHorizontal * 6,
                            iconEnabledColor: Theme.of(context).primaryColor,
                            alignment: Alignment.center,
                            elevation: 16,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: SizeConfig.blockSizeHorizontal * 4,
                              fontWeight: FontWeight.w600,
                            ),
                            underline: Container(height: 0),
                            onChanged: (String? newValue) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              setState(() {
                                _checklistName = newValue!;
                                _selectedChecklist = checklists.firstWhere(
                                    (element) => element.name == newValue);
                                _nameTextController.text =
                                    _selectedChecklist.name == 'New checklist'
                                        ? ''
                                        : _selectedChecklist.name;
                              });
                              _updateAnimationControllers();
                            },
                            dropdownColor:
                                Theme.of(context).appBarTheme.backgroundColor,
                            items: checklists.map<DropdownMenuItem<String>>(
                                (Checklist value) {
                              return DropdownMenuItem<String>(
                                value: value.name,
                                child: Text(
                                  value.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      // if (_checklistName == 'New checklist')
                      SizedBox(
                        child: Column(
                          children: [
                            const Divider(),
                            for (int i = 0;
                                i < _selectedChecklist.fields.keys.length;
                                i++)
                              if (_selectedChecklist.fields.keys.isNotEmpty)
                                Column(
                                  key: Key(
                                    _selectedChecklist.fields.keys.toList()[i],
                                  ),
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedChecklist.fields.remove(
                                                _selectedChecklist.fields.keys
                                                    .toList()[i],
                                              );
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _selectedChecklist.fields.keys
                                                    .toList()[i],
                                              ),
                                              RotationTransition(
                                                turns: _animations[i],
                                                child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      // change field value
                                                      _selectedChecklist.fields[
                                                              _selectedChecklist
                                                                  .fields.keys
                                                                  .toList()[i]] =
                                                          !_selectedChecklist
                                                                  .fields[
                                                              _selectedChecklist
                                                                  .fields.keys
                                                                  .toList()[i]]!;
                                                      // animate
                                                      !_selectedChecklist
                                                                  .fields[
                                                              _selectedChecklist
                                                                  .fields.keys
                                                                  .toList()[i]]!
                                                          ? _animationControllers[
                                                                  i]
                                                              .reverse()
                                                          : _animationControllers[
                                                                  i]
                                                              .forward();
                                                    });
                                                  },
                                                  icon: _selectedChecklist
                                                              .fields[
                                                          _selectedChecklist
                                                              .fields.keys
                                                              .toList()[i]]!
                                                      ? const CircleAvatar(
                                                          child:
                                                              Icon(Icons.done),
                                                          backgroundColor:
                                                              Colors.green,
                                                        )
                                                      : const CircleAvatar(
                                                          child:
                                                              Icon(Icons.clear),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                  ],
                                ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: _textController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical:
                                              SizeConfig.blockSizeHorizontal *
                                                  1,
                                          horizontal:
                                              SizeConfig.blockSizeHorizontal *
                                                  5,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor:
                                            Theme.of(context).splashColor,
                                        labelText:
                                            'Control point - ex. oil level, etc.',
                                        labelStyle: TextStyle(
                                          color: Theme.of(context)
                                              .appBarTheme
                                              .foregroundColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      String msg = '';
                                      if (_selectedChecklist.fields.keys
                                          .contains(
                                              _textController.text.trim())) {
                                        msg =
                                            '${_textController.text} alerede exist in the current checklist!';
                                      }

                                      if (_textController.text.isNotEmpty) {
                                        setState(() {
                                          _selectedChecklist.fields.putIfAbsent(
                                              _textController.text.trim(),
                                              () => false);
                                        });
                                        _textController.text = '';
                                      } else {
                                        msg = 'Text field is empty';
                                      }
                                      if (msg != '') {
                                        ScaffoldMessenger.of(context)
                                          ..clearSnackBars()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                msg,
                                              ),
                                              backgroundColor:
                                                  Theme.of(context).errorColor,
                                            ),
                                          );
                                      }
                                      // TODO
                                      _updateAnimationControllers();
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.green,
                                      size: SizeConfig.blockSizeHorizontal * 7,
                                    ),
                                    label: Text(
                                      'Add field',
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // save checklist
                            if (_selectedChecklist.fields.keys.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        controller: _nameTextController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical:
                                                SizeConfig.blockSizeHorizontal *
                                                    1,
                                            horizontal:
                                                SizeConfig.blockSizeHorizontal *
                                                    5,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor:
                                              Theme.of(context).splashColor,
                                          labelText: 'Checklist name',
                                          labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .appBarTheme
                                                .foregroundColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: IconButton(
                                        onPressed: () {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          String msg = '';
                                          if (_nameTextController.text
                                              .trim()
                                              .isEmpty) {
                                            msg = 'Type checklist name';
                                          }
                                          if (msg != '') {
                                            ScaffoldMessenger.of(context)
                                              ..clearSnackBars()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    msg,
                                                  ),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .errorColor,
                                                ),
                                              );
                                          }
                                          Map<String, bool> fields =
                                              _selectedChecklist.fields;
                                          for (var key in fields.keys) {
                                            fields[key] = false;
                                          }
                                          Provider.of<ChecklistProvider>(
                                                  context,
                                                  listen: false)
                                              .addChecklist(
                                                Checklist(
                                                  name:
                                                      _nameTextController.text,
                                                  fields: fields,
                                                ),
                                              )
                                              .then(
                                                (_) => setState(() {
                                                  _checklistName =
                                                      _nameTextController.text;
                                                }),
                                              );
                                        },
                                        icon: Icon(
                                          Icons.save,
                                          color: Colors.green,
                                          size: SizeConfig.blockSizeHorizontal *
                                              8,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        _checklistName = 'New checklist';
                                        Provider.of<ChecklistProvider>(context,
                                                listen: false)
                                            .deleteChecklist(
                                                _selectedChecklist);
                                        _updateAnimationControllers();
                                        setState(() {
                                          _selectedChecklist = checklists[0];
                                        });
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size:
                                            SizeConfig.blockSizeHorizontal * 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Divider(),
                      // comments
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: _commentsTextController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical:
                                        SizeConfig.blockSizeHorizontal * 1,
                                    horizontal:
                                        SizeConfig.blockSizeHorizontal * 5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).splashColor,
                                  labelText: 'Comments',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .appBarTheme
                                        .foregroundColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // last inspection - date picker
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
                          TextButton(
                            onPressed: _presentDayPicker,
                            child: Text(
                              'Pick',
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 4,
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
                            value: _inspectionInterval,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            iconSize: SizeConfig.blockSizeHorizontal * 6,
                            iconEnabledColor: Theme.of(context).primaryColor,
                            alignment: Alignment.center,
                            elevation: 16,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeHorizontal * 4,
                            ),
                            underline: Container(height: 0),
                            onChanged: (String? newValue) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              setState(() {
                                _inspectionInterval = newValue!;
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
                      // inspection status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Inspection status:',
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 4,
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                            ),
                          ),
                          DropdownButton<String>(
                            borderRadius: BorderRadius.circular(10),
                            value: _statusString,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            iconSize: SizeConfig.blockSizeHorizontal * 6,
                            iconEnabledColor: Theme.of(context).primaryColor,
                            alignment: Alignment.center,
                            elevation: 16,
                            style: TextStyle(
                              color: _statusString == 'OK'
                                  ? Colors.green
                                  : _statusString == 'Needs attention'
                                      ? Colors.amber
                                      : Colors.red,
                              fontSize: SizeConfig.blockSizeHorizontal * 4,
                            ),
                            underline: Container(height: 0),
                            onChanged: (String? newValue) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              setState(() {
                                _statusString = newValue!;
                              });
                            },
                            dropdownColor:
                                Theme.of(context).appBarTheme.backgroundColor,
                            items: <String>[
                              'OK',
                              'Needs attention',
                              'Failed',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
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
      ),
    );
  }
}
