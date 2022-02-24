import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/start/logo_widget.dart';

class AwaitApprovalScreen extends StatelessWidget {
  const AwaitApprovalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
        ],
      ),
    );
  }
}
