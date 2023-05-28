import 'dart:convert';
import 'dart:io';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/material_item.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/screens/GI/components/material_search_modal.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewController;

  List<MaterialItem> materials = [];

  @override
  void initState() {
    super.initState();
    _initializeWarehouse();
  }

  Future<void> _initializeWarehouse() async {
    final prefs = await SharedPreferences.getInstance();
    Warehouse warehouse = Warehouse.fromJson(json.decode(prefs.getString('activeWarehouse')!));
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
      Alerts.showMessage(context, "Something went wrong");
      return []; // Return an empty list or handle the error case appropriately
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AKIRA Good Issuing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () async {
                      qrViewController?.pauseCamera();
                      final selectedMaterial = await showModalBottomSheet<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return MaterialSearchModal(
                            onSearch: (query) => fetchMaterialsFromAPI(query),
                          );
                        },
                      );
                      if (selectedMaterial != null) {
                        setState(() {
                          selectedMaterialId = selectedMaterial;
                        });
                      }
                      qrViewController?.resumeCamera();
                    },
                    icon: const Icon(Icons.list_alt),
                  ),
                  const SizedBox(width: 16.0),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      // overlay: QrScannerOverlayShape(
                      //   borderRadius: 10,
                      //   borderColor: Colors.red,
                      //   borderLength: 30,
                      //   borderWidth: 10,
                      //   cutOutSize: 300,
                      // ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
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
                decoration: const InputDecoration(
                  labelText: 'Issue To',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  // You can add more validation logic for the issueTo field if needed
                  return null;
                },
                onSaved: (value) {
                  issueTo = value!;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _confirmInputs,
                child: const Text('Issue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrViewController = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      _vibrate(); // Call the vibration method after scanning a code
      _getMaterialBySKU(scanData.code!);
    });
  }

  void _getMaterialBySKU(String code) {
    ApiCalls.getMaterialBySKU(code).then((response) async {
      if (!mounted) {
        return;
      }

      var data = json.decode(response.body)['data'];
      setState(() {
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
    qrViewController?.resumeCamera();
  }

  void _confirmInputs() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (selectedMaterialId.isEmpty) {
        Alerts.showMessage(context, "Please select a material");
        return;
      }

      ApiCalls.issueMaterial(selectedMaterialId, quantity, issueTo, warehouseId!).then((response) {
        if (response.statusCode == 200) {
          Alerts.showMessage(context, "Material issued successfully");
          setState(() {
            selectedMaterialId = '';
            quantity = 0;
            issueTo = '';
          });
        } else {
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
}
