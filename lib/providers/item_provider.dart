import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  bool _showCategories = true;
  bool _descending = false;

  AppUser? user;

  ItemProvider();

  ItemProvider.user({this.user});

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

  // add new item to DB
  Future<void> addNewItem(Item item) async {
    // creates new batch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    final itemRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(user!.companyId)
        .collection('items')
        .doc();

    final inspectionRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(user!.companyId)
        .collection('items')
        .doc(itemRef.id)
        .collection('inspections')
        .doc();

    batch.set(itemRef, {
      'internalId': item.internalId,
      'producer': item.producer,
      'model': item.model,
      'category': item.category.toUpperCase(),
      'comments': item.comments,
      'inspectionStatus': item.inspectionStatus,
      'nextInspection': item.nextInspection.toIso8601String(),
      'lastInspection': item.lastInspection.toIso8601String(),
      'interval': item.interval,
    });

    batch.set(inspectionRef, {
      'date': item.lastInspection.toIso8601String(),
      'status': item.inspectionStatus,
      'comments': 'Initial inspection',
    });

    await batch.commit().then((_) {
      item.setAutogeneratedId(itemRef.id);
      _items.add(item);
      // print('adding item   $_items');
      notifyListeners();
    }).catchError(
      (e) => throw Exception('Connection error. Please try later...'),
    );
  }

  // fetch data from DB
  Future<void> fetchAndSetItems() async {
    List<Item> tmpItems = [];
    if (_showCategories) {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(user!.companyId)
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
          .doc(user!.companyId)
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
      if (item.nextInspection.isBefore(DateTime.now()) &&
          (item.inspectionStatus == InspectionStatus.ok.index ||
              item.inspectionStatus == InspectionStatus.needsAttention.index)) {
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
      _updateInspectionStatus(updatedItems, InspectionStatus.expired);
    }
  }

  Future<void> _updateInspectionStatus(
      List<String> updatedList, InspectionStatus status) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(user!.companyId)
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
}
