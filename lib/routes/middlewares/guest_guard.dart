import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/services/auth_session_service.dart';
import '../app_routes.dart';

class GuestGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final session = Get.find<AuthSessionService>();

    if (!session.isReady) {
      return const RouteSettings(name: AppRoutes.splash);
    }

    if (session.isAuthenticated) {
      if (!session.isRoleReady) {
        return const RouteSettings(name: AppRoutes.splash);
      }

      final role = session.role;
      final target = role == 'company'
          ? AppRoutes.companyHome
          : (role == null || role.isEmpty)
              ? AppRoutes.chooseRole
              : AppRoutes.jobsHome;

      if (route != target) {
        return RouteSettings(name: target);
      }
    }

    return null;
  }

  @override
  int? get priority => -1;
}
