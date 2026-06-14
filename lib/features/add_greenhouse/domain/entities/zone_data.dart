/// Data class representing a zone within a greenhouse.
///
/// Uses Micro-Tagging format for [id]: G{GH:03d}-{ZoneName}
class ZoneData {
  /// Micro-Tagging ID, e.g. "G001-ZoneA"
  final String id;

  /// Human-readable zone name, e.g. "ZoneA"
  final String name;

  /// Width in meters.
  final double width;

  /// Height in meters.
  final double height;

  /// X offset (left) in meters within the greenhouse floor.
  final double left;

  /// Y offset (top) in meters within the greenhouse floor.
  final double top;

  const ZoneData({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.left,
    required this.top,
  });

  /// Deserialize from the storage map format.
  factory ZoneData.fromMap(Map<String, dynamic> map) => ZoneData(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        width: (map['width'] as num?)?.toDouble() ?? 0,
        height: (map['height'] as num?)?.toDouble() ?? 0,
        left: (map['left'] as num?)?.toDouble() ?? 0,
        top: (map['top'] as num?)?.toDouble() ?? 0,
      );

  /// Serialize to the storage map format.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'width': width,
        'height': height,
        'left': left,
        'top': top,
      };

  @override
  String toString() => 'ZoneData($id / $name)';
}
