import '../../domain/entities/counter_entity.dart';
import '../../domain/repositories/i_counter_repository.dart';
import '../models/counter_model.dart';
import '../sources/local/counter_local_source.dart';

/// Implementation of [ICounterRepository].
/// Maps between domain entities and data-layer models.
class CounterRepositoryImpl implements ICounterRepository {
  final CounterLocalSource _localSource;

  CounterRepositoryImpl(this._localSource);

  @override
  Future<CounterEntity> getCounter() async {
    final model = await _localSource.fetchCounter();
    return model;
  }

  @override
  Future<void> saveCounter(CounterEntity counter) async {
    final model = CounterModel.fromEntity(counter);
    await _localSource.persistCounter(model);
  }
}
