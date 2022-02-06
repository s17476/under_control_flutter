import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/date_calc.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/checklist.dart';
import 'package:under_control_flutter/models/inspection.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/checklist_provider.dart';
import 'package:under_control_flutter/providers/inspection_provider.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';

// add inspections screen used while adding new asset
class AddInspectionScreen extends StatefulWidget {
  const AddInspectionScreen({Key? key}) : super(key: key);

  static const routeName = '/inspection-add';

  @override
  _AddInspectionScreenState createState() => _AddInspectionScreenState();
}

class _AddInspectionScreenState extends State<AddInspectionScreen>
    with TickerProviderStateMixin, ResponsiveSize {
  late Item item;
  late Task? task;

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];

  String _statusString = 'OK';
  DateTime? _inspectionDate;
  String _checklistName = 'New checklist';
  String _inspectionInterval = '1 year';

  final _textController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _commentsTextController = TextEditingController();

  late Checklist _selectedChecklist;

  List<Checklist> checklists = [];

  @override
  void initState() {
    super.initState();
    _inspectionDate = DateTime.now();
    Provider.of<ChecklistProvider>(context, listen: false)
        .fetchAndSetChecklists();
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

  // updates animations controllers in case of adding or deleting control point
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

  // date picker widget
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

  // save inspection
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

    // try to add inspection to DB
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
                'Error occured while adding to Data Base. Please try again later.',
              ),
              backgroundColor: Colors.red,
            ),
          );
      } else {
        item.inspectionStatus = inspection.status;
        item.lastInspection = inspection.date;
        item.interval = _inspectionInterval;

        item.nextInspection =
            DateCalc.getNextDate(item.lastInspection, item.interval)!;

        // updates item inspection status
        Provider.of<ItemProvider>(context, listen: false)
            .updateItem(item)
            .then((_) => Navigator.of(context).pop(value));
        // fetch inspections status - used on dashboard screen
        Provider.of<ItemProvider>(context, listen: false)
            .fetchInspectionsStatus();
        // fetch asset inspections data
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
            icon: const Icon(
              Icons.save,
              color: Colors.green,
              size: 40,
            ),
          ),
          const SizedBox(
            width: 8,
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
                              fontSize: responsiveSizePx(small: 18, medium: 24),
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                            ),
                          ),

                          // choose checklist
                          DropdownButton<String>(
                            borderRadius: BorderRadius.circular(10),
                            value: _checklistName,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            iconSize: responsiveSizePx(small: 30, medium: 45),
                            iconEnabledColor: Theme.of(context).primaryColor,
                            alignment: Alignment.center,
                            elevation: 16,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: responsiveSizePx(small: 18, medium: 24),
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
                                          vertical: 4,
                                          horizontal: responsiveSizePx(
                                              small: 20, medium: 30),
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
                                      _updateAnimationControllers();
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.green,
                                      size: responsiveSizePx(
                                          small: 35, medium: 50),
                                    ),
                                    label: Text(
                                      'Add field',
                                      style: TextStyle(
                                        fontSize: responsiveSizePx(
                                            small: 18, medium: 24),
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
                                            vertical: 4,
                                            horizontal: responsiveSizePx(
                                                small: 20, medium: 30),
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
                                          size: responsiveSizePx(
                                              small: 30, medium: 40),
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
                                        size: responsiveSizePx(
                                            small: 30, medium: 40),
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
                                    vertical: 4,
                                    horizontal:
                                        responsiveSizePx(small: 20, medium: 30),
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
                              fontSize: responsiveSizePx(small: 18, medium: 30),
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                            ),
                          ),
                          TextButton(
                            onPressed: _presentDayPicker,
                            child: Text(
                              'Pick',
                              style: TextStyle(
                                fontSize:
                                    responsiveSizePx(small: 18, medium: 30),
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
                              fontSize: responsiveSizePx(small: 18, medium: 30),
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                            ),
                          ),
                          DropdownButton<String>(
                            borderRadius: BorderRadius.circular(10),
                            value: _inspectionInterval,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            iconSize: responsiveSizePx(small: 18, medium: 30),
                            iconEnabledColor: Theme.of(context).primaryColor,
                            alignment: Alignment.center,
                            elevation: 16,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: responsiveSizePx(small: 18, medium: 30),
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
                              fontSize: responsiveSizePx(small: 18, medium: 30),
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                            ),
                          ),
                          DropdownButton<String>(
                            borderRadius: BorderRadius.circular(10),
                            value: _statusString,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            iconSize: responsiveSizePx(small: 18, medium: 30),
                            iconEnabledColor: Theme.of(context).primaryColor,
                            alignment: Alignment.center,
                            elevation: 16,
                            style: TextStyle(
                              color: _statusString == 'OK'
                                  ? Colors.green
                                  : _statusString == 'Needs attention'
                                      ? Colors.amber
                                      : Colors.red,
                              fontSize: responsiveSizePx(small: 18, medium: 30),
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
