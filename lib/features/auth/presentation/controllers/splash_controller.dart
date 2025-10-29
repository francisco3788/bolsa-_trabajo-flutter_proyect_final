import 'package:get/get.dart';

import '../../../../core/services/auth_session_service.dart';
import '../../../../routes/app_routes.dart';

class SplashController extends GetxController {
  SplashController(this._sessionService);

  final AuthSessionService _sessionService;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _sessionService.init();
    _sessionService.syncWithRouter(
      publicRoutes: {
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgot,
        AppRoutes.chooseRole,
      }.toSet(),
      unauthenticatedRoute: AppRoutes.login,
      authenticatedRoute: AppRoutes.dashboardCandidato,
      authenticatedRouteResolver: (_, currentRole) {
        if (currentRole == null || currentRole.isEmpty) {
          return AppRoutes.chooseRole;
        }
        return currentRole == 'company'
            ? AppRoutes.dashboardEmpresa
            : AppRoutes.dashboardCandidato;
      },
    );
    if (!_sessionService.isAuthenticated) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }
  }
}
