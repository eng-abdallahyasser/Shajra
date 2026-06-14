import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../add_greenhouse/data/sources/local/greenhouse_local_source.dart';
import '../../../add_greenhouse/domain/entities/greenhouse_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';

/// Time period filter for reports.
enum ReportPeriod { week, month, quarter }

/// A summary snapshot for a single greenhouse.
class GreenhouseReport {
  final String name;
  final String facilityType;
  final double area;
  final int zoneCount;
  final int treeCount;
  final double avgTemperature;
  final double avgHumidity;
  final int taskCount;
  final int completedTaskCount;

  const GreenhouseReport({
    required this.name,
    required this.facilityType,
    required this.area,
    required this.zoneCount,
    required this.treeCount,
    required this.avgTemperature,
    required this.avgHumidity,
    required this.taskCount,
    required this.completedTaskCount,
  });

  double get completionRate =>
      taskCount > 0 ? completedTaskCount / taskCount : 0;
}

/// Aggregated report data for the entire farm.
class FarmReport {
  final int totalGreenhouses;
  final int totalZones;
  final int totalTrees;
  final double totalArea;
  final int totalTasks;
  final int completedTasks;
  final List<GreenhouseReport> greenhouseReports;

  const FarmReport({
    required this.totalGreenhouses,
    required this.totalZones,
    required this.totalTrees,
    required this.totalArea,
    required this.totalTasks,
    required this.completedTasks,
    required this.greenhouseReports,
  });

  int get pendingTasks => totalTasks - completedTasks;
  double get completionRate => totalTasks > 0 ? completedTasks / totalTasks : 0;
}

/// Controller for the reports feature.
class ReportsController extends GetxController {
  final _greenhouseSource = GreenhouseLocalSource();
  final _storage = GetStorage();
  static const String _tasksKey = 'saved_tasks';

  final reportPeriod = ReportPeriod.month.obs;
  final farmReport = Rx<FarmReport?>(null);
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  void setPeriod(ReportPeriod period) {
    reportPeriod.value = period;
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    try {
      final greenhouses = await _greenhouseSource.fetchAll();
      final tasks = _loadTasks();

      final greenhouseReports = greenhouses.map((g) {
        final ghTasks = tasks.where((t) =>
            t.zone == 'All' ||
            g.zonesData.any((z) => z.name == t.zone));
        return GreenhouseReport(
          name: g.name.isNotEmpty ? g.name : 'Unnamed',
          facilityType: g.facilityType.isNotEmpty ? g.facilityType : '—',
          area: g.width * g.height,
          zoneCount: g.zonesData.length,
          treeCount: g.treesData.length,
          avgTemperature: _simulateTemperature(g),
          avgHumidity: _simulateHumidity(g),
          taskCount: ghTasks.length,
          completedTaskCount: ghTasks.where((t) => t.isCompleted).length,
        );
      }).toList();

      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t.isCompleted).length;

      farmReport.value = FarmReport(
        totalGreenhouses: greenhouses.length,
        totalZones: greenhouses.fold(0, (s, g) => s + g.zonesData.length),
        totalTrees: greenhouses.fold(0, (s, g) => s + g.treesData.length),
        totalArea: greenhouses.fold(0.0, (s, g) => s + g.width * g.height),
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        greenhouseReports: greenhouseReports,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Simulate a temperature reading based on greenhouse characteristics.
  double _simulateTemperature(GreenhouseEntity g) {
    // Base temp varies by facility type
    final base = switch (g.facilityType) {
      'Glasshouse' => 26.0,
      'Polytunnel' => 28.0,
      'Vertical Farm' => 24.0,
      'Growth Chamber' => 23.0,
      _ => 26.0,
    };
    // Add small variance based on zones count
    final variance = (g.zonesData.length * 0.5).clamp(0, 3);
    return base + variance;
  }

  /// Simulate a humidity reading based on greenhouse characteristics.
  double _simulateHumidity(GreenhouseEntity g) {
    final base = switch (g.facilityType) {
      'Glasshouse' => 65.0,
      'Polytunnel' => 72.0,
      'Vertical Farm' => 68.0,
      'Growth Chamber' => 60.0,
      _ => 65.0,
    };
    final variance = (g.zonesData.length * 2.0).clamp(0, 10);
    return (base + variance).clamp(0, 100);
  }

  List<TaskEntity> _loadTasks() {
    final raw = _storage.read<List>(_tasksKey) ?? [];
    final allTasks = raw
        .map((e) => TaskEntity.fromJson(e as Map<String, dynamic>))
        .toList();

    // Filter by the selected period using createdAt
    final cutoff = _periodCutoff();
    if (cutoff == null) return allTasks;
    return allTasks.where((t) => t.createdAt.isAfter(cutoff)).toList();
  }

  /// Returns the cutoff DateTime for the selected report period.
  /// Returns null for 'all time' (not currently used but available).
  DateTime? _periodCutoff() {
    final now = DateTime.now();
    return switch (reportPeriod.value) {
      ReportPeriod.week => now.subtract(const Duration(days: 7)),
      ReportPeriod.month => now.subtract(const Duration(days: 30)),
      ReportPeriod.quarter => now.subtract(const Duration(days: 90)),
    };
  }
}
