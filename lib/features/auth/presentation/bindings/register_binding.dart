import 'package:get/get.dart';
import '../../domain/usecases/sign_up_user.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<RegisterController>(RegisterController(Get.find<SignUpUser>()));
  }
}
