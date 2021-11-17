// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/widgets/auth_form_widget.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      body: AuthFormWidget(),
    );
  }
}
