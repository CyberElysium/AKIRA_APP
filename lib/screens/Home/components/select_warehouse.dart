import 'dart:convert';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectWarehouse extends StatefulWidget {
  const SelectWarehouse({Key? key}) : super(key: key);

  @override
  _SelectWarehouseState createState() => _SelectWarehouseState();
}

class _SelectWarehouseState extends State<SelectWarehouse> {
  List<Warehouse> warehouses = []; // Placeholder for the list of warehouses
  Warehouse? selectedWarehouse; // Placeholder for the selected warehouse

  Future<void> _fetchWarehouses() async {
    try {
      final response = await ApiCalls.getWarehouses();

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final warehouseList = List<Warehouse>.from(data['warehouses']
            .map((warehouseJson) => Warehouse.fromJson(warehouseJson)));
        setState(() {
          warehouses = warehouseList;
        });
      } else {
        Alerts.showMessage(context, "Something went wrong");
      }
    } catch (error) {
      print('Error: $error');
      // Handle error
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWarehouses();
  }

  void selectWarehouse(Warehouse warehouse) {
    setState(() {
      selectedWarehouse = warehouse;
    });
  }

  void _confirmSelection() {
    if (selectedWarehouse != null) {
      ApiCalls.setActiveWarehouse(selectedWarehouse!.id).then((response) async {
        if (!mounted) {
          return;
        }
        print(response.body);
        if (response.statusCode == 200) {
          var data = json.decode(response.body)['data'];
          final warehouse = Warehouse.fromJson(data['warehouse']);
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('activeWarehouse', json.encode(warehouse.toJson()));

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (route) => false,
          );
        } else {
          Alerts.showMessage(context, "Something went wrong");
        }
      });
    }
  }

  Future<void> _refreshData() async {
    // Fetch the warehouses again
    await _fetchWarehouses();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            // color: Colors.grey,
            child: const Center(
              child: Text(
                'Select Warehouse',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: warehouses.length,
              itemBuilder: (BuildContext context, int index) {
                final warehouse = warehouses[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedWarehouse = warehouse;
                    });
                  },
                  child: Material(
                    elevation: selectedWarehouse == warehouse ? 4.0 : 0.0,
                    color: selectedWarehouse == warehouse
                        ? Colors.blue.withOpacity(0.5)
                        : null,
                    child: ListTile(
                      title: Text(warehouse.name),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedWarehouse != null) {
                // Open popup and show selected warehouse data
                _confirmSelection();
              }
            },
            child: const Text('Confirm'),
          ),
          const SizedBox(height: 20.0)
        ],
      ),
    );
  }
}
