import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _address = '';
  String _postCode = '';
  String _city = '';

  Future<Company?> _addNewCompany(CompanyProvider companyProvider) async {
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
    CompanyProvider companyProvider = Provider.of<CompanyProvider>(context);
    // print(WidgetsBinding.instance!.window.viewInsets.bottom);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new company'),
      ),
      body: SingleChildScrollView(
        child: AnimatedPadding(
          padding: EdgeInsets.only(
            left: SizeConfig.blockSizeHorizontal * 10,
            right: SizeConfig.blockSizeHorizontal * 10,
            top: WidgetsBinding.instance!.window.viewInsets.bottom > 0
                ? SizeConfig.blockSizeHorizontal * 5
                : SizeConfig.blockSizeHorizontal * 20,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.apartment,
                  size: SizeConfig.blockSizeHorizontal * 20,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                TextFormField(
                  key: const ValueKey('name'),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockSizeHorizontal * 1,
                      horizontal: SizeConfig.blockSizeHorizontal * 5,
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
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                TextFormField(
                  key: const ValueKey('address'),
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockSizeHorizontal * 1,
                      horizontal: SizeConfig.blockSizeHorizontal * 5,
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
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                TextFormField(
                  key: const ValueKey('postCode'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockSizeHorizontal * 1,
                      horizontal: SizeConfig.blockSizeHorizontal * 5,
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
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                TextFormField(
                  keyboardAppearance: Brightness.dark,
                  key: const ValueKey('city'),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockSizeHorizontal * 1,
                      horizontal: SizeConfig.blockSizeHorizontal * 5,
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
                  height: SizeConfig.blockSizeVertical * 5,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _addNewCompany(companyProvider);
                    Navigator.of(context).pop(companyProvider.company);
                  },
                  child: Text(
                    'Add company',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5.5,
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
