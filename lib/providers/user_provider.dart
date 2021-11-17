import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:under_control_flutter/models/app_user.dart';

class UserProvider with ChangeNotifier {
  late final AppUser _user;
  var _isLoading = false;
  final _firebaseAuth = FirebaseAuth.instance;

  //returns a copy of current user object
  AppUser get user => AppUser.company(
        userId: _user.userId,
        email: _user.email,
        userName: _user.userName,
        password: _user.password,
        userImage: _user.userImage,
        company: _user.company,
        companyId: _user.companyId,
      );

  //returns data loading status
  bool get isLoading => _isLoading;

  //signup and signin method
  void submitAuthForm(
    String email,
    String userName,
    String password,
    File? userImage,
    bool isLogin,
    BuildContext context,
  ) async {
    UserCredential userCredential;
    String errorMessage;
    try {
      _isLoading = true;
      notifyListeners();
      if (isLogin) {
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        _isLoading = false;
        notifyListeners();
      } else {
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // add user image to cloud storage
        final imgRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(userCredential.user!.uid + '.jpg');
        await imgRef.putFile(userImage!);

        final imgUrl = await imgRef.getDownloadURL();

        // add user data to DB
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'userName': userName,
          'email': email,
          'imgUrl': imgUrl,
        });

        _user = AppUser(
          userId: userCredential.user!.uid,
          email: email,
          userName: userName,
          password: password,
          userImage: imgUrl,
        );

        _isLoading = false;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = e.message.toString();
      }
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).errorColor,
        ));
      if (isLogin) {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      if (isLogin) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
