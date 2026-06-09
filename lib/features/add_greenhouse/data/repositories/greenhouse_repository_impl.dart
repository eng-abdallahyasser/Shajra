import '../../domain/entities/greenhouse_entity.dart';
import '../../domain/repositories/i_greenhouse_repository.dart';
import '../sources/local/greenhouse_local_source.dart';

class GreenhouseRepositoryImpl implements IGreenhouseRepository {
  final GreenhouseLocalSource _localSource;

  GreenhouseRepositoryImpl(this._localSource);

  @override
  Future<void> save(GreenhouseEntity greenhouse) {
    return _localSource.insert(greenhouse);
  }

  @override
  Future<List<GreenhouseEntity>> getAll() {
    return _localSource.fetchAll();
  }

  @override
  Future<void> delete(String name) {
    return _localSource.remove(name);
  }
}
