import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/task.dart';

class CalendarEventsList extends StatelessWidget {
  const CalendarEventsList({
    Key? key,
    required this.selectedEvents,
  }) : super(key: key);

  final List<Color?> darkTheme = const [
    Colors.blue,
    Colors.indigo,
    Colors.red,
    Colors.green,
  ];

  final List<IconData> eventIcons = const [
    Icons.event,
    Icons.search_outlined,
    Icons.handyman_outlined,
    Icons.health_and_safety_outlined,
  ];

  // events to show
  final ValueNotifier<List<Task>> selectedEvents;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<List<Task>>(
        valueListenable: selectedEvents,
        builder: (context, value, _) {
          // return list of events for selected day
          return value.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      // height: SizeConfig.blockSizeHorizontal * 15,
                      margin: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockSizeHorizontal * 2,
                        vertical: SizeConfig.blockSizeHorizontal * 0.8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: darkTheme[value[index].type.index]!,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        onTap: () => print('${value[index]}'),
                        leading: Container(
                          width: SizeConfig.blockSizeHorizontal * 13,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14.0),
                              bottomLeft: Radius.circular(14.0),
                            ),
                            // borderRadius: BorderRadius.circular(15.0),
                            color: darkTheme[value[index].type.index]!,
                          ),
                          child: Center(
                            child: Icon(
                              eventIcons[value[index].type.index],
                              color: Colors.white,
                              size: SizeConfig.blockSizeHorizontal * 9,
                            ),
                          ),
                        ),
                        title: Text('${value[index].title}'),
                      ),
                    );
                  },
                )
              : Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 5),
                  child: const Text("No events for the selected date"),
                );
        },
      ),
    );
  }
}
