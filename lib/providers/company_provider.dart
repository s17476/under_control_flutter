import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:under_control_flutter/models/company.dart';

class CompanyProvider with ChangeNotifier {
  late Company _company;

  Stream<QuerySnapshot> streamAllCompanies() {
    return FirebaseFirestore.instance.collection('companies').snapshots();
  }
}
