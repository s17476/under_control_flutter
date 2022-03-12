import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/start/logo_widget.dart';

class AwaitApprovalScreen extends StatelessWidget with ResponsiveSize {
  const AwaitApprovalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      body: RefreshIndicator(
        color: Colors.green,
        backgroundColor: Colors.black,
        onRefresh: () =>
            userProvider.initializeUser(context, userProvider.user!.userId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: responsiveSizeVerticalPct(small: 30),
              ),
              const Logo(greenLettersSize: 15, whitheLettersSize: 10),
              const SizedBox(
                height: 50,
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Awaiting approval by the administrator of your organization.',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                child: Text(
                  '${userProvider.user!.company}',
                  style: const TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Provider.of<UserProvider>(context, listen: false)
                      .changeCompany(context);
                },
                child: const Text(
                  'Change company',
                  style: TextStyle(fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              SizedBox(
                height: responsiveSizePct(small: 20),
              ),
              const Text('Pull down to refresh'),
              SizedBox(
                height: responsiveSizePct(small: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
