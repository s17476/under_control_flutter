import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/task.dart';

class TaskComplete extends StatefulWidget {
  TaskComplete({
    Key? key,
    required this.task,
  }) : super(key: key);

  final Task task;

  @override
  _TaskCompleteState createState() => _TaskCompleteState();
}

class _TaskCompleteState extends State<TaskComplete> {
  String _taskInterval = 'No';
  int _min = 0;
  int _hour = 0;

  final List<Color?> darkTheme = const [
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.red,
  ];

  // date picker
  void _datePicker() {
    showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: darkTheme[widget.task.type.index]!,
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
        widget.task.date = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('duration ${widget.task.duration}');
    if (widget.task.duration != null && widget.task.duration != 0) {
      _hour = (widget.task.duration! ~/ 60);
      _min = widget.task.duration! % 60;
    }
    _taskInterval = widget.task.taskInterval!;
    return Column(
      children: [
        TextFormField(
          initialValue: widget.task.comments,
          key: const ValueKey('comments'),
          textInputAction: TextInputAction.newline,
          maxLines: null,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
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
            labelText: 'Comments',
            labelStyle:
                TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
          ),
          onSaved: (value) {
            if (value != null && value != '') {
              widget.task.comments = value;
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TextFormField(
            initialValue:
                widget.task.cost != null ? widget.task.cost!.toString() : '',
            key: const ValueKey('cost'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
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
              labelText: 'Cost',
              labelStyle: TextStyle(
                color: Theme.of(context).appBarTheme.backgroundColor,
              ),
            ),
            onSaved: (value) {
              if (value != null && value != '') {
                try {
                  widget.task.cost = double.parse(value);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wrong number format')));
                }
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.blockSizeHorizontal * 8,
            right: SizeConfig.blockSizeHorizontal * 8,
            top: SizeConfig.blockSizeHorizontal * 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(widget.task.date),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 4,
                  color: Theme.of(context).textTheme.headline6!.color,
                ),
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
              TextButton(
                onPressed: _datePicker,
                child: Text(
                  'Pick date',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 4,
                    color: Theme.of(context).appBarTheme.backgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        // inspection interval
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cyclic task:',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 4,
                  color: Theme.of(context).textTheme.headline6!.color,
                ),
              ),
              // date picker

              // task interval
              DropdownButton<String>(
                borderRadius: BorderRadius.circular(10),
                value: _taskInterval,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                iconSize: SizeConfig.blockSizeHorizontal * 6,
                iconEnabledColor: Theme.of(context).appBarTheme.backgroundColor,
                alignment: Alignment.center,
                elevation: 16,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  fontSize: SizeConfig.blockSizeHorizontal * 4,
                  fontWeight: FontWeight.w600,
                ),
                underline: Container(height: 0),
                onChanged: (String? newValue) {
                  setState(() {
                    widget.task.taskInterval = newValue!;
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
        ),

        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.blockSizeHorizontal * 8,
            right: SizeConfig.blockSizeHorizontal * 8,
            bottom: SizeConfig.blockSizeHorizontal * 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_hour hrs, $_min min',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 4,
                  color: Theme.of(context).textTheme.headline6!.color,
                ),
              ),
              TextButton(
                onPressed: () {
                  int duration = 0;
                  Picker(
                    adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
                      NumberPickerColumn(
                        initValue: _hour,
                        begin: 0,
                        end: 999,
                        suffix: const Text(' hours'),
                      ),
                      NumberPickerColumn(
                        initValue: _min,
                        begin: 0,
                        end: 60,
                        suffix: const Text(' minutes'),
                        jump: 5,
                      ),
                    ]),
                    delimiter: <PickerDelimiter>[
                      PickerDelimiter(
                        child: Container(
                          width: 30.0,
                          alignment: Alignment.center,
                          child: const Icon(Icons.more_vert),
                        ),
                      )
                    ],
                    cancelText: 'Cancel',
                    cancelTextStyle: TextStyle(
                      color: Colors.red,
                      fontSize: SizeConfig.blockSizeHorizontal * 6,
                    ),
                    hideHeader: true,
                    confirmText: 'OK',
                    confirmTextStyle: TextStyle(
                      color: Colors.green,
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                    ),
                    title: const Text('Select duration'),
                    selectedTextStyle: TextStyle(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      fontSize: SizeConfig.blockSizeHorizontal * 4,
                    ),
                    textStyle: TextStyle(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      fontSize: SizeConfig.blockSizeHorizontal * 4,
                    ),
                    onConfirm: (Picker picker, List<int> value) {
                      // You get your duration here
                      duration = (picker.getSelectedValues()[0] * 60) +
                          picker.getSelectedValues()[1];
                      setState(() {
                        print('set state $duration');
                        widget.task.duration = duration;
                      });
                    },
                  ).showDialog(context);
                },
                child: Text(
                  'Pick duration',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 4,
                    color: Theme.of(context).appBarTheme.backgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
