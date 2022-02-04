import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/widgets/dashboard/dash_inspection_status_item.dart';

class DashInspectionStatusCard extends StatefulWidget {
  const DashInspectionStatusCard({Key? key}) : super(key: key);

  @override
  _DashInspectionStatusCardState createState() =>
      _DashInspectionStatusCardState();
}

class _DashInspectionStatusCardState extends State<DashInspectionStatusCard>
    with ResponsiveSize {
  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    TextStyle cardTextStyle = Theme.of(context).textTheme.headline6!.copyWith(
          fontSize: responsiveSize(small: 4, medium: 3.5),
          color: Theme.of(context).appBarTheme.foregroundColor,
        );
    ItemProvider itemProvider = Provider.of<ItemProvider>(context);
    Map<InspectionStatus, int> inspectionsStatus =
        itemProvider.inspectionsStatus;

    return Card(
      color: Theme.of(context).splashColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      margin: const EdgeInsets.only(
        right: 16,
        left: 16,
        bottom: 16,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsiveSize(small: 2)),
        child: Column(
          children: [
            Text(
              'Equipment status',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                  fontSize: responsiveSize(small: 4),
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
                    count:
                        inspectionsStatus[InspectionStatus.needsAttention] ?? 0,
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
              padding: EdgeInsets.all(responsiveSize(small: 3)),
              alignment: Alignment.centerRight,
              child: makeComment(inspectionsStatus),
            ),
          ],
        ),
      ),
    );
  }

  Text makeComment(Map<InspectionStatus, int> inspectionsStatus) {
    String comment;
    Color commentColor;
    if (inspectionsStatus[InspectionStatus.expired] != null &&
        inspectionsStatus[InspectionStatus.expired] != 0) {
      comment = "Some inspections are out of date.";
      commentColor = Colors.red;
    } else if (inspectionsStatus[InspectionStatus.failed] != null &&
        inspectionsStatus[InspectionStatus.failed] != 0) {
      comment = "Some inspections failed.";
      commentColor = Colors.red;
    } else if (inspectionsStatus[InspectionStatus.needsAttention] != null &&
        inspectionsStatus[InspectionStatus.needsAttention] != 0) {
      comment = "Some assets needs attention.";
      commentColor = Colors.amber;
    } else if (inspectionsStatus[InspectionStatus.ok] != null &&
        inspectionsStatus[InspectionStatus.ok] != 0) {
      comment = "All inspections are OK. Well done.";
      commentColor = Colors.green;
    } else {
      comment = "No assets found.";
      commentColor = Colors.grey;
    }

    return Text(
      comment,
      style: Theme.of(context).textTheme.headline6?.copyWith(
            fontSize: responsiveSize(small: 4, medium: 3.5),
            color: commentColor,
          ),
    );
  }
}
