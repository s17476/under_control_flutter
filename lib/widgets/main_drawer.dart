import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/widgets/logo_widget.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: SizeConfig.blockSizeVertical * 17,
            width: double.infinity,
            padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 2),
            alignment: Alignment.bottomLeft,
            color: Colors.black,
            child: const Logo(
              greenLettersSize: 11,
              whitheLettersSize: 8,
            ),
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
    );
  }
}
