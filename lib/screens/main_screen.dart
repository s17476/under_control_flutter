import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/company_provider.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/screens/add_equipment_screen.dart';
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

  @override
  initState() {
    super.initState();

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
            SliverAppBar(
              title: Text(
                BottomNaviBar.tabs[_selectedPageIndex]['title'] as String,
              ),
              actions: [
                if (_selectedPageIndex != 1)
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chat)),
                if (_selectedPageIndex == 1)
                  IconButton(
                    onPressed: () {
                      final itemProvider =
                          Provider.of<ItemProvider>(context, listen: false);
                      // if (itemProvider.showCategories) {
                      itemProvider
                        ..setShowCategories = false
                        ..toggleDescendning()
                        ..fetchAndSetItems();
                      // }

                      // setState(() {
                      //   _selectedPageIndex = 1;
                      // });
                    },
                    icon: const Icon(Icons.checklist_rtl),
                  ),
                SizedBox(
                  width:
                      SizeConfig.blockSizeHorizontal * _selectedPageIndex != 1
                          ? 4
                          : 1,
                ),
                if (_selectedPageIndex != 1)
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor,
                    backgroundImage: NetworkImage(userProvider.user!.userImage),
                    maxRadius: SizeConfig.blockSizeHorizontal * 4,
                  ),
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

                // show add button for task and equipment screen
                if (_selectedPageIndex == 1)
                  IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(AddEquipmentScreen.routeName)
                          .then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item successcul added'),
                          ),
                        );
                      });
                      // try {
                      //   Provider.of<ItemProvider>(context, listen: false)
                      //       .addNewItem(
                      //     Item(
                      //       internalId: 'B1',
                      //       producer: 'Bosh',
                      //       model: 'Turbo1000',
                      //       category: 'power tool',
                      //       lastInspection: DateTime.now(),
                      //       interval: 12,
                      //       inspectionStatus: InspectionStatus.ok.index,
                      //     ),
                      //   );
                      // } catch (error) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text(error as String),
                      //     ),
                      //   );
                      // }
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
}
