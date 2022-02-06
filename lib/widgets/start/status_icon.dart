import 'package:flutter/material.dart';
import 'package:under_control_flutter/models/item.dart';

class StatusIcon extends StatelessWidget {
  const StatusIcon({
    Key? key,
    required this.heroTag,
    required this.inspectionStatus,
    required this.size,
    required this.textSize,
  }) : super(key: key);

  final String heroTag;
  final int inspectionStatus;
  final double size;
  final double textSize;

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
                  size: size,
                ),
              ),
              if (textSize != 0)
                Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: textSize,
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
                      size: size,
                    ),
                  ),
                  if (textSize != 0)
                    Text(
                      'FAILED',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: textSize,
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
                          size: size,
                        ),
                      ),
                      if (textSize != 0)
                        Text(
                          'NEEDS ATTENTION',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: textSize,
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
                          size: size,
                        ),
                      ),
                      if (textSize != 0)
                        Text(
                          'EXPIRED',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: textSize,
                          ),
                        ),
                    ],
                  );
  }
}
