import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/calendar_event_list/calendar_events_list.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  var executor = TaskExecutor.all;

  Map<String, List<Task>> _eventList = {};

  late final ValueNotifier<List<Task>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _eventList = Provider.of<TaskProvider>(context, listen: false).getAllTasks;
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Task> _getEventsForDay(DateTime day) {
    final date = DateFormat('dd/MM/yyyy').format(day);

    List<Task> shownEvents;
    if (_eventList[date] != null) {
      if (executor == TaskExecutor.company) {
        shownEvents = _eventList[date]!.where((event) {
          return event.executor == executor;
        }).toList();
        // print('to show ${shownEvents.length}');
      } else if (executor == TaskExecutor.shared) {
        shownEvents = _eventList[date]!.where((event) {
          return event.executor == executor;
        }).toList();
        // print('to show ${shownEvents.length}');
      } else if (executor == TaskExecutor.user) {
        shownEvents = _eventList[date]!.where((event) {
          return (event.executor == executor &&
              event.executorId ==
                  Provider.of<UserProvider>(context).user!.userId);
        }).toList();
        // print('to show ${shownEvents.length}');
      } else {
        shownEvents = _eventList[date]!;
      }
    } else {
      shownEvents = [];
    }

    // print("getevents $date, ${_eventList[date]}");
    return shownEvents..sort((a, b) => a.type.index.compareTo(b.type.index));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  void _onFormatChanged(format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TaskProvider taskProvider = Provider.of<TaskProvider>(context);
    _eventList = taskProvider.getAllTasks;
    print(
        "build ..................................... ${_eventList.keys}, $_selectedDay");
    executor = Provider.of<TaskProvider>(context).executor;
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          eventLoader: (day) {
            return _getEventsForDay(day);
          },
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            leftChevronIcon: Icon(
              Icons.arrow_back_ios_sharp,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            rightChevronIcon: Icon(
              Icons.arrow_forward_ios_sharp,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: _onDaySelected,
          onFormatChanged: _onFormatChanged,
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
            dowBuilder: (context, day) {
              if (day.weekday == DateTime.monday ||
                  day.weekday == DateTime.tuesday ||
                  day.weekday == DateTime.wednesday ||
                  day.weekday == DateTime.thursday ||
                  day.weekday == DateTime.friday) {
                final text = DateFormat.E().format(day);

                return Center(
                  child: Text(
                    text,
                    style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor),
                  ),
                );
              }
            },
            todayBuilder: (context, day, focusedDay) {
              return Center(
                  child: CircleAvatar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                child: Text(
                  day.day.toString(),
                ),
              ));
            },
            selectedBuilder: (context, day, focusedDay) {
              return Center(
                  child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  day.day.toString(),
                ),
              ));
            },
            outsideBuilder: (context, day, focusedDay) {
              return Center(
                  child: Text(
                day.day.toString(),
                style: TextStyle(color: Theme.of(context).splashColor),
              ));
            },
            markerBuilder: (context, day, events) {
              return events.isNotEmpty
                  ? Positioned(
                      right: 3,
                      top: 3,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Theme.of(context).appBarTheme.backgroundColor,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          events.length.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                  : null;
            },
          ),
        ),
        CalendarEventsList(selectedEvents: _selectedEvents),
      ],
    );
  }
}
