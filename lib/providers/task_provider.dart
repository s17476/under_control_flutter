import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';

class TaskProvider with ChangeNotifier {
  AppUser? _user;

  TaskProvider();

  void clear() {
    _user = null;
  }

  void update(AppUser? user) {
    _user = user;
  }

////////////////////////////////////////////
  void addTask(Task task) {
    // get inspections referance
    final taskRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('tasks')
        .doc();
  }
}
