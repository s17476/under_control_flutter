import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
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
    with SingleTickerProviderStateMixin, ResponsiveSize {
  final _formKey = GlobalKey<FormState>();

  DateTime? _lastInspection;
  DateTime? _nextInspection;
  String _internalId = '';
  String _producer = '';
  String _model = '';
  String _category = '';
  String _location = '';
  String _comments = '';

  // add new asset
  Future<void> _addNewEquipment() async {
    if (_formKey.currentState != null) {
      // validate user input
      final isValid = _formKey.currentState!.validate();
      FocusScope.of(context).unfocus();

      // if user is valid
      if (isValid) {
        _formKey.currentState!.save();

        // set inspections interval
        _nextInspection = _lastInspection!;

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
          interval: '',
          inspectionStatus: 0,
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
              icon: const Icon(
                Icons.save,
                size: 40,
              )),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      // background
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
          child: AnimatedPadding(
            padding: EdgeInsets.only(
              left: responsiveSizePx(small: 24, medium: 60),
              right: responsiveSizePx(small: 24, medium: 60),
              top: responsiveSizePx(small: 20, medium: 50),
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
                        size: responsiveSizePx(small: 100, medium: 150),
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        height: responsiveSizePx(small: 30, medium: 50),
                      ),
                      // internal id
                      TextFormField(
                        key: const ValueKey('internalId'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 24,
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
                        height: responsiveSizePx(small: 20, medium: 40),
                      ),
                      // producer
                      TextFormField(
                        key: const ValueKey('producer'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 24,
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
                        height: responsiveSizePx(small: 20, medium: 40),
                      ),
                      // model
                      TextFormField(
                        key: const ValueKey('model'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 24,
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
                        height: responsiveSizePx(small: 20, medium: 40),
                      ),
                      //catergory
                      TextFormField(
                        key: const ValueKey('category'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 24,
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
                        height: responsiveSizePx(small: 20, medium: 40),
                      ),
                      //location
                      TextFormField(
                        key: const ValueKey('location'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 24,
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
                        height: responsiveSizePx(small: 20, medium: 40),
                      ),
                      // comments
                      TextFormField(
                        maxLines: null,
                        // expands: true,
                        key: const ValueKey('comments'),
                        keyboardType: TextInputType.multiline,
                        // textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 24,
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
                        height: responsiveSizePx(small: 20, medium: 40),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: responsiveSizePx(small: 20, medium: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
