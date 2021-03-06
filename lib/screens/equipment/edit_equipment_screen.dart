import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';

class EditEquipmentScreen extends StatefulWidget {
  const EditEquipmentScreen({Key? key}) : super(key: key);

  static const routeName = '/edit_equipment';

  @override
  _EditEquipmentScreenState createState() => _EditEquipmentScreenState();
}

class _EditEquipmentScreenState extends State<EditEquipmentScreen>
    with SingleTickerProviderStateMixin, ResponsiveSize {
  final _formKey = GlobalKey<FormState>();
  late Item _item;

  String _internalId = '';
  String _producer = '';
  String _model = '';
  String _category = '';
  String _location = '';
  String _comments = '';

  @override
  void didChangeDependencies() {
    // get passed to this screen Item object
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
          location: _location,
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
    SizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit asset'),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        actions: [
          IconButton(
              onPressed: _editEquipment,
              icon: const Icon(
                Icons.save,
                size: 32,
              )),
          const SizedBox(
            width: 10,
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
              Colors.white10,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: AnimatedPadding(
            padding: EdgeInsets.only(
              left: responsiveSizePct(small: 10, medium: 20),
              right: responsiveSizePct(small: 10, medium: 20),
              top: responsiveSizePx(small: 20, medium: 70),
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
                        size: responsiveSizePct(small: 20),
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        height: responsiveSizePx(small: 30, medium: 40),
                      ),
                      // internal id
                      TextFormField(
                        initialValue: _item.internalId,
                        key: const ValueKey('internalId'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).splashColor,
                          labelText: 'Internal id',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
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
                        height: responsiveSizePx(small: 24, medium: 36),
                      ),
                      // producer
                      TextFormField(
                        initialValue: _item.producer,
                        key: const ValueKey('producer'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 20,
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
                        height: responsiveSizePx(small: 24, medium: 36),
                      ),
                      // model
                      TextFormField(
                        initialValue: _item.model,
                        key: const ValueKey('model'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 20,
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
                        height: responsiveSizePx(small: 24, medium: 36),
                      ),
                      //catergory
                      TextFormField(
                        initialValue: _item.category,
                        key: const ValueKey('category'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 20,
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
                        height: responsiveSizePx(small: 24, medium: 36),
                      ),
                      //location
                      TextFormField(
                        initialValue: _item.location,
                        key: const ValueKey('location'),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).splashColor,
                          labelText: 'Asset location',
                        ),
                        validator: (val) {
                          if (val!.length < 2) {
                            return 'Asset to short';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _location = value!;
                        },
                      ),
                      SizedBox(
                        height: responsiveSizePx(small: 24, medium: 36),
                      ),
                      // comments
                      TextFormField(
                        maxLines: null,
                        initialValue: _item.comments,
                        key: const ValueKey('comments'),
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 20,
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
                    ],
                  ),
                ),
                SizedBox(
                  height: responsiveSizePx(small: 24, medium: 36),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
