/// Entity representing a single tree inspection observation session.
///
/// Stores which problems were observed and which corrective actions were
/// taken across one of the 5 main categories (Irrigation, Insects,
/// Pruning, Nutrition, Fungal).
class TreeObservationEntity {
  /// Unique identifier (timestamp-based).
  final String id;

  /// Micro-Tagging ID of the tree, e.g. "G001-ZoneA-01-T02".
  final String treeId;

  /// Category key: 'irrigation', 'insects', 'pruning', 'nutrition', 'fungal'.
  final String category;

  /// List of selected problem descriptions (Arabic).
  final List<String> selectedProblems;

  /// List of selected corrective action descriptions (Arabic).
  final List<String> selectedActions;

  /// Optional user notes.
  final String notes;

  /// Local file path to a captured photo for this observation.
  final String? imagePath;

  /// When this observation was recorded.
  final DateTime createdAt;

  const TreeObservationEntity({
    required this.id,
    required this.treeId,
    required this.category,
    required this.selectedProblems,
    required this.selectedActions,
    this.notes = '',
    this.imagePath,
    required this.createdAt,
  });

  /// Serialize to JSON for GetStorage persistence.
  Map<String, dynamic> toJson() => {
        'id': id,
        'treeId': treeId,
        'category': category,
        'selectedProblems': selectedProblems,
        'selectedActions': selectedActions,
        'notes': notes,
        'imagePath': imagePath,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  /// Deserialize from JSON.
  factory TreeObservationEntity.fromJson(Map<String, dynamic> json) =>
      TreeObservationEntity(
        id: json['id'] as String,
        treeId: json['treeId'] as String,
        category: json['category'] as String,
        selectedProblems:
            (json['selectedProblems'] as List<dynamic>?)?.cast<String>() ?? [],
        selectedActions:
            (json['selectedActions'] as List<dynamic>?)?.cast<String>() ?? [],
        notes: json['notes'] as String? ?? '',
        imagePath: json['imagePath'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );

  @override
  String toString() =>
      'TreeObservation($treeId, $category, ${selectedProblems.length} problems)';
}
