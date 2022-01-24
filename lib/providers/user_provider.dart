import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/company.dart';

// this class provides user data and DB operations methods
class UserProvider with ChangeNotifier {
  AppUser? _user;
  List<AppUser?> _allUsersInCompany = [];
  var _isLoading = false;
  var _hasData = false;
  final _firebaseAuth = FirebaseAuth.instance;

  //returns a copy of current user object
  AppUser? get user {
    if (_user != null) {
      return AppUser.company(
        userId: _user!.userId,
        email: _user!.email,
        userName: _user!.userName,
        userImage: _user!.userImage,
        company: _user!.company,
        companyId: _user!.companyId,
      );
    }
    return null;
  }

  //returns data loading status
  bool get isLoading => _isLoading;

  bool get hasData => _hasData;

  List<AppUser?> get allUsersInCompany => [..._allUsersInCompany];

  // initializes users in company
  Future<void> initializeCompanyUsers() async {
    List<AppUser?> tmpUsers = [];
    await FirebaseFirestore.instance
        .collection('users')
        .where('companyId', isEqualTo: _user?.companyId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        tmpUsers.add(AppUser.company(
          userId: doc.id,
          email: doc['email'],
          userName: doc['userName'],
          userImage: doc['imgUrl'],
          company: doc['company'],
          companyId: doc['companyId'],
        ));
      }
    });
    _allUsersInCompany = tmpUsers;
    notifyListeners();
  }

  // initializes user data
  Future<AppUser?> initializeUser(
    BuildContext context,
    String userId,
  ) async {
    _isLoading = true;
    _user = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      AppUser? tmpUser;
      final userSnapshot = documentSnapshot.data() as Map<String, dynamic>;
      if (userSnapshot['company'] == null) {
        tmpUser = AppUser(
            userId: documentSnapshot.id,
            email: userSnapshot['email'],
            userName: userSnapshot['userName'],
            userImage: userSnapshot['imgUrl']);
      } else {
        tmpUser = AppUser.company(
          userId: documentSnapshot.id,
          email: userSnapshot['email'],
          userName: userSnapshot['userName'],
          userImage: userSnapshot['imgUrl'],
          company: userSnapshot['company'],
          companyId: userSnapshot['companyId'],
        );
      }
      _isLoading = false;
      _hasData = true;
      return tmpUser;
    });
    notifyListeners();
    return _user;
  }

  // gets user by id
  Future<AppUser?> getUserById(
    BuildContext context,
    String userId,
  ) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      AppUser? tmpUser;
      if (documentSnapshot.exists) {
        final userSnapshot = documentSnapshot.data() as Map<String, dynamic>;

        tmpUser = AppUser.company(
          userId: documentSnapshot.id,
          email: userSnapshot['email'],
          userName: userSnapshot['userName'],
          userImage: userSnapshot['imgUrl'],
          company: userSnapshot['company'],
          companyId: userSnapshot['companyId'],
        );
      } else {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: const Text('Unable get user data. Try again later...'),
            backgroundColor: Theme.of(context).errorColor,
          ));
      }
      return tmpUser;
    });
  }

  // gets shared user by id
  Future<AppUser?> getSharedUserById(
    String userId,
  ) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      AppUser? tmpUser;
      if (documentSnapshot.exists) {
        final userSnapshot = documentSnapshot.data() as Map<String, dynamic>;

        tmpUser = AppUser.company(
          userId: documentSnapshot.id,
          email: userSnapshot['email'],
          userName: userSnapshot['userName'],
          userImage: userSnapshot['imgUrl'],
          company: userSnapshot['company'],
          companyId: userSnapshot['companyId'],
        );
      }
      return tmpUser;
    });
  }

  // sets company to the current user
  Future<void> setCompany(BuildContext context, Company company) async {
    _user = AppUser.company(
      userId: _user!.userId,
      email: _user!.email,
      userName: _user!.userName,
      userImage: _user!.userImage,
      company: company.name,
      companyId: company.companyId,
    );
    await updateUser(context);
  }

  // updates user data in DB
  Future<void> updateUser(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.userId)
        .set({
      'userName': _user!.userName,
      'email': _user!.email,
      'imgUrl': _user!.userImage,
      'company': _user!.company,
      'companyId': _user!.companyId,
    });
    notifyListeners();
  }

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
        await initializeUser(context, userCredential.user!.uid);

        _isLoading = false;
        notifyListeners();
      } else {
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // adds user image to cloud storage
        final imgRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(userCredential.user!.uid + '.jpg');
        await imgRef.putFile(userImage!);

        final imgUrl = await imgRef.getDownloadURL();

        // adds user data to DB
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
          // password: password,
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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  // signout method
  void signout() {
    FirebaseAuth.instance.signOut();
    _user = null;
    _isLoading = false;
    _hasData = false;
    notifyListeners();
  }

  // listens to user authentification status
  Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }
}
