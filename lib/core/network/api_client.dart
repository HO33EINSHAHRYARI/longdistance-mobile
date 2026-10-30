import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _getHeaders({bool isJson = true}) async {
    final token = await getToken();
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json; charset=utf-8';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> get(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      Uri uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
      }
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw Exception('خطا در برقراری ارتباط با سرور: $e');
    }
  }

  static Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders();
      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw Exception('خطا در برقراری ارتباط با سرور: $e');
    }
  }

  static dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyString = utf8.decode(response.bodyBytes);
    
    dynamic data;
    try {
      data = jsonDecode(bodyString);
    } catch (_) {
      data = {'raw': bodyString};
    }

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    } else if (statusCode == 401) {
      throw Exception('نشست کاربری شما منقضی شده است. لطفا مجددا وارد شوید.');
    } else if (statusCode == 403) {
      throw Exception(data is Map && data.containsKey('error') ? data['error'] : 'دسترسی محدود است');
    } else {
      final errorMsg = data is Map && data.containsKey('error') ? data['error'] : 'خطای سرور ($statusCode)';
      throw Exception(errorMsg);
    }
  }
}
