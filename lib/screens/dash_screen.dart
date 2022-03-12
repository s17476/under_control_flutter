import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/dashboard/dash_approve_user.dart';
import 'package:under_control_flutter/widgets/dashboard/dash_completed_tasks.dart';
import 'package:under_control_flutter/widgets/dashboard/dash_inspection_status_card.dart';
import 'package:under_control_flutter/widgets/dashboard/dash_task_status_card.dart';

class DashScreen extends StatelessWidget {
  const DashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.green,
      backgroundColor: Colors.black,
      onRefresh: () => Provider.of<UserProvider>(context, listen: false)
          .fetchAndSetUsersToApprove(),
      child: SingleChildScrollView(
        child: Column(
          children: const [
            // users to approve
            DashApproveUser(),
            // upcomming tasks
            DashTaskStatusCard(),
            // recently completed tasks
            DashCompletedTasks(),
            // assets status
            DashInspectionStatusCard(),
          ],
        ),
      ),
    );
  }
}
