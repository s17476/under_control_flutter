import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/company_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';

class TaskListItem extends StatelessWidget {
  const TaskListItem({
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
    bool isExpired = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).isAfter(task.date);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3.0,
        horizontal: 8.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          color: Theme.of(context).splashColor,
          child: Row(
            children: <Widget>[
              Hero(
                tag: task.taskId!,
                child: Container(
                  color: darkTheme[task.type.index]!,
                  width: SizeConfig.blockSizeHorizontal * 16,
                  height: task.executor == TaskExecutor.shared
                      ? SizeConfig.blockSizeHorizontal * 22
                      : SizeConfig.blockSizeHorizontal * 18,
                  child: Icon(
                    eventIcons[task.type.index],
                    color: Colors.white,
                    size: SizeConfig.blockSizeHorizontal * 12,
                  ),
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
                        color: isExpired &&
                                Provider.of<TaskProvider>(context,
                                        listen: false)
                                    .isActive
                            ? Colors.red
                            : Colors.white,
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
                          //sahred with company
                          if (task.executor == TaskExecutor.shared)
                            Row(
                              children: [
                                Icon(
                                  Icons.share,
                                  color: Theme.of(context).hintColor,
                                  size: 15,
                                ),
                                task.executorId !=
                                        Provider.of<UserProvider>(context)
                                            .user!
                                            .companyId
                                    ? FutureBuilder(
                                        future: Provider.of<CompanyProvider>(
                                                context)
                                            .getCompanyById(task.executorId!),
                                        builder: (ctx, companyName) {
                                          if (companyName.hasData) {
                                            return Text(
                                              companyName.data as String,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            );
                                          }
                                          return SizedBox(
                                            width: 10,
                                            height: 10,
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          );
                                        })
                                    : FutureBuilder(
                                        future:
                                            Provider.of<UserProvider>(context)
                                                .getUserById(
                                                    context, task.userId),
                                        builder: (ctx, user) {
                                          if (user.hasData) {
                                            return Text(
                                              (user.data as AppUser).company!,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            );
                                          }
                                          return SizedBox(
                                            width: 10,
                                            height: 10,
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          );
                                        })
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

              //task is active
              Provider.of<TaskProvider>(context).isActive
                  ? task.executor == TaskExecutor.shared
                      ? task.executorId ==
                              Provider.of<UserProvider>(context).user!.companyId
                          //shared with me
                          ? Icon(
                              Icons.emoji_people,
                              color:
                                  Theme.of(context).appBarTheme.foregroundColor,
                              size: 40,
                            )
                          //shared
                          : Icon(
                              Icons.share,
                              color:
                                  Theme.of(context).appBarTheme.foregroundColor,
                              size: 40,
                            )
                      : Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).primaryColor,
                          size: 35,
                        )

                  // task is done
                  : Icon(
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
