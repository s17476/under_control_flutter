import 'package:flutter/material.dart';
import 'package:under_control_flutter/widgets/auth_form_widget.dart';

class AuthScree extends StatelessWidget {
  const AuthScree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthFormWidget(),
    );
  }
}
