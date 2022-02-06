import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/screens/equipment/edit_equipment_screen.dart';
import 'package:under_control_flutter/screens/tasks/add_task_screen.dart';
import 'package:under_control_flutter/widgets/inspection/inspections_list.dart';
import 'package:under_control_flutter/widgets/start/status_icon.dart';
import 'package:under_control_flutter/widgets/task/connected_tasks.dart';

class EquipmentDetailsScreen extends StatefulWidget {
  const EquipmentDetailsScreen({Key? key}) : super(key: key);

  static const routeName = '/equipment-details';

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen>
    with ResponsiveSize {
  late Item item;

  // delete dialog
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
              child: const Text(
                'No',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(item);
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
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
    try {
      item = Provider.of<ItemProvider>(context)
          .items
          .firstWhere((element) => element.itemId == id.itemId);
    } catch (e) {}
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final textStyle = Theme.of(context)
        .textTheme
        .headline6!
        .copyWith(fontSize: responsiveSizePx(small: 18, medium: 22));
    final expiredTextStyle = textStyle.copyWith(
      color: Theme.of(context).errorColor,
    );
    final labelTextStyle = Theme.of(context)
        .textTheme
        .headline6!
        .copyWith(fontSize: responsiveSizePx(small: 12, medium: 14));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        actions: [
          // edit button
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
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          const SizedBox(
            width: 5,
          ),

          // delete button
          IconButton(
            onPressed: () {
              _showDeleteDialog(context, item).then((value) {
                if (value != null) {
                  Provider.of<ItemProvider>(context, listen: false)
                      .deleteItem(context, item.itemId);
                  var tasks = Provider.of<TaskProvider>(context, listen: false)
                      .getAllTasks;
                  for (var key in tasks.keys) {
                    for (var task in tasks[key]!) {
                      if (task.itemId == item.itemId) {
                        Provider.of<TaskProvider>(context, listen: false)
                            .deleteTask(task);
                      }
                    }
                  }
                  // update status
                  Provider.of<ItemProvider>(context, listen: false)
                      .fetchInspectionsStatus();
                }
              });
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).errorColor,
            ),
          ),
          const SizedBox(
            width: 15,
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
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: responsiveSizePct(small: 50, medium: 70),
                          // left column
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  'Internal ID',
                                  style: labelTextStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  item.internalId,
                                  style: textStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  'Producer',
                                  style: labelTextStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  item.producer,
                                  style: textStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  'Model',
                                  style: labelTextStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  item.model,
                                  style: textStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  'Category',
                                  style: labelTextStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  item.category,
                                  style: textStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  'Location',
                                  style: labelTextStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  item.location,
                                  style: textStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  'Comments',
                                  style: labelTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // right column
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                'Inspection every',
                                style: labelTextStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                item.interval,
                                style: textStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                'Last inspection',
                                style: labelTextStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                DateFormat('dd/MMM/yyyy')
                                    .format(item.lastInspection),
                                style: textStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                'Next inspection',
                                style: labelTextStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
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
                                heroTag: item.itemId!,
                                inspectionStatus: item.inspectionStatus,
                                size: responsiveSizePx(small: 70, medium: 100),
                                textSize: 18,
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
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline6!.color,
                            fontSize: responsiveSizePx(small: 18, medium: 22),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // add new task button
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(
                  left: 8,
                ),
                child: TextButton.icon(
                  label: Text(
                    "Add new task",
                    style: TextStyle(
                      fontSize: responsiveSizePx(small: 18, medium: 30),
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(
                      AddTaskScreen.routeName,
                      arguments: ['asset', item]),
                  icon: Container(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                    ),
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.add_task,
                      size: responsiveSizePx(small: 25, medium: 40),
                    ),
                  ),
                ),
              ),
              // inspections list
              InspectionsList(context: context, item: item),
              // list of connected with asset tasks
              ConnectedTasks(context: context, item: item),
            ],
          ),
        ),
      ),
    );
  }
}
