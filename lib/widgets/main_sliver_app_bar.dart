import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/providers/user_provider.dart';

class MainSliverAppBar extends StatefulWidget {
  const MainSliverAppBar({Key? key}) : super(key: key);

  @override
  _MainSliverAppBarState createState() => _MainSliverAppBarState();
}

class _MainSliverAppBarState extends State<MainSliverAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      snap: false,
      floating: false,

      // title: const Text(
      //   'UnderControl',
      //   style: TextStyle(
      //     fontSize: 30,
      //     color: Colors.white,
      //   ),
      // ),
      // title: Text('UnderControl'),
      expandedHeight: MediaQuery.of(context).size.height * 0.15,
      actions: [
        TextButton.icon(
            onPressed: Provider.of<UserProvider>(context).signout,
            icon: Icon(Icons.logout),
            label: Text('Logout')),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'UnderControl',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        background: Opacity(
          opacity: 0.15,
          child: Image.asset(
            'assets/slivers/main_screen.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
