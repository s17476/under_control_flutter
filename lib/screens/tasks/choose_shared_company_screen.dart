import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/company.dart';
import 'package:under_control_flutter/providers/company_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';

class ChooseSharedCompanyScreen extends StatelessWidget {
  const ChooseSharedCompanyScreen({Key? key}) : super(key: key);

  static const routeName = '/choose_shared_company';

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
              'Do You want to share this task with ${company.name}?',
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
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(company);
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontSize: 18,
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

              final Company company = Company.dto(
                companyId: document.id,
                name: data['name'],
                address: data['address'],
                city: data['city'],
                postCode: data['postCode'],
              );

              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      if (company.companyId !=
                          Provider.of<UserProvider>(context, listen: false)
                              .user!
                              .companyId) {
                        _showDialog(context, company).then((choosenCompany) {
                          if (choosenCompany != null) {
                            Navigator.of(context).pop(choosenCompany);
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content:
                                  Text('You can\'t choose your own company.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                      }
                    },
                    title: Text(company.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${company.city} ${company.postCode}',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                        Text(
                          company.address,
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
