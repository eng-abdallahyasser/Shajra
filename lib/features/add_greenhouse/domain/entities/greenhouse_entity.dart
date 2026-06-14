import 'tree_data.dart';
import 'zone_data.dart';

/// Domain entity representing a greenhouse with its zone, tree, and sensor configuration.
class GreenhouseEntity {
  final String name;
  final String description;
  final String facilityType;
  final String solarOrientation;
  final double width;
  final double height;
  final String? sensorType;
  final int? sensorCount;
  final String? locationTag;
  final List<ZoneData> zonesData;
  final List<TreeData> treesData;

  const GreenhouseEntity({
    required this.name,
    required this.description,
    required this.facilityType,
    required this.solarOrientation,
    required this.width,
    required this.height,
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
    double? height,
    String? sensorType,
    int? sensorCount,
    String? locationTag,
    List<ZoneData>? zonesData,
    List<TreeData>? treesData,
  }) {
    return GreenhouseEntity(
      name: name ?? this.name,
      description: description ?? this.description,
      facilityType: facilityType ?? this.facilityType,
      solarOrientation: solarOrientation ?? this.solarOrientation,
      width: width ?? this.width,
      height: height ?? this.height,
      sensorType: sensorType ?? this.sensorType,
      sensorCount: sensorCount ?? this.sensorCount,
      locationTag: locationTag ?? this.locationTag,
      zonesData: zonesData ?? this.zonesData,
      treesData: treesData ?? this.treesData,
    );
  }
}
