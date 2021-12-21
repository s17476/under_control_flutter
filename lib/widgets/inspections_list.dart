import 'package:flutter/material.dart';
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
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.blockSizeHorizontal * 4,
          ),
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
                    'Hide inspections',
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
                    'Show inspections',
                    style: buttonStyle.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),

        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: showInspections ? 100 : 0,
          color: Colors.white12,
          child: ListView(children: [
            ...Provider.of<InspectionProvider>(context).inspections.map((insp) {
              return ListTile(
                title: Text(insp.date.toString()),
              );
            }),
          ]),
        ),
        // Divider(
        //   color: Theme.of(context).appBarTheme.backgroundColor,
        // ),
      ],
    );
  }
}
