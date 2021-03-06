import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/inspection_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/start/status_icon.dart';

class InspectionsList extends StatefulWidget {
  const InspectionsList({Key? key, required this.context, required this.item})
      : super(key: key);

  final BuildContext context;
  final Item item;

  @override
  _InspectionsListState createState() => _InspectionsListState();
}

class _InspectionsListState extends State<InspectionsList> with ResponsiveSize {
  var showInspections = false;

  @override
  void initState() {
    Provider.of<InspectionProvider>(context, listen: false)
        .fetchByItem(widget.item);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final buttonStyle = Theme.of(widget.context).textTheme.headline6!.copyWith(
        fontSize: responsiveSizePx(small: 18, medium: 30),
        color: Theme.of(context).primaryColor);
    final userProvider = Provider.of<UserProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: showInspections
                ? TextButton.icon(
                    icon: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.green,
                      size: responsiveSizePx(small: 35, medium: 50),
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
                      size: responsiveSizePx(small: 35, medium: 50),
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
              ...Provider.of<InspectionProvider>(context)
                  .inspections
                  .map((insp) {
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
                                                    vertical: 2),
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
                                size: responsiveSizePx(small: 40, medium: 55),
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
      ),
    );
  }
}
