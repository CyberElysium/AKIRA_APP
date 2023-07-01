import 'dart:convert';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/constants/colors.dart';
import 'package:akira_mobile/models/good_issue.dart';
import 'package:akira_mobile/models/material_data.dart';
import 'package:akira_mobile/models/material_item.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductionReturnForm extends StatefulWidget {
  @override
  _ProductionReturnFormState createState() => _ProductionReturnFormState();
}

class _ProductionReturnFormState extends State<ProductionReturnForm> {
  int? warehouseId;
  int? type = 1;
  int? GoodIssuingId = null;
  int? supplierId = null;
  String material = '';
  String goodIssueCode = '';
  double quantity = 0;
  String location = '';
  String batch = '';
  String invoice = '';
  DateTime? effDate = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  List<GoodIssue> good_issues = [];
  GoodIssue? selectedGoodIssue;

  @override
  void initState() {
    super.initState();
    _initializeWarehouse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedGoodIssue == null)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Search Good Issuing',
                      border: OutlineInputBorder(),
                      fillColor: primaryInputColor,
                      filled: true,
                    ),
                    onChanged: (query) {
                      setState(() {
                        good_issues = [];
                      });
                      _searchGoodIssuings(query);
                    },
                  ),
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (good_issues.isNotEmpty)
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: good_issues.length,
                          itemBuilder: (context, index) {
                            final good_issue = good_issues[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(good_issue.code),
                                onTap: () {
                                  setState(() {
                                    selectedGoodIssue = good_issue;
                                    good_issues = [];
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    if (selectedGoodIssue != null && good_issues.isEmpty)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GI Code: ${selectedGoodIssue!.code}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text('Material Code: ${selectedGoodIssue!.materialCode}'),
                              Text('QTY: ${selectedGoodIssue!.qty}'),
                              Text('SKU: ${selectedGoodIssue!.sku}'),
                              Text('Warehouse: ${selectedGoodIssue!.warehouseName}'),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      setState(() {
                                        selectedGoodIssue = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    final double? quantityValue = double.tryParse(value);
                    if (quantityValue == null) {
                      return 'Please enter a valid quantity';
                    }
                    if (quantityValue < 0) {
                      return 'Quantity cannot be negative';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    quantity = double.parse(value!);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Effective Date',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an effective date';
                    }
                    return null;
                  },
                  onTap: () {
                    // Show date picker
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          effDate = selectedDate;
                        });
                      }
                    });
                  },
                  readOnly: true,
                  controller: TextEditingController(
                    text: effDate != null
                        ? DateFormat('yyyy-MM-dd').format(effDate!)
                        : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _initializeWarehouse() async {
    final prefs = await SharedPreferences.getInstance();
    Warehouse warehouse =
        Warehouse.fromJson(json.decode(prefs.getString('activeWarehouse')!));
    setState(() {
      warehouseId = warehouse.id;
    });
  }

  Future<List<GoodIssue>> fetchGoodIssueFromAPI(String query) async {
    final response = await ApiCalls.getGoodIssuingList(query);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      print(data);
      final giList = List<GoodIssue>.from(data['gis']
          .map((giJson) => GoodIssue.fromJson(giJson)));
      return giList;
    } else {
      return []; // Return an empty list or handle the error case appropriately
    }
  }

  void _searchGoodIssuings(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        good_issues = [];
      });
      final giList = await fetchGoodIssueFromAPI(query);
      setState(() {
        good_issues = giList;
      });
    }
  }

  void _submitForm() {
    // Validate the form inputs
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Save form inputs
    _formKey.currentState!.save();

    material = selectedGoodIssue!.materialCode!;
    goodIssueCode = selectedGoodIssue!.code!;

    // Display a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Good Issue Code: $goodIssueCode'),
            const SizedBox(height: 8),
            Text('Material Code: $material'),
            const SizedBox(height: 8),
            Text('Quantity: $quantity'),
            const SizedBox(height: 8),
            Text('Effective Date: ${effDate.toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Call API to submit the form
              _submitGRNForm();

              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitGRNForm() async {
    // Display a loading dialog
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Call API to submit the form
    final response = await ApiCalls.createGRN(warehouseId!, material, quantity,
        location, batch, invoice, effDate!, type, supplierId,goodIssueCode);

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      Alerts.showSuccessMessage(context, "GRN created successfully");
    } else {
      if (response.statusCode == 401) {
        Alerts.showMessage(context, json.decode(response.body)['message']);
      } else if (response.statusCode == 422) {
        Alerts.showMessage(context, json.decode(response.body)['message']);
      } else {
        Alerts.showMessage(context, "Something went wrong");
      }
    }
  }
}
