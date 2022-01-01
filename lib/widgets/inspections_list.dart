import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/inspection_provider.dart';

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
  void didChangeDependencies() {
    Provider.of<InspectionProvider>(context, listen: false)
        .fetchByItem(widget.item);
    super.didChangeDependencies();
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
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        showInspections = !showInspections;
                      });
                    },
                    label: Text(
                      'Hide inspections history',
                      style: buttonStyle.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  )
                : TextButton.icon(
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        showInspections = !showInspections;
                      });
                    },
                    label: Text(
                      'Show inspections history',
                      style: buttonStyle.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),

          // if (showInspections)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showInspections ? null : 0,

            // color: Colors.white12,
            child: ListView(shrinkWrap: true, children: [
              const Divider(),
              ...Provider.of<InspectionProvider>(context)
                  .inspections
                  .map((insp) {
                return Row(
                  children: [
                    Text(
                      DateFormat('dd/MMM/yyyy').format(insp.date),
                    ),
                    Column(
                      children: [
                        if (insp.comments != '') Text(insp.comments),
                        const Text('Checklist:'),
                        if (insp.checklist != null &&
                            insp.checklist!.fields.isNotEmpty)
                          for (var item in insp.checklist!.fields.keys)
                            Text('$item - ${insp.checklist!.fields[item]}'),
                      ],
                    )
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
