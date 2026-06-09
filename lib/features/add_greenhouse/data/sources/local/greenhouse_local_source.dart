import '../../../domain/entities/greenhouse_entity.dart';

/// In-memory local data source for greenhouse records.
/// This can later be swapped for a persistent store (SQLite, Hive, etc.).
class GreenhouseLocalSource {
  final List<GreenhouseEntity> _greenhouses = [];

  Future<void> insert(GreenhouseEntity greenhouse) async {
    _greenhouses.add(greenhouse);
  }

  Future<List<GreenhouseEntity>> fetchAll() async {
    return List.unmodifiable(_greenhouses);
  }

  Future<void> remove(String name) async {
    _greenhouses.removeWhere((g) => g.name == name);
  }
}
