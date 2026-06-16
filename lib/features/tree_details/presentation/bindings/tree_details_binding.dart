import 'package:get/get.dart';
import 'package:shajra/features/tasks/presentation/controllers/tasks_controller.dart';
import '../controllers/tree_details_controller.dart';

class TreeDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TasksController(), permanent: true);
    Get.lazyPut(() => TreeDetailsController());
  }
}
