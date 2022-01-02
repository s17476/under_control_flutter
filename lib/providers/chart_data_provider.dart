import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';

class ChartDataProvider with ChangeNotifier {
  Map<String, double> _chartValues = {};
  AppUser? _user;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void clear() {
    _user = null;
  }

  void updateUser(AppUser? user) {
    _user = user;
  }

  Map<String, double> get chartValues => _chartValues;

  Future<void> getAssetExpenses({
    DateTime? fromMonth,
    DateTime? toMonth,
    Item? item,
  }) async {
    Map<String, double> result = {};
    _isLoading = true;
    final nowDate = DateTime.now();
    fromMonth ??= DateTime(nowDate.year - 1, nowDate.month, 1);
    toMonth ??= nowDate;

    // print(fromMonth.difference(toMonth).);

    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('archive')
        .where('date', isGreaterThanOrEqualTo: fromMonth.toIso8601String())
        .where('date', isLessThanOrEqualTo: toMonth.toIso8601String())
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final date = DateTime.parse(doc['date']);
        final stringDate = DateFormat('MMM yyyy').format(date);

        // print(stringDate);

        if (result[stringDate] == null && doc['cost'] != null) {
          result[stringDate] = doc['cost'];
        } else if (doc['cost'] != null) {
          result[stringDate] = result[stringDate]! + doc['cost'];
        }

        // print(result);

        _chartValues = result;
        notifyListeners();
        _isLoading = false;
      }
    });
  }
}
