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

  // inits tasks and calendar parameters
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

  // gets all tasks for a date
  List<Task> _getEventsForDay(DateTime day) {
    final date = DateFormat('dd/MM/yyyy').format(day);

    // filters tasks by executor
    List<Task> shownEvents;
    if (_eventList[date] != null) {
      if (executor == TaskExecutor.company) {
        shownEvents = _eventList[date]!.where((event) {
          return event.executor == executor;
        }).toList();
      } else if (executor == TaskExecutor.shared) {
        shownEvents = _eventList[date]!.where((event) {
          return event.executor == executor;
        }).toList();
      } else if (executor == TaskExecutor.user) {
        shownEvents = _eventList[date]!.where((event) {
          return (event.executor == executor &&
              event.executorId ==
                  Provider.of<UserProvider>(context).user!.userId);
        }).toList();
      } else {
        shownEvents = _eventList[date]!;
      }
    } else {
      shownEvents = [];
    }

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
    // get data from provider and set listeners
    TaskProvider taskProvider = Provider.of<TaskProvider>(context);
    _eventList = taskProvider.getAllTasks;
    executor = taskProvider.executor;
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
    return Column(
      children: [
        // calendar widget
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
            // monday to friday style
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
            // today marker style
            todayBuilder: (context, day, focusedDay) {
              return Center(
                  child: CircleAvatar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                child: Text(
                  day.day.toString(),
                ),
              ));
            },
            // selected day marker style
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
                  // badge with events count for date
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
        // events list widget
        CalendarEventsList(selectedEvents: _selectedEvents),
      ],
    );
  }
}
