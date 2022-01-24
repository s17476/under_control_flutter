import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/widgets/start/auth_form_widget.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return const Scaffold(
      body: AuthFormWidget(),
    );
  }
}
