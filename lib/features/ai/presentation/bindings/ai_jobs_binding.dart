import 'package:get/get.dart';
import '../../ai_module.dart';

class AiJobsBinding extends Bindings {
  @override
  void dependencies() {
    print('AiJobsBinding: Initializing AI module...');
    AiModule.init();
    print('AiJobsBinding: AI module initialization complete!');
  }
}
