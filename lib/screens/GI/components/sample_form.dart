import 'dart:convert';
import 'dart:io';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/constants/colors.dart';
import 'package:akira_mobile/models/material_item.dart';
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

class SampleForm extends StatefulWidget {
  @override
  _SampleFormState createState() => _SampleFormState();
}

class _SampleFormState extends State<SampleForm> {
  String selectedMaterialId = '';
  String issueTo = '';
  int quantity = 0;
  int? warehouseId;
  int? styleId;
  String issueType = 'Sample';
  String styleNumber = '';
  int cutPieces = 0;
  DateTime? effectiveDate = DateTime.now();

  bool showQrScanner = true;
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewController;

  List<MaterialItem> materials = [];
  List<Style> styles = [];

  MaterialItem? selectedMaterial;
  Style? selectedStyle;

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
    _openQR();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _openQR();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedMaterialId = '';
                          selectedMaterial = null;
                          showQrScanner = !showQrScanner;
                          if (showQrScanner) {
                            _openQR();
                          } else {
                            qrViewController?.pauseCamera();
                          }
                        });
                      },
                      icon: Icon(
                        showQrScanner ? Icons.qr_code_scanner : Icons.list_alt,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                  ],
                ),
                const SizedBox(height: 16.0),
                if (!showQrScanner && selectedMaterialId.isEmpty)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showQrScanner && selectedMaterialId.isEmpty)
                      SizedBox(
                        height: 200.0,
                        child: QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                        ),
                      )
                    else if (selectedMaterialId.isEmpty && materials.isEmpty)
                      const Center(
                        child: Text('No materials found.'),
                      )
                    else if (selectedMaterialId.isEmpty)
                        SizedBox(
                          height: 200.0,
                          child: ListView.builder(
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
                                  title: Text(material.name_with_code),
                                  onTap: () {
                                    _getStockMaterialById(material.id);
                                  },
                                ),
                              );
                            },
                          ),
                        )
                      else
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
                                Text('UOM: ${selectedMaterial!.uom_name}'),
                                Text(
                                    'Category: ${selectedMaterial!.category_name}'),
                                Text(
                                    'Available Quantity: ${selectedMaterial!.quantity}'),
                                Text('SKU: ${selectedMaterial!.sku}'),
                              ],
                            ),
                          ),
                        )
                  ],
                ),
                const SizedBox(height: 16.0),
                if (selectedStyle == null)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Search Style',
                      border: OutlineInputBorder(),
                      fillColor: primaryInputColor,
                      filled: true,
                    ),
                    onChanged: (query) {
                      setState(() {
                        styles = [];
                      });
                      _searchStyle(query);
                    },
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (styles.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: styles.length,
                          itemBuilder: (context, index) {
                            final style = styles[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(style.nameCode),
                                onTap: () {
                                  setState(() {
                                    selectedStyle = style;
                                    styles = [];
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    if (selectedStyle != null && styles.isEmpty)
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
                                'Style name: ${selectedStyle!.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text('Code: ${selectedStyle!.code}'),
                              Text(
                                  'Description: ${selectedStyle!.description ?? 'N/A'}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      setState(() {
                                        selectedStyle = null;
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
                    if (selectedMaterial != null &&
                        quantityValue >
                            double.parse(selectedMaterial!.quantity)) {
                      return 'Yardage cannot be greater than available quantity';
                    }
                    // You can add more validation logic for quantity if needed
                    return null;
                  },
                  onSaved: (value) {
                    quantity = int.parse(value!);
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cut Pieces',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  onSaved: (value) {
                    if (value == null || value.isEmpty) {
                      cutPieces = 0;
                      return;
                    } else {
                      cutPieces = int.parse(value);
                    }
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

  Future<List<MaterialItem>> fetchMaterialsFromAPI(String query) async {
    final response = await ApiCalls.getMaterials(query);
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      final materialList = List<MaterialItem>.from(data['materials']
          .map((materialJson) => MaterialItem.fromJson(materialJson)));
      return materialList;
    } else {
      // Alerts.showMessage(context, "Something went wrong");
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

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrViewController = controller;
    });
    if (showQrScanner) {
      controller.scannedDataStream.listen((scanData) {
        _vibrate(); // Call the vibration method after scanning a code
        _getMaterialBySKU(scanData.code!);
      });
    }
  }

  void _getMaterialBySKU(String code) {
    ApiCalls.getMaterialBySKU(code).then((response) async {
      if (!mounted) {
        return;
      }

      if (response.statusCode == 404) {
        Fluttertoast.showToast(
          msg: "No Material found.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      if (response.statusCode == 204) {
        Fluttertoast.showToast(
          msg: "Material not found in this warehouse.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      var data = json.decode(response.body)['data'];
      setState(() {
        selectedMaterial = MaterialItem.fromJson(data['stock']);
        selectedMaterialId = data['stock']['id'].toString();
      });
    });
  }

  void _getStockMaterialById(int materialId) {
    ApiCalls.getStockMaterialById(materialId).then((response) async {
      if (!mounted) {
        return;
      }

      var data = json.decode(response.body)['data'];
      print(data['stock']);
      setState(() {
        selectedMaterial = MaterialItem.fromJson(data['stock']);
        selectedMaterialId = data['stock']['id'].toString();
      });
    });
  }

  void _vibrate() {
    if (kIsWeb) return; // Vibration is not supported on web platforms
    if (Platform.isIOS) {
      Vibration.vibrate(duration: 100);
    } else if (Platform.isAndroid) {
      Vibration.vibrate();
    }
  }

  void _openQR() {
    qrViewController?.toggleFlash();
    if (showQrScanner) {
      qrViewController?.resumeCamera();
    }
  }

  void _confirmInputs() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      if (selectedMaterialId.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Alerts.showMessage(context, "Please select a material");
        return;
      }

      if (effectiveDate == null) {
        setState(() {
          isLoading = false;
        });
        Alerts.showMessage(context, "Please select an effective date");
        return;
      }

      styleNumber = selectedStyle!.code;

      ApiCalls.issueMaterial(selectedMaterialId, quantity, issueTo,
          warehouseId!, styleNumber, cutPieces, issueType, effectiveDate!, bodyType)
          .then((response) {
        if (response.statusCode == 200) {
          // reset the form
          setState(() {
            selectedMaterial = null;
            selectedMaterialId = "";
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

  @override
  void dispose() {
    qrViewController?.dispose();
    super.dispose();
  }

  Future<List<Style>> fetchStyleFromAPI(String query) async {
    final response = await ApiCalls.getStyleList(query);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      print(data);
      final styleList = List<Style>.from(
          data['styles'].map((supplierJson) => Style.fromJson(supplierJson)));
      return styleList;
    } else {
      return []; // Return an empty list or handle the error case appropriately
    }
  }

  void _searchStyle(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        styles = [];
      });
      final styleList = await fetchStyleFromAPI(query);
      setState(() {
        styles = styleList;
      });
    }
  }
}
