import 'package:get/get.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/greenhouse_entity.dart';

class GreenhouseDetailsController extends GetxController {
  late final GreenhouseEntity greenhouse;

  @override
  void onInit() {
    super.onInit();
    greenhouse = Get.arguments as GreenhouseEntity;
  }
}
