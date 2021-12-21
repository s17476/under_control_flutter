import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/screens/equipment/edit_equipment_screen.dart';
import 'package:under_control_flutter/widgets/inspections_list.dart';
import 'package:under_control_flutter/widgets/status_icon.dart';

class EquipmentDetailsScreen extends StatefulWidget {
  const EquipmentDetailsScreen({Key? key}) : super(key: key);

  static const routeName = '/equipment-details';

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  late Item item;

  Future<dynamic> _showDeleteDialog(
    BuildContext context,
    Item item,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm your choice'),
          content: SingleChildScrollView(
            child: Text(
              'Are you sure You want to delete \n ${item.producer} ${item.model}?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Theme.of(context).errorColor,
                  fontSize: SizeConfig.blockSizeVertical * 2.5,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(item);
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeVertical * 2.5,
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    var id = ModalRoute.of(context)!.settings.arguments as Item;
    item = Provider.of<ItemProvider>(context)
        .items
        .firstWhere((element) => element.itemId == id.itemId);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline6!.copyWith(
          fontSize: SizeConfig.blockSizeHorizontal * 4.5,
          color: Theme.of(context).primaryColor,
        );
    final expiredTextStyle = textStyle.copyWith(
      color: Theme.of(context).errorColor,
    );
    final labelTextStyle = Theme.of(context)
        .textTheme
        .headline6!
        .copyWith(fontSize: SizeConfig.blockSizeHorizontal * 3);
    // Item item = ModalRoute.of(context)!.settings.arguments as Item;
    var showTasks = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context)
                .pushNamed(EditEquipmentScreen.routeName, arguments: item)
                .then((value) {
              if (value != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item edited'),
                  ),
                );
              }
            }),
            icon: const Icon(Icons.edit),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 2,
          ),

          // delete button
          IconButton(
            onPressed: () {
              _showDeleteDialog(context, item).then((value) {
                if (value != null) {
                  Provider.of<ItemProvider>(context, listen: false)
                      .deleteItem(context, item.itemId);
                }
              });
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).errorColor,
            ),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 3,
          ),
        ],
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              // color: Colors.black,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              'Internal ID:',
                              style: labelTextStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              item.internalId,
                              style: textStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              'Producer:',
                              style: labelTextStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              item.producer,
                              style: textStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              'Model:',
                              style: labelTextStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              item.model,
                              style: textStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              'Category:',
                              style: labelTextStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              item.category,
                              style: textStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              'Comments:',
                              style: labelTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            'Inspection every:',
                            style: labelTextStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            item.interval,
                            style: textStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            'Last inspection:',
                            style: labelTextStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            DateFormat('dd/MMM/yyyy')
                                .format(item.lastInspection),
                            style: textStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            'Next inspection:',
                            style: labelTextStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            DateFormat('dd/MMM/yyyy')
                                .format(item.nextInspection),
                            style: item.inspectionStatus ==
                                    InspectionStatus.expired.index
                                ? expiredTextStyle
                                : textStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: StatusIcon(
                            inspectionStatus: item.inspectionStatus,
                            size:
                                (SizeConfig.blockSizeHorizontal * 1.5).toInt(),
                            textSize:
                                (SizeConfig.blockSizeHorizontal * 1.5).toInt(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      item.comments.isEmpty ? '------' : item.comments,
                      // overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.headline6!.color,
                        fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // add new inspection button
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
              top: SizeConfig.blockSizeHorizontal * 5,
              left: SizeConfig.blockSizeHorizontal * 4,
            ),
            child: TextButton.icon(
              label: Text(
                "Add new inspection",
                style:
                    TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4.5),
              ),
              onPressed: () {
                print("add new inspection");
              },
              icon: Container(
                // width: SizeConfig.blockSizeHorizontal * 14.5,
                alignment: Alignment.topRight,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal * 4),
                      child: Icon(
                        Icons.add,
                        size: SizeConfig.blockSizeHorizontal * 4.5,
                      ),
                    ),
                    Icon(
                      Icons.search,
                      size: SizeConfig.blockSizeHorizontal * 7,
                    )
                  ],
                ),
              ),
            ),
          ),
          // add new task
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
              top: SizeConfig.blockSizeHorizontal,
              left: SizeConfig.blockSizeHorizontal * 4,
            ),
            child: TextButton.icon(
              label: Text(
                "Add new task",
                style:
                    TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4.5),
              ),
              onPressed: () {
                print("add new task");
              },
              icon: Container(
                padding: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal * 1,
                  right: SizeConfig.blockSizeHorizontal * 1.5,
                ),
                // width: SizeConfig.blockSizeHorizontal * 14.5,
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.add_task,
                  size: SizeConfig.blockSizeHorizontal * 6,
                ),
              ),
            ),
          ),
          InspectionsList(context: context, item: item),
        ],
      ),
    );
  }
}
