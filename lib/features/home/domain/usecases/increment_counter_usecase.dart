import '../entities/counter_entity.dart';
import '../repositories/i_counter_repository.dart';

/// Business logic: increment the counter value.
/// Pure Dart — no Flutter or GetX imports.
class IncrementCounterUseCase {
  final ICounterRepository _repository;

  IncrementCounterUseCase(this._repository);

  Future<CounterEntity> call() async {
    final current = await _repository.getCounter();
    final updated = current.copyWith(value: current.value + 1);
    await _repository.saveCounter(updated);
    return updated;
  }
}
