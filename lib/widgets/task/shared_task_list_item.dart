import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';

class SharedTaskListItem extends StatelessWidget {
  const SharedTaskListItem({
    Key? key,
    required this.task,
    required this.item,
  }) : super(key: key);

  final Task task;

  final Item? item;

  final List<Color?> darkTheme = const [
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.red,
  ];

  final List<IconData> eventIcons = const [
    Icons.health_and_safety_outlined,
    Icons.event,
    Icons.search_outlined,
    Icons.handyman_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3.0,
        horizontal: 8.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          // height: 50,
          color: Theme.of(context).splashColor,
          child: Row(
            children: <Widget>[
              Container(
                color: darkTheme[task.type.index]!,
                width: SizeConfig.blockSizeHorizontal * 16,
                height: SizeConfig.blockSizeHorizontal * 18,
                child: Icon(
                  eventIcons[task.type.index],
                  color: Colors.white,
                  size: SizeConfig.blockSizeHorizontal * 12,
                ),
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 4,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.location != null && task.location != '')
                      SizedBox(
                        height: SizeConfig.blockSizeHorizontal,
                      ),
                    if (task.location != null && task.location != '')
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).hintColor,
                                size: 15,
                              ),
                              Text(
                                task.location!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                          if (task.itemName != '')
                            Row(
                              children: [
                                Icon(
                                  Icons.handyman,
                                  color: Theme.of(context).hintColor,
                                  size: 15,
                                ),
                                Text(
                                  task.itemName!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Icon(
                Icons.done,
                color: Theme.of(context).primaryColor,
                size: 45,
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
