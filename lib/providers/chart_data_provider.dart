import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/models/app_user.dart';

// this class provides data to the charts in overview screen
class ChartDataProvider with ChangeNotifier {
  Map<String, double> _chartValues = {};
  AppUser? _user;

  bool _isLoading = false;

  double _totalCost = 0;
  int _totalTime = 0;
  Map<String, int> _assetsTime = {};
  Map<String, double> _assetsCost = {};

  Map<String, int> get assetsTime => _assetsTime;

  Map<String, double> get assetsCosts => _assetsCost;

  double get totalCost => _totalCost;

  int get totalTime => _totalTime;

  bool get isLoading => _isLoading;

  void clear() {
    _user = null;
  }

  void updateUser(AppUser? user) {
    _user = user;
  }

  Map<String, double> get chartValues => _chartValues;

  // get date of first expenses
  Future<DateTime> getBottomTimeBorder() async {
    return await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('archive')
        .orderBy('date')
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs[0];
        return DateTime.parse(doc['date']);
      }
      return DateTime(DateTime.now().year - 1);
    });
  }

  // fetch data from DB
  Future<void> getAssetExpenses({
    DateTime? fromDate,
    DateTime? toDate,
    String? itemId,
  }) async {
    Map<String, double> result = {};
    _isLoading = true;
    final nowDate = DateTime.now();

    // set chart start - end date
    fromDate ??= await getBottomTimeBorder();
    toDate ??= DateTime(nowDate.year, nowDate.month);
    toDate = DateTime(toDate.year, toDate.month + 1, 1);

    if (fromDate == toDate) {
      fromDate = DateTime(fromDate.year, fromDate.month, 1);
    }

    // prepare keys
    DateTime tmpDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
    while (tmpDate.isBefore(toDate)) {
      result[DateFormat('MMM yyyy').format(tmpDate)] = 0;
      tmpDate = DateTime(tmpDate.year, tmpDate.month + 1, 1);
    }

    // get data for given range from DB
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('archive')
        .where('date', isGreaterThanOrEqualTo: fromDate.toIso8601String())
        .where('date', isLessThan: toDate.toIso8601String())
        .where('itemId', isEqualTo: itemId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final date = DateTime.parse(doc['date']);
        final stringDate = DateFormat('MMM yyyy').format(date);

        if (result[stringDate] == null && doc['cost'] != null) {
          result[stringDate] = doc['cost'];
        } else if (doc['cost'] != null) {
          result[stringDate] = result[stringDate]! + doc['cost'];
        }
      }

      _chartValues = result;
      notifyListeners();
      _isLoading = false;
    });
  }

  Future<void> getCosts(
    DateTime? fromDate,
    DateTime? toDate,
    String? itemId,
  ) async {
    double tmpTotalCost = 0;
    int tmpTotalTime = 0;
    Map<String, double> tmpAssetsCosts = {};
    Map<String, int> tmpAssetsTime = {};

    final nowDate = DateTime.now();
    toDate ??= DateTime(nowDate.year, nowDate.month, 31);
    toDate = DateTime(toDate.year, toDate.month, 31);

    FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('archive')
        .where('date', isGreaterThanOrEqualTo: fromDate?.toIso8601String())
        .where('date', isLessThanOrEqualTo: toDate.toIso8601String())
        .where('itemId', isEqualTo: itemId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['cost'] != null) {
          tmpTotalCost += doc['cost'];
          if (doc['itemId'] != null) {
            if (tmpAssetsCosts.keys.contains(doc['itemId'])) {
              tmpAssetsCosts[doc['itemId']] =
                  tmpAssetsCosts[doc['itemId']]! + doc['cost'];
            } else {
              tmpAssetsCosts[doc['itemId']] = doc['cost'];
            }
          }
        }
        if (doc['duration'] != null) {
          tmpTotalTime += doc['duration'] as int;
          if (doc['itemId'] != null) {
            if (tmpAssetsTime.keys.contains(doc['itemId'])) {
              tmpAssetsTime[doc['itemId']] =
                  tmpAssetsTime[doc['itemId']]! + doc['duration'] as int;
            } else {
              tmpAssetsTime[doc['itemId']] = doc['duration'] as int;
            }
          }
        }
      }
      _totalCost = tmpTotalCost;
      _totalTime = tmpTotalTime;
      _assetsCost = tmpAssetsCosts;
      _assetsTime = tmpAssetsTime;
      notifyListeners();
    });
  }
}
