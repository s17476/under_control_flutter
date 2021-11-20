import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/screens/calendar_screen.dart';
import 'package:under_control_flutter/screens/dash_screen.dart';
import 'package:under_control_flutter/screens/equipment_screen.dart';
import 'package:under_control_flutter/screens/overview_screen.dart';
import 'package:under_control_flutter/screens/tasks_screen.dart';

class BottomNaviBar extends StatelessWidget {
  const BottomNaviBar(
      {Key? key,
      required this.selectPage,
      required this.isBottomNavBarVisible,
      required this.selectedPageIndex})
      : super(key: key);

  final Function(int)? selectPage;
  final bool isBottomNavBarVisible;
  final int selectedPageIndex;

  //list of bottom navigation options
  static const List<Map<String, Object>> tabs = [
    {
      'page': TasksScreen(),
      'title': 'Tasks',
      'icon': Icon(Icons.task_alt),
      'background': 'assets/slivers/main_screen.jpg',
    },
    {
      'page': EquipmentScreen(),
      'title': 'Equipment',
      'icon': Icon(Icons.handyman),
      'background': 'assets/slivers/main_screen.jpg',
    },
    {
      'page': DashScreen(),
      'title': 'Dash',
      'icon': Icon(Icons.home),
      'background': 'assets/slivers/dash_screen.jpg',
    },
    {
      'page': CalendarScreen(),
      'title': 'Calendar',
      'icon': Icon(Icons.today),
      'background': 'assets/slivers/main_screen.jpg',
    },
    {
      'page': OverviewScreen(),
      'title': 'Overview',
      'icon': Icon(Icons.query_stats),
      'background': 'assets/slivers/main_screen.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      height: isBottomNavBarVisible ? SizeConfig.blockSizeVertical * 7 : 0,
      child: Wrap(
        children: [
          BottomNavigationBar(
            onTap: selectPage,
            items: tabs
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: item['icon'] as Icon,
                    label: item['title'] as String,
                    backgroundColor: Theme.of(context)
                        .bottomNavigationBarTheme
                        .backgroundColor,
                  ),
                )
                .toList(),
            currentIndex: selectedPageIndex,
          ),
        ],
      ),
    );
  }
}
