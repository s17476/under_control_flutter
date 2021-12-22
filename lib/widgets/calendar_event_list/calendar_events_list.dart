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

  final List<IconData> statusIcons = const [
    Icons.pending_actions_outlined,
    Icons.pending_outlined,
    Icons.done,
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
                  shrinkWrap: true,
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3.0, horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          // height: 50,
                          color: Theme.of(context).splashColor,
                          child: Row(
                            children: <Widget>[
                              Container(
                                color: darkTheme[value[index].type.index]!,
                                width: SizeConfig.blockSizeHorizontal * 15,
                                height: SizeConfig.blockSizeHorizontal * 15,
                                child: Icon(
                                  eventIcons[value[index].type.index],
                                  color: Colors.white,
                                  size: SizeConfig.blockSizeHorizontal * 9,
                                ),
                              ),
                              SizedBox(
                                  width: SizeConfig.blockSizeHorizontal * 3),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      value[index].title,
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 4,
                                        // fontWeight: FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                        height: SizeConfig.blockSizeHorizontal),
                                    Text(
                                      value[index].description,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                statusIcons[value[index].status.index],
                                color: Colors.white,
                                size: SizeConfig.blockSizeHorizontal * 9,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  color: Theme.of(context).primaryColor),
                              const SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        ),
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
