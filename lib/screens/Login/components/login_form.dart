import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/api_calls.dart';
import '../../../constants/colors.dart';
import '../../../constants/styles.dart';
import '../../../models/user.dart';
import '../../../utils/alerts.dart';
import '../../../utils/settings.dart';
import '../../../utils/validations.dart';
import '../../../widgets/already_have_an_account_acheck.dart';
import '../../Home/home.dart';
import 'package:http/http.dart' as http;

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _pinController = TextEditingController();
  final _usernameController = TextEditingController();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (username) {},
            controller: _usernameController,
            decoration: const InputDecoration(
              hintText: "Username",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              controller: _pinController,
              maxLength: 6, // Restrict the PIN to 6 digits
              decoration: const InputDecoration(
                hintText: "PIN (6 digits)",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
              onPressed: () {
                onLogInPress();
              },
              child: Text(
                "Login".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }

  void onLogInPress() {
    String username = _usernameController.text.trim();
    String pin = _pinController.text.trim();
    String deviceName = Platform.isAndroid ? "android" : "ios";

    if (!Validations.validateString(username)) {
      Alerts.showMessage(context, "Invalid username");
      return;
    }

    if (!Validations.validateString(pin) || pin.length != 6) {
      Alerts.showMessage(context, "Invalid PIN. Please enter a 6-digit PIN.");
      return;
    }

    ApiCalls.login(username: username, pin: pin, deviceName: deviceName)
        .then((response) async {
      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['token']);
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/home'),
            builder: (context) {
              return const HomeScreen();
            },
          ),
        );
      } else if (response.statusCode == 422) {
        var message = json.decode(response.body)['message'];
        Alerts.showMessage(context, message);
      } else {
        Alerts.showMessage(context, "Sign up failed");
      }
    });
  }
}
