import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:intl/intl.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({Key? key}) : super(key: key);

  static const routeName = '/add_equipment';

  @override
  _AddEquipmentScreenState createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  DateTime? _lastInspection;
  String statusValue = 'OK';
  String _inspectionInterval = '1 year';
  String _internalId = '';
  String _producer = '';
  String _model = '';
  String _category = '';
  String _comments = '';

  void _presentDayPicker() {
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
        _lastInspection = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String choosenDate;

    _lastInspection ??= DateTime.now();

    choosenDate = 'Inspection date: ' +
        DateFormat('dd/MMM/yyyy').format(_lastInspection!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add equipment'),
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.handyman,
                  size: SizeConfig.blockSizeHorizontal * 20,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                // internal id
                TextFormField(
                  key: const ValueKey('internalId'),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
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
                    hintText: 'Internal id',
                  ),
                  validator: (val) {
                    if (val!.length < 4) {
                      return 'Min. 4 characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _internalId = value!;
                  },
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                // producer
                TextFormField(
                  key: const ValueKey('producer'),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
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
                    hintText: 'Producer',
                  ),
                  validator: (val) {
                    if (val!.length < 3) {
                      return 'Producer to short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _producer = value!;
                  },
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                // model
                TextFormField(
                  key: const ValueKey('model'),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
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
                    hintText: 'Model',
                  ),
                  validator: (val) {
                    if (val!.length < 3) {
                      return 'Model to short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _model = value!;
                  },
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                //catergory
                TextFormField(
                  key: const ValueKey('category'),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
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
                    hintText: 'Category - ex. power tools, machine',
                  ),
                  validator: (val) {
                    if (val!.length < 2) {
                      return 'Categoty to short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _category = value!;
                  },
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                // comments
                TextFormField(
                  maxLines: null,
                  // expands: true,
                  key: const ValueKey('comments'),
                  keyboardType: TextInputType.multiline,
                  // textInputAction: TextInputAction.next,
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
                    hintText: 'Comments',
                  ),
                  validator: (val) {
                    return null;
                  },
                  onSaved: (value) {
                    _comments = value!;
                  },
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 1,
                ),
                // last inspection - date picker
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        choosenDate,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 4,
                          color: Theme.of(context).textTheme.headline6!.color,
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
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
                // SizedBox(
                //   height: SizeConfig.blockSizeVertical * 1,
                // ),

                // status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Inspection status:',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 4,
                        color: Theme.of(context).textTheme.headline6!.color,
                      ),
                    ),
                    DropdownButton<String>(
                      value: statusValue,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      iconSize: SizeConfig.blockSizeHorizontal * 4,
                      alignment: Alignment.center,
                      elevation: 16,
                      style: TextStyle(
                        color: statusValue == 'OK'
                            ? Colors.green
                            : statusValue == 'Needs attention'
                                ? Colors.amber
                                : Colors.red,
                        fontSize: SizeConfig.blockSizeHorizontal * 4,
                      ),
                      underline: Container(height: 0),
                      onChanged: (String? newValue) {
                        setState(() {
                          statusValue = newValue!;
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
                // SizedBox(
                //   height: SizeConfig.blockSizeVertical * 3,
                // ),

                // inspection interval
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Inspections interval:',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 4,
                        color: Theme.of(context).textTheme.headline6!.color,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _inspectionInterval,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      iconSize: SizeConfig.blockSizeHorizontal * 4,
                      alignment: Alignment.center,
                      elevation: 16,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: SizeConfig.blockSizeHorizontal * 4,
                      ),
                      underline: Container(height: 0),
                      onChanged: (String? newValue) {
                        setState(() {
                          _inspectionInterval = newValue!;
                        });
                      },
                      dropdownColor:
                          Theme.of(context).appBarTheme.backgroundColor,
                      items: <String>[
                        '1 year',
                        '6 months',
                        '3 months',
                        '1 month',
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
                  height: SizeConfig.blockSizeVertical * 3,
                ),

                // save button
                ElevatedButton(
                  onPressed: () async {},
                  child: Text(
                    'Add equipment',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
