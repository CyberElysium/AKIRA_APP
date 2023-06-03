import 'package:akira_mobile/api/api_calls.dart';
import 'package:akira_mobile/models/warehouse.dart';
import 'package:akira_mobile/screens/GI/good_issuing.dart';
import 'package:akira_mobile/screens/GRN/create.dart';
import 'package:akira_mobile/screens/Material/create.dart';
import 'package:akira_mobile/screens/Preview/scan_page.dart';
import 'package:akira_mobile/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenu extends StatefulWidget {
  final Warehouse activeWarehouse;

  const MainMenu(this.activeWarehouse, {Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'to ${widget.activeWarehouse.name}',
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: _resetConfirmation,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _scanQR();
                      },
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 5,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 80,
                                color: Colors.black,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Scan QR Code',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoodIssuing(),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 5,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.shopping_bag,
                                size: 80,
                                color: Colors.black,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Goods Issuing',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateMaterial(),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 5,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_box,
                                size: 80,
                                color: Colors.black,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Create Material',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateGRN(),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 5,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.grain,
                                size: 80,
                                color: Colors.black,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'GRN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),

      ],
    );
  }

  void _scanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanPage(),
      ),
    );
  }

  Future<void> _resetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
              'Are you sure.. you want to reset warehouse selection?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Return false if not confirmed
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Return true if confirmed
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Call reset API
      _resetAPI();
    }
  }

  void _resetAPI() {
    ApiCalls.resetWarehouse().then((response) async {
      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('activeWarehouse');

        setState(() {
          widget.activeWarehouse.id = 0;
          widget.activeWarehouse.name = '';
          widget.activeWarehouse.code = '';
        });

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false,
        );
      } else {
        Alerts.showMessage(context, 'Something went wrong');
      }
    });
  }
}
