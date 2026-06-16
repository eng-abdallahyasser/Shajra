import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/greenhouse_entity.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/tree_data.dart';
import '../../data/repositories/scan_log_repository.dart';
import '../../domain/entities/scan_log_entity.dart';
import '../services/mango_disease_service.dart';

class TreeDetailsController extends GetxController {
  final ScanLogRepository _logRepo = ScanLogRepository();
  final MangoDiseaseService _diseaseService = MangoDiseaseService.instance;
  final ImagePicker _picker = ImagePicker();

  // ── Passed arguments ──
  late final TreeData tree;
  late final GreenhouseEntity greenhouse;

  // ── Observable state ──
  final logs = <ScanLogEntity>[].obs;
  final isModelLoaded = false.obs;
  final isScanning = false.obs;
  final modelError = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    tree = args['tree'] as TreeData;
    greenhouse = args['greenhouse'] as GreenhouseEntity;
    _initModel();
    _loadLogs();
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
}
