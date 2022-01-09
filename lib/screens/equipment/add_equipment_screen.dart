import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/date_calc.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/screens/inspection/add_inspection_screen.dart';

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
  DateTime? _nextInspection;
  String _statusString = 'OK';
  String _inspectionInterval = '1 year';
  String _internalId = '';
  String _producer = '';
  String _model = '';
  String _category = '';
  String _location = '';
  String _comments = '';

  // add new asset
  Future<Item?> _addNewEquipment() async {
    if (_formKey.currentState != null) {
      // validate user input
      final isValid = _formKey.currentState!.validate();
      FocusScope.of(context).unfocus();

      // if user is valid
      if (isValid) {
        // set inspection status
        int statusValue;
        if (_statusString == 'OK') {
          statusValue = InspectionStatus.ok.index;
        } else if (_statusString == 'Needs attention') {
          statusValue = InspectionStatus.needsAttention.index;
        } else {
          statusValue = InspectionStatus.failed.index;
        }
        _formKey.currentState!.save();

        // set inspections interval
        _nextInspection =
            DateCalc.getNextDate(_lastInspection!, _inspectionInterval);
        // List<String> duration = _inspectionInterval.split(' ');
        // if (duration[1] == 'week' || duration[1] == 'weeks') {
        //   _nextInspection = DateTime(
        //     _lastInspection!.year,
        //     _lastInspection!.month,
        //     _lastInspection!.day + (int.parse(duration[0]) * 7),
        //   );
        // } else if (duration[1] == 'month' || duration[1] == 'months') {
        //   _nextInspection = DateTime(
        //       _lastInspection!.year,
        //       _lastInspection!.month + int.parse(duration[0]),
        //       _lastInspection!.day);
        // } else if (duration[1] == 'year' || duration[1] == 'years') {
        //   _nextInspection = DateTime(
        //     _lastInspection!.year + int.parse(duration[0]),
        //     _lastInspection!.month,
        //     _lastInspection!.day,
        //   );
        // }

        // create new asset
        Item item = Item(
          internalId: _internalId,
          producer: _producer,
          model: _model,
          category: _category,
          location: _location,
          comments: _comments,
          lastInspection: _lastInspection!,
          nextInspection: _nextInspection!,
          interval: _inspectionInterval,
          inspectionStatus: statusValue,
        );

        // try to add data to DB and close current screen
        //or show snackbar with error message
        await Provider.of<ItemProvider>(context, listen: false)
            .addNewItem(item)
            .then((resultItem) {
          // add initial inspection
          Navigator.of(context).pushNamed(AddInspectionScreen.routeName,
              arguments: [resultItem, null]).then(
            (value) {
              if (value != null) {
                Navigator.of(context).pop(resultItem);
              } else {
                Provider.of<ItemProvider>(context, listen: false)
                    .deleteItem(context, item.itemId);
              }
            },
          );
        }).catchError((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error while adding new equipment'),
            ),
          );
          Navigator.of(context).pop();
        });
      }
    }
  }

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
        title: const Text('Add asset'),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        actions: [
          IconButton(
              onPressed: _addNewEquipment,
              icon: Icon(
                Icons.save,
                size: SizeConfig.blockSizeHorizontal * 9,
              )),
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
                      //location
                      TextFormField(
                        key: const ValueKey('location'),
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
                          hintText: 'Asset location',
                        ),
                        validator: (val) {
                          if (val!.length < 2) {
                            return 'location to short';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _location = value!;
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
                    ],
                  ),
                ),
                // last inspection - date picker
                // Row(
                //   children: [
                //     Expanded(
                //       child: Text(
                //         choosenDate,
                //         textAlign: TextAlign.center,
                //         style: TextStyle(
                //           fontSize: SizeConfig.blockSizeHorizontal * 4,
                //           color: Theme.of(context).textTheme.headline6!.color,
                //         ),
                //       ),
                //     ),
                //     SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                //     TextButton(
                //       onPressed: _presentDayPicker,
                //       child: Text(
                //         'Pick',
                //         style: TextStyle(
                //           fontSize: SizeConfig.blockSizeHorizontal * 4,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(
                //   height: SizeConfig.blockSizeVertical * 1,
                // ),

                // status
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     Text(
                //       'Inspection status:',
                //       style: TextStyle(
                //         fontSize: SizeConfig.blockSizeHorizontal * 4,
                //         color: Theme.of(context).textTheme.headline6!.color,
                //       ),
                //     ),
                //     DropdownButton<String>(
                //       value: _statusString,
                //       icon: const Icon(Icons.keyboard_arrow_down_rounded),
                //       iconSize: SizeConfig.blockSizeHorizontal * 4,
                //       alignment: Alignment.center,
                //       elevation: 16,
                //       style: TextStyle(
                //         color: _statusString == 'OK'
                //             ? Colors.green
                //             : _statusString == 'Needs attention'
                //                 ? Colors.amber
                //                 : Colors.red,
                //         fontSize: SizeConfig.blockSizeHorizontal * 4,
                //       ),
                //       underline: Container(height: 0),
                //       onChanged: (String? newValue) {
                //         setState(() {
                //           _statusString = newValue!;
                //         });
                //       },
                //       dropdownColor:
                //           Theme.of(context).appBarTheme.backgroundColor,
                //       items: <String>[
                //         'OK',
                //         'Needs attention',
                //         'Failed',
                //       ].map<DropdownMenuItem<String>>((String value) {
                //         return DropdownMenuItem<String>(
                //           value: value,
                //           child: Text(value),
                //         );
                //       }).toList(),
                //     ),
                //   ],
                // ),
                // SizedBox(
                //   height: SizeConfig.blockSizeVertical * 3,
                // ),

                // inspection interval
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     Text(
                //       'Inspections interval:',
                //       style: TextStyle(
                //         fontSize: SizeConfig.blockSizeHorizontal * 4,
                //         color: Theme.of(context).textTheme.headline6!.color,
                //       ),
                //     ),
                //     DropdownButton<String>(
                //       borderRadius: BorderRadius.circular(10),
                //       value: _inspectionInterval,
                //       icon: const Icon(Icons.keyboard_arrow_down_rounded),
                //       iconSize: SizeConfig.blockSizeHorizontal * 4,
                //       alignment: Alignment.center,
                //       elevation: 16,
                //       style: TextStyle(
                //         color: Colors.green,
                //         fontSize: SizeConfig.blockSizeHorizontal * 4,
                //       ),
                //       underline: Container(height: 0),
                //       onChanged: (String? newValue) {
                //         setState(() {
                //           _inspectionInterval = newValue!;
                //         });
                //       },
                //       dropdownColor:
                //           Theme.of(context).appBarTheme.backgroundColor,
                //       items: <String>[
                //         '2 years',
                //         '1 year',
                //         '6 months',
                //         '3 months',
                //         '1 month',
                //         '2 weeks',
                //         '1 week',
                //       ].map<DropdownMenuItem<String>>((String value) {
                //         return DropdownMenuItem<String>(
                //           value: value,
                //           child: Text(value),
                //         );
                //       }).toList(),
                //     ),
                //   ],
                // ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
