import 'package:get/get.dart';
import '../../../add_greenhouse/data/repositories/greenhouse_repository_impl.dart';
import '../../../add_greenhouse/data/sources/local/greenhouse_local_source.dart';
import '../../../add_greenhouse/domain/repositories/i_greenhouse_repository.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../controllers/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    // Shell controller
    Get.lazyPut<ShellController>(() => ShellController());

    // Greenhouse repository (shared with AddGreenhouseBinding)
    Get.lazyPut<GreenhouseLocalSource>(() => GreenhouseLocalSource());
    Get.lazyPut<IGreenhouseRepository>(
      () => GreenhouseRepositoryImpl(Get.find<GreenhouseLocalSource>()),
    );

    // Home page controller
    Get.lazyPut(
      () => HomeController(Get.find<IGreenhouseRepository>()),
    );
  }
}
