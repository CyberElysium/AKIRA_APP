import 'dart:convert';
import 'dart:io';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/constants/colors.dart';
import 'package:akira_mobile/models/material_item.dart';
import 'package:akira_mobile/models/transaction_type.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/screens/GI/components/general_form.dart';
import 'package:akira_mobile/screens/GI/components/gi_for_mr_form.dart';
import 'package:akira_mobile/screens/GI/components/sample_form.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class GoodIssuing extends StatefulWidget {
  @override
  _GoodIssuingState createState() => _GoodIssuingState();
}

class _GoodIssuingState extends State<GoodIssuing> {

  String? selectedDropdownItem;

  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<TransactionType> transactionTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactionTypes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AKIRA Good Issuing'),
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
                      labelText: 'Issue Type',
                      border: OutlineInputBorder(),
                      fillColor: primaryInputColor,
                      filled: true,
                    ),
                    items: transactionTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type.name,
                        child: Text(type.name),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a Type';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        selectedDropdownItem = value!;
                      });
                    },
                  ),
                ),
                if (selectedDropdownItem == 'General')
                  GeneralForm(),
                if (selectedDropdownItem == 'Sample')
                  SampleForm(),
                if (selectedDropdownItem == 'GI for MR')
                  GiForMrForm(),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchTransactionTypes() async {
    try {
      final response = await ApiCalls.getTransactionTypes();

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        print(data['types']);
        final transactionTypesList = List<TransactionType>.from(
            data['types'].map((types) => TransactionType.fromJson(types)));
        setState(() {
          transactionTypes = transactionTypesList;
        });
      } else {
        // Alerts.showMessage(context, "Something went wrong");
      }
    } catch (error) {
      print('Error: $error');
      // Handle error
    }
  }
}
