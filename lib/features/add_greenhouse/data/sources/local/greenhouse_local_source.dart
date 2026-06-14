import 'package:get_storage/get_storage.dart';
import '../../../domain/entities/greenhouse_entity.dart';
import '../../../domain/entities/tree_data.dart';
import '../../../domain/entities/zone_data.dart';

/// Local data source using GetStorage for persistence.
class GreenhouseLocalSource {
  final _storage = GetStorage();
  static const String _key = 'saved_greenhouses';

  Future<void> insert(GreenhouseEntity greenhouse) async {
    final list = fetchAllRaw();
    list.add(_serialize(greenhouse));
    await _storage.write(_key, list);
  }

  Future<List<GreenhouseEntity>> fetchAll() async {
    final raw = fetchAllRaw();
    return raw.map((m) => _deserialize(m)).toList();
  }

  Future<void> remove(String name) async {
    final list = fetchAllRaw();
    list.removeWhere((m) => m['name'] == name);
    await _storage.write(_key, list);
  }

  // ---- Internal helpers ----

  List<Map<String, dynamic>> fetchAllRaw() {
    final raw = _storage.read<List<dynamic>>(_key);
    if (raw == null) return [];
    return raw.cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _serialize(GreenhouseEntity g) => {
        'name': g.name,
        'description': g.description,
        'facilityType': g.facilityType,
        'solarOrientation': g.solarOrientation,
        'width': g.width,
        'height': g.height,
        'sensorType': g.sensorType,
        'sensorCount': g.sensorCount,
        'locationTag': g.locationTag,
        'zonesData': g.zonesData.map((z) => z.toMap()).toList(),
        'treesData': g.treesData.map((t) => t.toMap()).toList(),
      };

  GreenhouseEntity _deserialize(Map<String, dynamic> m) => GreenhouseEntity(
        name: m['name'] as String? ?? '',
        description: m['description'] as String? ?? '',
        facilityType: m['facilityType'] as String? ?? '',
        solarOrientation: m['solarOrientation'] as String? ?? '',
        width: (m['width'] as num?)?.toDouble() ?? 0,
        height: (m['height'] as num?)?.toDouble() ?? 0,
        sensorType: m['sensorType'] as String?,
        sensorCount: m['sensorCount'] as int?,
        locationTag: m['locationTag'] as String?,
        zonesData: _safeZoneList(m['zonesData']),
        treesData: _safeTreeList(m['treesData']),
      );

  List<ZoneData> _safeZoneList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => ZoneData.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  List<TreeData> _safeTreeList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => TreeData.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
