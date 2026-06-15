/// Entity representing a single leaf scan / disease detection log entry.
class ScanLogEntity {
  /// Unique identifier (timestamp-based or UUID).
  final String id;

  /// Micro-Tagging ID of the tree that was scanned, e.g. "G001-ZoneA-01-T02".
  final String treeId;

  /// When the scan was performed.
  final DateTime scannedAt;

  /// Local file path to the captured leaf image.
  final String imagePath;

  /// Model confidence score (sigmoid output, 0.0 – 1.0).
  /// Values ≥ 0.5 indicate disease detected.
  final double confidence;

  /// Whether the model considers this leaf diseased.
  bool get isDiseased => confidence >= 0.5;

  /// Severity label based on confidence.
  String get severityLabel {
    if (confidence < 0.5) return 'Healthy';
    if (confidence < 0.7) return 'Mild';
    if (confidence < 0.9) return 'Moderate';
    return 'Severe';
  }

  /// Optional notes entered by the user after the scan.
  final String notes;

  const ScanLogEntity({
    required this.id,
    required this.treeId,
    required this.scannedAt,
    required this.imagePath,
    required this.confidence,
    this.notes = '',
  });

  /// Serialize to JSON for GetStorage persistence.
  Map<String, dynamic> toJson() => {
        'id': id,
        'treeId': treeId,
        'scannedAt': scannedAt.millisecondsSinceEpoch,
        'imagePath': imagePath,
        'confidence': confidence,
        'notes': notes,
      };

  /// Deserialize from JSON.
  factory ScanLogEntity.fromJson(Map<String, dynamic> json) => ScanLogEntity(
        id: json['id'] as String,
        treeId: json['treeId'] as String,
        scannedAt: DateTime.fromMillisecondsSinceEpoch(json['scannedAt'] as int),
        imagePath: json['imagePath'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] as String? ?? '',
      );

  @override
  String toString() => 'ScanLog($treeId, ${isDiseased ? "Diseased" : "Healthy"}, ${(confidence * 100).toStringAsFixed(1)}%)';
}
