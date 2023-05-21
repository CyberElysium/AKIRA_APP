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
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            controller: _emailController,
            decoration: const InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: "Your password",
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
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String deviceName = Platform.isAndroid ? "android" : "ios";

    if (!Validations.validateString(email)) {
      Alerts.showMessage(context, "Invalid email");
      return;
    }

    if (!Validations.validateString(password)) {
      Alerts.showMessage(context, "Invalid password");
      return;
    }

    ApiCalls.login(email: email, password: password, deviceName: deviceName)
        .then((response) async {
      if (!mounted) {
        return;
      }

      print(response.body);

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
