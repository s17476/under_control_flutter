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

  @override
  Widget build(BuildContext context) {
    _lastInspection ??= DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add asset'),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        // app bar buttons
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
      // background
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
