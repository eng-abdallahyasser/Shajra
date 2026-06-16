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

  /// Model confidence score (max probability across all classes, 0.0–1.0).
  final double confidence;

  /// Index of the predicted class (0=Anthracnose, 1=Bacterial Canker,
  /// 2=Cutting Weevil, 3=Die Back, 4=Gall Midge, 5=Healthy,
  /// 6=Powdery Mildew, 7=Sooty Mould).
  /// Null for logs migrated from the old binary model format.
  final int? predictedClass;

  /// Whether the model considers this leaf diseased (class != 5, i.e. not Healthy).
  /// Falls back to the confidence threshold for legacy logs (pre-multi-class model).
  bool get isDiseased => predictedClass != null ? predictedClass! != 5 : confidence >= 0.5;

  /// Human-readable class label.
  String get className {
    switch (predictedClass) {
      case 0:
        return 'Anthracnose';
      case 1:
        return 'Bacterial Canker';
      case 2:
        return 'Cutting Weevil';
      case 3:
        return 'Die Back';
      case 4:
        return 'Gall Midge';
      case 5:
        return 'Healthy';
      case 6:
        return 'Powdery Mildew';
      case 7:
        return 'Sooty Mould';
      default:
        // Fallback for legacy logs (old binary model) — use confidence threshold
        return confidence >= 0.5 ? 'Diseased' : 'Healthy';
    }
  }

  /// Severity label based on predicted class.
  String get severityLabel {
    switch (predictedClass) {
      case 0:
        return 'Anthracnose';
      case 1:
        return 'Bacterial Canker';
      case 2:
        return 'Cutting Weevil';
      case 3:
        return 'Die Back';
      case 4:
        return 'Gall Midge';
      case 5:
        return 'Healthy';
      case 6:
        return 'Powdery Mildew';
      case 7:
        return 'Sooty Mould';
      default:
        // Fallback for legacy logs
        if (confidence < 0.5) return 'Healthy';
        if (confidence < 0.7) return 'Mild';
        if (confidence < 0.9) return 'Moderate';
        return 'Severe';
    }
  }

  /// Optional notes entered by the user after the scan.
  final String notes;

  const ScanLogEntity({
    required this.id,
    required this.treeId,
    required this.scannedAt,
    required this.imagePath,
    required this.confidence,
    this.predictedClass,
    this.notes = '',
  });

  /// Serialize to JSON for GetStorage persistence.
  Map<String, dynamic> toJson() => {
        'id': id,
        'treeId': treeId,
        'scannedAt': scannedAt.millisecondsSinceEpoch,
        'imagePath': imagePath,
        'confidence': confidence,
        'predictedClass': predictedClass,
        'notes': notes,
      };

  /// Deserialize from JSON.
  factory ScanLogEntity.fromJson(Map<String, dynamic> json) => ScanLogEntity(
        id: json['id'] as String,
        treeId: json['treeId'] as String,
        scannedAt: DateTime.fromMillisecondsSinceEpoch(json['scannedAt'] as int),
        imagePath: json['imagePath'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        predictedClass: json['predictedClass'] as int?,
        notes: json['notes'] as String? ?? '',
      );

  @override
  String toString() =>
      'ScanLog($treeId, $className, ${(confidence * 100).toStringAsFixed(1)}%)';
}
