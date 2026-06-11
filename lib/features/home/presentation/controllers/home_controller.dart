import 'package:get/get.dart';
import '../../../add_greenhouse/domain/entities/greenhouse_entity.dart';
import '../../../add_greenhouse/domain/repositories/i_greenhouse_repository.dart';

class HomeController extends GetxController {
  final IGreenhouseRepository _greenhouseRepo;

  final greenhouses = <GreenhouseEntity>[].obs;
  final isLoading = false.obs;

  HomeController(this._greenhouseRepo);

  @override
  void onInit() {
    super.onInit();
    loadGreenhouses();
  }

  Future<void> loadGreenhouses() async {
    isLoading.value = true;
    try {
      final result = await _greenhouseRepo.getAll();
      greenhouses.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  int get zoneCount => greenhouses.fold(0, (sum, g) => sum + g.zonesData.length);

  int get treeCount => greenhouses.fold(0, (sum, g) => sum + g.treesData.length);
}
