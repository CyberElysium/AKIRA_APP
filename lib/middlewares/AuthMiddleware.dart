import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMiddleware extends RouteObserver<PageRoute<dynamic>> {
  @override
  Future<void> didPush(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    super.didPush(route, previousRoute);
    if (route is MaterialPageRoute) {
      // Check if the screen requires authentication
      bool isLoggedIn = await _isLoggedIn();
      if (route.settings.name == '/home' && isLoggedIn == false) {
        // Redirect to the login screen if the user is not authenticated
        Navigator.of(route.navigator!.context).pushReplacementNamed('/login');
      }
    }
  }
    Future<bool> _isLoggedIn() async {
      // Check if the user is authenticated
      // You can use SharedPreferences to check if the user is logged in
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    }
}
