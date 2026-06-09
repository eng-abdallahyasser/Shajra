import '../entities/greenhouse_entity.dart';

/// Repository interface for greenhouse persistence.
abstract class IGreenhouseRepository {
  /// Persists a new greenhouse.
  Future<void> save(GreenhouseEntity greenhouse);

  /// Retrieves all saved greenhouses.
  Future<List<GreenhouseEntity>> getAll();

  /// Deletes a greenhouse by name.
  Future<void> delete(String name);
}
