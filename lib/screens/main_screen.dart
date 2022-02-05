import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/date_calc.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/checklist_provider.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/screens/equipment/add_equipment_screen.dart';
import 'package:under_control_flutter/screens/tasks/add_task_screen.dart';
import 'package:under_control_flutter/widgets/start/bottom_navi_bar.dart';
import 'package:under_control_flutter/widgets/main_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with ResponsiveSize {
  late ScrollController _scrollController;
  late bool _isBottomNavBarVisible;

  DateTime preBackpress = DateTime.now();

  int _selectedPageIndex = 2;

  String dropdownValue = "All";

  // task executors filter options
  List<String> dropdownItems = [
    'Shared',
    'Company',
    'Mine',
    'All',
  ];

  @override
  initState() {
    super.initState();

    // initialize providers
    Provider.of<TaskProvider>(context, listen: false)
      ..fetchAndSetTasks()
      ..fetchAndSetCompletedTasks();
    Provider.of<ItemProvider>(context, listen: false)
      ..fetchAndSetItems()
      ..fetchInspectionsStatus();
    Provider.of<ChecklistProvider>(context, listen: false)
        .fetchAndSetChecklists();

    //hide and show bottom navigation bar while scrolling
    _isBottomNavBarVisible = true;
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (_isBottomNavBarVisible) {
            setState(() {
              _isBottomNavBarVisible = false;
            });
          }
        }
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!_isBottomNavBarVisible) {
            setState(() {
              _isBottomNavBarVisible = true;
            });
          }
        }
      });
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return WillPopScope(
      // double click to exit the app
      onWillPop: () async {
        final timegap = DateTime.now().difference(preBackpress);
        final cantExit = timegap >= const Duration(seconds: 2);
        preBackpress = DateTime.now();
        if (cantExit) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: const Text('Press Back button again to Exit'),
              duration: const Duration(seconds: 2),
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            ));
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        drawer: const MainDrawer(),
        body: SafeArea(
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                // app bar
                SliverAppBar(
                  iconTheme:
                      IconThemeData(color: Theme.of(context).primaryColor),
                  title: (_selectedPageIndex == 0 || _selectedPageIndex == 1)
                      ? const Text('')
                      : Text(
                          BottomNaviBar.tabs[_selectedPageIndex]['title']
                              as String,
                        ),
                  actions: [
                    // show toggle button in task and calendar screen
                    if (_selectedPageIndex == 0 || _selectedPageIndex == 1)
                      Builder(builder: (context) {
                        final taskProvider = Provider.of<TaskProvider>(context);
                        return TextButton(
                          onPressed: taskProvider.toggleIsActive,
                          child: taskProvider.isActive
                              ? const Text(
                                  'Active tasks',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                )
                              : const Text(
                                  'Done tasks',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.amber,
                                  ),
                                ),
                        );
                      }),

                    // show by category icon in assets screen
                    if (_selectedPageIndex == 3)
                      IconButton(
                        onPressed: () {
                          final itemProvider =
                              Provider.of<ItemProvider>(context, listen: false);
                          itemProvider
                            ..setShowCategories = false
                            ..toggleDescendning()
                            ..fetchAndSetItems();
                        },
                        icon: Icon(
                          Icons.checklist_rtl,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                      ),
                    if (_selectedPageIndex == 3) const SizedBox(width: 20),

                    // sort by status - button in assets screen
                    if (_selectedPageIndex == 3)
                      IconButton(
                        onPressed: () {
                          final itemProvider =
                              Provider.of<ItemProvider>(context, listen: false);
                          itemProvider
                            ..setShowCategories = true
                            ..toggleDescendning()
                            ..fetchAndSetItems();
                        },
                        icon: Icon(
                          Icons.category,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                      ),
                    if (_selectedPageIndex == 3) const SizedBox(width: 20),

                    // avatar in dashboard screen
                    if (_selectedPageIndex == 2)
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).appBarTheme.backgroundColor,
                        backgroundImage:
                            NetworkImage(userProvider.user!.userImage),
                        maxRadius: 20,
                      ),

                    // show in calendar and tasks screen
                    if (_selectedPageIndex == 1 || _selectedPageIndex == 0)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                        ),
                        child: DropdownButton<String>(
                          alignment: AlignmentDirectional.center,
                          underline: Container(),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                          value: dropdownValue,
                          items: dropdownItems.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Center(
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                            Provider.of<TaskProvider>(context, listen: false)
                                    .executor =
                                TaskExecutor.values[
                                    dropdownItems.indexOf(dropdownValue)];
                          },
                          dropdownColor: Colors.black,
                        ),
                      ),

                    // show add button in tasks and assets screen
                    if (_selectedPageIndex == 0 ||
                        _selectedPageIndex == 1 ||
                        _selectedPageIndex == 3)
                      IconButton(
                        onPressed:
                            // in assets screen
                            _selectedPageIndex == 3
                                ? () {
                                    Navigator.of(context)
                                        .push(_createRute(
                                            () => const AddEquipmentScreen()))
                                        .then((resultItem) {
                                      if (resultItem != null) {
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'New asset added!',
                                              ),
                                              backgroundColor: Theme.of(context)
                                                  .appBarTheme
                                                  .backgroundColor,
                                            ),
                                          );
                                        var tmpItem = resultItem as Item;
                                        Provider.of<TaskProvider>(context,
                                                listen: false)
                                            .addTask(
                                          Task(
                                            title:
                                                '${tmpItem.producer} ${tmpItem.model}',
                                            date: DateCalc.getNextDate(
                                              tmpItem.lastInspection,
                                              tmpItem.interval,
                                            )!,
                                            executor: TaskExecutor.company,
                                            userId: Provider.of<UserProvider>(
                                                    context,
                                                    listen: false)
                                                .user!
                                                .userId,
                                            description:
                                                'Periodic inspection. Auto-added.',
                                            comments: '',
                                            status: TaskStatus.planned,
                                            type: TaskType.inspection,
                                            itemId: tmpItem.itemId,
                                            itemName:
                                                '${tmpItem.producer} ${tmpItem.model}',
                                            location: tmpItem.location,
                                            taskInterval: tmpItem.interval,
                                            nextDate: DateCalc.getNextDate(
                                              tmpItem.nextInspection,
                                              tmpItem.interval,
                                            )!,
                                          ),
                                        );
                                        Provider.of<ItemProvider>(context,
                                                listen: false)
                                            .fetchInspectionsStatus();
                                      }
                                    }).catchError((e) {
                                      ScaffoldMessenger.of(context)
                                        ..removeCurrentSnackBar()
                                        ..showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Cancelled!',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                    });
                                  }
                                // in tasks screen
                                : Provider.of<TaskProvider>(context).isActive
                                    ? () {
                                        Navigator.of(context)
                                            .push(_createRute(
                                                () => const AddTaskScreen()))
                                            .then((value) {
                                          if (value != null) {
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    'New task added',
                                                  ),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .appBarTheme
                                                          .backgroundColor,
                                                ),
                                              );
                                          }
                                        });
                                      }
                                    : null,
                        icon: Icon(
                          Icons.add,
                          size: 40,
                          color: Provider.of<TaskProvider>(context).isActive ||
                                  _selectedPageIndex == 3
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).appBarTheme.backgroundColor,
                        ),
                      ),
                    SizedBox(
                      width: responsiveSizePx(small: 10, large: 20),
                    ),
                  ],
                  pinned: false,
                  floating: true,
                  snap: true,
                ),
              ];
            },
            body: BottomNaviBar.tabs[_selectedPageIndex]['page'] as Widget,
          ),
        ),
        bottomNavigationBar: BottomNaviBar(
          selectPage: _selectPage,
          isBottomNavBarVisible: _isBottomNavBarVisible,
          selectedPageIndex: _selectedPageIndex,
        ),
      ),
    );
  }

  Route<Object?> _createRute(Widget Function() widgetConstructor) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            widgetConstructor(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;

          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeIn));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }
}
