import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';

class StatusIcon extends StatelessWidget {
  const StatusIcon(
      {Key? key,
      required this.item,
      required this.size,
      required this.textSize})
      : super(key: key);

  final Item item;
  final int size;
  final int textSize;

  @override
  Widget build(BuildContext context) {
    return item.inspectionStatus == InspectionStatus.ok.index
        ? Column(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
                size: SizeConfig.blockSizeVertical * size,
              ),
              if (textSize != 0)
                const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
            ],
          )
        : item.inspectionStatus == InspectionStatus.failed.index
            ? Column(
                children: [
                  Icon(
                    Icons.clear_rounded,
                    color: Colors.red,
                    size: SizeConfig.blockSizeVertical * size,
                  ),
                  if (textSize != 0)
                    const Text(
                      'FAILED',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                ],
              )
            : item.inspectionStatus == InspectionStatus.needsAttention.index
                ? Column(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: SizeConfig.blockSizeVertical * size,
                      ),
                      if (textSize != 0)
                        const Text(
                          'NEEDS ATTENTION',
                          style: TextStyle(
                            color: Colors.amber,
                          ),
                        ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(
                        Icons.alarm_outlined,
                        color: Colors.red,
                        size: SizeConfig.blockSizeVertical * size,
                      ),
                      if (textSize != 0)
                        const Text(
                          'EXPIRED',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                    ],
                  );
  }
}
