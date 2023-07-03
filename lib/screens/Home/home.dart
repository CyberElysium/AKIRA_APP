// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/screens/Home/components/geometric_loading_screen.dart';
import 'package:akira_mobile/screens/Home/components/main_menu.dart';
import 'package:akira_mobile/screens/Home/components/select_warehouse.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  int _selectedIndex = 1;
  int _loadView = 1;
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
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: const Icon(Icons.menu),
        //   onPressed: () {},
        // ),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loadView == 1) {
      // Show loading screen with custom design
      return Container(
        color: Colors.white, // Set the background color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              // Add spinning loading indicator from flutter_spinkit
              SpinKitCircle(
                color: Colors.blue, // Customize the color of the spinner
                size: 80.0, // Customize the size of the spinner
              ),
              SizedBox(height: 8), // Add spacing between elements
              Text(
                'Please wait while the data is loading',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Show home body based on selected index
      return _getHomeBody(_selectedIndex);
    }
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
          _loadView = 0;
        });
      } else if (response.statusCode == 204) {
        setState(() {
          _selectedIndex = 0;
          _loadView = 0;
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
        return const SelectWarehouse();
      case 1:
        return MainMenu(_activeWarehouse);
      default:
        return MainMenu(_activeWarehouse);
    }
  }
}
