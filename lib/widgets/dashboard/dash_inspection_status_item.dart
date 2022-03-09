import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/widgets/start/status_icon.dart';

class DashInspectionStatusItem extends StatelessWidget with ResponsiveSize {
  const DashInspectionStatusItem(
      {Key? key,
      required this.isLoading,
      required this.count,
      required this.style,
      required this.status})
      : super(key: key);

  final bool isLoading;
  final int count;
  final TextStyle style;
  final InspectionStatus status;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SizedBox(
            width: SizeConfig.blockSizeHorizontal * 6,
            height: SizeConfig.blockSizeHorizontal * 6,
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          )
        : Row(
            children: [
              Text(
                '$count items ',
                style: style,
              ),
              StatusIcon(
                heroTag: '',
                inspectionStatus: status.index,
                size: responsiveSizePx(small: 25, medium: 45),
                textSize: 0,
              ),
            ],
          );
  }
}
