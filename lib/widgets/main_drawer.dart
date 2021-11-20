import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/logo_widget.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Drawer(
      child: Column(
        children: [
          //logo container
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            height: SizeConfig.blockSizeVertical * 14,
            width: double.infinity,
            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 7.5),
            child: const Logo(greenLettersSize: 7, whitheLettersSize: 5.5),
          ),
          //menu content
          Expanded(
            child: Container(
              color: Theme.of(context).popupMenuTheme.color,
              // height: double.infinity,
              // width: double.infinity,
              padding: EdgeInsets.only(
                top: SizeConfig.blockSizeVertical * 7,
                left: SizeConfig.blockSizeHorizontal * 5,
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: userProvider.signout,
                    icon: Icon(
                      Icons.logout,
                      color: Theme.of(context).errorColor,
                    ),
                    label: Text(
                      'Logout',
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.symmetric(
                      // horizontal: SizeConfig.blockSizeVertical * 2,
                      vertical: SizeConfig.blockSizeHorizontal * 2,
                    ),
                    child: TextButton.icon(
                      onPressed: userProvider.signout,
                      icon: Icon(
                        Icons.logout,
                        color: Theme.of(context).errorColor,
                      ),
                      label: Text(
                        'Logout',
                        style: TextStyle(color: Theme.of(context).errorColor),
                      ),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
