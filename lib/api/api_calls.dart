import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCalls {
  // static const String baseUrl = "http://10.0.2.2:8000/api/";
  static const String baseUrl = "https://akira.cyberelysium.xyz/api/";

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

  static Future<Response> login({required String username, required String pin, required String deviceName}) async {
    var url = Uri.parse("${baseUrl}login");
    var payload = {
      "username": username,
      "pin": pin,
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

  static Future<Response> getMaterials(query) async {
    var url = Uri.parse("${baseUrl}materials/list?query=$query");
    var headers = await _headerWithToken();
    var response = await get(url, headers: headers);
    return response;
  }

  static Future<Response> getMaterialBySKU(String code) async {
    var url = Uri.parse("${baseUrl}materials/by-sku/$code");
    var headers = await _headerWithToken();
    var response = await get(url, headers: headers);
    return response;
  }

  static Future<Response> issueMaterial(String materialId, int quantity,String issueTo, int warehouseId) async {
    var url = Uri.parse("${baseUrl}gi/issue");
    var headers = await _headerWithToken();
    var payload = {
      "stock_id": materialId,
      "qty": quantity,
      "issue_to": issueTo,
      "warehouse_id": warehouseId
    };
    var response = await post(url, headers: headers, body: json.encode(payload));
    return response;
  }



}
