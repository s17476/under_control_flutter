import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/checklist.dart';
import 'package:under_control_flutter/models/inspection.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/checklist_provider.dart';

class InspectionForm extends StatefulWidget {
  const InspectionForm({
    Key? key,
    required this.task,
    required this.item,
    required this.inspection,
  }) : super(key: key);

  final Task task;
  final Item item;
  final Inspection inspection;

  @override
  _InspectionFormState createState() => _InspectionFormState();
}

class _InspectionFormState extends State<InspectionForm>
    with TickerProviderStateMixin {
  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];

  String _statusString = 'OK';
  // DateTime? _inspectionDate;
  String _checklistName = 'New checklist';

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _nameTextController = TextEditingController();
  // final TextEditingController _commentsTextController = TextEditingController();

  late Checklist _selectedChecklist;

  List<Checklist> checklists = [];

  @override
  void initState() {
    super.initState();
    // _inspectionDate = DateTime.now();
    checklists =
        Provider.of<ChecklistProvider>(context, listen: false).checklists;
    _selectedChecklist = checklists[0];
  }

  @override
  void didChangeDependencies() {
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

  void _updateAnimationControllers() {
    for (int i = 0; i < _selectedChecklist.fields.keys.length; i++) {
      _animationControllers.insert(
        i,
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        ),
      );
      _animations.insert(
        i,
        CurvedAnimation(
            parent: _animationControllers[i], curve: Curves.easeOut),
      );
    }
  }

  void setStatus() {
    if (_selectedChecklist.name == 'New checklist') {
      _selectedChecklist.name = '';
    }
    if (_statusString == 'OK') {
      widget.inspection.status = InspectionStatus.ok.index;
    } else if (_statusString == 'Needs attention') {
      widget.inspection.status = InspectionStatus.needsAttention.index;
    } else {
      widget.inspection.status = InspectionStatus.failed.index;
    }
  }

  void setChecklist() {
    widget.inspection.checklist = _selectedChecklist;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Form(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Checklist:',
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 4,
                          color: Theme.of(context).textTheme.headline6!.color,
                        ),
                      ),

                      // choose checklist
                      DropdownButton<String>(
                        borderRadius: BorderRadius.circular(10),
                        value: _checklistName,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        iconSize: SizeConfig.blockSizeHorizontal * 6,
                        iconEnabledColor: Colors.black,
                        alignment: Alignment.center,
                        elevation: 16,
                        style: TextStyle(
                          color: Colors.black,
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
                          setChecklist();
                          _updateAnimationControllers();
                        },
                        dropdownColor: Colors.grey,
                        items: checklists
                            .map<DropdownMenuItem<String>>((Checklist value) {
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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
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
                                                  !_selectedChecklist.fields[
                                                          _selectedChecklist
                                                              .fields.keys
                                                              .toList()[i]]!
                                                      ? _animationControllers[i]
                                                          .reverse()
                                                      : _animationControllers[i]
                                                          .forward();
                                                });
                                              },
                                              icon: _selectedChecklist.fields[
                                                      _selectedChecklist
                                                          .fields.keys
                                                          .toList()[i]]!
                                                  ? const CircleAvatar(
                                                      child: Icon(Icons.done),
                                                      backgroundColor:
                                                          Colors.green,
                                                    )
                                                  : const CircleAvatar(
                                                      child: Icon(Icons.clear),
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
                                    .contains(_textController.text.trim())) {
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
                                color: Colors.black,
                                size: SizeConfig.blockSizeHorizontal * 7,
                              ),
                              label: Text(
                                'Add field',
                                style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal * 4,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // save checklist
                      if (_selectedChecklist.fields.keys.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                                                Theme.of(context).errorColor,
                                          ),
                                        );
                                    }
                                    Map<String, bool> fields =
                                        _selectedChecklist.fields;
                                    for (var key in fields.keys) {
                                      fields[key] = false;
                                    }
                                    Provider.of<ChecklistProvider>(context,
                                            listen: false)
                                        .addChecklist(
                                          Checklist(
                                            name: _nameTextController.text,
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
                                    size: SizeConfig.blockSizeHorizontal * 8,
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
                                      .deleteChecklist(_selectedChecklist);
                                  _updateAnimationControllers();
                                  setState(() {
                                    _selectedChecklist = checklists[0];
                                  });
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: SizeConfig.blockSizeHorizontal * 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(),

                // inspection status
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 32,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inspection status:',
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 4,
                          color: Theme.of(context).textTheme.headline6!.color,
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
                          fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                          fontWeight: FontWeight.w500,
                        ),
                        underline: Container(height: 0),
                        onChanged: (String? newValue) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            _statusString = newValue!;
                          });
                          setStatus();
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
