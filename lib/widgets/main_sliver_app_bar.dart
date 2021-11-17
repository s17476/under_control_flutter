import 'package:flutter/material.dart';

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
      snap: true,
      floating: true,

      // title: const Text(
      //   'UnderControl',
      //   style: TextStyle(
      //     fontSize: 30,
      //     color: Colors.white,
      //   ),
      // ),
      // title: Text('UnderControl'),
      expandedHeight: MediaQuery.of(context).size.height * 0.15,

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
