import 'package:flutter/material.dart';

class InitializeWentWrong extends StatelessWidget {
  const InitializeWentWrong({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 100,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Something went wrong! Please try again later',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
