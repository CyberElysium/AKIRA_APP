import 'package:akira_mobile/screens/GRN/components/general_form.dart';
import 'package:akira_mobile/screens/GRN/components/production_return_form.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class CreateGRN extends StatefulWidget {
  @override
  _CreateGRNState createState() => _CreateGRNState();
}

class _CreateGRNState extends State<CreateGRN> {
  int? type = 0;
  String? selectedDropdownItem;
  List<String> dropdownItems = ['General', 'Production Return'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New GRN'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'GRN Type',
                      border: OutlineInputBorder(),
                      fillColor: primaryInputColor,
                      filled: true,
                    ),
                    value: selectedDropdownItem,
                    onChanged: (value) {
                      setState(() {
                        selectedDropdownItem = value;
                      });
                    },
                    items: dropdownItems.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                  ),
                ),
                // Load the related widget based on the selected item
                if (selectedDropdownItem == 'General')
                  GeneralForm(),
                if (selectedDropdownItem == 'Production Return')
                  ProductionReturnForm(),
                // Add your other widgets here
                // ...
              ],
            ),
          ),
        ),
      ),
    );
  }
}
