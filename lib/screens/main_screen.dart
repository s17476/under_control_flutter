import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            snap: true,
            floating: true,
            centerTitle: true,
            title: const Text(
              'UnderControl',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            // title: Text('UnderControl'),
            expandedHeight: MediaQuery.of(context).size.height * 0.15,

            flexibleSpace: FlexibleSpaceBar(
              // title: const Text(
              //   'UnderControl',
              //   style: TextStyle(
              //     // fontSize: 50,
              //     color: Colors.white,
              //   ),
              // ),
              background: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/slivers/main_screen.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              width: double.infinity,
              height: 4000,
            )
          ]))
        ],
      ),
    );
  }
}
