import 'package:bolsa_de_trabajo/core/services/auth_session_service.dart';
import 'package:bolsa_de_trabajo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bolsa_de_trabajo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/repositories/auth_repository.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/usecases/get_current_user.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/usecases/login_user.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/usecases/logout_user.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/usecases/resend_email_verification.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/usecases/send_recovery_code.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/usecases/sign_up_user.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/usecases/update_password.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/usecases/verify_recovery_code.dart';
import 'package:bolsa_de_trabajo/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:bolsa_de_trabajo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:bolsa_de_trabajo/features/profile/domain/repositories/profile_repository.dart';
import 'package:bolsa_de_trabajo/features/profile/domain/usecases/get_current_role.dart';
import 'package:bolsa_de_trabajo/features/profile/domain/usecases/save_candidate_profile.dart';
import 'package:bolsa_de_trabajo/features/profile/domain/usecases/save_company_profile.dart';
import 'package:bolsa_de_trabajo/features/profile/domain/usecases/set_user_role.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Injector {
  static void init() {
    final supabase = Supabase.instance.client;

    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceSupabase(supabase),
      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<LoginUser>(() => LoginUser(Get.find()), fenix: true);
    Get.lazyPut<SignUpUser>(() => SignUpUser(Get.find()), fenix: true);
    Get.lazyPut<LogoutUser>(() => LogoutUser(Get.find()), fenix: true);
    Get.lazyPut<SendRecoveryCode>(
      () => SendRecoveryCode(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ResendEmailVerification>(
      () => ResendEmailVerification(Get.find()),
      fenix: true,
    );
    Get.lazyPut<VerifyRecoveryCode>(
      () => VerifyRecoveryCode(Get.find()),
      fenix: true,
    );
    Get.lazyPut<UpdatePassword>(() => UpdatePassword(Get.find()), fenix: true);
    Get.lazyPut<GetCurrentUser>(
      () => GetCurrentUser(repository: Get.find()),
      fenix: true,
    );

    Get.lazyPut<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceSupabase(supabase),
      fenix: true,
    );

    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<GetCurrentRole>(() => GetCurrentRole(Get.find()), fenix: true);
    Get.lazyPut<SetUserRole>(() => SetUserRole(Get.find()), fenix: true);
    Get.lazyPut<SaveCandidateProfile>(
      () => SaveCandidateProfile(Get.find()),
      fenix: true,
    );
    Get.lazyPut<SaveCompanyProfile>(
      () => SaveCompanyProfile(Get.find()),
      fenix: true,
    );

    Get.put<AuthSessionService>(
      AuthSessionService(
        supabaseClient: supabase,
        getCurrentUser: Get.find<GetCurrentUser>(),
        getCurrentRole: Get.find<GetCurrentRole>(),
      ),
      permanent: true,
    );
  }
}
