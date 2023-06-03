import 'dart:io';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/stock.dart';
import 'package:flutter/material.dart';
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

  final picker = ImagePicker();

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
    ApiCalls.uploadImage(_image!,widget.stock?.materialId).then((response) async {
      if (!mounted) {
        return;
      }

      print('Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Image uploaded successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    });
  }

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
                              widget.stock!.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
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
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Capture Image'),
            ),
            if (_image != null) SizedBox(height: 10),
            ElevatedButton(
              onPressed: submitImage,
              child: const Text('Submit Image'),
            ),
          ],
        ),
      ),
    );
  }
}
