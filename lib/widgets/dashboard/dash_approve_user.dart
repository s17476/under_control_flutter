import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/providers/user_provider.dart';

class DashApproveUser extends StatefulWidget {
  const DashApproveUser({Key? key}) : super(key: key);

  @override
  State<DashApproveUser> createState() => _DashApproveUserState();
}

class _DashApproveUserState extends State<DashApproveUser> with ResponsiveSize {
  List<AppUser?> usersToApprove = [];

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false)
        .fetchAndSetUsersToApprove();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle cardTextStyle = Theme.of(context).textTheme.headline6!.copyWith(
          fontSize: responsiveSizePx(small: 16, medium: 22),
          color: Theme.of(context).appBarTheme.foregroundColor,
        );
    usersToApprove = Provider.of<UserProvider>(context).usersToApprove;
    List<Widget> usersToApproveCards = [];
    return Builder(builder: (context) {
      for (var user in usersToApprove) {
        usersToApproveCards.add(
          Card(
            color: Theme.of(context).splashColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            margin: const EdgeInsets.only(
              right: 16,
              left: 16,
              top: 16,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    'Approve user',
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontSize: responsiveSizePx(small: 18, medium: 30),
                        color: Theme.of(context).primaryColor),
                  ),
                  const Divider(),
                  // avatar
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor,
                    backgroundImage: NetworkImage(user!.userImage),
                    maxRadius: responsiveSizePct(small: 30),
                  ),
                  const SizedBox(height: 12),
                  // name
                  Text(
                    user.userName,
                    style: cardTextStyle,
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // rteject button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            usersToApprove.remove(user);
                          });
                          Provider.of<UserProvider>(context, listen: false)
                              .rejectUser(user);
                        },
                        child: const Text(
                          'Reject',
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      ),
                      // approve button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            usersToApprove.remove(user);
                          });
                          Provider.of<UserProvider>(context, listen: false)
                              .approveUser(user);
                        },
                        child: const Text(
                          'Approve',
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Column(
        children: usersToApproveCards,
      );
    });
  }
}
