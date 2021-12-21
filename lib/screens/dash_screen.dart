import 'package:flutter/material.dart';
import 'package:under_control_flutter/widgets/dashboard/dash_inspection_status_card.dart';

class DashScreen extends StatelessWidget {
  const DashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          DashInspectionStatusCard(),
        ],
      ),
    );
  }
}
