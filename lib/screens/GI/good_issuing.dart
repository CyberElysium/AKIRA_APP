import 'dart:convert';
import 'dart:io';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/constants/colors.dart';
import 'package:akira_mobile/models/material_item.dart';
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

class GoodIssuing extends StatefulWidget {
  @override
  _GoodIssuingState createState() => _GoodIssuingState();
}

class _GoodIssuingState extends State<GoodIssuing> {
  String selectedMaterialId = '';
  String issueTo = '';
  int quantity = 0;
  int? warehouseId;
  String issueType = '';
  String styleNumber = '';
  int cutPieces = 0;
  DateTime? effectiveDate = DateTime.now();

  bool showQrScanner = true;
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewController;

  List<MaterialItem> materials = [];
  List<TransactionType> transactionTypes = [];
  MaterialItem? selectedMaterial;

  @override
  void initState() {
    super.initState();
    _initializeWarehouse();
    _fetchTransactionTypes();
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

  Future<List<MaterialItem>> fetchMaterialsFromAPI(String query) async {
    final response = await ApiCalls.getMaterials(query);
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Issue Type',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  items: transactionTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type.id.toString(),
                      child: Text(type.name),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a UOM';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      issueType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Style Number',
                    border: OutlineInputBorder(),
                    fillColor: primaryInputColor,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a style number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    styleNumber = value!;
                  },
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
                    }else{
                      cutPieces = int.parse(value);
                    }
                  },
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
                  onPressed: isLoading ? null : () {
                    setState(() {
                      isLoading = true;
                    });
                    _confirmInputs();
                  },
                  // Hide the button if isLoading is true
                  style: isLoading ? const ButtonStyle().copyWith(backgroundColor: MaterialStateProperty.all(Colors.transparent)) : null,
                  // Show a loader if isLoading is true
                  child: isLoading
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
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
      ),
    );
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

      if (issueType.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Alerts.showMessage(context, "Please select an issue type");
        return;
      }

      if (effectiveDate == null) {
        setState(() {
          isLoading = false;
        });
        Alerts.showMessage(context, "Please select an effective date");
        return;
      }

      ApiCalls.issueMaterial(selectedMaterialId, quantity, issueTo,
              warehouseId!, styleNumber, cutPieces, issueType, effectiveDate!)
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
