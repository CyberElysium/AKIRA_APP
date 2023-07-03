import 'dart:convert';
import 'dart:io';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/constants/colors.dart';
import 'package:akira_mobile/models/material_item.dart';
import 'package:akira_mobile/models/material_request.dart';
import 'package:akira_mobile/models/stock.dart';
import 'package:akira_mobile/models/style.dart';
import 'package:akira_mobile/models/transaction_type.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class GiForMrForm extends StatefulWidget {
  @override
  _GiForMrFormState createState() => _GiForMrFormState();
}

class _GiForMrFormState extends State<GiForMrForm> {
  String issueTo = '';
  int quantity = 0;
  int? warehouseId;
  int? styleId;
  String issueType = 'GI for MR';
  DateTime? effectiveDate = DateTime.now();

  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<MaterialRequest> mrs = [];
  List<Stock> stocks = [];

  MaterialRequest? selectedMr;
  Stock? selectedStock;

  int? bodyTypeId;
  String? bodyType;
  List<Map<String, dynamic>> bodyTypeList = [
    {
      'id': 1,
      'name': 'Contrast',
    },
    {
      'id': 2,
      'name': 'General',
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeWarehouse();
  }

  Future<void> _initializeWarehouse() async {
    final prefs = await SharedPreferences.getInstance();
    Warehouse warehouse =
        Warehouse.fromJson(json.decode(prefs.getString('activeWarehouse')!));
    setState(() {
      warehouseId = warehouse.id;
    });
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
              children: [
                if (selectedMr == null)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Search MR',
                      border: OutlineInputBorder(),
                      fillColor: primaryInputColor,
                      filled: true,
                    ),
                    onChanged: (query) {
                      setState(() {
                        mrs = [];
                      });
                      _searchMr(query);
                    },
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mrs.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: mrs.length,
                          itemBuilder: (context, index) {
                            final mr = mrs[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(mr.code),
                                onTap: () {
                                  setState(() {
                                    selectedMr = mr;
                                    mrs = [];
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    if (selectedMr != null && mrs.isEmpty)
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
                                'Material Request Code: ${selectedMr!.code}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                  'Style Code: ${selectedMr!.styleCode ?? 'N/A'}'),
                              Text(
                                  'Material: ${selectedMr!.materialNameWithQty ?? 'N/A'}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      setState(() {
                                        selectedMr = null;
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
                const SizedBox(height: 16.0),
                if (selectedStock == null)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Search SKU',
                      border: OutlineInputBorder(),
                      fillColor: primaryInputColor,
                      filled: true,
                    ),
                    onChanged: (query) {
                      setState(() {
                        stocks = [];
                      });
                      _searchMrStock(query);
                    },
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stocks.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: stocks.length,
                          itemBuilder: (context, index) {
                            final stock = stocks[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(stock.sku),
                                onTap: () {
                                  setState(() {
                                    selectedStock = stock;
                                    stocks = [];
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    if (selectedStock != null && stocks.isEmpty)
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
                                'SKU: ${selectedStock!.sku}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                  'Material Name: ${selectedStock!.materialName ?? 'N/A'}'),
                              Text(
                                  'Quantity: ${selectedStock!.quantity ?? 'N/A'}'),
                              Text(
                                  'Category Name: ${selectedStock!.categoryName ?? 'N/A'}'),
                              Text(
                                  'Supplier Name: ${selectedStock!.supplierName ?? 'N/A'}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      setState(() {
                                        selectedStock = null;
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
                const SizedBox(height: 16.0),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Yardage / QTY',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid number';
                    }
                    final double? quantityValue = double.tryParse(value);
                    if (quantityValue == null) {
                      return 'Please enter a valid number';
                    }
                    if (quantityValue < 0) {
                      return 'Yardage cannot be negative';
                    }

                    // You can add more validation logic for quantity if needed
                    return null;
                  },
                  onSaved: (value) {
                    quantity = int.parse(value!);
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Body Type',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  value: bodyType,
                  onChanged: (value) {
                    setState(() {
                      bodyType = value;
                    });
                  },
                  items: bodyTypeList.map((Map<String, dynamic> item) {
                    return DropdownMenuItem<String>(
                      value: item['name'] as String,
                      child: Text(item['name'] as String),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Issue To (Location)',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  onSaved: (value) {
                    issueTo = value!;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Effective Date',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        effectiveDate = selectedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (effectiveDate == null) {
                      return 'Please select an effective date';
                    }
                    return null;
                  },
                  readOnly: true,
                  controller: TextEditingController(
                    text: effectiveDate != null
                        ? '${effectiveDate!.day}/${effectiveDate!.month}/${effectiveDate!.year}'
                        : '',
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            isLoading = true;
                          });
                          _confirmInputs();
                        },
                  // Hide the button if isLoading is true
                  style: isLoading
                      ? const ButtonStyle().copyWith(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent))
                      : null,
                  // Show a loader if isLoading is true
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white))
                      : const Text(
                          'Issue',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  void _confirmInputs() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      if (effectiveDate == null) {
        setState(() {
          isLoading = false;
        });
        Alerts.showMessage(context, "Please select an effective date");
        return;
      }

      final styleNumber = selectedMr!.styleCode;
      final cutPieces = 0;
      final selectedMaterialId = selectedStock!.id.toString();
      final selectedMrId = selectedMr!.id;

      ApiCalls.issueMaterial(
              selectedMaterialId,
              quantity,
              issueTo,
              warehouseId!,
              styleNumber,
              cutPieces,
              issueType,
              effectiveDate!,
              bodyType,
              selectedMrId)
          .then((response) {
            print(response.body);
        if (response.statusCode == 200) {
          // reset the form
          setState(() {
            isLoading = false;
            quantity = 0;
            issueTo = "";
          });

          Alerts.showSuccessMessage(context, "Material issued successfully");
        } else {
          setState(() {
            isLoading = false;
          });
          Alerts.showMessage(context, "Something went wrong");
        }
      });
    }
  }

  Future<List<MaterialRequest>> fetchMrFromAPI(String query) async {
    final response = await ApiCalls.getMrList(query);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      print(data);
      final mrList = List<MaterialRequest>.from(
          data['mrs'].map((mrJson) => MaterialRequest.fromJson(mrJson)));
      return mrList;
    } else {
      return []; // Return an empty list or handle the error case appropriately
    }
  }

  void _searchMr(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        mrs = [];
      });
      final mrList = await fetchMrFromAPI(query);
      setState(() {
        mrs = mrList;
      });
    }
  }

  Future<List<Stock>> fetchMrStockFromAPI(String query) async {
    final materialId = selectedMr?.materialId;
    final response =
        await ApiCalls.getMrStockList(query, materialId!, warehouseId!);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      print(data);
      final stockList = List<Stock>.from(
          data['stocks'].map((stockJson) => Stock.fromJson(stockJson)));
      return stockList;
    } else {
      return []; // Return an empty list or handle the error case appropriately
    }
  }

  void _searchMrStock(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        stocks = [];
      });
      final stockList = await fetchMrStockFromAPI(query);
      setState(() {
        stocks = stockList;
      });
    }
  }
}
