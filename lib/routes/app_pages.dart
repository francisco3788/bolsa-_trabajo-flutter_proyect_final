import 'package:bolsa_de_trabajo/features/auth/presentation/bindings/forgot_password_binding.dart';
import 'package:bolsa_de_trabajo/features/auth/presentation/bindings/login_binding.dart';
import 'package:bolsa_de_trabajo/features/auth/presentation/bindings/register_binding.dart';
import 'package:bolsa_de_trabajo/features/auth/presentation/bindings/splash_binding.dart';
import 'package:bolsa_de_trabajo/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:bolsa_de_trabajo/features/auth/presentation/pages/login_page.dart';
import 'package:bolsa_de_trabajo/features/auth/presentation/pages/register_page.dart';
import 'package:bolsa_de_trabajo/features/auth/presentation/pages/splash_page.dart';
import 'package:bolsa_de_trabajo/features/company/presentation/bindings/company_home_binding.dart' as company_binding;
import 'package:bolsa_de_trabajo/features/company/presentation/pages/company_home_page.dart';
import 'package:bolsa_de_trabajo/features/jobs/presentation/bindings/jobs_home_binding.dart';
import 'package:bolsa_de_trabajo/features/jobs/presentation/bindings/company_home_binding.dart' as jobs_company_binding;
import 'package:bolsa_de_trabajo/features/jobs/presentation/bindings/company_applications_binding.dart';
import 'package:bolsa_de_trabajo/features/jobs/presentation/pages/jobs_home_page.dart';
import 'package:bolsa_de_trabajo/features/jobs/presentation/pages/dashboard_candidato_page.dart';
import 'package:bolsa_de_trabajo/features/jobs/presentation/pages/dashboard_empresa_page.dart';
import 'package:bolsa_de_trabajo/features/jobs/presentation/pages/publicar_oferta_page.dart';
import 'package:bolsa_de_trabajo/features/jobs/presentation/pages/postulaciones_job_page.dart';
import 'package:bolsa_de_trabajo/features/profile/presentation/bindings/choose_role_binding.dart';
import 'package:bolsa_de_trabajo/features/profile/presentation/pages/choose_role_page.dart';
import 'package:bolsa_de_trabajo/routes/app_routes.dart';
import 'package:bolsa_de_trabajo/routes/middlewares/auth_guard.dart';
import 'package:bolsa_de_trabajo/routes/middlewares/guest_guard.dart';
import 'package:bolsa_de_trabajo/routes/middlewares/role_guard.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.chooseRole,
      page: () => const ChooseRolePage(),
      binding: ChooseRoleBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.jobsHome,
      page: () => const JobsHomePage(),
      binding: JobsHomeBinding(),
      middlewares: [
        AuthGuard(),
        RoleGuard(allowedRoles: ['candidate']),
      ],
    ),
    GetPage(
      name: AppRoutes.companyHome,
      page: () => const CompanyHomePage(),
      binding: company_binding.CompanyHomeBinding(),
      middlewares: [
        AuthGuard(),
        RoleGuard(allowedRoles: ['company']),
      ],
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.forgot,
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
    ),
    // New job-related pages
    GetPage(
      name: AppRoutes.dashboardCandidato,
      page: () => const DashboardCandidatoPage(),
      binding: JobsHomeBinding(),
      middlewares: [
        AuthGuard(),
        RoleGuard(allowedRoles: ['candidate']),
      ],
    ),
    GetPage(
      name: AppRoutes.dashboardEmpresa,
      page: () => const DashboardEmpresaPage(),
      binding: jobs_company_binding.CompanyHomeBinding(),
      middlewares: [
        AuthGuard(),
        RoleGuard(allowedRoles: ['company']),
      ],
    ),
    GetPage(
      name: AppRoutes.publicarOferta,
      page: () => const PublicarOfertaPage(),
      binding: jobs_company_binding.CompanyHomeBinding(),
      middlewares: [
        AuthGuard(),
        RoleGuard(allowedRoles: ['company']),
      ],
    ),
    GetPage(
      name: AppRoutes.postulacionesJob,
      page: () => const PostulacionesJobPage(),
      binding: CompanyApplicationsBinding(),
      middlewares: [
        AuthGuard(),
        RoleGuard(allowedRoles: ['company']),
      ],
    ),
  ];
}
