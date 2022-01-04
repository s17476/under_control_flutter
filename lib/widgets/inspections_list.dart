import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/inspection_provider.dart';
import 'package:under_control_flutter/widgets/status_icon.dart';

class InspectionsList extends StatefulWidget {
  const InspectionsList({Key? key, required this.context, required this.item})
      : super(key: key);

  final BuildContext context;
  final Item item;

  @override
  _InspectionsListState createState() => _InspectionsListState();
}

class _InspectionsListState extends State<InspectionsList> {
  var showInspections = false;

  @override
  void initState() {
    Provider.of<InspectionProvider>(context, listen: false)
        .fetchByItem(widget.item);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = Theme.of(widget.context).textTheme.headline6!.copyWith(
        fontSize: SizeConfig.blockSizeHorizontal * 4.5,
        color: Theme.of(context).primaryColor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            // padding: EdgeInsets.symmetric(
            // vertical: SizeConfig.blockSizeHorizontal * 4,
            // ),
            child: showInspections
                ? TextButton.icon(
                    icon: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.green,
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
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.green,
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

          // if (showInspections)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showInspections ? null : 0,

            // color: Colors.white12,
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
                                                    vertical: 2),
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
                    const Divider(),
                  ],
                );

                //   subtitle: Column(
                //     children: [
                //
                //

                //       // TODO
                //     ],
                //   ),
                // );
              }),
            ]),
          ),
          // Divider(
          //   color: Theme.of(context).appBarTheme.backgroundColor,
          // ),
        ],
      ),
    );
  }
}
