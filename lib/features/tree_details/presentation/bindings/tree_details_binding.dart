import 'package:get/get.dart';
import '../controllers/tree_details_controller.dart';

class TreeDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TreeDetailsController());
  }
}
