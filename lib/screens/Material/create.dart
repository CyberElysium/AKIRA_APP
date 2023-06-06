import 'dart:convert';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/category.dart';
import 'package:akira_mobile/models/supplier.dart';
import 'package:akira_mobile/models/uom.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateMaterial extends StatefulWidget {
  @override
  _CreateMaterialState createState() => _CreateMaterialState();
}

class _CreateMaterialState extends State<CreateMaterial> {
  int? warehouseId;

  final _formKey = GlobalKey<FormState>();

  bool withGRN = false;

  String name = '';
  String uom = '';
  String category = '';
  double rate = 0;
  String supplier = '';
  String color = '';
  double width = 0;
  double height = 0;
  double length = 0;
  double size = 0;
  double weight = 0;
  double quantity = 0;
  String location = '';
  String batch = '';
  String invoice = '';
  DateTime? effDate;

  List<UOM> uomOptions = [];
  List<Category> categoryOptions = [];
  List<Supplier> supplierOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchUOMOptions();
    _fetchCategoryOptions();
    _fetchSupplierOptions();
    _initializeWarehouse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Material'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'UOM'),
                  items: uomOptions.map((uom) {
                    return DropdownMenuItem<String>(
                      value: uom.id.toString(),
                      child: Text(uom.name),
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
                      uom = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categoryOptions.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id.toString(),
                      child: Text(category.name),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      category = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Rate'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a rate';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      rate = double.parse(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Supplier'),
                  items: supplierOptions.map((supplier) {
                    return DropdownMenuItem<String>(
                      value: supplier.id.toString(),
                      child: Text(supplier.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      supplier = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Color'),
                  onChanged: (value) {
                    setState(() {
                      color = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'WIDTH (inches)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      width = double.parse(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'HEIGHT (inches)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      height = double.parse(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'LENGTH (inches)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      length = double.parse(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'SIZE (inches)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      size = double.parse(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'WEIGHT (kg)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      weight = double.parse(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('WITH GRN'),
                  value: withGRN,
                  onChanged: (value) {
                    setState(() {
                      withGRN = value;
                    });
                  },
                ),
                if (withGRN)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'QUANTITY'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a quantity';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            quantity = double.parse(value);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'LOCATION'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            location = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'BATCH'),
                        onChanged: (value) {
                          setState(() {
                            batch = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'INVOICE'),
                        onChanged: (value) {
                          setState(() {
                            invoice = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'EFF DATE'),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          setState(() {
                            effDate = pickedDate;
                          });
                        },
                        readOnly: true,
                        controller: TextEditingController(
                          text: effDate != null ? DateFormat('yyyy-MM-dd').format(effDate!) : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: submitForm,
                  child: const Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
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

  Future<void> _fetchUOMOptions() async {
    try {
      final response = await ApiCalls.getUOMs();

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final uomOptionsList = List<UOM>.from(
            data['uoms'].map((warehouseJson) => UOM.fromJson(warehouseJson)));
        setState(() {
          uomOptions = uomOptionsList;
        });
      } else {
        Alerts.showMessage(context, "Something went wrong");
      }
    } catch (error) {
      print('Error: $error');
      // Handle error
    }
  }

  Future<void> _fetchCategoryOptions() async {
    try {
      final response = await ApiCalls.getCategories();

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final categoryOptionsList = List<Category>.from(data['categories']
            .map((warehouseJson) => Category.fromJson(warehouseJson)));
        setState(() {
          categoryOptions = categoryOptionsList;
        });
      } else {
        Alerts.showMessage(context, "Something went wrong");
      }
    } catch (error) {
      print('Error: $error');
      // Handle error
    }
  }

  Future<void> _fetchSupplierOptions() async {
    try {
      final response = await ApiCalls.getSuppliers();

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final supplierOptionsList = List<Supplier>.from(data['suppliers']
            .map((warehouseJson) => Supplier.fromJson(warehouseJson)));
        setState(() {
          supplierOptions = supplierOptionsList;
        });
      } else {
        Alerts.showMessage(context, "Something went wrong");
      }
    } catch (error) {
      print('Error: $error');
      // Handle error
    }
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      // Perform form submission and show confirm popup with added data
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Name: $name'),
                Text('UOM: $uom'),
                Text('Category: $category'),
                Text('Rate: $rate'),
                Text('Supplier: $supplier'),
                Text('Color: $color'),
                Text('Width: $width'),
                Text('Height: $height'),
                Text('Length: $length'),
                Text('Size: $size'),
                Text('Weight: $weight'),
                if (withGRN)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: $quantity'),
                      Text('Location: $location'),
                      Text('Batch: $batch'),
                      Text('Invoice: $invoice'),
                      Text('Eff Date: ${effDate.toString()}'),
                    ],
                  ),
              ],
            ),
            actions: [
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _createMaterial();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text(
                      'Submit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 6),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }

  void _createMaterial() {
    ApiCalls.createMaterial(
      name: name,
      uom: uom,
      category: category,
      rate: rate,
      supplier: supplier,
      color: color,
      width: width,
      height: height,
      length: length,
      size: size,
      weight: weight,
      quantity: quantity,
      location: location,
      batch: batch,
      invoice: invoice,
      effDate: effDate,
      warehouseId: warehouseId,
    ).then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        Alerts.showSuccessMessage(context, "Material created successfully");

      } else {
        if (response.statusCode == 401) {
          Alerts.showMessage(
              context, json.decode(response.body)['message']);
        } else {
          Alerts.showMessage(context, "Something went wrong");
        }
      }
    });
  }
}
