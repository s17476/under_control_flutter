import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/inspection_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/start/status_icon.dart';

class SharedInspectionsList extends StatefulWidget {
  const SharedInspectionsList(
      {Key? key, required this.context, required this.task})
      : super(key: key);

  final BuildContext context;
  final Task task;

  @override
  _SharedInspectionsListState createState() => _SharedInspectionsListState();
}

class _SharedInspectionsListState extends State<SharedInspectionsList> {
  var showInspections = false;
  AppUser? taskCreator;

  @override
  void initState() {
    getTaskCreator();

    super.initState();
  }

  void getTaskCreator() async {
    taskCreator = await Provider.of<UserProvider>(context, listen: false)
        .getUserById(context, widget.task.userId);
    Provider.of<InspectionProvider>(context, listen: false)
        .fetchBySharedTask(widget.task, taskCreator!.companyId!);
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = Theme.of(widget.context).textTheme.headline6!.copyWith(
        fontSize: SizeConfig.blockSizeHorizontal * 4.5,
        color: Theme.of(context).primaryColor);
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: showInspections
              ? TextButton.icon(
                  icon: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.green,
                    size: SizeConfig.blockSizeHorizontal * 8,
                  ),
                  onPressed: () {
                    setState(() {
                      showInspections = !showInspections;
                    });
                  },
                  label: Text(
                    'Hide inspections history',
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
                      showInspections = !showInspections;
                    });
                  },
                  label: Text(
                    'Show inspections history',
                    style: buttonStyle.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: showInspections ? null : 0,
          child: Column(children: [
            const Divider(),
            ...Provider.of<InspectionProvider>(context).inspections.map((insp) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('dd').format(insp.date),
                            ),
                            Text(
                              DateFormat('MMM').format(insp.date),
                            ),
                            Text(
                              DateFormat('yyyy').format(insp.date),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Text('Checklist:'),
                              if (insp.checklist != null &&
                                  insp.checklist!.fields.isNotEmpty)
                                for (var item in insp.checklist!.fields.keys)
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item),
                                      insp.checklist!.fields[item] == true
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 2,
                                              ),
                                              child: CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.green,
                                                child: Icon(
                                                  Icons.done,
                                                  size: 25,
                                                ),
                                              ),
                                            )
                                          : const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 2,
                                              ),
                                              child: CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.red,
                                                child: Icon(
                                                  Icons.clear,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Text('Inspection'),
                            const Text('status'),
                            StatusIcon(
                              textSize: 0,
                              heroTag: insp.date.toIso8601String(),
                              size: 10,
                              inspectionStatus: insp.status,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Comments',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          insp.comments == '' ? '----' : insp.comments,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Done by',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 12),
                        ),
                        FutureBuilder(
                            future:
                                userProvider.getUserById(context, insp.user),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  (snapshot.data as AppUser).userName,
                                  style: const TextStyle(fontSize: 16),
                                );
                              } else {
                                return const Text('No data');
                              }
                            }),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              );
            }),
          ]),
        ),
      ],
    );
  }
}
