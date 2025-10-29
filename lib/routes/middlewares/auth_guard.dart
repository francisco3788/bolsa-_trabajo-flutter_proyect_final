import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/services/auth_session_service.dart';
import '../app_routes.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final session = Get.find<AuthSessionService>();

    if (!session.isReady) {
      return const RouteSettings(name: AppRoutes.splash);
    }

    if (!session.isAuthenticated) {
      if (route != AppRoutes.login) {
        return const RouteSettings(name: AppRoutes.login);
      }
    }

    return null;
  }

  @override
  int? get priority => 0;
}
