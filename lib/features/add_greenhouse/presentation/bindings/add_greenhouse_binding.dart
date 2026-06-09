import 'package:get/get.dart';
import '../../data/repositories/greenhouse_repository_impl.dart';
import '../../data/sources/local/greenhouse_local_source.dart';
import '../../domain/repositories/i_greenhouse_repository.dart';
import '../../domain/usecases/create_greenhouse_usecase.dart';
import '../controllers/add_greenhouse_controller.dart';

class AddGreenhouseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GreenhouseLocalSource>(() => GreenhouseLocalSource());
    Get.lazyPut<IGreenhouseRepository>(
      () => GreenhouseRepositoryImpl(Get.find<GreenhouseLocalSource>()),
    );
    Get.lazyPut(
      () => CreateGreenhouseUseCase(Get.find<IGreenhouseRepository>()),
    );
    Get.lazyPut(
      () => AddGreenhouseController(Get.find<CreateGreenhouseUseCase>()),
    );
  }
}
