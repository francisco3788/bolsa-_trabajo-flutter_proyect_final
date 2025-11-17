import 'dart:convert';
import 'package:get/get.dart';
import '../config/app_env.dart';
import '../constants/core_texts.dart';

class ApiClient extends GetConnect {
  ApiClient() {
    final base = AppEnv.baseUrl;
    if (base.isNotEmpty) {
      httpClient.baseUrl = base;
    }
    httpClient.timeout = const Duration(seconds: 30);
    httpClient.defaultContentType = CoreHttp.applicationJson;
    httpClient.addRequestModifier<void>((request) async {
      final token = _authToken;
      if (token != null && token.isNotEmpty) {
        request.headers[CoreHttp.authorizationHeader] = '${CoreHttp.bearerPrefix}$token';
      } else {
        request.headers.remove(CoreHttp.authorizationHeader);
      }
      return request;
    });
  }

  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<Map<String, dynamic>> postRequest(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return post(path, body ?? {}).then((response) {
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        final data = response.body;
        if (data is Map<String, dynamic>) return data;
        if (data is String && data.isNotEmpty) {
          final decoded = json.decode(data);
          return Map<String, dynamic>.from(decoded as Map);
        }
        throw Exception(CoreTexts.invalidResponse);
      }
      throw Exception('HTTP $status: ${response.statusText ?? CoreTexts.httpErrorDefault}');
    });
  }

  Future<Map<String, dynamic>> getRequest(String path) {
    return get(path).then((response) {
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        final data = response.body;
        if (data is Map<String, dynamic>) return data;
        if (data is String && data.isNotEmpty) {
          final decoded = json.decode(data);
          return Map<String, dynamic>.from(decoded as Map);
        }
        throw Exception(CoreTexts.invalidResponse);
      }
      throw Exception('HTTP $status: ${response.statusText ?? CoreTexts.httpErrorDefault}');
    });
  }

  Future<void> deleteRequest(String path) {
    return delete(path).then((response) {
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        return;
      }
      throw Exception('HTTP $status: ${response.statusText ?? CoreTexts.httpErrorDefault}');
    });
  }
}
