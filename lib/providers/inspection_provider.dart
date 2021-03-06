import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/checklist.dart';
import 'package:under_control_flutter/models/inspection.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';

// this class provides inspections data and DB operations methods
class InspectionProvider with ChangeNotifier {
  InspectionProvider();

  List<Inspection> _inspections = [];
  AppUser? _user;

  List<Inspection> get inspections => _inspections;

  void clear() {
    _user = null;
    _inspections = [];
  }

  void updateUser(AppUser? user) {
    _user = user;
  }

  // getch inspections by item
  Future<void> fetchByItem(Item item) async {
    List<Inspection> tmpInspections = [];
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('items')
        .doc(item.itemId)
        .collection('inspections')
        .orderBy('date', descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      // fetch inspections
      for (var doc in querySnapshot.docs) {
        Checklist tmpChecklist = Checklist(name: '', fields: {});
        tmpInspections.add(Inspection(
          inspectionId: doc.id,
          user: doc['user'],
          date: DateTime.parse(doc['date']),
          comments: doc['comments'],
          status: doc['status'],
          taskId: doc['taskId'],
          checklist: tmpChecklist,
        ));

        // fetch checklist
        Map checkpointsMap = doc.data() as Map;
        for (var checkpoint in checkpointsMap.keys) {
          if (checkpoint == 'checklistName') {
            tmpChecklist.name = checkpoint;
          } else if (checkpoint != 'user' &&
              checkpoint != 'date' &&
              checkpoint != 'comments' &&
              checkpoint != 'status' &&
              checkpoint != 'taskId') {
            tmpChecklist.fields[checkpoint] = doc[checkpoint];
          }
        }
      }

      _inspections = tmpInspections;
      notifyListeners();
    });
  }

  // getch inspections by shared task
  Future<void> fetchBySharedTask(Task task, String companyId) async {
    List<Inspection> tmpInspections = [];
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('items')
        .doc(task.itemId)
        .collection('inspections')
        .orderBy('date', descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      // fetch inspections
      for (var doc in querySnapshot.docs) {
        Checklist tmpChecklist = Checklist(name: '', fields: {});
        tmpInspections.add(Inspection(
          inspectionId: doc.id,
          user: doc['user'],
          date: DateTime.parse(doc['date']),
          comments: doc['comments'],
          status: doc['status'],
          taskId: doc['taskId'],
          checklist: tmpChecklist,
        ));

        // fetch checklist
        Map checkpointsMap = doc.data() as Map;
        for (var checkpoint in checkpointsMap.keys) {
          if (checkpoint == 'checklistName') {
            tmpChecklist.name = checkpoint;
          } else if (checkpoint != 'user' &&
              checkpoint != 'date' &&
              checkpoint != 'comments' &&
              checkpoint != 'status' &&
              checkpoint != 'taskId') {
            tmpChecklist.fields[checkpoint] = doc[checkpoint];
          }
        }
      }

      _inspections = tmpInspections;
      notifyListeners();
    });
  }

  // add new inspection
  Future<bool> addInspection(Item item, Inspection inspection) async {
    bool response;
    final checklistName =
        inspection.checklist == null ? '' : inspection.checklist!.name;

    final inspectionRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('items')
        .doc(item.itemId)
        .collection('inspections');

    Map<String, dynamic> values = {
      'user': inspection.user,
      'date': inspection.date.toIso8601String(),
      'comments': inspection.comments,
      'status': inspection.status,
      'checklistName': checklistName,
      'taskId': inspection.taskId,
    };

    if (inspection.checklist != null) {
      values.addAll(inspection.checklist!.fields);
    }

    // add to DB
    response = await inspectionRef.add(values).then(
      (value) {
        inspection = inspection.copyWith(inspectionId: value.id);
        // add to local list
        _inspections.add(inspection);
        notifyListeners();

        return true;
      },
    ).catchError((_) {
      return false;
    });
    return response;
  }

  // add shared inspection
  Future<bool> addSharedInspection(
      Item item, Inspection inspection, String companyId) async {
    bool response;
    final checklistName =
        inspection.checklist == null ? '' : inspection.checklist!.name;

    final inspectionRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('items')
        .doc(item.itemId)
        .collection('inspections');

    Map<String, dynamic> values = {
      'user': inspection.user,
      'date': inspection.date.toIso8601String(),
      'comments': inspection.comments,
      'status': inspection.status,
      'checklistName': checklistName,
      'taskId': inspection.taskId,
    };

    if (inspection.checklist != null) {
      values.addAll(inspection.checklist!.fields);
    }

    // add to DB
    response = await inspectionRef.add(values).then(
      (value) {
        inspection = inspection.copyWith(inspectionId: value.id);
        // add to local list
        _inspections.add(inspection);
        notifyListeners();

        return true;
      },
    ).catchError((_) {
      return false;
    });
    return response;
  }
}
