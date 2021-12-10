import 'package:flutter/material.dart';
import 'package:under_control_flutter/widgets/dash_inspection_status_card.dart';

class DashScreen extends StatelessWidget {
  const DashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        DashInspectionStatusCard(),
      ],
    );
  }
}
