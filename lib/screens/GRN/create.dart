import 'dart:convert';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/material_item.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateGRN extends StatefulWidget {
  @override
  _CreateGRNState createState() => _CreateGRNState();
}

class _CreateGRNState extends State<CreateGRN> {
  int? warehouseId;
  String material = '';
  double quantity = 0;
  String location = '';
  String batch = '';
  String invoice = '';
  DateTime? effDate;

  final _formKey = GlobalKey<FormState>();

  List<MaterialItem> materials = [];
  MaterialItem? selectedMaterial;

  @override
  void initState() {
    super.initState();
    _initializeWarehouse();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Material Code'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Material code';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    material = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    quantity = double.parse(value!);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    location = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Batch'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a batch';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    batch = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Invoice'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an invoice';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    invoice = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Effective Date'),
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
                    text: effDate != null ? effDate.toString() : '',
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
                        style: TextStyle(fontSize: 16),
                      ),
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

  Future<void> _initializeWarehouse() async {
    final prefs = await SharedPreferences.getInstance();
    Warehouse warehouse =
        Warehouse.fromJson(json.decode(prefs.getString('activeWarehouse')!));
    setState(() {
      warehouseId = warehouse.id;
    });
  }

  void _submitForm() {
    // Validate the form inputs
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Save form inputs
    _formKey.currentState!.save();

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
            Text('Material Code: $material'),
            const SizedBox(height: 8),
            Text('Quantity: $quantity'),
            const SizedBox(height: 8),
            Text('Location: $location'),
            const SizedBox(height: 8),
            Text('Batch: $batch'),
            const SizedBox(height: 8),
            Text('Invoice: $invoice'),
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
    final response = await ApiCalls.createGRN(
      warehouseId!,
      material,
      quantity,
      location,
      batch,
      invoice,
      effDate!,
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      Alerts.showSuccessMessage(context, "GRN created successfully");

    } else {
      if (response.statusCode == 401) {
        Alerts.showMessage(
            context, json.decode(response.body)['message']);
      } else if(response.statusCode == 422) {
        Alerts.showMessage(
            context, json.decode(response.body)['message']);
      } else {
        Alerts.showMessage(
            context, "Something went wrong");
      }
    }
  }
}
