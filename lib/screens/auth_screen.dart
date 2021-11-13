import 'dart:io';

import 'package:flutter/material.dart';
import 'package:under_control_flutter/widgets/auth_form_widget.dart';

class AuthScree extends StatelessWidget {
  const AuthScree({Key? key}) : super(key: key);

  void _submitAuthForm(
    String email,
    String userName,
    String password,
    File? userImage,
    bool isLogin,
    BuildContext context,
  ) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthFormWidget(
        isLoading: false,
        submitAuthForm: _submitAuthForm,
      ),
    );
  }
}
