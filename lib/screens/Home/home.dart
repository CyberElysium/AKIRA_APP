// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/screens/Home/components/main_menu.dart';
import 'package:akira_mobile/screens/Home/components/select_warehouse.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  int _selectedIndex = 1;
  Warehouse _activeWarehouse = Warehouse(id: 0, name: '', code: '');

  @override
  void initState() {
    super.initState();

    _checkActiveWarehouse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('AKIRA Inventory System'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {

          },
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'profile',
                  child: Text('Profile'),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 'profile') {
                // Handle profile action
              } else if (value == 'logout') {
                _logout();
              }
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: _getHomeBody(_selectedIndex),
    );
  }

  _checkActiveWarehouse() {
    ApiCalls.getActiveWarehouse().then((response) async {
      if (!mounted) {
        return;
      }

      print(response.statusCode);
      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];

        print(data);

        final warehouse = Warehouse.fromJson(data['warehouse']);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('activeWarehouse', json.encode(warehouse.toJson()));

        setState(() {
          _activeWarehouse = warehouse;
          _selectedIndex = 1;
        });

      } else if (response.statusCode == 204) {
        setState(() {
          _selectedIndex = 0;
        });
      } else {
        Alerts.showMessage(context, "Something went wrong");
      }

      // print(response.statusCode);
    });
  }

  void _logout() {
    ApiCalls.logout().then((response) async {
      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.setBool('isLoggedIn', false);

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      } else {
        Alerts.showMessage(context, "Something went wrong");
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    });
  }

  _getHomeBody(pos) {
    switch (pos) {
      case 0:
        return SelectWarehouse();
      case 1:
        return  MainMenu(_activeWarehouse);
      default:
        return MainMenu(_activeWarehouse);
    }
  }
}
