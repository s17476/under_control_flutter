import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/pickers/user_image_picker.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/screens/choose_company.dart';
import 'package:under_control_flutter/widgets/logo_widget.dart';

class AuthFormWidget extends StatefulWidget {
  const AuthFormWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  var _isInLoginMode = true;

  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';
  File? _userImageFile;

  AnimationController? _animationController;
  Animation<Offset>? _userSlideAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;
  Animation<double>? _opacityAnimationBackward;

  @override
  void initState() {
    super.initState();
    //initialize animations controllers
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _userSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.3),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.3),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    ));
    _opacityAnimationBackward =
        Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController!.dispose();
  }

  void _pickImage(File? image) {
    _userImageFile = image;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
  }

  void _trySubmit() {
    //input fields validation
    if (_formKey.currentState != null) {
      _formKey.currentState!.save();
      FocusScope.of(context).unfocus();

      if (!_isInLoginMode && _userImageFile == null) {
        _showSnackBar('Please add avatar');
        return;
      } else if (!_userEmail.contains('@')) {
        _showSnackBar('Bad email format');
        return;
      } else if (!_isInLoginMode && _userName.length < 4) {
        _showSnackBar('User name to short');
        return;
      } else if (_userPassword.length < 7) {
        _showSnackBar('Password is to short');
        return;
      }

      //submiting formular
      Provider.of<UserProvider>(context, listen: false).submitAuthForm(
        _userEmail.trim(),
        _userName.trim(),
        _userPassword.trim(),
        _userImageFile,
        _isInLoginMode,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return SingleChildScrollView(
      child: AnimatedPadding(
        padding: EdgeInsets.only(
          left: SizeConfig.blockSizeHorizontal * 10,
          right: SizeConfig.blockSizeHorizontal * 10,
          top: WidgetsBinding.instance!.window.viewInsets.bottom > 0
              ? SizeConfig.blockSizeHorizontal * 20
              : SizeConfig.blockSizeHorizontal * 40,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //logo and image picker
              _isInLoginMode
                  ? FadeTransition(
                      opacity: _opacityAnimationBackward!,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: SizeConfig.blockSizeVertical * 4.7,
                        ),
                        child: const Logo(
                          greenLettersSize: 16,
                          whitheLettersSize: 10,
                        ),
                      ),
                    )
                  : FadeTransition(
                      opacity: _opacityAnimation!,
                      child: UserImagePicker(
                        imagePickFn: _pickImage,
                        image: _userImageFile,
                      ),
                    ),
              SizedBox(
                height: _isInLoginMode
                    ? SizeConfig.blockSizeHorizontal * 13
                    : SizeConfig.blockSizeHorizontal * 5,
              ),

              //email field
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        right: SizeConfig.blockSizeHorizontal * 2),
                    child: Icon(
                      Icons.person,
                      color: Colors.green,
                      size: SizeConfig.blockSizeHorizontal * 10,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      key: const ValueKey('email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockSizeHorizontal * 1,
                          horizontal: SizeConfig.blockSizeHorizontal * 5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).splashColor,
                        hintText: 'E-mail address',
                      ),
                      onSaved: (value) {
                        _userEmail = value!;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: SizeConfig.blockSizeHorizontal * 4,
              ),

              //name field
              FadeTransition(
                opacity: _opacityAnimation!,
                child: SlideTransition(
                  position: _userSlideAnimation!,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            right: SizeConfig.blockSizeHorizontal * 2),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.green,
                          size: SizeConfig.blockSizeHorizontal * 10,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('name'),
                          enabled: _isInLoginMode ? false : true,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockSizeHorizontal * 1,
                              horizontal: SizeConfig.blockSizeHorizontal * 5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).splashColor,
                            hintText: 'User name',
                          ),
                          onSaved: (value) {
                            _userName = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SlideTransition(
                position: _userSlideAnimation!,
                child: SizedBox(
                  height: SizeConfig.blockSizeHorizontal * 4,
                ),
              ),

              //password
              SlideTransition(
                position: _slideAnimation!,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          right: SizeConfig.blockSizeHorizontal * 2),
                      child: Icon(
                        Icons.lock,
                        color: Colors.green,
                        size: SizeConfig.blockSizeHorizontal * 10,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        onFieldSubmitted: (val) {
                          _trySubmit();
                        },
                        key: const ValueKey('password'),
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: SizeConfig.blockSizeHorizontal * 1,
                            horizontal: SizeConfig.blockSizeHorizontal * 5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).splashColor,
                          hintText: 'Password',
                        ),
                        obscureText: true,
                        onSaved: (value) {
                          _userPassword = value!;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: SizeConfig.blockSizeHorizontal * 6,
              ),

              // Login button
              SlideTransition(
                position: _slideAnimation!,
                child: ElevatedButton(
                  onPressed: _trySubmit,
                  child: Provider.of<UserProvider>(context).isLoading
                      ? Padding(
                          padding: EdgeInsets.all(SizeConfig.blockSizeVertical),
                          child: SizedBox(
                            height: SizeConfig.blockSizeVertical * 2.5,
                            width: SizeConfig.blockSizeVertical * 2.5,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _isInLoginMode ? 'Login' : 'Signup',
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeHorizontal * 5,
              ),

              // toggle button
              SlideTransition(
                position: _slideAnimation!,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(ChooseCompany.routeName);
                    setState(() {
                      _isInLoginMode = !_isInLoginMode;
                    });
                    if (!_isInLoginMode) {
                      _animationController!.forward();
                      // _fieldHeight = SizeConfig.blockSizeVertical * 8;
                    } else {
                      _animationController!.reverse();
                      // _fieldHeight = 0;
                    }
                  },
                  child: Provider.of<UserProvider>(context).isLoading
                      ? SizedBox(
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          height: SizeConfig.blockSizeHorizontal * 7,
                          width: SizeConfig.blockSizeHorizontal * 7,
                        )
                      : Text(
                          _isInLoginMode
                              ? 'Create new account'
                              : 'I aleready have an account',
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
