import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/checklist.dart';

class ChecklistProvider with ChangeNotifier {
  ChecklistProvider();

  AppUser? _user;

  List<Checklist> _checklists = [];

  void updateUser(AppUser? user) {
    _user = user;
  }

  void clear() {
    _user = null;
  }

  List<Checklist> get checklists =>
      [Checklist(name: 'New checklist', fields: {}), ..._checklists];

  // add new checklist
  Future<Checklist> addChecklist(Checklist checklist) async {
    Checklist result;
    var checklistsRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('checklists');

    Map<String, dynamic> values = {
      'name': checklist.name,
    };

    values.addAll(checklist.fields);
    result = await checklistsRef.add(values).then((value) {
      checklist = checklist.copyWith(checklistId: value.id);
      // add to local list
      var index =
          _checklists.indexWhere((element) => element.name == checklist.name);
      // replace if alerede exist
      if (index >= 0) {
        _checklists.removeAt(index);
      }
      _checklists.add(checklist);
      notifyListeners();

      return checklist;
    });
    return result;
  }

  // initialize checklist provider
  Future<void> fetchAndSetChecklists() async {
    List<Checklist> tmpChecklists = [];
    var checklistsRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('checklists')
        .get();

    await checklistsRef.then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final tmpChecklist = Checklist(
          checklistId: doc.id,
          name: doc['name'],
          fields: {},
        );
        Map checkpointsMap = doc.data() as Map;
        for (var checkpoint in checkpointsMap.keys) {
          if (checkpoint != 'name') {
            tmpChecklist.fields[checkpoint] = false;
          }
        }
        tmpChecklists.add(tmpChecklist);
      }
      _checklists = tmpChecklists;
      notifyListeners();
    });
  }

  // delete checklist
  Future<void> deleteChecklist(Checklist checklist) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('checklists')
        .doc(checklist.checklistId)
        .delete()
        .then((_) {
      _checklists.remove(checklist);
      notifyListeners();
    });
  }
}
