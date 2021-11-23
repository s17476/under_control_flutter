import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/widgets/logo_widget.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Logo(
            greenLettersSize: SizeConfig.blockSizeVertical * 2,
            whitheLettersSize: SizeConfig.blockSizeVertical * 1.4,
          ),
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
