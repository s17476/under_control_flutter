import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/company.dart';
import 'package:under_control_flutter/providers/company_provider.dart';

class ChooseCompany extends StatefulWidget {
  const ChooseCompany({Key? key}) : super(key: key);

  static const routeName = '/choose_company';

  @override
  State<ChooseCompany> createState() => _ChooseCompanyState();
}

// Company? _company = null;

Future<dynamic> _showDialog(
  BuildContext context,
  Company company,
) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm your choose'),
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

class _ChooseCompanyState extends State<ChooseCompany> {
  @override
  Widget build(BuildContext context) {
    CompanyProvider companyProwider = Provider.of<CompanyProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose company'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 3),
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.add,
                  size: SizeConfig.blockSizeVertical * 5,
                  color: Theme.of(context).primaryColor,
                )),
          )
        ],
      ),
      body: StreamBuilder(
        stream: companyProwider.streamAllCompanies(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              var data = document.data() as Map<String, dynamic>;
              final Company company =
                  Company.dto(companyId: document.id, name: data['name']);
              return ListTile(
                onTap: () {
                  _showDialog(context, company).then((value) {
                    if (value != null) {
                      Navigator.of(context).pop(value);
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
