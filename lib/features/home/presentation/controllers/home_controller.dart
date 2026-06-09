import 'package:get/get.dart';
import '../../domain/usecases/get_counter_usecase.dart';
import '../../domain/usecases/increment_counter_usecase.dart';

class HomeController extends GetxController {
  final GetCounterUseCase _getCounterUseCase;
  final IncrementCounterUseCase _incrementUseCase;

  final count = 0.obs;
  final isLoading = false.obs;

  HomeController(this._getCounterUseCase, this._incrementUseCase);

  @override
  void onInit() {
    super.onInit();
    loadCounter();
  }

  Future<void> loadCounter() async {
    isLoading.value = true;
    try {
      final counter = await _getCounterUseCase.call();
      count.value = counter.value;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> increment() async {
    isLoading.value = true;
    try {
      final updated = await _incrementUseCase.call();
      count.value = updated.value;
    } finally {
      isLoading.value = false;
    }
  }
}
