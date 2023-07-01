import 'dart:convert';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/constants/colors.dart';
import 'package:akira_mobile/models/material_data.dart';
import 'package:akira_mobile/models/material_item.dart';
import 'package:akira_mobile/models/supplier.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralForm extends StatefulWidget {
  @override
  _GeneralFormState createState() => _GeneralFormState();
}

class _GeneralFormState extends State<GeneralForm> {
  int? warehouseId;
  int? supplierId;
  int? type = 0;
  String material = '';
  double quantity = 0;
  String location = '';
  String batch = '';
  String invoice = '';
  DateTime? effDate = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  List<MaterialData> materials = [];
  List<Supplier> suppliers = [];

  MaterialData? selectedMaterial;
  Supplier? selectedSupplier;

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
                if (selectedMaterial == null)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Search Material',
                      border: OutlineInputBorder(),
                      fillColor: primaryInputColor,
                      filled: true,
                    ),
                    onChanged: (query) {
                      setState(() {
                        materials = [];
                      });
                      _searchMaterials(query);
                    },
                  ),
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (materials.isNotEmpty)
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: materials.length,
                          itemBuilder: (context, index) {
                            final material = materials[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(material.nameWithCode),
                                onTap: () {
                                  setState(() {
                                    selectedMaterial = material;
                                    materials = [];
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    if (selectedMaterial != null && materials.isEmpty)
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
                                'Material name: ${selectedMaterial!.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text('Code: ${selectedMaterial!.code}'),
                              Text('UOM: ${selectedMaterial!.uomName}'),
                              Text(
                                  'Category: ${selectedMaterial!.categoryName}'),

                              // show image using url
                              if (selectedMaterial!.imageUrl != null)
                                Image.network(selectedMaterial!.imageUrl!),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      setState(() {
                                        selectedMaterial = null;
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
                if (selectedSupplier == null)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Search Supplier',
                      border: OutlineInputBorder(),
                      fillColor: primaryInputColor,
                      filled: true,
                    ),
                    onChanged: (query) {
                      setState(() {
                        suppliers = [];
                      });
                      _searchSuppliers(query);
                    },
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (suppliers.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: suppliers.length,
                          itemBuilder: (context, index) {
                            final supplier = suppliers[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(supplier.name),
                                onTap: () {
                                  setState(() {
                                    selectedSupplier = supplier;
                                    suppliers = [];
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    if (selectedSupplier != null && materials.isEmpty)
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
                                'Supplier name: ${selectedSupplier!.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text('Code: ${selectedSupplier!.code}'),
                              Text(
                                  'Company: ${selectedSupplier!.company ?? 'N/A'}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      setState(() {
                                        selectedSupplier = null;
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
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'Batch',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  onSaved: (value) {
                    batch = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Invoice',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  onSaved: (value) {
                    invoice = value!;
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

  Future<List<MaterialData>> fetchMaterialsFromAPI(String query) async {
    final response = await ApiCalls.getMaterialList(query);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      final materialList = List<MaterialData>.from(data['materials']
          .map((materialJson) => MaterialData.fromJson(materialJson)));
      return materialList;
    } else {
      return []; // Return an empty list or handle the error case appropriately
    }
  }

  Future<List<Supplier>> fetchSupplierFromAPI(String query) async {
    final response = await ApiCalls.getSupplierList(query);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      print(data);
      final supplierList = List<Supplier>.from(data['suppliers']
          .map((supplierJson) => Supplier.fromJson(supplierJson)));
      return supplierList;
    } else {
      return []; // Return an empty list or handle the error case appropriately
    }
  }

  void _searchMaterials(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        materials = [];
      });
      final materialList = await fetchMaterialsFromAPI(query);
      setState(() {
        materials = materialList;
      });
    }
  }

  void _searchSuppliers(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        suppliers = [];
      });
      final supplierList = await fetchSupplierFromAPI(query);
      setState(() {
        suppliers = supplierList;
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

    material = selectedMaterial!.code;
    supplierId = selectedSupplier!.id;
    final supplierName = selectedSupplier!.name;

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
            Text('Supplier: $supplierName'),
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
    final response = await ApiCalls.createGRN(warehouseId!, material, quantity,
        location, batch, invoice, effDate!, type, supplierId);

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
