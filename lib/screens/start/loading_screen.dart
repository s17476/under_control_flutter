import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/widgets/start/logo_widget.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Logo(
            greenLettersSize: 15,
            whitheLettersSize: 10,
          ),
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
