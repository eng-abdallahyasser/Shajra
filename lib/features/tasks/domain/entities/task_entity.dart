/// Priority levels for tasks in the greenhouse management system.
enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;
  const TaskPriority(this.label);
}

/// Domain entity representing a task.
class TaskEntity {
  final String id;
  final String title;
  final String description;
  final String zone;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;

  TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.zone = 'All',
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? zone,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      zone: zone ?? this.zone,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Serialize to JSON for GetStorage persistence.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'zone': zone,
        'priority': priority.name,
        'isCompleted': isCompleted,
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  /// Deserialize from JSON.
  factory TaskEntity.fromJson(Map<String, dynamic> json) => TaskEntity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        zone: json['zone'] as String? ?? 'All',
        priority: TaskPriority.values.firstWhere(
          (p) => p.name == json['priority'],
          orElse: () => TaskPriority.medium,
        ),
        isCompleted: json['isCompleted'] as bool? ?? false,
        dueDate: json['dueDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'] as int)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
            : DateTime.now(),
      );
}
