import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/services/auth_session_service.dart';
import '../../core/constants/roles.dart';
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
      final target = role == Roles.company
          ? AppRoutes.dashboardCompany
          : (role == null || role.isEmpty)
              ? AppRoutes.chooseRole
              : AppRoutes.dashboardCandidate;

      if (route != target) {
        return RouteSettings(name: target);
      }
    }

    return null;
  }

  @override
  int? get priority => -1;
}
