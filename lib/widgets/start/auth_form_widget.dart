import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/pickers/user_image_picker.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/widgets/start/logo_widget.dart';

class AuthFormWidget extends StatefulWidget {
  const AuthFormWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget>
    with SingleTickerProviderStateMixin, ResponsiveSize {
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

    Provider.of<UserProvider>(context, listen: false).isLoading = false;

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
    var isLoading = Provider.of<UserProvider>(context).isLoading;
    if (isLargeScreen()) {
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, -2.4),
        end: const Offset(0, 0),
      ).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: Curves.linear,
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: responsiveSizePct(small: 10),
          right: responsiveSizePct(small: 10),
          top: responsiveSizePct(small: 40, medium: 30, large: 4),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //logo and image picker
              SizedBox(
                height: responsiveSizePct(small: 40, large: 17),
                child: _isInLoginMode
                    ? FadeTransition(
                        opacity: _opacityAnimationBackward!,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: responsiveSizePct(small: 4.7, large: 3),
                          ),
                          child: SizedBox(
                            width: responsiveSizePct(small: 70, large: 40),
                            child: FittedBox(
                              child: Logo(
                                greenLettersSize: responsiveSizePct(
                                    small: 3.5, medium: 2, large: 0.6),
                                whitheLettersSize: responsiveSizePct(
                                    small: 2.3, medium: 1.3, large: 0.4),
                              ),
                            ),
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
              ),
              // SizedBox(
              //   height: _isInLoginMode
              //       ? responsiveSize(small: 18)
              //       : responsiveSize(small: 5),
              // ),

              //email field
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      responsiveSizePct(small: 0, medium: 15, large: 25),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right:
                            responsiveSizePct(small: 2, medium: 1, large: 0.3),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.green,
                        size: responsiveSizePct(small: 10, medium: 6, large: 3),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        key: const ValueKey('email'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: responsiveSizePct(
                                small: 1, medium: 2, large: 0),
                            horizontal: responsiveSizePct(
                                small: 5, medium: 3, large: 2),
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
              ),

              SizedBox(
                height: responsiveSizePct(small: 4, medium: 2.5, large: 1),
              ),

              //name field
              FadeTransition(
                opacity: _opacityAnimation!,
                child: SlideTransition(
                  position: _userSlideAnimation!,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          responsiveSizePct(small: 0, medium: 15, large: 25),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: responsiveSizePct(
                                small: 2, medium: 1, large: 0.3),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.green,
                            size: responsiveSizePct(
                                small: 10, medium: 6, large: 3),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            style: const TextStyle(color: Colors.white),
                            key: const ValueKey('name'),
                            enabled: _isInLoginMode ? false : true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: responsiveSizePct(
                                    small: 1, medium: 2, large: 0),
                                horizontal: responsiveSizePct(
                                    small: 5, medium: 3, large: 2),
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
              ),

              SlideTransition(
                position: _userSlideAnimation!,
                child: SizedBox(
                  height: responsiveSizePct(small: 4, medium: 2.5, large: 1),
                ),
              ),

              //password
              SlideTransition(
                position: _userSlideAnimation!,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        responsiveSizePct(small: 0, medium: 15, large: 25),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: responsiveSizePct(
                              small: 2, medium: 1, large: 0.3),
                        ),
                        child: Icon(
                          Icons.lock,
                          color: Colors.green,
                          size:
                              responsiveSizePct(small: 10, medium: 6, large: 3),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          style: const TextStyle(color: Colors.white),
                          onFieldSubmitted: (val) {
                            _trySubmit();
                          },
                          key: const ValueKey('password'),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: responsiveSizePct(
                                  small: 1, medium: 2, large: 0),
                              horizontal: responsiveSizePct(
                                  small: 5, medium: 3, large: 2),
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
              ),

              SizedBox(
                height: responsiveSizePct(small: 6, large: 2),
              ),

              // Login button
              SlideTransition(
                position: _slideAnimation!,
                child: ElevatedButton(
                  onPressed: _trySubmit,
                  child: isLoading
                      ? Padding(
                          padding: EdgeInsets.all(
                              responsiveSizeVerticalPct(small: 1)),
                          child: SizedBox(
                            height: responsiveSizeVerticalPct(small: 2.5),
                            width: responsiveSizeVerticalPct(small: 2.5),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _isInLoginMode ? 'Login' : 'Signup',
                          style: TextStyle(
                            fontSize: responsiveSizePct(
                                small: 5.5, medium: 3, large: 1),
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
                height: responsiveSizePct(small: 5, large: 1),
              ),

              // toggle button
              SlideTransition(
                position: _slideAnimation!,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isInLoginMode = !_isInLoginMode;
                    });
                    if (!_isInLoginMode) {
                      _animationController!.forward();
                    } else {
                      _animationController!.reverse();
                    }
                  },
                  child: isLoading
                      ? SizedBox(
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          height: responsiveSizePct(small: 7),
                          width: responsiveSizePct(small: 7),
                        )
                      : Text(
                          _isInLoginMode
                              ? 'Create new account'
                              : 'I aleready have an account',
                          style: TextStyle(
                            fontSize: responsiveSizePct(
                                small: 4.5, medium: 3, large: 1),
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
