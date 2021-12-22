import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';
import 'package:under_control_flutter/providers/company_provider.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/screens/equipment/add_equipment_screen.dart';
import 'package:under_control_flutter/widgets/bottom_navi_bar.dart';
import 'package:under_control_flutter/widgets/main_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late ScrollController _scrollController;
  late bool _isBottomNavBarVisible;

  int _selectedPageIndex = 2;

  String dropdownValue = "Company";
  List<String> dropdownItems = ['Company', 'Mine', 'All'];

  @override
  initState() {
    super.initState();

    // initialize providers
    Provider.of<TaskProvider>(context, listen: false).fetchAndSetTasks();

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
    CompanyProvider companyProvider = Provider.of<CompanyProvider>(context);
    // print(companyProvider.company);

    return Scaffold(
      drawer: const MainDrawer(),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // app bar
            SliverAppBar(
              title: Text(
                BottomNaviBar.tabs[_selectedPageIndex]['title'] as String,
              ),
              actions: [
                // chat icon in dashboard screen
                if (_selectedPageIndex == 2)
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chat)),
                // show by category icon in assets screen
                if (_selectedPageIndex == 1)
                  IconButton(
                    onPressed: () {
                      final itemProvider =
                          Provider.of<ItemProvider>(context, listen: false);
                      itemProvider
                        ..setShowCategories = false
                        ..toggleDescendning()
                        ..fetchAndSetItems();
                    },
                    icon: const Icon(Icons.checklist_rtl),
                  ),
                SizedBox(
                  width:
                      SizeConfig.blockSizeHorizontal * _selectedPageIndex != 1
                          ? 4
                          : 1,
                ),
                // avatar in dashboard screen
                if (_selectedPageIndex == 2)
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor,
                    backgroundImage: NetworkImage(userProvider.user!.userImage),
                    maxRadius: SizeConfig.blockSizeHorizontal * 4,
                  ),
                // show by status button in assets screen
                if (_selectedPageIndex == 1)
                  IconButton(
                    onPressed: () {
                      final itemProvider =
                          Provider.of<ItemProvider>(context, listen: false);
                      // if (!itemProvider.showCategories) {
                      itemProvider
                        ..setShowCategories = true
                        ..toggleDescendning()
                        ..fetchAndSetItems();
                      // }
                    },
                    icon: const Icon(Icons.category),
                  ),
                SizedBox(
                  width:
                      SizeConfig.blockSizeHorizontal * _selectedPageIndex != 1
                          ? 4
                          : 1,
                ),

                // show add button in tasks and assets screen
                if (_selectedPageIndex == 1 || _selectedPageIndex == 0)
                  IconButton(
                    onPressed:
                        // in assets screen
                        _selectedPageIndex == 1
                            ? () {
                                Navigator.of(context)
                                    .push(_createRute(
                                        () => const AddEquipmentScreen()))
                                    .then((value) {
                                  if (value != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Item successcul added'),
                                      ),
                                    );
                                  }
                                });
                              }
                            // in tasks screen
                            //TODO uuuuuuuuuuuuuuuuussssssssssseeeeeeeeeeeerrrrrrrrrrr
                            : () {
                                Provider.of<TaskProvider>(context,
                                        listen: false)
                                    .addTask(
                                  Task(
                                    title: 'title reaireee',
                                    date: DateTime.now(),
                                    description:
                                        'descriptionfdsg sdg dsg  sdfg dsfg dgfsdsg dsgfh hggfd hdgf h fdh fg hfdg h fdg h gdfhdfhdfh dfh dfh ',
                                    comments: 'comments',
                                    executor: TaskExecutor.company,
                                    userId: userProvider.user!.userId,
                                    status: TaskStatus.planned,
                                    type: TaskType.reparation,
                                    itemId: '8ltQaK3lxRfBmBL3vUba',
                                  ),
                                );
                              },
                    icon: Icon(
                      Icons.add,
                      size: SizeConfig.blockSizeVertical * 5,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal * 4,
                ),
                // show in calendar
                if (_selectedPageIndex == 3 || _selectedPageIndex == 0)
                  Padding(
                    padding: EdgeInsets.only(
                      top: SizeConfig.safeBlockHorizontal * 1.5,
                      right: SizeConfig.blockSizeHorizontal * 3,
                    ),
                    child: DropdownButton<String>(
                      alignment: AlignmentDirectional.center,
                      underline: Container(),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                      value: dropdownValue,
                      // style: TextStyle(color: Colors.white),
                      items: dropdownItems.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Center(
                            child: Text(
                              value,
                              // textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                              ),
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
                            TaskExecutor
                                .values[dropdownItems.indexOf(dropdownValue)];
                      },
                      dropdownColor: Colors.black,
                    ),
                  )
              ],
              pinned: false,
              floating: true,
              snap: true,
            ),
          ];
        },
        body: BottomNaviBar.tabs[_selectedPageIndex]['page'] as Widget,
      ),
      bottomNavigationBar: BottomNaviBar(
        selectPage: _selectPage,
        isBottomNavBarVisible: _isBottomNavBarVisible,
        selectedPageIndex: _selectedPageIndex,
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
