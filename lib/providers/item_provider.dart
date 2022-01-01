import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  bool _showCategories = true;
  bool _descending = false;
  Map<InspectionStatus, int> _inspectionsStatus = {};

  AppUser? _user;

  ItemProvider();

  // ItemProvider.user({this.user});

  Map<InspectionStatus, int> get inspectionsStatus {
    return _inspectionsStatus;
  }

  void clear() {
    _user = null;
    _showCategories = true;
    _descending = false;
    _inspectionsStatus = {};
  }

  void updateUser(AppUser? user) {
    _user = user;
  }

  Future<void> fetchInspectionsStatus() async {
    Map<InspectionStatus, int> statusMap = {};
    for (var i = 0; i < InspectionStatus.values.length; i++) {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(_user!.companyId)
          .collection('items')
          .where('inspectionStatus',
              isEqualTo: InspectionStatus.values[i].index)
          .get()
          .then((QuerySnapshot querySnapshot) => statusMap.putIfAbsent(
              InspectionStatus.values[i], () => querySnapshot.size))
          .catchError(
            (e) => throw Exception('Connection error. Please try later...'),
          );
    }
    // print("ftech $statusMap");
    _inspectionsStatus = statusMap;
    notifyListeners();
  }

  bool get showCategories => _showCategories;

  set setShowCategories(bool showCategories) {
    _showCategories = showCategories;
    notifyListeners();
  }

  void toggleDescendning() {
    _descending = !_descending;
  }

  // returns a copy of items list
  List<Item> get items => [..._items];

  // add new asset to DB
  Future<Item?> addNewItem(Item item) async {
    Item? tmpItem;
    // creates new batch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // get assets DB referance
    final itemRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('items')
        .doc();

    // get inspections referance
    final inspectionRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('items')
        .doc(itemRef.id)
        .collection('inspections')
        .doc();

    // add asset to DB
    batch.set(itemRef, {
      'internalId': item.internalId,
      'producer': item.producer,
      'model': item.model,
      'category': item.category.toUpperCase(),
      'location': item.location,
      'comments': item.comments,
      'inspectionStatus': item.inspectionStatus,
      'nextInspection': item.nextInspection.toIso8601String(),
      'lastInspection': item.lastInspection.toIso8601String(),
      'interval': item.interval,
    });

    // add initial inspection
    batch.set(inspectionRef, {
      'user': _user!.userId,
      'date': item.lastInspection.toIso8601String(),
      'status': item.inspectionStatus,
      'comments': 'Initial inspection',
      'checklistName': '',
      'taskId': '',
    });

    // commit batch if no error occured
    await batch.commit().then((_) {
      item.setAutogeneratedId(itemRef.id);
      _items.add(item);
      tmpItem = item;
      notifyListeners();
    }).catchError(
      (e) => throw Exception('Connection error. Please try later...'),
    );
    return tmpItem;
  }

  // updateItemInDb
  Future<void> updateItem(Item item) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('items')
        .doc(item.itemId)
        .update({
      'internalId': item.internalId,
      'producer': item.producer,
      'model': item.model,
      'category': item.category.toUpperCase(),
      'location': item.location,
      'comments': item.comments,
      'inspectionStatus': item.inspectionStatus,
      'nextInspection': item.nextInspection.toIso8601String(),
      'lastInspection': item.lastInspection.toIso8601String(),
      'interval': item.interval,
    }).then((_) {
      var editedItem =
          _items.indexWhere((element) => element.itemId == item.itemId);
      _items.removeAt(editedItem);
      _items.insert(editedItem, item);
      notifyListeners();
    }).catchError(
      (e) => throw Exception('Connection error. Please try later...'),
    );
  }

  // fetch data from DB
  Future<void> fetchAndSetItems() async {
    // print('fetch');
    List<Item> tmpItems = [];
    if (_showCategories) {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(_user!.companyId)
          .collection('items')
          .orderBy('category', descending: _descending)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          tmpItems.add(
            Item(
              itemId: doc.id,
              internalId: doc['internalId'],
              producer: doc['producer'],
              model: doc['model'],
              category: doc['category'],
              location: doc['location'],
              comments: doc['comments'],
              lastInspection: DateTime.parse(doc['lastInspection']),
              nextInspection: DateTime.parse(doc['nextInspection']),
              interval: doc['interval'],
              inspectionStatus: doc['inspectionStatus'],
            ),
          );
        }
        _items = tmpItems;
        return _items;
      });
    } else {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(_user!.companyId)
          .collection('items')
          .orderBy('inspectionStatus', descending: _descending)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          tmpItems.add(
            Item(
              itemId: doc.id,
              internalId: doc['internalId'],
              producer: doc['producer'],
              model: doc['model'],
              category: doc['category'],
              location: doc['location'],
              comments: doc['comments'],
              lastInspection: DateTime.parse(doc['lastInspection']),
              nextInspection: DateTime.parse(doc['nextInspection']),
              interval: doc['interval'],
              inspectionStatus: doc['inspectionStatus'],
            ),
          );
        }
        _items = tmpItems;
        return _items;
      });
    }

    // check if inspection has expired
    List<String> updatedItems = [];
    for (Item item in _items) {
      // print(item.nextInspection.isBefore(DateTime.now()) &&
      //     (item.inspectionStatus == InspectionStatus.ok.index ||
      //         item.inspectionStatus == InspectionStatus.needsAttention.index));
      if (item.nextInspection.isBefore(DateTime.now()) &&
          (item.inspectionStatus == InspectionStatus.ok.index ||
              item.inspectionStatus == InspectionStatus.needsAttention.index)) {
        // print('expired');
        item.inspectionStatus = InspectionStatus.expired.index;
        updatedItems.add(item.itemId!);
        if (!_showCategories) {
          int index =
              _items.indexWhere((element) => element.itemId == item.itemId);
          Item expiredItem = _items[index];

          _items.removeAt(index);
          _items.insert(!_descending ? _items.length : 0, expiredItem);
        }
      }
    }
    // update expired status
    if (updatedItems.isNotEmpty) {
      await _updateInspectionStatus(updatedItems, InspectionStatus.expired);
    }
    // notifyListeners();
  }

  Future<void> _updateInspectionStatus(
      List<String> updatedList, InspectionStatus status) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('items')
        .get()
        .then(
      (querySnapshot) {
        for (var element in querySnapshot.docs) {
          if (updatedList.contains(element.id)) {
            batch.update(element.reference, {'inspectionStatus': status.index});
          }
        }
      },
    );
    return batch.commit();
  }

  //delete item from DB
  Future<void> deleteItem(BuildContext context, String? itemId) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    final itemRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('items')
        .doc(itemId);

    // delete items from subcollection
    await itemRef.collection('inspections').get().then((querySnapshot) {
      for (var element in querySnapshot.docs) {
        batch.delete(element.reference);
      }
    });

    batch.delete(itemRef);

    await batch.commit().then((_) {
      _items.removeWhere((element) => element.itemId == itemId);
      notifyListeners();
      Navigator.of(context).pop(true);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete item"),
        ),
      );
      return error;
    });
  }
}
