import '../entities/counter_entity.dart';
import '../repositories/i_counter_repository.dart';

/// Business logic: retrieve the current counter value.
/// Pure Dart — no Flutter or GetX imports.
class GetCounterUseCase {
  final ICounterRepository _repository;

  GetCounterUseCase(this._repository);

  Future<CounterEntity> call() async {
    return _repository.getCounter();
  }
}
