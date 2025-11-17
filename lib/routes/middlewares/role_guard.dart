import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/services/auth_session_service.dart';
import '../../core/constants/roles.dart';
import '../app_routes.dart';

class RoleGuard extends GetMiddleware {
  RoleGuard({this.allowedRoles});

  final List<String>? allowedRoles;

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
      return null;
    }

    if (!session.isRoleReady) {
      return const RouteSettings(name: AppRoutes.splash);
    }

    final currentRole = session.role;

    if (currentRole == null || currentRole.isEmpty) {
      // When the role is not ready or absent, delegate the decision to Splash
      // to avoid rendering /choose-role intermittently.
      if (route != AppRoutes.splash) {
        return const RouteSettings(name: AppRoutes.splash);
      }
      return null;
    }

    if (allowedRoles != null &&
        allowedRoles!.isNotEmpty &&
        !allowedRoles!.contains(currentRole)) {
      if (currentRole == Roles.company) {
        return const RouteSettings(name: AppRoutes.dashboardCompany);
      }
      return const RouteSettings(name: AppRoutes.dashboardCandidate);
    }

    return null;
  }

  @override
  int? get priority => 0;
}
