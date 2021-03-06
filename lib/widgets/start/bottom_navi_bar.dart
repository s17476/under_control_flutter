import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/screens/calendar/calendar_screen.dart';
import 'package:under_control_flutter/screens/dash_screen.dart';
import 'package:under_control_flutter/screens/equipment/equipment_screen.dart';
import 'package:under_control_flutter/screens/overview_screen.dart';
import 'package:under_control_flutter/screens/tasks/tasks_screen.dart';

class BottomNaviBar extends StatelessWidget with ResponsiveSize {
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
      'page': CalendarScreen(),
      'title': 'Calendar',
      'icon': Icon(Icons.today),
      'background': 'assets/slivers/main_screen.jpg',
    },
    {
      'page': DashScreen(),
      'title': 'Dash',
      'icon': Icon(Icons.home),
      'background': 'assets/slivers/dash_screen.jpg',
    },
    {
      'page': EquipmentScreen(),
      'title': 'Assets',
      'icon': Icon(Icons.handyman),
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
      duration: const Duration(milliseconds: 300),
      height:
          isBottomNavBarVisible ? responsiveSizePx(small: 55, medium: 90) : 0,
      child: Wrap(
        children: [
          BottomNavigationBar(
            iconSize: responsiveSizePx(small: 28, medium: 50),
            selectedLabelStyle:
                TextStyle(fontSize: SizeConfig.isSmallScreen ? 14 : 25),
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
