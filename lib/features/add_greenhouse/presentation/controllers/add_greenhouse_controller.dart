import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  final _storage = GetStorage();

  /// GetStorage key for the wizard draft.
  static const String _draftKey = 'greenhouse_draft';

  AddGreenhouseController(this._createUseCase);

  // ---- Wizard state ----
  final currentStep = 0.obs;
  final totalSteps = 3;

  // ---- Step labels ----
  static const stepLabels = ['BASIC INFO', 'GREENHOUSE MAP', 'REVIEW & CONFIRM'];

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

  /// Zone positions converted to meters (dividing by scale).
  List<Map<String, dynamic>> get zonesData => zones.map((z) {
        final scale = metersToPixels;
        return {
          'name': z.name,
          'width': (z.rect.width / scale).toStringAsFixed(1),
          'height': (z.rect.height / scale).toStringAsFixed(1),
          'left': (z.rect.left / scale).toStringAsFixed(1),
          'top': (z.rect.top / scale).toStringAsFixed(1),
        };
      }).toList();

  /// Tree positions converted to meters.
  List<Map<String, dynamic>> get treesData => treePlacements.map((t) {
        final scale = metersToPixels;
        return {
          'x': (t.position.dx / scale).toStringAsFixed(1),
          'y': (t.position.dy / scale).toStringAsFixed(1),
          'zoneId': t.zoneId,
        };
      }).toList();

  /// Advance to the next step if the current step is valid.
  void nextStep() {
    _saveDraft(); // persist form data from current step
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

  @override
  void onInit() {
    super.onInit();
    _loadDraft();
  }

  /// Persist current wizard state to GetStorage.
  void _saveDraft() {
    _storage.write(_draftKey, {
      'name': nameController.text,
      'facilityType': selectedFacilityType.value,
      'solarOrientation': selectedSolarOrientation.value,
      'width': widthController.text,
      'length': lengthController.text,
      'sensorType': selectedSensorType.value,
      'sensorCount': sensorCountController.text,
      'zones': zones.map((z) => {
            'id': z.id,
            'name': z.name,
            'left': z.rect.left,
            'top': z.rect.top,
            'width': z.rect.width,
            'height': z.rect.height,
          }).toList(),
      'trees': treePlacements.map((t) => {
            'id': t.id,
            'zoneId': t.zoneId,
            'dx': t.position.dx,
            'dy': t.position.dy,
          }).toList(),
    });
  }

  /// Restore wizard state from GetStorage.
  void _loadDraft() {
    final data = _storage.read<Map>(_draftKey);
    if (data == null) return;
    nameController.text = data['name'] ?? '';
    selectedFacilityType.value = data['facilityType'] ?? '';
    selectedSolarOrientation.value = data['solarOrientation'] ?? '';
    widthController.text = data['width'] ?? '';
    lengthController.text = data['length'] ?? '';
    selectedSensorType.value = data['sensorType'] ?? '';
    sensorCountController.text = data['sensorCount'] ?? '';

    final zoneList = data['zones'] as List?;
    if (zoneList != null) {
      zones.value = zoneList.map((z) => GreenhouseMapZone(
            id: z['id'] as String,
            name: z['name'] as String,
            rect: Rect.fromLTWH(
              (z['left'] as num).toDouble(),
              (z['top'] as num).toDouble(),
              (z['width'] as num).toDouble(),
              (z['height'] as num).toDouble(),
            ),
          )).toList();
    }

    final treeList = data['trees'] as List?;
    if (treeList != null) {
      treePlacements.value = treeList.map((t) => TreePlacement(
            id: t['id'] as String,
            zoneId: t['zoneId'] as String?,
            position: Offset(
              (t['dx'] as num).toDouble(),
              (t['dy'] as num).toDouble(),
            ),
          )).toList();
    }
  }

  /// Add a new zone to the map (rect in canvas pixels).
  void addZone(Rect rect) {
    final id = 'zone_${zones.length + 1}';
    zones.add(GreenhouseMapZone(
      id: id,
      name: 'Zone ${String.fromCharCode(65 + zones.length)}',
      rect: rect,
    ));
    _saveDraft();
  }

  /// Rename a zone by its ID.
  void renameZone(String id, String newName) {
    final index = zones.indexWhere((z) => z.id == id);
    if (index >= 0) {
      final z = zones[index];
      zones[index] = GreenhouseMapZone(
        id: z.id,
        name: newName,
        rect: z.rect,
      );
      _saveDraft();
    }
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
      _saveDraft();
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
    _saveDraft();
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
        zonesData: zonesData,
        treesData: treesData,
      );
      await _createUseCase(greenhouse);
      _storage.remove(_draftKey);
      Get.back(result: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Remove a zone by ID (called from the view in remove mode).
  void removeZone(String id) {
    zones.removeWhere((z) => z.id == id);
    _saveDraft();
  }

  /// Remove a tree by ID.
  void removeTree(String id) {
    treePlacements.removeWhere((t) => t.id == id);
    _saveDraft();
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
