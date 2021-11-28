import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/company.dart';
import 'package:under_control_flutter/providers/company_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/screens/add_company_screen.dart';

class ChooseCompanyScreen extends StatelessWidget {
  const ChooseCompanyScreen({Key? key}) : super(key: key);

  static const routeName = '/choose_company';

  // confirm company choice
  Future<dynamic> _showDialog(
    BuildContext context,
    Company company,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm your choice'),
          content: SingleChildScrollView(
            child: Text(
              'Do You work for ${company.name}?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Theme.of(context).errorColor,
                  fontSize: SizeConfig.blockSizeVertical * 2.5,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(company);
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeVertical * 2.5,
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CompanyProvider companyProwider = Provider.of<CompanyProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose company'),
        actions: [
          // logout button
          Padding(
            padding: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 3),
            child: IconButton(
              onPressed: Provider.of<UserProvider>(context).signout,
              icon: Icon(
                Icons.logout,
                size: SizeConfig.blockSizeVertical * 4,
                color: Theme.of(context).errorColor,
              ),
            ),
          ),
          // add company button
          Padding(
            padding: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 3),
            child: IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(AddCompanyScreen.routeName)
                    .then(
                  (company) {
                    if (company != null) {
                      Provider.of<UserProvider>(context, listen: false)
                          .setCompany(context, company as Company);
                    }
                  },
                );
              },
              icon: Icon(
                Icons.add,
                size: SizeConfig.blockSizeVertical * 5,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      // build all companies list
      body: FutureBuilder(
        future: companyProwider.getAllCompanies(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // if DB returns error
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          // show spinner while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // show companies list
          return ListView(
            // map data to list elements
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              var data = document.data() as Map<String, dynamic>;
              final Company company =
                  Company.dto(companyId: document.id, name: data['name']);
              return ListTile(
                onTap: () {
                  _showDialog(context, company).then((choosenCompany) {
                    if (choosenCompany != null) {
                      Provider.of<UserProvider>(context, listen: false)
                          .setCompany(context, choosenCompany);
                    }
                  });
                },
                title: Text(company.name),
                subtitle: Text(company.companyId),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}