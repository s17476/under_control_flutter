import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/dashboard/dash_inspection_status_item.dart';
import 'package:under_control_flutter/widgets/status_icon.dart';

class DashInspectionStatusCard extends StatefulWidget {
  const DashInspectionStatusCard({Key? key}) : super(key: key);

  @override
  _DashInspectionStatusCardState createState() =>
      _DashInspectionStatusCardState();
}

class _DashInspectionStatusCardState extends State<DashInspectionStatusCard> {
  // @override
  // void initState() {
  //   initProviders();
  //   super.initState();
  // }

  // Future<void> initProviders() async {
  //   await Provider.of<ItemProvider>(context, listen: false)
  //       .fetchInspectionsStatus();
  // }

  @override
  Widget build(BuildContext context) {
    TextStyle cardTextStyle = Theme.of(context)
        .textTheme
        .headline6!
        .copyWith(fontSize: SizeConfig.blockSizeHorizontal * 4);
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ItemProvider itemProvider = Provider.of<ItemProvider>(context);
    Map<InspectionStatus, int> inspectionsStatus =
        itemProvider.inspectionsStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Theme.of(context).splashColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          margin: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
            child: Column(
              children: [
                Text(
                  'Equipment status',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      fontSize: SizeConfig.blockSizeHorizontal * 4,
                      color: Theme.of(context).primaryColor),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inspection OK',
                        style: cardTextStyle,
                      ),
                      DashInspectionStatusItem(
                        isLoading: inspectionsStatus.isEmpty,
                        count: inspectionsStatus[InspectionStatus.ok] ?? 0,
                        style: cardTextStyle,
                        status: InspectionStatus.ok,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Needs attention',
                        style: cardTextStyle,
                      ),
                      DashInspectionStatusItem(
                        isLoading: inspectionsStatus.isEmpty,
                        count: inspectionsStatus[
                                InspectionStatus.needsAttention] ??
                            0,
                        style: cardTextStyle,
                        status: InspectionStatus.needsAttention,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inspection failed',
                        style: cardTextStyle,
                      ),
                      DashInspectionStatusItem(
                        isLoading: inspectionsStatus.isEmpty,
                        count: inspectionsStatus[InspectionStatus.failed] ?? 0,
                        style: cardTextStyle,
                        status: InspectionStatus.failed,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inspection expired',
                        style: cardTextStyle,
                      ),
                      DashInspectionStatusItem(
                        isLoading: inspectionsStatus.isEmpty,
                        count: inspectionsStatus[InspectionStatus.expired] ?? 0,
                        style: cardTextStyle,
                        status: InspectionStatus.expired,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 3),
                  alignment: Alignment.centerRight,
                  child: makeComment(inspectionsStatus),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Text makeComment(Map<InspectionStatus, int> inspectionsStatus) {
    String comment;
    Color commentColor;
    if (inspectionsStatus[InspectionStatus.expired] != null) {
      comment = "Some inspections are out of date.";
      commentColor = Colors.red;
    } else if (inspectionsStatus[InspectionStatus.failed] != null) {
      comment = "Some inspections failed.";
      commentColor = Colors.red;
    } else if (inspectionsStatus[InspectionStatus.needsAttention] != null) {
      comment = "Some inspections are out of date.";
      commentColor = Colors.amber;
    } else if (inspectionsStatus[InspectionStatus.ok] != null) {
      comment = "All inspections are OK. Well done.";
      commentColor = Colors.green;
    } else {
      comment = "No assets found.";
      commentColor = Colors.grey;
    }

    return Text(
      comment,
      style: Theme.of(context).textTheme.headline6?.copyWith(
            fontSize: SizeConfig.blockSizeHorizontal * 4,
            color: commentColor,
          ),
    );
  }
}
