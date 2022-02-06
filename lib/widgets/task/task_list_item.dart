import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/company_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';

class TaskListItem extends StatelessWidget with ResponsiveSize {
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
    SizeConfig.init(context);
    bool isExpired = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).isAfter(task.date);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: responsiveSizePx(small: 3, medium: 6),
        horizontal: 8.0,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(responsiveSizePx(small: 15, medium: 30)),
        child: Container(
          color: Theme.of(context).splashColor,
          child: Row(
            children: <Widget>[
              Hero(
                tag: task.taskId!,
                child: Container(
                  color: darkTheme[task.type.index]!,
                  width: responsiveSizePx(small: 70, medium: 120),
                  height: task.executor == TaskExecutor.shared
                      ? responsiveSizePx(small: 90, medium: 160)
                      : responsiveSizePx(small: 70, medium: 130),
                  child: Icon(
                    eventIcons[task.type.index],
                    color: Colors.white,
                    size: responsiveSizePx(small: 50, medium: 90),
                  ),
                ),
              ),
              SizedBox(width: responsiveSizePx(small: 8, medium: 16)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: responsiveSizePx(small: 16, medium: 30),
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
                        height: responsiveSizePx(small: 4, medium: 8),
                      ),
                    if (task.location != null && task.location != '')
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).hintColor,
                                size: responsiveSizePx(small: 15, medium: 30),
                              ),
                              Text(
                                task.location!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize:
                                      responsiveSizePx(small: 14, medium: 22),
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
                                  size: responsiveSizePx(small: 15, medium: 30),
                                ),
                                Text(
                                  task.itemName!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize:
                                        responsiveSizePx(small: 14, medium: 22),
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
                                  size: responsiveSizePx(small: 15, medium: 30),
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
                                                fontSize: responsiveSizePx(
                                                    small: 14, medium: 22),
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
                              size: responsiveSizePx(small: 40, medium: 70),
                            )
                          //shared
                          : Icon(
                              Icons.share,
                              color:
                                  Theme.of(context).appBarTheme.foregroundColor,
                              size: responsiveSizePx(small: 40, medium: 70),
                            )
                      : Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).primaryColor,
                          size: responsiveSizePx(small: 40, medium: 70),
                        )

                  // task is done
                  : Icon(
                      Icons.done,
                      color: Theme.of(context).primaryColor,
                      size: responsiveSizePx(small: 40, medium: 70),
                    ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
