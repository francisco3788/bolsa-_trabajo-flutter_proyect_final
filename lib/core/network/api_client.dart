import 'package:get/get.dart';

class ApiClient extends GetConnect {
  ApiClient() {
    //httpClient.baseUrl = AppEnv.baseUrl;
    httpClient.timeout = const Duration(seconds: 30);
  }

  Future<Map<String, dynamic>> postRequest(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return Future.value({
      'id': '1',
      'name': 'Usuario Demo',
      'email': body?['email'] ?? 'demo@example.com',
      'token': 'token-demo',
    });
  }

  Future<Map<String, dynamic>> getRequest(String path) {
    return Future.value({
      'id': '1',
      'name': 'Usuario Demo',
      'email': 'demo@example.com',
    });
  }

  Future<void> deleteRequest(String path) {
    return Future.value();
  }
}
