import 'dart:convert';
import 'dart:io';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/stock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

class MaterialUpdatePage extends StatefulWidget {
  final Stock? stock;

  const MaterialUpdatePage({Key? key, this.stock}) : super(key: key);

  @override
  _MaterialUpdatePageState createState() => _MaterialUpdatePageState();
}

class _MaterialUpdatePageState extends State<MaterialUpdatePage> {
  File? _image;
  Stock? updatedStock;

  bool _isUploading = false;

  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
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
                        widget.stock?.sku ?? '',
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
                        widget.stock?.materialName ?? '',
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
                        widget.stock?.materialCode ?? '',
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
                        widget.stock?.uom ?? '',
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
                        widget.stock?.categoryName ?? '',
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
                        widget.stock?.warehouseName ?? '',
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
                        widget.stock?.rate ?? '',
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
                        widget.stock?.color ?? '',
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
                        widget.stock?.supplierName ?? '',
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
                      subtitle: widget.stock?.imageUrl != null
                          ? Image.network(
                        updatedStock != null && updatedStock!.imageUrl != null ? updatedStock!.imageUrl! : widget.stock!.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_isUploading)
              Container(
                alignment: Alignment.center,
                child: SpinKitCircle(
                  color: Colors.blue,
                  size: 50.0,
                ),
              ),
            if (_image != null)
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: getImage,
                  icon: Icon(Icons.camera_alt),
                  tooltip: 'Capture Image',
                ),
                if (_image != null) const SizedBox(width: 10),
                IconButton(
                  onPressed: submitImage,
                  icon: Icon(Icons.cloud_upload),
                  tooltip: 'Submit Image',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Future getImage() async {
    setState(() {
      _image = null;
    });

    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void submitImage() {
    setState(() {
      _isUploading = true;
    });

    ApiCalls.uploadImage(_image!,widget.stock?.materialId).then((response) async {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Image uploaded successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        _getMaterialBySKU(widget.stock?.sku ?? '');
      } else {
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    });
  }

  void _getMaterialBySKU(String code) {
    ApiCalls.getMaterialBySKUPreview(code).then((response) async {
      if (!mounted) {
        return;
      }

      if(response.statusCode == 200) {
        var data = json.decode(response.body)['data'];
        setState(() {
          updatedStock = Stock.fromJson(data['stock']);
        });
      }

    });
  }
}
