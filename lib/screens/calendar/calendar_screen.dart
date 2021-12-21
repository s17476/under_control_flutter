import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/models/task.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final ValueNotifier<List<Task>> _selectedEvents;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

////////////////////////////////////////////////fix
  List<Task> _getEventsForDay(DateTime day) {
    // Implementation example
    return [
      Task(
        title: "tytuł",
        date: DateTime.now(),
        description: "opis",
        comments: "komentarz",
        status: 0,
      )
    ];
    //  ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
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
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              print("selected $selectedDay");
              print("focused $focusedDay");
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
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
          ),
        ),
        Text(_focusedDay.toString())
      ],
    );
  }
}
