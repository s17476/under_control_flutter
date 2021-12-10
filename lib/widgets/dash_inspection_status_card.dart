import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/dash_inspection_status_item.dart';
import 'package:under_control_flutter/widgets/status_icon.dart';

class DashInspectionStatusCard extends StatefulWidget {
  const DashInspectionStatusCard({Key? key}) : super(key: key);

  @override
  _DashInspectionStatusCardState createState() =>
      _DashInspectionStatusCardState();
}

class _DashInspectionStatusCardState extends State<DashInspectionStatusCard> {
  @override
  void initState() {
    Provider.of<ItemProvider>(context, listen: false).fetchInspectionsStatus();
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   Provider.of<ItemProvider>(context, listen: false).fetchInspectionsStatus();
  //   super.didChangeDependencies();
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
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.blockSizeHorizontal * 5,
            top: SizeConfig.blockSizeHorizontal * 3,
            bottom: SizeConfig.blockSizeHorizontal,
          ),
          child: Text(
            'Equipment status',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                fontSize: SizeConfig.blockSizeHorizontal * 4,
                color: Theme.of(context).primaryColor),
          ),
        ),
        Card(
          elevation: 10,
          margin: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
            child: Column(
              children: [
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
                        'Failed inspection',
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
