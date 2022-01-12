import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';

class StatusIcon extends StatelessWidget {
  const StatusIcon(
      {Key? key,
      required this.heroTag,
      required this.inspectionStatus,
      required this.size,
      required this.textSize})
      : super(key: key);

  final String heroTag;
  final int inspectionStatus;
  final int size;
  final int textSize;

  @override
  Widget build(BuildContext context) {
    return inspectionStatus == InspectionStatus.ok.index
        ? Column(
            children: [
              Hero(
                tag: heroTag,
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: SizeConfig.blockSizeHorizontal * size,
                ),
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
        : inspectionStatus == InspectionStatus.failed.index
            ? Column(
                children: [
                  Hero(
                    tag: heroTag,
                    child: Icon(
                      Icons.clear_rounded,
                      color: Colors.red,
                      size: SizeConfig.blockSizeHorizontal * size,
                    ),
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
            : inspectionStatus == InspectionStatus.needsAttention.index
                ? Column(
                    children: [
                      Hero(
                        tag: heroTag,
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber,
                          size: SizeConfig.blockSizeHorizontal * size,
                        ),
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
                      Hero(
                        tag: heroTag,
                        child: Icon(
                          Icons.alarm_outlined,
                          color: Colors.red,
                          size: SizeConfig.blockSizeHorizontal * size,
                        ),
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