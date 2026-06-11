/// Domain entity representing a greenhouse with its zone configuration
/// and sensor setup.
class GreenhouseEntity {
  final String name;
  final String description;
  final String facilityType;
  final String solarOrientation;
  final double width;
  final double length;
  final String? sensorType;
  final int? sensorCount;
  final String? locationTag;
  final List<Map<String, dynamic>> zonesData;
  final List<Map<String, dynamic>> treesData;

  const GreenhouseEntity({
    required this.name,
    required this.description,
    required this.facilityType,
    required this.solarOrientation,
    required this.width,
    required this.length,
    this.sensorType,
    this.sensorCount,
    this.locationTag,
    this.zonesData = const [],
    this.treesData = const [],
  });

  GreenhouseEntity copyWith({
    String? name,
    String? description,
    String? facilityType,
    String? solarOrientation,
    double? width,
    double? length,
    String? sensorType,
    int? sensorCount,
    String? locationTag,
    List<Map<String, dynamic>>? zonesData,
    List<Map<String, dynamic>>? treesData,
  }) {
    return GreenhouseEntity(
      name: name ?? this.name,
      description: description ?? this.description,
      facilityType: facilityType ?? this.facilityType,
      solarOrientation: solarOrientation ?? this.solarOrientation,
      width: width ?? this.width,
      length: length ?? this.length,
      sensorType: sensorType ?? this.sensorType,
      sensorCount: sensorCount ?? this.sensorCount,
      locationTag: locationTag ?? this.locationTag,
      zonesData: zonesData ?? this.zonesData,
      treesData: treesData ?? this.treesData,
    );
  }
}
