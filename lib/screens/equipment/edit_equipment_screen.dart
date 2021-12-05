import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';

class EditEquipmentScreen extends StatefulWidget {
  const EditEquipmentScreen({Key? key}) : super(key: key);

  static const routeName = '/edit_equipment';

  @override
  _EditEquipmentScreenState createState() => _EditEquipmentScreenState();
}

class _EditEquipmentScreenState extends State<EditEquipmentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late Item _item; ////////////////

  String _internalId = '';
  String _producer = '';
  String _model = '';
  String _category = '';
  String _comments = '';

  @override
  void didChangeDependencies() {
    _item = ModalRoute.of(context)!.settings.arguments as Item;
    super.didChangeDependencies();
  }

  Future<Item?> _editEquipment() async {
    if (_formKey.currentState != null) {
      final isValid = _formKey.currentState!.validate();
      FocusScope.of(context).unfocus();

      if (isValid) {
        _formKey.currentState!.save();

        Item item = Item(
          itemId: _item.itemId,
          internalId: _internalId,
          producer: _producer,
          model: _model,
          category: _category,
          comments: _comments,
          lastInspection: _item.lastInspection,
          nextInspection: _item.nextInspection,
          interval: _item.interval,
          inspectionStatus: _item.inspectionStatus,
        );

        await Provider.of<ItemProvider>(context, listen: false)
            .updateItem(item)
            .then((_) => Navigator.of(context).pop(true))
            .catchError((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error while updating equipment'),
            ),
          );
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit equipment'),
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
                      initialValue: _item.internalId,
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
                        labelText: 'Internal id',
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        // focusColor: Colors.green,
                        // hoverColor: Colors.green,
                      ),
                      // cursorColor: Theme.of(context).primaryColor,
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
                      initialValue: _item.producer,
                      key: const ValueKey('producer'),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
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
                        labelText: 'Producer',
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
                      initialValue: _item.model,
                      key: const ValueKey('model'),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
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
                        labelText: 'Model',
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
                      initialValue: _item.category,
                      key: const ValueKey('category'),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
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
                        labelText: 'Category - ex. power tools, machine',
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
                      initialValue: _item.comments,
                      key: const ValueKey('comments'),
                      keyboardType: TextInputType.multiline,
                      // textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
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
                        labelText: 'Comments',
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
                height: SizeConfig.blockSizeVertical * 2,
              ),
              // save button
              ElevatedButton(
                onPressed: _editEquipment,
                child: Text(
                  'Save changes',
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
    );
  }
}
