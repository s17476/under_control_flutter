import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/models/company.dart';

class CompanyProvider with ChangeNotifier {
  Company? _company;

  Company get company => Company(
        companyId: _company!.companyId,
        name: _company!.name,
        address: _company!.address,
        postCode: _company!.postCode,
        city: _company!.city,
      );

  Future<QuerySnapshot> getAllCompanies() {
    return FirebaseFirestore.instance
        .collection('companies')
        .orderBy('name')
        .get();
  }

  Future<Company?> initializeCompany(
    BuildContext context,
    String companyId,
  ) async {
    _company = await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      Company? tmpCompany;
      if (documentSnapshot.exists) {
        final companySnapshot = documentSnapshot.data() as Map<String, dynamic>;

        tmpCompany = Company(
          companyId: companyId,
          name: companySnapshot['name'],
          address: companySnapshot['address'],
          postCode: companySnapshot['postCode'],
          city: companySnapshot['city'],
        );
      } else {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content:
                  const Text('Unable get company data. Try again later...'),
              backgroundColor: Theme.of(context).errorColor,
            ),
          );
      }

      notifyListeners();
      return tmpCompany;
    });
    return _company;
  }

  // add new company to DB
  Future<Company?> addNewCompany(BuildContext context, Company company) async {
    await FirebaseFirestore.instance.collection('companies').add({
      'name': company.name,
      'address': company.address,
      'postCode': company.postCode,
      'city': company.city,
    }).then((value) {
      print(value.id);
      _company = Company(
        companyId: value.id,
        name: company.name,
        address: company.address,
        postCode: company.postCode,
        city: company.city,
      );
    });
    return _company;
  }
}
