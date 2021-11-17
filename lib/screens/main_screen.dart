import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/widgets/main_drawer.dart';

import 'package:under_control_flutter/widgets/main_sliver_app_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      //adds side drawer to the main screen
      drawer: const MainDrawer(),
      body: CustomScrollView(
        slivers: [
          const MainSliverAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(
                width: double.infinity,
                height: 4000,
              )
            ]),
          ),
        ],
      ),
    );
  }
}
