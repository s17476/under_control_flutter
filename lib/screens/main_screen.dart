import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          SliverAppBar(
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
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            const SizedBox(
              width: double.infinity,
              height: 4000,
            )
          ]))
        ],
      ),
    );
  }
}
