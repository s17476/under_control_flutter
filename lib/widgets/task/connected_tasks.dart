import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/widgets/task/tasks_list.dart';

class ConnectedTasks extends StatefulWidget {
  const ConnectedTasks({Key? key, required this.context, required this.item})
      : super(key: key);

  final BuildContext context;
  final Item item;

  @override
  _ConnectedTasksState createState() => _ConnectedTasksState();
}

class _ConnectedTasksState extends State<ConnectedTasks> with ResponsiveSize {
  var showTasks = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final buttonStyle = Theme.of(widget.context).textTheme.headline6!.copyWith(
        fontSize: responsiveSizePx(small: 18, medium: 30),
        color: Theme.of(context).primaryColor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
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
                          size: responsiveSizePx(small: 35, medium: 50),
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
                          size: responsiveSizePx(small: 35, medium: 50),
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
                  child: Builder(builder: (context) {
                    final taskProvider = Provider.of<TaskProvider>(context);
                    return TextButton(
                      onPressed: taskProvider.toggleIsActive,
                      child: taskProvider.isActive
                          ? Text(
                              'Active tasks',
                              style: TextStyle(
                                fontSize:
                                    responsiveSizePx(small: 18, medium: 30),
                              ),
                            )
                          : Text(
                              'Done tasks',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize:
                                    responsiveSizePx(small: 18, medium: 30),
                              ),
                            ),
                    );
                  }),
                ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showTasks ? null : 0,
            child: Column(children: [
              const Divider(),
              TasksList.item(item: widget.item),
            ]),
          ),
        ],
      ),
    );
  }
}
