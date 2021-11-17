import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: SizeConfig.blockSizeVertical * 14.2,
            ),
            Text(
              'U',
              style: TextStyle(
                color: Colors.green,
                fontSize: SizeConfig.blockSizeHorizontal * 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'nder',
              style: TextStyle(
                // color: Colors.green,
                fontSize: SizeConfig.blockSizeHorizontal * 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'C',
              style: TextStyle(
                color: Colors.green,
                fontSize: SizeConfig.blockSizeHorizontal * 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'ontrol',
              style: TextStyle(
                // color: Colors.green,
                fontSize: SizeConfig.blockSizeHorizontal * 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(
          height: SizeConfig.blockSizeHorizontal * 8,
        ),
      ],
    );
  }
}
