import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCalls {
  static const String baseUrl = "http://10.0.2.2:8000/api/";
  // static const String baseUrl = "https://akira.cyberelysium.xyz/api/";

  static _emptyHeaders() {
    return {
      "Accept": "application/json",
      "Content-Type": "application/json"
    };
  }

  static Future<Map<String, String>> _headerWithToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token'); // Get the token from SharedPreferences

    var headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    return headers;
  }

  static Future<Response> allUsers() async {
    var url = Uri.parse("${baseUrl}all/users");
    var response = await get(url);
    return response;
  }

  static Future<Response> login({required String email, required String password, required String deviceName}) async {
    var url = Uri.parse("${baseUrl}login");
    var payload = {
      "email": email,
      "password": password,
      "device_name": deviceName
    };
    var response = await post(url, headers: _emptyHeaders(), body: json.encode(payload));
    return response;
  }

  static Future<Response> logout() async {
    var url = Uri.parse("${baseUrl}user/revoke");
    var headers = await _headerWithToken();
    var response = await get(url, headers: headers);
    return response;
  }

  static Future<Response> getActiveWarehouse() async {
    var url = Uri.parse("${baseUrl}user/active/warehouse");
    var headers = await _headerWithToken();
    var response = await get(url, headers: headers);
    return response;
  }

  static Future<Response> getWarehouses() async {
    var url = Uri.parse("${baseUrl}warehouses/list");
    var headers = await _headerWithToken();
    var response = await get(url, headers: headers);
    return response;
  }

  static Future<Response> setActiveWarehouse(int warehouseId) async {
    var url = Uri.parse("${baseUrl}user/active/warehouse");
    var headers = await _headerWithToken();
    var payload = {
      "warehouse_id": warehouseId
    };
    var response = await post(url, headers: headers, body: json.encode(payload));
    return response;
  }

  static Future<Response> resetWarehouse() async {
    var url = Uri.parse("${baseUrl}user/reset/warehouse");
    var headers = await _headerWithToken();
    var response = await get(url, headers: headers);
    return response;
  }



}
