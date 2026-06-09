import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/greenhouse_entity.dart';
import '../../domain/usecases/create_greenhouse_usecase.dart';

/// A zone drawn within the greenhouse floor on the map canvas.
class GreenhouseMapZone {
  final String id;
  final String name;
  final Rect rect;

  GreenhouseMapZone({
    required this.id,
    required this.name,
    required this.rect,
  });
}

/// A tree placed on the greenhouse map.
class TreePlacement {
  final String id;
  final String? zoneId;
  final Offset position;

  const TreePlacement({
    required this.id,
    this.zoneId,
    required this.position,
  });
}

/// Active tool on the map canvas.
enum MapTool { select, addZone, addTree, addSensor }

/// Controller that manages the three-step greenhouse creation wizard.
class AddGreenhouseController extends GetxController {
  final CreateGreenhouseUseCase _createUseCase;
  final pageController = PageController(initialPage: 0);

  AddGreenhouseController(this._createUseCase);

  // ---- Wizard state ----
  final currentStep = 0.obs;
  final totalSteps = 3;

  // ---- Step labels ----
  static const stepLabels = ['BASIC INFO', 'GREENHOUSE MAP', 'SENSOR SETUP'];

  // ---- Form data (step 1) ----
  final nameController = TextEditingController();
  final selectedFacilityType = ''.obs;
  final selectedSolarOrientation = ''.obs;
  final widthController = TextEditingController();
  final lengthController = TextEditingController();
  final descriptionController = TextEditingController();

  static const facilityTypes = ['Glasshouse', 'Polytunnel', 'Vertical Farm', 'Growth Chamber'];
  static const solarOrientations = ['North-South Alignment', 'East-West Alignment', 'Multi-Span'];

  // ---- Sensor data (step 3) ----
  final selectedSensorType = ''.obs;
  final sensorCountController = TextEditingController();

  // ---- Map state (step 2) ----
  final zones = <GreenhouseMapZone>[].obs;
  final treePlacements = <TreePlacement>[].obs;
  final selectedTool = Rx<MapTool>(MapTool.addZone);
  final transformationController = TransformationController();

  // ---- Submission state ----
  final isSubmitting = false.obs;

  bool get isFirstStep => currentStep.value == 0;
  bool get isLastStep => currentStep.value == totalSteps - 1;

  String get currentStepLabel => stepLabels[currentStep.value];

  /// Advance to the next step if the current step is valid.
  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Go back one step.
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Scale factor: 1 meter = 15 pixels on the canvas.
  static const double metersToPixels = 15.0;

  /// Floor dimensions from Step 1, converted to canvas pixels.
  /// Falls back to a default 600×400 if parsing fails.
  double get greenhouseFloorWidthPixels {
    final meters = double.tryParse(widthController.text) ?? 0;
    if (meters <= 0) return 600;
    return (meters * metersToPixels).clamp(300, 3000);
  }

  double get greenhouseFloorHeightPixels {
    final meters = double.tryParse(lengthController.text) ?? 0;
    if (meters <= 0) return 400;
    return (meters * metersToPixels).clamp(200, 3000);
  }

  /// Cancel the wizard.
  void cancel() {
    Get.back();
  }

  /// Add a new zone to the map (rect in canvas pixels).
  void addZone(Rect rect) {
    final id = 'zone_${zones.length + 1}';
    zones.add(GreenhouseMapZone(
      id: id,
      name: 'Zone ${String.fromCharCode(65 + zones.length)}',
      rect: rect,
    ));
  }

  /// Shift a zone by [dx, dy] pixels to support drag-to-move.
  void moveZone(String id, double dx, double dy) {
    final index = zones.indexWhere((z) => z.id == id);
    if (index >= 0) {
      final z = zones[index];
      zones[index] = GreenhouseMapZone(
        id: z.id,
        name: z.name,
        rect: z.rect.shift(Offset(dx, dy)),
      );
    }
  }

  /// Add a tree at the given position (relative to the virtual floor).
  void addTree(Offset position, {String? zoneId}) {
    final id = 'tree_${treePlacements.length + 1}';
    treePlacements.add(TreePlacement(
      id: id,
      zoneId: zoneId,
      position: position,
    ));
  }

  /// Zoom in by 25%.
  void zoomIn() {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.25).clamp(0.5, 4.0);
    final matrix = Matrix4.diagonal3Values(newScale, newScale, 1);
    transformationController.value = matrix;
  }

  /// Zoom out by 20%.
  void zoomOut() {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.25).clamp(0.5, 4.0);
    final matrix = Matrix4.diagonal3Values(newScale, newScale, 1);
    transformationController.value = matrix;
  }

  /// Submit the greenhouse and navigate back.
  Future<void> submit() async {
    isSubmitting.value = true;
    try {
      final greenhouse = GreenhouseEntity(
        name: nameController.text.trim(),
        description: '',
        facilityType: selectedFacilityType.value,
        solarOrientation: selectedSolarOrientation.value,
        width: double.tryParse(widthController.text) ?? 0,
        length: double.tryParse(lengthController.text) ?? 0,
        sensorType: selectedSensorType.value.isNotEmpty
            ? selectedSensorType.value
            : null,
        sensorCount: int.tryParse(sensorCountController.text),
      );
      await _createUseCase(greenhouse);
      Get.back(result: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    transformationController.dispose();
    nameController.dispose();
    widthController.dispose();
    lengthController.dispose();
    sensorCountController.dispose();
    super.onClose();
  }
}
