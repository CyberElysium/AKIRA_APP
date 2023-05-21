import 'package:akira_mobile/models/material_item.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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

    fetchMaterials();
    _openQR();
  }

  void fetchMaterials() {
    // Simulating an asynchronous API call to fetch materials
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        // Update the materials list with the fetched data
        materials = [
          MaterialItem(id: '1', name: 'Material 1', quantity: 20),
          MaterialItem(id: '2', name: 'Material 2', quantity: 10),
          MaterialItem(id: '3', name: 'Material 3', quantity: 5),
          MaterialItem(id: '4', name: 'Material 4', quantity: 50),
          MaterialItem(id: '5', name: 'Material 5', quantity: 100),
        ];
      });
    });
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
                    onPressed: () {
                      qrViewController?.pauseCamera();
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 600,
                            child: ListView.builder(
                              itemCount: materials.length,
                              itemBuilder: (BuildContext context, int index) {
                                MaterialItem material = materials[index];
                                return ListTile(
                                  title: Text(material.name),
                                  onTap: () {
                                    setState(() {
                                      selectedMaterialId = material.id;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
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
                child: const Text('Confirm'),
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
