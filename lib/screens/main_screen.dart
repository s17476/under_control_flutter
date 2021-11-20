import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/bottom_navi_bar.dart';
import 'package:under_control_flutter/widgets/logo_widget.dart';
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

    //hide/show bottom navigation bar
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
    // UserProvider _userProvider = Provider.of<UserProvider>(context);
    // print(Provider.of<UserProvider>(context).user.toString() + 'xxxxx');
    return Scaffold(
      drawer: const MainDrawer(),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(
                  BottomNaviBar.tabs[_selectedPageIndex]['title'] as String),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.chat)),
                // GestureDetector(
                //   child: CircleAvatar(
                //     child: Image.network(_userProvider.user.userImage),
                //   ),
                // )
              ],
              pinned: false,
              floating: true,
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
