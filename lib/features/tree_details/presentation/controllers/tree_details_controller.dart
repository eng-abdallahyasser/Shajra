import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/greenhouse_entity.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/tree_data.dart';
import 'package:shajra/features/tasks/domain/entities/task_entity.dart';
import 'package:shajra/features/tasks/presentation/controllers/tasks_controller.dart';
import '../../data/repositories/scan_log_repository.dart';
import '../../data/repositories/tree_observation_repository.dart';
import '../../domain/entities/scan_log_entity.dart';
import '../../domain/entities/tree_observation_data.dart';
import '../../domain/entities/tree_observation_entity.dart';
import '../services/mango_disease_service.dart';

class TreeDetailsController extends GetxController {
  final ScanLogRepository _logRepo = ScanLogRepository();
  final TreeObservationRepository _obsRepo = TreeObservationRepository();
  final MangoDiseaseService _diseaseService = MangoDiseaseService.instance;
  final ImagePicker _picker = ImagePicker();

  // ── Passed arguments ──
  late final TreeData tree;
  late final GreenhouseEntity greenhouse;

  // ── Scan state ──
  final logs = <ScanLogEntity>[].obs;
  final isModelLoaded = false.obs;
  final isScanning = false.obs;
  final modelError = Rxn<String>();

  // ── Observation state ──
  final observations = <TreeObservationEntity>[].obs;
  final expandedCategory = Rxn<String>();
  final pendingProblems = <String>[].obs;
  final pendingActions = <String>[].obs;
  final isSavingObs = false.obs;
  final notesController = TextEditingController();

  // ── Observation image state ──
  final obsImagePath = Rxn<String>();

  // ── Schedule task state ──
  final scheduleTaskTitle = Rxn<String>();
  final scheduleTaskDueDate = Rxn<DateTime>();
  final scheduleTaskPriority = Rx<TaskPriority>(TaskPriority.medium);
  final shouldScheduleTask = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    tree = args['tree'] as TreeData;
    greenhouse = args['greenhouse'] as GreenhouseEntity;
    _initModel();
    _loadLogs();
    _loadObservations();
  }

  Future<void> _initModel() async {
    try {
      await _diseaseService.loadModel();
      isModelLoaded.value = true;
    } catch (e) {
      modelError.value = 'Failed to load AI model: $e';
    }
  }

  /// Reload scan logs for the current tree.
  void _loadLogs() {
    logs.value = _logRepo.fetchByTreeId(tree.id);
  }

  /// Take a leaf photo using the camera and run inference.
  Future<void> scanLeaf() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo == null) return;

      isScanning.value = true;

      debugPrint('[TreeDetailsController] Starting scan for tree: ${tree.id}');
      final file = File(photo.path);
      final result = await _diseaseService.predict(file);

      debugPrint('[TreeDetailsController] Scan complete: $result');

      final log = ScanLogEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        treeId: tree.id,
        scannedAt: DateTime.now(),
        imagePath: photo.path,
        confidence: result.confidence,
        predictedClass: result.predictedClass,
      );
      await _logRepo.insert(log);

      _loadLogs();
    } catch (e, stack) {
      debugPrint('[TreeDetailsController] Scan FAILED: $e\n$stack');
      Get.snackbar(
        'Scan Failed',
        'Could not complete the scan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
    } finally {
      isScanning.value = false;
    }
  }

  /// View the full-size image from a log entry.
  void viewImage(String imagePath) {
    if (imagePath.isEmpty) return;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  /// Delete a single log entry.
  Future<void> deleteLog(ScanLogEntity log) async {
    await _logRepo.delete(tree.id, log.id);
    _loadLogs();
  }

  /// Clear all scan logs for this tree.
  Future<void> clearAllLogs() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear All Logs'),
        content: const Text('This will remove all scan records for this tree. Continue?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Clear')),
        ],
      ),
    );
    if (confirm == true) {
      await _logRepo.deleteAll(tree.id);
      _loadLogs();
    }
  }

  /// Find the zone name for this tree.
  String get zoneName {
    if (tree.zoneId == null) return 'Not assigned';
    final zone = greenhouse.zonesData.firstWhereOrNull(
      (z) => z.id == tree.zoneId,
    );
    return zone?.name ?? 'Not assigned';
  }

  /// Parse greenhouse number from the tree Micro-Tagging ID.
  String get ghNumber {
    if (tree.id.startsWith('G')) {
      final parts = tree.id.split('-');
      if (parts.isNotEmpty) return parts[0].substring(1);
    }
    return '';
  }

  /// Latest scan result, if any.
  ScanLogEntity? get latestScan => logs.isNotEmpty ? logs.first : null;

  // ═══════════════════════════════════════════════
  //  Observation methods
  // ═══════════════════════════════════════════════

  /// Reload observations from the repository.
  void _loadObservations() {
    observations.value = _obsRepo.fetchByTreeId(tree.id);
  }

  /// Toggle expanded state for a category card.
  void toggleCategory(String categoryKey) {
    if (expandedCategory.value == categoryKey) {
      expandedCategory.value = null;
      _resetPendingState();
    } else {
      expandedCategory.value = categoryKey;
      _resetPendingState();
    }
  }

  void _resetPendingState() {
    pendingProblems.clear();
    pendingActions.clear();
    notesController.clear();
    obsImagePath.value = null;
    shouldScheduleTask.value = false;
    scheduleTaskTitle.value = null;
    scheduleTaskDueDate.value = null;
    scheduleTaskPriority.value = TaskPriority.medium;
  }

  /// Toggle a problem selection for the current pending observation.
  void togglePendingProblem(String problem) {
    if (pendingProblems.contains(problem)) {
      pendingProblems.remove(problem);
    } else {
      pendingProblems.add(problem);
    }
  }

  /// Toggle an action selection for the current pending observation.
  void togglePendingAction(String action) {
    if (pendingActions.contains(action)) {
      pendingActions.remove(action);
    } else {
      pendingActions.add(action);
    }
  }

  /// Save the current pending selection as a new observation entry.
  Future<void> saveObservation() async {
    final categoryKey = expandedCategory.value;
    if (categoryKey == null) return;
    if (pendingProblems.isEmpty && pendingActions.isEmpty) {
      Get.snackbar(
        'No selection',
        'Please select at least one problem or action.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
      );
      return;
    }

    isSavingObs.value = true;
    try {
      // 1. Save the observation
      final obs = TreeObservationEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        treeId: tree.id,
        category: categoryKey,
        selectedProblems: List.from(pendingProblems),
        selectedActions: List.from(pendingActions),
        notes: notesController.text.trim(),
        imagePath: obsImagePath.value,
        createdAt: DateTime.now(),
      );
      await _obsRepo.insert(obs);

      // 2. Schedule a task if requested
      if (shouldScheduleTask.value) {
        final taskTitle = scheduleTaskTitle.value?.trim().isNotEmpty == true
            ? scheduleTaskTitle.value!
            : '${_categoryLabel(categoryKey)} - ${tree.id}';

        final tasksController = Get.find<TasksController>();
        tasksController.addTask(
          title: taskTitle,
          description: '${_categoryLabel(categoryKey)}: ${pendingProblems.join(', ')}',
          zone: zoneName,
          priority: scheduleTaskPriority.value,
          dueDate: scheduleTaskDueDate.value,
        );
      }

      final taskWasScheduled = shouldScheduleTask.value;

      // Reset pending state
      _resetPendingState();
      expandedCategory.value = null;

      _loadObservations();

      Get.snackbar(
        'Observation Saved',
        'The observation has been recorded successfully.'
            '${taskWasScheduled ? ' A task was created.' : ''}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Save Failed',
        'Could not save the observation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
    } finally {
      isSavingObs.value = false;
    }
  }

  /// Get Arabic label for a category key.
  String _categoryLabel(String key) {
    final data = TreeObservationData.byKey(key);
    return data?.labelAr ?? key;
  }

  /// Pick an image from the camera or gallery for this observation.
  Future<void> pickObservationImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        obsImagePath.value = photo.path;
      }
    } catch (e) {
      debugPrint('[TreeDetailsController] Image pick failed: $e');
    }
  }

  /// Clear the selected observation image.
  void clearObsImage() {
    obsImagePath.value = null;
  }

  /// Set the schedule task toggle and auto-generate a title.
  void toggleScheduleTask() {
    shouldScheduleTask.value = !shouldScheduleTask.value;
    if (shouldScheduleTask.value && scheduleTaskTitle.value == null) {
      scheduleTaskTitle.value = '';
    }
  }

  /// View an observation image in full screen.
  void viewObsImage(String imagePath) {
    if (imagePath.isEmpty) return;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  /// Delete a single observation.
  Future<void> deleteObservation(TreeObservationEntity obs) async {
    await _obsRepo.delete(tree.id, obs.id);
    _loadObservations();
  }

  /// Get the count of observations for a specific category.
  int observationCountForCategory(String categoryKey) {
    return observations.where((o) => o.category == categoryKey).length;
  }

  /// Get the most recent observation for a category, if any.
  TreeObservationEntity? latestObservationForCategory(String categoryKey) {
    final filtered =
        observations.where((o) => o.category == categoryKey).toList();
    if (filtered.isEmpty) return null;
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.first;
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
