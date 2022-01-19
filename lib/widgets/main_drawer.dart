import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/providers/chart_data_provider.dart';
import 'package:under_control_flutter/providers/checklist_provider.dart';
import 'package:under_control_flutter/providers/company_provider.dart';
import 'package:under_control_flutter/providers/inspection_provider.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/task_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/start/logo_widget.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  // logout function calls clear on all providers to reset all data
  // it results from optimization in terms of
  // the number of connections to the database
  void logout(BuildContext context, UserProvider userProvider) {
    Provider.of<CompanyProvider>(context, listen: false).clear();
    Provider.of<InspectionProvider>(context, listen: false).clear();
    Provider.of<ItemProvider>(context, listen: false).clear();
    Provider.of<TaskProvider>(context, listen: false).clear();
    Provider.of<ChecklistProvider>(context, listen: false).clear();
    Provider.of<ChartDataProvider>(context, listen: false).clear();
    userProvider.signout();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final companyProvider = Provider.of<CompanyProvider>(context);
    return Drawer(
      child: Column(
        children: [
          //logo container
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            height: SizeConfig.blockSizeVertical * 15,
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
                top: SizeConfig.blockSizeVertical * 3,
                left: SizeConfig.blockSizeHorizontal * 5,
                right: SizeConfig.blockSizeHorizontal * 5,
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).appBarTheme.backgroundColor,
                          backgroundImage:
                              NetworkImage(userProvider.user!.userImage),
                          maxRadius: SizeConfig.blockSizeHorizontal * 8,
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProvider.user!.userName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical,
                            ),
                            Text(
                              userProvider.user!.company!,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 10,
                        ),
                        // SizedBox(
                        //   width: SizeConfig.blockSizeHorizontal * 10,
                        // ),
                        Icon(
                          Icons.navigate_next,
                          size: SizeConfig.blockSizeVertical * 4,
                          color: Theme.of(context).textTheme.headline1!.color,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: SizeConfig.blockSizeVertical * 0.2,
                    // endIndent: SizeConfig.blockSizeHorizontal * 5,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.symmetric(
                        // horizontal: SizeConfig.blockSizeVertical * 2,
                        vertical: SizeConfig.blockSizeHorizontal * 2,
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          logout(context, userProvider);
                        },
                        icon: Icon(
                          Icons.logout,
                          color: Theme.of(context).textTheme.headline1!.color,
                          size: SizeConfig.blockSizeVertical * 4,
                        ),
                        label: Text(
                          'Logout',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline1!.color,
                            fontSize: SizeConfig.blockSizeVertical * 2.5,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
