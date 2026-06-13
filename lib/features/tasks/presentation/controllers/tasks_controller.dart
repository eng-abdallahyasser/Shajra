import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../domain/entities/task_entity.dart';

/// Filter options for the task list.
enum TaskFilter { all, pending, completed }

/// Controller managing the tasks feature with GetStorage persistence.
class TasksController extends GetxController {
  final _storage = GetStorage();
  static const String _storageKey = 'saved_tasks';

  /// Observable list of all tasks.
  final tasks = <TaskEntity>[].obs;

  /// Current active filter.
  final activeFilter = TaskFilter.all.obs;

  /// Whether data has been loaded from storage.
  final isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTasks();
    if (tasks.isEmpty) {
      loadSampleTasks();
    }
  }

  // ── Persistence ──

  void _loadTasks() {
    final raw = _storage.read<List>(_storageKey) ?? [];
    tasks.value = raw
        .map((e) => TaskEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    isLoaded.value = true;
  }

  void _saveTasks() {
    _storage.write(
      _storageKey,
      tasks.map((t) => t.toJson()).toList(),
    );
  }

  // ── Filtering ──

  void setFilter(TaskFilter filter) {
    activeFilter.value = filter;
  }

  /// Returns tasks filtered by the current filter.
  List<TaskEntity> get filteredTasks {
    switch (activeFilter.value) {
      case TaskFilter.pending:
        return tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return tasks.where((t) => t.isCompleted).toList();
      case TaskFilter.all:
        return tasks.toList();
    }
  }

  // ── Computed stats ──

  int get totalCount => tasks.length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;
  int get completedCount => tasks.where((t) => t.isCompleted).length;

  // ── CRUD operations ──

  /// Add a new task with the given details.
  void addTask({
    required String title,
    String description = '',
    String zone = 'All',
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) {
    final task = TaskEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      zone: zone,
      priority: priority,
      dueDate: dueDate,
    );
    tasks.insert(0, task);
    _saveTasks();
  }

  /// Toggle the completed status of a task.
  void toggleTask(String id) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      tasks[index] = tasks[index].copyWith(
        isCompleted: !tasks[index].isCompleted,
      );
      _saveTasks();
    }
  }

  /// Update an existing task's fields.
  void updateTask({
    required String id,
    String? title,
    String? description,
    String? zone,
    TaskPriority? priority,
    DateTime? dueDate,
  }) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final existing = tasks[index];
      tasks[index] = existing.copyWith(
        title: title,
        description: description,
        zone: zone,
        priority: priority,
        dueDate: dueDate,
      );
      _saveTasks();
    }
  }

  /// Delete a task by ID.
  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    _saveTasks();
  }

  /// Clear all completed tasks.
  void clearCompleted() {
    tasks.removeWhere((t) => t.isCompleted);
    _saveTasks();
  }

  /// Pre-populate the task list with sample tasks for the greenhouse app.
  void loadSampleTasks() {
    if (tasks.isNotEmpty) return;
    final samples = [
      TaskEntity(
        id: 'sample_1',
        title: 'Check irrigation lines in Zone A',
        description: 'Inspect drip emitters and valves for clogs',
        zone: 'Zone A',
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(hours: 4)),
      ),
      TaskEntity(
        id: 'sample_2',
        title: 'Prepare nutrient solution',
        description: 'Mix NPK 20-20-20 for morning feeding cycle',
        zone: 'All',
        priority: TaskPriority.medium,
        dueDate: DateTime.now().add(const Duration(hours: 2)),
      ),
      TaskEntity(
        id: 'sample_3',
        title: 'Log temperature & humidity readings',
        description: 'Record sensor data from all zones',
        zone: 'All',
        priority: TaskPriority.medium,
      ),
      TaskEntity(
        id: 'sample_4',
        title: 'Prune tomato vines in Zone B',
        description: 'Remove suckers and old leaves',
        zone: 'Zone B',
        priority: TaskPriority.low,
        dueDate: DateTime.now().add(const Duration(days: 1)),
      ),
      TaskEntity(
        id: 'sample_5',
        title: 'Inspect CO2 sensor calibration',
        description: 'Check sensor accuracy and recalibrate if needed',
        zone: 'Zone C',
        priority: TaskPriority.critical,
        dueDate: DateTime.now().add(const Duration(hours: 1)),
      ),
    ];
    tasks.addAll(samples);
    _saveTasks();
  }
}
