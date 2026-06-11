import 'package:get/get.dart';
import '../controllers/greenhouse_details_controller.dart';

class GreenhouseDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GreenhouseDetailsController());
  }
}
