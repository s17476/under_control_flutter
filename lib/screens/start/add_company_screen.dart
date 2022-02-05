import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/company.dart';
import 'package:under_control_flutter/providers/company_provider.dart';

class AddCompanyScreen extends StatefulWidget {
  const AddCompanyScreen({Key? key}) : super(key: key);

  static const routeName = '/add_company';

  @override
  _AddCompanyScreenState createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen>
    with SingleTickerProviderStateMixin, ResponsiveSize {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _address = '';
  String _postCode = '';
  String _city = '';

  Future<void> _addNewCompany(CompanyProvider companyProvider) async {
    if (_formKey.currentState != null) {
      final isValid = _formKey.currentState!.validate();
      FocusScope.of(context).unfocus();

      if (isValid) {
        _formKey.currentState!.save();
        Company company = Company(
          companyId: '',
          name: _name,
          address: _address,
          postCode: _postCode,
          city: _city,
        );
        await companyProvider.addNewCompany(context, company);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    CompanyProvider companyProvider = Provider.of<CompanyProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new company'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: responsiveSizePct(small: 10, medium: 18),
            right: responsiveSizePct(small: 10, medium: 18),
            top: responsiveSizePct(small: 20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.apartment,
                  size: responsiveSizePct(small: 20),
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(
                  height: responsiveSizePct(small: 5),
                ),
                TextFormField(
                  key: const ValueKey('name'),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: responsiveSizePct(small: 1),
                      horizontal: responsiveSizePct(small: 5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).splashColor,
                    hintText: 'Company name',
                  ),
                  validator: (val) {
                    if (val!.length < 4) {
                      return 'Company name to short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                SizedBox(
                  height: responsiveSizePct(small: 5),
                ),
                TextFormField(
                  key: const ValueKey('address'),
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: responsiveSizePct(small: 1),
                      horizontal: responsiveSizePct(small: 5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).splashColor,
                    hintText: 'Street and number',
                  ),
                  validator: (val) {
                    if (val!.length < 4) {
                      return 'Address to short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _address = value!;
                  },
                ),
                SizedBox(
                  height: responsiveSizePct(small: 5),
                ),
                TextFormField(
                  key: const ValueKey('postCode'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: responsiveSizePct(small: 1),
                      horizontal: responsiveSizePct(small: 5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).splashColor,
                    hintText: 'Postal code',
                  ),
                  validator: (val) {
                    if (val!.length < 4) {
                      return 'Post code to short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _postCode = value!;
                  },
                ),
                SizedBox(
                  height: responsiveSizePct(small: 5),
                ),
                TextFormField(
                  keyboardAppearance: Brightness.dark,
                  key: const ValueKey('city'),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: responsiveSizePct(small: 1),
                      horizontal: responsiveSizePct(small: 5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).splashColor,
                    hintText: 'City',
                  ),
                  validator: (val) {
                    if (val!.length < 2) {
                      return 'City name to short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _city = value!;
                  },
                ),
                SizedBox(
                  height: responsiveSizePct(small: 7),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _addNewCompany(companyProvider);
                    Navigator.of(context).pop(companyProvider.company);
                  },
                  child: Text(
                    'Add company',
                    style: TextStyle(
                      fontSize: responsiveSizePct(small: 5.5, medium: 2),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
