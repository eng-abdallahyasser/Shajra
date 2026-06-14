/// Data class representing a tree placed in a greenhouse.
///
/// Uses Micro-Tagging format for [id]: G{GH:03d}-{Zone}-{Row:02d}-T{Tree:02d}
class TreeData {
  /// Micro-Tagging ID, e.g. "G001-ZoneA-01-T02"
  final String id;

  /// The ID of the zone this tree belongs to, e.g. "G001-ZoneA"
  final String? zoneId;

  /// X position in meters within the greenhouse floor.
  final double x;

  /// Y position in meters within the greenhouse floor.
  final double y;

  const TreeData({
    required this.id,
    this.zoneId,
    required this.x,
    required this.y,
  });

  /// Deserialize from the storage map format.
  factory TreeData.fromMap(Map<String, dynamic> map) => TreeData(
        id: map['id'] as String? ?? '',
        zoneId: map['zoneId'] as String?,
        x: (map['x'] as num?)?.toDouble() ?? 0,
        y: (map['y'] as num?)?.toDouble() ?? 0,
      );

  /// Serialize to the storage map format.
  Map<String, dynamic> toMap() => {
        'id': id,
        'zoneId': zoneId,
        'x': x,
        'y': y,
      };

  @override
  String toString() => 'TreeData($id)';
}
