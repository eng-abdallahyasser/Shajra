import 'package:get/get.dart';
import '../../../home/data/repositories/counter_repository_impl.dart';
import '../../../home/data/sources/local/counter_local_source.dart';
import '../../../home/domain/repositories/i_counter_repository.dart';
import '../../../home/domain/usecases/get_counter_usecase.dart';
import '../../../home/domain/usecases/increment_counter_usecase.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../controllers/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    // Shell controller
    Get.lazyPut<ShellController>(() => ShellController());

    // Home page dependencies
    Get.lazyPut<CounterLocalSource>(() => CounterLocalSource());
    Get.lazyPut<ICounterRepository>(
      () => CounterRepositoryImpl(Get.find<CounterLocalSource>()),
    );
    Get.lazyPut(
      () => GetCounterUseCase(Get.find<ICounterRepository>()),
    );
    Get.lazyPut(
      () => IncrementCounterUseCase(Get.find<ICounterRepository>()),
    );
    Get.lazyPut(
      () => HomeController(
        Get.find<GetCounterUseCase>(),
        Get.find<IncrementCounterUseCase>(),
      ),
    );
  }
}
