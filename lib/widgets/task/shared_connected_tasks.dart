import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/widgets/task/shared_tasks_list.dart';
import 'package:under_control_flutter/widgets/task/tasks_list.dart';

class SharedConnectedTasks extends StatefulWidget {
  const SharedConnectedTasks(
      {Key? key, required this.context, required this.task})
      : super(key: key);

  final BuildContext context;
  final Task task;

  @override
  _SharedConnectedTasksState createState() => _SharedConnectedTasksState();
}

class _SharedConnectedTasksState extends State<SharedConnectedTasks> {
  var showTasks = false;
  Item? item;

  @override
  Widget build(BuildContext context) {
    item = Item(
        itemId: widget.task.itemId,
        model: '',
        category: '',
        inspectionStatus: 0,
        producer: '',
        lastInspection: DateTime.now(),
        internalId: '',
        nextInspection: DateTime.now(),
        location: '',
        interval: '');
    final buttonStyle = Theme.of(widget.context).textTheme.headline6!.copyWith(
        fontSize: SizeConfig.blockSizeHorizontal * 4.5,
        color: Theme.of(context).primaryColor);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: showTasks
                  ? TextButton.icon(
                      icon: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.green,
                        size: SizeConfig.blockSizeHorizontal * 8,
                      ),
                      onPressed: () {
                        setState(() {
                          showTasks = !showTasks;
                        });
                      },
                      label: Text(
                        'Hide connected tasks',
                        style: buttonStyle.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    )
                  : TextButton.icon(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.green,
                        size: SizeConfig.blockSizeHorizontal * 8,
                      ),
                      onPressed: () {
                        setState(() {
                          showTasks = !showTasks;
                        });
                      },
                      label: Text(
                        'Show connected tasks',
                        style: buttonStyle.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
            ),
            if (showTasks)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  'Done tasks',
                  style: TextStyle(
                      color: Theme.of(context).appBarTheme.foregroundColor),
                ),
              ),
          ],
        ),

        // if (showTasks)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: showTasks ? null : 0,

          // color: Colors.white12,
          child: Column(children: [
            const Divider(),
            SharedTasksList.item(item: item, task: widget.task),
          ]),
        ),
        // Divider(
        //   color: Theme.of(context).appBarTheme.backgroundColor,
        // ),
      ],
    );
  }
}
