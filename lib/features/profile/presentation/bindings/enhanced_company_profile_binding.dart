import 'package:get/get.dart';

import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_enhanced_company_profile.dart';
import '../../domain/usecases/save_enhanced_company_profile.dart';
import '../../domain/usecases/upload_company_logo.dart';
import '../controllers/enhanced_company_profile_controller.dart';

class EnhancedCompanyProfileBinding implements Bindings {
  @override
  void dependencies() {
    // Data sources
    Get.lazyPut<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceSupabase(Get.find()),
    );

    // Repository
    Get.lazyPut<ProfileRepositoryImpl>(
      () => ProfileRepositoryImpl(Get.find()),
    );

    // Use cases
    Get.lazyPut<GetEnhancedCompanyProfile>(
      () => GetEnhancedCompanyProfile(Get.find<ProfileRepositoryImpl>()),
    );
    Get.lazyPut<SaveEnhancedCompanyProfile>(
      () => SaveEnhancedCompanyProfile(Get.find<ProfileRepositoryImpl>()),
    );
    Get.lazyPut<UploadCompanyLogo>(
      () => UploadCompanyLogo(Get.find<ProfileRepositoryImpl>()),
    );

    // Controller
    Get.lazyPut<EnhancedCompanyProfileController>(
      () => EnhancedCompanyProfileController(
        getEnhancedCompanyProfile: Get.find(),
        saveEnhancedCompanyProfile: Get.find(),
        uploadCompanyLogo: Get.find(),
      ),
    );
  }
}