import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/widgets/main_sliver_app_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              alignment: Alignment.centerLeft,
              color: Theme.of(context).colorScheme.secondary,
              child: Text('Cooking up!',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
            const SizedBox(
              height: 50,
            ),
            TextButton.icon(
              onPressed: FirebaseAuth.instance.signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            )
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          MainSliverAppBar(),
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
