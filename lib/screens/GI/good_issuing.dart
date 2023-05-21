import 'dart:convert';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/material_item.dart';
import 'package:akira_mobile/screens/GI/components/material_search_modal.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class GoodIssuing extends StatefulWidget {
  @override
  _GoodIssuingState createState() => _GoodIssuingState();
}

class _GoodIssuingState extends State<GoodIssuing> {
  String selectedMaterialId = '';
  String issueTo = '';
  int quantity = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewController;

  List<MaterialItem> materials = [];

  @override
  void initState() {
    super.initState();

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
                    icon: Icon(Icons.list_alt),
                  ),
                  SizedBox(width: 16.0),
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
                      overlay: QrScannerOverlayShape(
                        borderRadius: 10,
                        borderColor: Colors.red,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: 300,
                      ),
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
      setState(() {
        // Handle scanned QR code data here
        // You can update the selectedMaterial or any other fields based on the scan result
      });
    });
  }

  void _openQR() {
    qrViewController?.toggleFlash();
    qrViewController?.resumeCamera();
  }

  void _confirmInputs() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Inputs'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Material: $selectedMaterialId'),
                Text('Quantity: $quantity'),
                Text('Issue To: $issueTo'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    qrViewController?.dispose();
    super.dispose();
  }
}
