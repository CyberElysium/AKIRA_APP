import 'dart:convert';
import 'dart:io';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/stock.dart';
import 'package:akira_mobile/screens/Material/update.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

import 'package:http/http.dart' as http;

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  QRViewController? controller;
  Barcode? result;
  Stock? stock;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool showScanner = true; // Track whether to show the QR scanner or stock data

  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: <Widget>[
          if (showScanner) // Show QR scanner if showScanner is true
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 50,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(
                          10.0), // Add border radius for a rounded look
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add some spacing between the QR scanner and the guideline text
                  const Text(
                    'Please center the camera on the QR code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          if (!showScanner && stock != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  tooltip: 'Take Photo',
                  onPressed: () {
                    // Navigate to the new material update page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MaterialUpdatePage(stock: stock)),
                    );
                  },
                ),
              ),
            ),
          if (!showScanner &&
              stock !=
                  null) // Show stock data if showScanner is false and stock is not null
            Expanded(
              flex: 1,
              child: RefreshIndicator(
                onRefresh: _refreshStockData,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text(
                          'SKU Code:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          stock?.sku ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Material Name:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          stock?.materialName ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Material Code:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          stock?.materialCode ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'UOM:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          stock?.uom ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Category Name:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          stock?.categoryName ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Warehouse Name:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          stock?.warehouseName ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Rate:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          stock?.rate ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Color:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          stock?.color ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Supplier Name:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          stock?.supplierName ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Image:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: stock?.imageUrl != null
                            ? Image.network(
                                stock!.imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!showScanner) // Show the icon button if showScanner is false
            IconButton(
              icon: const Icon(Icons.qr_code),
              tooltip: 'Scan QR Code',
              iconSize: 40,
              onPressed: () {
                setState(() {
                  showScanner =
                      true; // Set showScanner to true to show the QR scanner again
                  stock = null; // Clear previous stock data
                });
              },
            ),
        ],
      ),
    );
  }

  Future<void> _refreshStockData() async {
    _getMaterialBySKU(stock?.sku ?? '');
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    // controller!.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      _vibrate(); // Call the vibration method after scanning a code
      _getMaterialBySKU(scanData.code!);
    });
  }

  void _getMaterialBySKU(String code) {
    ApiCalls.getMaterialBySKUPreview(code).then((response) async {
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

      try {
        var data = json.decode(response.body)['data'];
        setState(() {
          showScanner =
              false; // Set showScanner to false to hide the QR scanner
          stock = Stock.fromJson(data['stock']);
        });
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Something went wrong. Please try again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
